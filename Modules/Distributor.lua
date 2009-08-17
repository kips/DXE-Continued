-- Credits to Bazaar (by Shadowed) for this idea

local addon = DXE
local L = addon.L

local Colors = addon.Media.Colors

local ipairs, pairs = ipairs, pairs
local remove,wipe = table.remove,table.wipe
local match,len,format,split,find = string.match,string.len,string.format,string.split,string.find

local db,pfl

----------------------------------
-- CONSTANTS
----------------------------------
-- IMPORTANT: Change if previous encounters are incompatible with Invoker
local VERSION = 4

local FIRST_MULTIPART, NEXT_MULTIPART, LAST_MULTIPART = "\001", "\002", "\003"
local MAIN_PREFIX = "DXE_Dist"..VERSION
local TRANSFER_PREFIX = "DXE_DistT"..VERSION
local UL_SUFFIX = "UL"
local DL_SUFFIX = "DL"
local DR_PTN = TRANSFER_PREFIX.."_([%w'%- ]+)" -- DownloadReceived
local CMA_PTN = TRANSFER_PREFIX.."_([%w'%- ]+)(.*)" -- CHAT_MSG_ADDON
local UL_TIMEOUT = 5
local DL_TIMEOUT = 8

----------------------------------
-- INITIALIZATION
----------------------------------

