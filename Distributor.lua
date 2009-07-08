local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version
local L = DXE.L

local util = DXE.util
local Roster = DXE.Roster

local AceGUI = DXE.AceGUI
local Colors = DXE.Constants.Colors

local ipairs, pairs = ipairs, pairs
local remove,wipe = table.remove,table.wipe
local match,len,format,split,find = string.match,string.len,string.format,string.split,string.find

local locale = GetLocale()

-- Credits to Bazaar for this implementation

----------------------------------
-- CONSTANTS
----------------------------------

local FIRST_MULTIPART, NEXT_MULTIPART, LAST_MULTIPART = "\001", "\002", "\003"
local MAIN_PREFIX = "DXE_Distro"
local TRANSFER_PREFIX = "DXE_DistroT"
local UL_SUFFIX = "UL"
local DL_SUFFIX = "DL"

----------------------------------
-- INITIALIZATION
----------------------------------

local Distributor = DXE:NewModule("Distributor","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
DXE.Distributor = Distributor
local StackAnchor

function Distributor:OnInitialize()
	DXE:AddPluginOptions("distributor",self:GetOptions())

	StackAnchor = DXE:CreateLockableFrame("DistributorStackAnchor",200,10,L["Download/Upload Anchor"])
	DXE:RegisterMoveSaving(StackAnchor,"CENTER","UIParent","CENTER",0,300)
	DXE:LoadPosition("DXEDistributorStackAnchor")
end

function Distributor:OnEnable()
	self:RegisterComm(MAIN_PREFIX)
	self:RegisterEvent("CHAT_MSG_ADDON")
end

----------------------------------
-- OPTIONS
----------------------------------


local EncKeys,RaidNames = {},{}
local ListSelect,PlayerSelect
function Distributor:GetOptions()
	return {
		dist_group = {
			type = "group",
			name = L["Distributor"],
			order = 300,
			get = function(info) return DXE.db.global.Distributor[info[#info]] end,
			set = function(info,value) DXE.db.global.Distributor[info[#info]] = value end,
			args = {
				AutoAccept = {
					type = "toggle",
					name = L["Auto accept"],
					order = 50,
				},
				blank = DXE.genblank(75),
				ListSelect = {
					type = "select",
					order = 100,
					name = L["Select an encounter"],
					get = function() return ListSelect end,
					set = function(info,value) ListSelect = value end,
					values = function()
						wipe(EncKeys)
						for k in DXE:IterateEDB() do
							EncKeys[k] = DXE.EDB[k].name
						end
						return EncKeys
					end,
				},
				send_raid_group = {
					type = "group",
					name = L["Raid Distributing"],
					order = 120,
					inline = true,
					args = {
						DistributeToRaid = {
							type = "execute",
							name = L["Send to raid"],
							order = 100,
							func = function() Distributor:Distribute(ListSelect) end,
							disabled = function() return not ListSelect end,
						},
						--[[
						DistributeAllToRaid = {
							type = "execute",
							name = "Send all to raid",
							order = 200,
							func = function() 
										for key in pairs(DXE.EDB) do
											if key ~= "default" then
												Distributor:Distribute(name)
											end
										end
									 end,
							confirm = true,
							confirmText = "Are you sure you want to do this?",
						},
						]]
					},
				},
				send_player_group = {
					type = "group",
					name = L["Player Distributing"],
					order = 200,
					inline = true,
					disabled = function() return not ListSelect end,
					args = {
						PlayerSelect = {
							type = "select",
							order = 100,
							name = L["Select a player"],
							get = function() return PlayerSelect end,
							set = function(info,value) PlayerSelect = value end,
							values = function()
								wipe(RaidNames)
								for _,unit in pairs(Roster.index_to_unit) do
									local name = UnitName(unit)
									if name ~= DXE.PNAME then
										 RaidNames[name] = name
									end
								end
								return RaidNames
							end,
							disabled = function() return GetNumRaidMembers() == 0 or not ListSelect end,
						},
						blank = DXE.genblank(200),
						DistributeToPlayer = {
							type = "execute",
							order = 300,
							name = L["Send to player"],
							func = function() Distributor:Distribute(ListSelect, "WHISPER", PlayerSelect) end,
							disabled = function() return not PlayerSelect end,
						},
						--[[
						DistributeAllToPlayer = {
							type = "execute",
							order = 400,
							name = "Send all to player",
							func = function()
										for key in pairs(DXE.EDB) do
											if key ~= "default" then
												Distributor:Distribute(name, "WHISPER", PlayerSelect)
											end
										end
									 end,
							disabled = function() return not PlayerSelect end,
							confirm = true,
							confirmText = "Are you sure you want to do this?",
						},
						]]
					},
				},
			},
		}
	}
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

function Distributor:DispatchDistribute(info)
	local success,key,dist,target = self:Deserialize(info)
	if success then self:Distribute(key,dist,target) end
end

-- Used to start uploads
function Distributor:Distribute(key, dist, target)
	dist = dist or "RAID"
	local data = DXE:GetEncounterData(key)
	if not data or Uploads[key] or key == "default" or GetNumRaidMembers() == 0 then return end
	if util.tablesize(Uploads) == 4 then UploadQueue[key] = self:Serialize(key,dist,target) return end
	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format("UPDATE:%s:%d:%d:%s:%s",key,data.version,length,data.name,locale) -- ex. UPDATE:sartharion:150:800:Sartharion:enUS

	-- Create upload bar
	local bar = self:GetProgressBar()
	bar:SetStatus(L["Waiting"])
	bar:SetText(data.name)
	bar:SetColor(Colors.GREY)
	local dest = (dist == "WHISPER") and 1 or DXE:GetNumWithAddOn()

	Uploads[key] = {
		accepts = 0,
		declines = 0,
		sent = 0,
		length = length,
		name = data.name,
		bar = bar,
		dest = dest,
		serialData = serialData,
		timer = self:ScheduleTimer("StartUpload",30,key),
		dist = dist,
		target = target,
	}

	bar.userdata.timeleft = 30
	bar.userdata.totaltime = 30
	self:StartUpdating(key..UL_SUFFIX,bar)
	
	self:SendCommMessage(MAIN_PREFIX, message, dist, target)
end

-- Used when uploading
function Distributor:StartUpload(key)
	local ul = Uploads[key]
	if ul.started then return end
	if ul.accepts == 0 then self:ULTimeout(key) return end
	local message = ul.serialData
	self:SendCommMessage(format("%s_%s",TRANSFER_PREFIX,key), message, ul.dist, ul.target)
	ul.bar:SetValue(0)
	ul.bar:SetStatus(L["Uploading"])
	ul.started = true
	self:RemoveFromUpdating(key..UL_SUFFIX)
end

-- Used when downloading
function Distributor:StartReceiving(key,length,sender,dist,name)
	local prefix = format("%s_%s",TRANSFER_PREFIX,key)
	if Downloads[key] then self:RemoveDL(key) end

	-- Create download bar
	local bar = self:GetProgressBar()
	bar:SetStatus(L["Queued"])
	bar:SetText(name)
	bar:SetPerc(0)
	bar:SetColor(Colors.GREY)
	bar.userdata.timeleft = 40
	bar.userdata.totaltime = 40

	Downloads[key] = {
		key = key,
		name = name,
		sender = sender,
		received = 0,
		length = length,
		bar = bar,
		timer = self:ScheduleTimer("DLTimeout",40,key),
		dist = dist,
	}
	
	self:StartUpdating(key..DL_SUFFIX,bar)
	self:RegisterComm(prefix, "DownloadReceived")
end

function Distributor:Respond(msg,sender)
	self:SendCommMessage(MAIN_PREFIX, msg, "WHISPER",sender)
end

function Distributor:OnCommReceived(prefix, msg, dist, sender)
	if sender == DXE.PNAME then return end
	local type,args = match(msg,"(%w+):(.+)")
	-- Someone wants to send an encounter
	if type == "UPDATE" then
		local key,version,length,name,rlocale = split(":",args)
		length = tonumber(length)
		version = tonumber(version)

		local data = DXE.EDB[key]
		-- Version and locale check
		if (data and data.version >= version) or rlocale ~= locale then
			self:Respond(format("RESPONSE:%s:%s",key,"NO"),sender)
			return
		end

		if DXE.db.global.Distributor.AutoAccept then
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
				button1 = "Accept",
				button2 = "Reject",
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

		ul.bar:SetPerc(format("%d/%d",ul.accepts+ul.declines,ul.dest))

		if ul.dest == ul.accepts + ul.declines then
			self:CancelTimer(ul.timer,true)
			self:StartUpload(key)
		end
	end
end

function Distributor:CHAT_MSG_ADDON(_,prefix, msg, dist, sender)
	if find(prefix,TRANSFER_PREFIX) and (dist == "RAID" or dist == "WHISPER") and (next(Downloads) or next(Uploads)) then
		local key, mark = match(prefix, TRANSFER_PREFIX.." _([%w'%- ]+)(.*)")
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
				dl.bar:SetPerc("%d%%",0)
				dl.bar:SetColor(Colors.ORANGE)
			elseif mark == NEXT_MULTIPART or mark == LAST_MULTIPART then
				local perc = dl.received/dl.length
				dl.bar:SetValue(perc)
				dl.bar:SetPerc("%d%%",perc*100)
			end	
		end

		-- Track uploads
		local ul = Uploads[key]
		if ul and sender == DXE.PNAME then
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

function Distributor:DownloadReceived(prefix, msg, dist, sender)
	self:UnregisterComm(prefix)
	local key = match(prefix, TRANSFER_PREFIX.."_([%w'%- ]+)")

	local dl = Downloads[key]
	if not dl then return end

	-- For WHISPER distributions
	if dl.dist == "WHISPER" then
		self:SendCommMessage(prefix,"COMPLETED","WHISPER",sender)
	end

	local success, data = self:Deserialize(msg)
	-- Failed to deserialize
	if not success then DXE:Print(format(L["Failed to load %s after downloading! Request another distribute from %s"],dl.name,dl.sender)) return end

	DXE:UnregisterEncounter(key)
	DXE:RegisterEncounter(data)

	DXE.RDB[key] = data

	DXE:BroadcastVersion(key)

	self:DLCompleted(key,dl.sender,dl.name)
end

function Distributor:DLCompleted(key,sender,name)
	DXE:Print(format(L["%s successfully updated from %s"],name,sender))
	self:LoadCompleted(key,Downloads[key],L["Completed"],Colors.GREEN,"RemoveDL")
end

function Distributor:DLTimeout(key)
	DXE:Print(format(L["%s download updating timed out"],Downloads[key].name))
	self:LoadCompleted(key,Downloads[key],L["Timed Out"],Colors.Red,"RemoveDL")
end

function Distributor:QueueNextUL()
	local qname,info = next(UploadQueue)
	if qname then
		UploadQueue[qname] = nil
		self:ScheduleTimer("DispatchDistribute",3.5,info)
	end
end

function Distributor:ULCompleted(key)
	DXE:Print(format(L["%s successfully sent"],Uploads[key].name))
	self:LoadCompleted(key,Uploads[key],L["Completed"],Colors.GREEN,"RemoveUL")
	self:QueueNextUL()
end

function Distributor:ULTimeout(key)
	DXE:Print(format(L["%s upload timed out"],Uploads[key].name))
	self:LoadCompleted(key,Uploads[key],L["Timed Out"],Colors.RED,"RemoveUL")
	self:QueueNextUL()
end

function Distributor:LoadCompleted(key,ld,text,color,func)
	if not ld then return end
	local bar = ld.bar
	bar:SetStatus(text)
	bar:SetColor(color)
	bar:SetValue(1)
	self:FadeBar(bar)
	self:ScheduleTimer(func,3,key)
end

function Distributor:RemoveDL(key)
	self:RemoveLoad(Downloads,key)
end

function Distributor:RemoveUL(key)
	self:RemoveLoad(Uploads,key)
end

function Distributor:RemoveLoad(tbl,key)
	self:RemoveFromUpdating(key..UL_SUFFIX)
	self:RemoveFromUpdating(key..DL_SUFFIX)
	local ld = tbl[key]
	if not ld then return end
	self:CancelTimer(ld.timer,true)
	self:RemoveProgressBar(ld.bar)
	AceGUI:Release(ld.bar)
	tbl[key] = nil
end

function Distributor:FadeBar(bar)
	UIFrameFadeOut(bar.frame,4,bar.frame:GetAlpha(),0)
end

----------------------------------
-- PROGRESS BARS
----------------------------------
local ProgressStack = {}

function Distributor:GetProgressBar()
	local bar = AceGUI:Create("DXE_ProgressBar")
	ProgressStack[#ProgressStack+1] = bar
	self:LayoutBarStack()
	return bar
end

function Distributor:RemoveProgressBar(bar)
	for i,_alert in ipairs(ProgressStack) do
		if _alert == bar then
			remove(ProgressStack,i)
			break 
		end
	end
	self:LayoutBarStack()
end

function Distributor:LayoutBarStack()
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

function Distributor:StartUpdating(key,bar)
	UpdateStack[key] = bar
	frame:SetScript("OnUpdate",OnUpdate)
end

function Distributor:RemoveFromUpdating(key)
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
		self.text = text

		local perc = bar:CreateFontString(nil,"ARTWORK")
		perc:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",8)
		perc:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-5,-3)
		self.perc = perc

		local status = bar:CreateFontString(nil,"ARTWORK")
		status:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",8)
		status:SetPoint("TOPLEFT",frame,"TOPLEFT",5,-3)
		status:SetTextColor(1,0.82,0)
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

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(WidgetType,Constructor,WidgetVersion)
end