local module = addon:NewModule("Distributor","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
addon.Distributor = module
local StackAnchor

function module:RefreshProfile()
	pfl = self.db.profile
end

function module:InitializeOptions(area)
	local list,names = {},{}
	local ListSelect,PlayerSelect
	area.dist_group = {
		type = "group",
		name = L["Distributor"],
		order = 300,
		get = function(info) return pfl[info[#info]] end,
		set = function(info,v) pfl[info[#info]] = v end,
		args = {
			AutoAccept = {
				type = "toggle",
				name = L["Auto accept"],
				desc = L["Automatically accepts encounters sent by players"],
				order = 50,
			},
			first_desc = {
				type = "description",
				order = 75,
				name = L["You can send encounters to the entire raid or to a player. You can check versions by typing |cffffd200/dxe vc|r or by opening the version checker from the pane"],
			},
			raid_desc = {
				type = "description",
				order = 90,
				name = "\n"..L["If you want to send an encounter to the raid, select an encounter, and then press '|cffffd200Send to raid|r'"],
			},
			ListSelect = {
				type = "select",
				order = 100,
				name = L["Select an encounter"],
				get = function() return ListSelect end,
				set = function(info,value) ListSelect = value end,
				values = function()
					wipe(list)
					for k in addon:IterateEDB() do
						list[k] = addon.EDB[k].name
					end
					return list
				end,
			},
			DistributeToRaid = {
				type = "execute",
				name = L["Send to raid"],
				order = 200,
				func = function() module:Distribute(ListSelect) end,
				disabled = function() return GetNumRaidMembers() == 0 or not ListSelect  end,
			},
			player_desc = {
				type = "description",
				order = 250,
				name = "\n\n"..L["If you want to send an encounter to a player, select an encounter, select a player, and then press '|cffffd200Send to player|r'"],
			},
			PlayerSelect = {
				type = "select",
				order = 300,
				name = L["Select a player"],
				get = function() return PlayerSelect end,
				set = function(info,value) PlayerSelect = value end,
				values = function()
					wipe(names)
					for name in pairs(addon.Roster.name_to_unit) do
						if name ~= addon.PNAME then
							 names[name] = name
						end
					end
					return names
				end,
				disabled = function() return GetNumRaidMembers() == 0 or not ListSelect end,
			},
			DistributeToPlayer = {
				type = "execute",
				order = 400,
				name = L["Send to player"],
				func = function() module:Distribute(ListSelect, "WHISPER", PlayerSelect) end,
				disabled = function() return not PlayerSelect end,
			},
		},
	}
end

function module:OnInitialize()
	StackAnchor = addon:CreateLockableFrame("DistributorStackAnchor",200,10,L["Download/Upload Anchor"])
	addon:RegisterMoveSaving(StackAnchor,"CENTER","UIParent","CENTER",0,300)
	addon:LoadPosition("DXEDistributorStackAnchor")

	self.db = addon.db:RegisterNamespace("Distributor", {
		profile = {
			AutoAccept = true,
		},
	})
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

	addon:AddModuleOptionInitializer(module,"InitializeOptions")
end

function module:OnEnable()
	self:RegisterComm(MAIN_PREFIX)
end

----------------------------------
-- MAIN
----------------------------------
-- The active downloads
local Downloads = {}

-- The active uploads
local Uploads = {}
-- The queued uploads
local UploadQueue = {}

function module:DispatchDistribute(info)
	local success,key,dist,target = self:Deserialize(info)
	if success then self:Distribute(key,dist,target) end
end

-- Used to start uploads
function module:Distribute(key, dist, target)
	dist = dist or "RAID"
	local data = addon:GetEncounterData(key)
	if not data or Uploads[key] or key == "default" or GetNumRaidMembers() == 0 then return end
	if addon.util.tablesize(Uploads) == 4 then UploadQueue[key] = self:Serialize(key,dist,target) return end
	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format("UPDATE:%s:%d:%d:%s:%s",key,data.version,length,data.name,GetLocale()) -- ex. UPDATE:sartharion:150:800:Sartharion:enUS

	-- Create upload bar
	local bar = self:GetProgressBar()
	bar:SetStatus(L["Waiting"])
	bar:SetText(data.name)
	bar:SetColor(Colors.GREY)
	local dest = (dist == "WHISPER") and 1 or -1

	Uploads[key] = {
		accepts = 0,
		declines = 0,
		sent = 0,
		length = length,
		name = data.name,
		bar = bar,
		dest = dest,
		serialData = serialData,
		timer = self:ScheduleTimer("StartUpload",UL_TIMEOUT,key),
		dist = dist,
		target = target,
	}

	bar.userdata.timeleft = UL_TIMEOUT
	bar.userdata.totaltime = UL_TIMEOUT
	self:StartUpdating(key..UL_SUFFIX,bar)
	
	self:SendCommMessage(MAIN_PREFIX, message, dist, target)
end

-- Used when uploading
function module:StartUpload(key)
	local ul = Uploads[key]
	if ul.started then return end
	if ul.accepts == 0 then self:ULTimeout(key) return end
	local message = ul.serialData
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:SendCommMessage(format("%s_%s",TRANSFER_PREFIX,key), message, ul.dist, ul.target)
	ul.bar:SetValue(0)
	ul.bar:SetStatus(L["Uploading"])
	ul.started = true
	self:RemoveFromUpdating(key..UL_SUFFIX)
end

-- Used when downloading
function module:StartReceiving(key,length,sender,dist,name)
	local prefix = format("%s_%s",TRANSFER_PREFIX,key)
	if Downloads[key] then self:RemoveDL(key) end
	self:RegisterEvent("CHAT_MSG_ADDON")

	-- Create download bar
	local bar = self:GetProgressBar()
	bar:SetStatus(L["Queued"])
	bar:SetText(name)
	bar:SetPerc(0)
	bar:SetColor(Colors.GREY)
	bar.userdata.timeleft = DL_TIMEOUT
	bar.userdata.totaltime = DL_TIMEOUT

	Downloads[key] = {
		key = key,
		name = name,
		sender = sender,
		received = 0,
		length = length,
		bar = bar,
		timer = self:ScheduleTimer("DLTimeout",DL_TIMEOUT,key),
		dist = dist,
	}
	
	self:StartUpdating(key..DL_SUFFIX,bar)
	self:RegisterComm(prefix, "DownloadReceived")
end

function module:Respond(msg,sender)
	self:SendCommMessage(MAIN_PREFIX, msg, "WHISPER",sender)
end

function module:OnCommReceived(prefix, msg, dist, sender)
	if sender == addon.PNAME then return end
	local type,args = match(msg,"(%w+):(.+)")
	-- Someone wants to send an encounter
	if type == "UPDATE" then
		local key,version,length,name,rlocale = split(":",args)
		length = tonumber(length)
		version = tonumber(version)

		local data = addon.EDB[key]
		-- Version and locale check
		if (data and data.version >= version) or rlocale ~= GetLocale() then
			self:Respond(format("RESPONSE:%s:%s",key,"NO"),sender)
			return
		end

		if pfl.AutoAccept then
			self:StartReceiving(key,length,sender,dist,name)
			self:Respond(format("RESPONSE:%s:%s",key,"YES"),sender)
			return
		end

		local popupkey = format("DXE_Confirm_%s",key)
		if not StaticPopupDialogs[popupkey] then
			local STATIC_CONFIRM = {
				text = format(L["%s is sharing an update for %s"],sender,name),
				OnAccept = function() self:StartReceiving(key,length,sender,dist,name)
											 self:Respond(format("RESPONSE:%s:%s",key,"YES"),sender)
							  end,
				OnCancel = function() self:Respond(format("RESPONSE:%s:%s",key,"NO"),sender) end,
				button1 = L["Accept"],
				button2 = L["Reject"],
				timeout = 25,
				whileDead = 1,
				hideOnEscape = 1,
			}

			StaticPopupDialogs[popupkey] = STATIC_CONFIRM
		end

		StaticPopup_Show(popupkey)
	-- Someone responded to your send
	elseif type == "RESPONSE" and dist == "WHISPER" then
		local key,answer = split(":",args)
		local ul = Uploads[key]
		if not ul then return end
		if answer == "YES" then
			ul.accepts = ul.accepts + 1
		elseif answer == "NO" then
			ul.declines = ul.declines + 1
		end

		ul.bar:SetPerc(format("%s: %d %s: %d",L["A"],ul.accepts,L["D"],ul.declines))

		if ul.dest == ul.accepts + ul.declines then
			self:CancelTimer(ul.timer,true)
			self:StartUpload(key)
		end
	end
end

function module:CHAT_MSG_ADDON(_,prefix, msg, dist, sender)
	if find(prefix,TRANSFER_PREFIX) and (dist == "RAID" or dist == "WHISPER") and (next(Downloads) or next(Uploads)) then
		local key, mark = match(prefix, CMA_PTN)
		if not key then return end
		-- For WHISPER distributions
		if msg == "COMPLETED" and Uploads[key] then
			self:ULCompleted(key)
			return
		end

		-- Make sure the mark exists
		if #mark == 0 then return end
		-- Track downloads
		local dl = Downloads[key]
		if dl and dl.sender == sender then
			self:RemoveFromUpdating(key..DL_SUFFIX)
			dl.received = dl.received + len(msg)
			if mark == FIRST_MULTIPART then
				dl.bar:SetStatus(L["Downloading"])
				dl.bar:SetPerc(format("%d%%",0))
				dl.bar:SetColor(Colors.ORANGE)
			elseif mark == NEXT_MULTIPART or mark == LAST_MULTIPART then
				local perc = dl.received/dl.length
				dl.bar:SetValue(perc)
				dl.bar:SetPerc(format("%d%%",perc*100))
			end	
		end

		-- Track uploads
		local ul = Uploads[key]
		if ul and sender == addon.PNAME then
			ul.sent = ul.sent + len(msg)
			if mark == FIRST_MULTIPART then
				ul.bar:SetPerc(0)
				ul.bar:SetColor(Colors.YELLOW)
			elseif mark == NEXT_MULTIPART or mark == LAST_MULTIPART then
				local perc = ul.sent/ul.length
				ul.bar:SetValue(perc)
				ul.bar:SetPerc(format("%d%%",perc*100))
				if mark == LAST_MULTIPART then
					self:ULCompleted(key)
				end
			end	
		end
	end
end

----------------------------------
-- COMPLETIONS
----------------------------------

function module:QueueNextUL()
	local qname,info = next(UploadQueue)
	if qname then
		UploadQueue[qname] = nil
		self:ScheduleTimer("DispatchDistribute",5,info)
	end
end

function module:DownloadReceived(prefix, msg, dist, sender)
	self:UnregisterComm(prefix)
	local key = match(prefix, DR_PTN)

	local dl = Downloads[key]
	if not dl then return end

	-- For WHISPER distributions
	if dl.dist == "WHISPER" then
		self:SendCommMessage(prefix,"COMPLETED","WHISPER",sender)
	end

	local success, data = self:Deserialize(msg)
	-- Failed to deserialize
	if not success then addon:Print(format(L["Failed to load %s after downloading! Request another distribute from %s"],dl.name,dl.sender)) return end

	addon:UnregisterEncounter(key)
	addon:RegisterEncounter(data)

	addon.RDB[key] = data

	addon:SendWhisperComm(dl.sender,"VersionBroadcast",key,data.version)

	self:DLCompleted(key,dl.sender,dl.name)
end

function module:DLCompleted(key,sender,name)
	addon:Print(format(L["%s successfully updated from %s"],name,sender))
	self:LoadCompleted(key,Downloads[key],L["Completed"],Colors.GREEN,"RemoveDL")
end

function module:DLTimeout(key)
	addon:Print(format(L["%s download updating timed out"],Downloads[key].name))
	self:LoadCompleted(key,Downloads[key],L["Timed Out"],Colors.Red,"RemoveDL")
end

function module:ULCompleted(key)
	addon:Print(format(L["%s successfully sent"],Uploads[key].name))
	self:LoadCompleted(key,Uploads[key],L["Completed"],Colors.GREEN,"RemoveUL")
	self:QueueNextUL()
end

function module:ULTimeout(key)
	addon:Print(format(L["%s upload timed out"],Uploads[key].name))
	self:LoadCompleted(key,Uploads[key],L["Timed Out"],Colors.RED,"RemoveUL")
	self:QueueNextUL()
end

function module:LoadCompleted(key,loadInfo,text,color,func) -- func = RemoveDL|RemoveUL
	local bar = loadInfo.bar
	bar:SetStatus(text)
	bar:SetColor(color)
	bar:SetValue(1)
	self:FadeBar(bar)
	self:ScheduleTimer(func,4,key)
end

function module:RemoveDL(key)
	self:RemoveLoad(Downloads,key)
end

function module:RemoveUL(key)
	self:RemoveLoad(Uploads,key)
end

function module:RemoveLoad(loadTable,key)
	self:RemoveFromUpdating(key..UL_SUFFIX)
	self:RemoveFromUpdating(key..DL_SUFFIX)
	local loadInfo = loadTable[key]
	self:CancelTimer(loadInfo.timer,true)
	self:RemoveProgressBar(loadInfo.bar)
	addon.AceGUI:Release(loadInfo.bar)
	loadTable[key] = nil
	if not next(Uploads) and not next(Downloads) then
		self:UnregisterEvent("CHAT_MSG_ADDON")
	end
end

function module:FadeBar(bar)
	UIFrameFadeOut(bar.frame,4,bar.frame:GetAlpha(),0)
end

----------------------------------
-- PROGRESS BARS
----------------------------------
local ProgressStack = {}

function module:GetProgressBar()
	local bar = addon.AceGUI:Create("DXE_ProgressBar")
	ProgressStack[#ProgressStack+1] = bar
	self:LayoutBarStack()
	return bar
end

function module:RemoveProgressBar(bar)
	for i,_alert in ipairs(ProgressStack) do
		if _alert == bar then
			remove(ProgressStack,i)
			break 
		end
	end
	self:LayoutBarStack()
end

function module:LayoutBarStack()
	local anchor = StackAnchor
	for i=1,#ProgressStack do
		local bar = ProgressStack[i]
		bar:Anchor("TOP",anchor,"BOTTOM")
		anchor = bar.frame
	end
end

----------------------------------
-- PROGRESS BAR
----------------------------------
-- The active progress bars
local UpdateStack = {}
-- Frame used for updating
local frame = CreateFrame("Frame",nil,UIParent)

local function OnUpdate(self,elapsed)
	for name,bar in pairs(UpdateStack) do
		local timeleft,totaltime = bar.userdata.timeleft - elapsed,bar.userdata.totaltime
		bar.userdata.timeleft = timeleft
		local perc = 1-(timeleft/totaltime)
		if perc >= 0 then
			bar:SetValue(perc)
		end
	end
	if not next(UpdateStack) then self:SetScript("OnUpdate",nil) end
end

function module:StartUpdating(key,bar)
	UpdateStack[key] = bar
	frame:SetScript("OnUpdate",OnUpdate)
end

function module:RemoveFromUpdating(key)
	if not UpdateStack[key] then return end
	UpdateStack[key] = nil
	if not next(UpdateStack) then frame:SetScript("OnUpdate",nil) end
end

do
	local WidgetType = "DXE_ProgressBar"
	local WidgetVersion = 1

	local WHITE = {r=1,g=1,b=1}
	local BLUE = {r=0,g=0,b=1} 
	
	local function OnAcquire(self)
		self.frame:Show()
		self.frame:SetParent(UIParent)
		self:SetColor(BLUE,WHITE)
	end

	local function OnRelease(self)
		self.frame:Hide()
		self.frame:ClearAllPoints()
		self.bar:SetValue(0)
		self:SetAlpha(1)
		self.perc:SetText("")
		UIFrameFadeRemoveFrame(self.frame)
	end

	local function SetText(self,text)
		self.text:SetText(text)
	end

	local function SetFormattedText(self,text,...)
		self.text:SetFormattedText(text,...)
	end

	local function SetPerc(self,perc)
		self.perc:SetText(perc)
	end

	local function SetStatus(self,status,r,g,b)
		self.status:SetFormattedText(L["STATUS"]..": |cffffffff%s|r",status)
	end

	local function SetColor(self,c1,c2)
		if c1 then
			self.userdata.c1 = c1
			self.bar:SetStatusBarColor(c1.r,c1.g,c1.b)
		end
		if c2 then self.userdata.c2 = c2 end
	end

	local function Anchor(self,relPoint,frame,relTo)
		self.userdata.animFunc = nil
		self.frame:ClearAllPoints()
		self.frame:SetPoint(relPoint,frame,relTo)
	end
	
	local function SetAlpha(self,alpha)
		self.frame:SetAlpha(alpha)
	end

	local function SetValue(self,value)
		self.bar:SetValue(value)
	end

	local backdrop = {
		bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
		tileSize=16,
		insets = {left = 2, right = 2, top = 1, bottom = 2}
	}

	local backdropborder = {
		edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
		edgeSize = 9,             
		insets = {left = 2, right = 2, top = 3, bottom = 2}
	}

	local function Constructor()
		local self = {}
		self.type = WidgetType
		local frame = CreateFrame("Frame",nil,UIParent)

		frame:SetWidth(222) 
		frame:SetHeight(27)
		frame:SetBackdrop(backdrop)
		
		local bar = CreateFrame("StatusBar",nil,frame)
		bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		bar:SetPoint("TOPLEFT",2,-2)
		bar:SetPoint("BOTTOMRIGHT",-2,2)
		bar:SetMinMaxValues(0,1) 
		bar:SetValue(0)
		self.bar = bar

		local border = CreateFrame("Frame",nil,frame)
		border:SetAllPoints(true)
		border:SetBackdrop(backdropborder)
		border:SetBackdropBorderColor(0.33,0.33,0.33)
		border:SetFrameLevel(bar:GetFrameLevel()+1)
		
		local text = bar:CreateFontString(nil,"ARTWORK")
		text:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",9)
		text:SetPoint("CENTER",frame,"CENTER",0,-4)
		text:SetTextColor(0.6,1,0.2)
		text:SetShadowOffset(1,-1)
		self.text = text

		local perc = bar:CreateFontString(nil,"ARTWORK")
		perc:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",8)
		perc:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-5,-3)
		perc:SetShadowOffset(1,-1)
		self.perc = perc

		local status = bar:CreateFontString(nil,"ARTWORK")
		status:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",8)
		status:SetPoint("TOPLEFT",frame,"TOPLEFT",5,-3)
		status:SetTextColor(1,0.82,0)
		status:SetShadowOffset(1,-1)
		self.status = status
		
		self.OnAcquire = OnAcquire
		self.OnRelease = OnRelease
		self.SetText = SetText
		self.SetColor = SetColor
		self.Anchor = Anchor
		self.SetAlpha = SetAlpha
		self.SetValue = SetValue
		self.SetPerc = SetPerc
		self.SetStatus = SetStatus
		self.SetFormattedText = SetFormattedText
		
		self.frame = frame
		frame.obj = self

		addon.AceGUI:RegisterAsWidget(self)
		return self
	end

	addon.AceGUI:RegisterWidgetType(WidgetType,Constructor,WidgetVersion)
end
