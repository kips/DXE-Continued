-- Credits to Bazaar (by Shadowed) for this idea

local defaults = {
	profile = {
		AutoAccept = true,
	},
}

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
local VERSION = 10 

local FIRST_MULTIPART, NEXT_MULTIPART, LAST_MULTIPART = "\001", "\002", "\003"
local MAIN_PREFIX = "DXE_Dist"..VERSION
local TRANSFER_PREFIX = "DXE_DistT"..VERSION
local UL_SUFFIX = "UL"
local DL_SUFFIX = "DL"
local DR_PTN = TRANSFER_PREFIX.."_([%w'%- ]+)" -- DownloadReceived
local CMA_PTN = TRANSFER_PREFIX.."_([%w'%- ]+)(.*)" -- CHAT_MSG_ADDON
local UL_TIMEOUT = 5
local DL_TIMEOUT = 35

----------------------------------
-- INITIALIZATION
----------------------------------

local module = addon:NewModule("Distributor","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
addon.Distributor = module
local StackAnchor

function module:RefreshProfile() pfl = self.db.profile end

function module:OnInitialize()
	StackAnchor = addon:CreateLockableFrame("DistributorStackAnchor",200,10,L["Download/Upload Anchor"])
	addon:RegisterMoveSaving(StackAnchor,"CENTER","UIParent","CENTER",0,300)
	addon:LoadPosition("DXEDistributorStackAnchor")

	self.db = addon.db:RegisterNamespace("Distributor", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
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
	local data = addon.EDB[key]
	if not data or Uploads[key] or key == "default" or GetNumRaidMembers() == 0 then return end
	if addon.util.tablesize(Uploads) == 4 then UploadQueue[key] = self:Serialize(key,dist,target) return end
	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format("UPDATE:%s:%g:%d:%s:%s",key,data.version,length,data.name,GetLocale()) -- ex. UPDATE:sartharion:150:800:Sartharion:enUS

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
		prefix = prefix,
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
	self:CancelTimer(loadInfo.timer,true)
	if loadInfo.prefix then self:UnregisterComm(loadInfo.prefix) end
	self:RemoveFromUpdating(key..UL_SUFFIX)
	self:RemoveFromUpdating(key..DL_SUFFIX)
	self:ScheduleTimer(func,2,key)
	if not next(Uploads) and not next(Downloads) then
		self:UnregisterEvent("CHAT_MSG_ADDON")
	end
end

function module:RemoveDL(key)
	self:RemoveLoad(Downloads,key)
end

function module:RemoveUL(key)
	self:RemoveLoad(Uploads,key)
end

function module:RemoveLoad(loadTable,key)
	local loadInfo = loadTable[key]
	self:RemoveProgressBar(loadInfo.bar)
	self:ReleaseProgressBar(loadInfo.bar)
	loadTable[key] = nil
end

function module:FadeBar(bar)
	UIFrameFadeOut(bar.frame,2,bar.frame:GetAlpha(),0)
end

----------------------------------
-- PROGRESS BARS
----------------------------------
local CreateProgressBar
local FramePool = {}
local ProgressStack = {}

function module:GetProgressBar()
	local bar = next(FramePool)
	if bar then FramePool[bar] = nil
	else bar = CreateProgressBar() end
	bar:OnAcquire()
	ProgressStack[#ProgressStack+1] = bar
	self:LayoutBarStack()
	return bar
end

function module:ReleaseProgressBar(bar)
	bar:OnRelease()
	FramePool[bar] = true
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

-- UPDATING

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

-- PROTOTYPE
local prototype = {}

function prototype:OnAcquire()
	self.frame:Show()
	self.frame:SetParent(UIParent)
	self:SetColor(Colors.BLUE)
end

function prototype:OnRelease()
	self.frame:Hide()
	self.frame:ClearAllPoints()
	self.bar:SetValue(0)
	self:SetAlpha(1)
	self.perc:SetText("")
	UIFrameFadeRemoveFrame(self.frame)
	wipe(self.userdata)
end

function prototype:SetText(text) self.text:SetText(text) end
function prototype:SetFormattedText(text,...) self.text:SetFormattedText(text,...) end
function prototype:SetPerc(perc) self.perc:SetText(perc) end
function prototype:SetStatus(status,r,g,b) self.status:SetFormattedText(L["STATUS"]..": |cffffffff%s|r",status) end
function prototype:SetAlpha(alpha) self.frame:SetAlpha(alpha) end
function prototype:SetValue(value) self.bar:SetValue(value) end
function prototype:SetColor(c) self.bar:SetStatusBarColor(c.r,c.g,c.b) end
function prototype:Anchor(relPoint,frame,relTo)
	self.frame:ClearAllPoints()
	self.frame:SetPoint(relPoint,frame,relTo)
end

function CreateProgressBar()
	local self = {}
	self.userdata = {}
	local frame = CreateFrame("Frame",nil,UIParent)

	frame:SetWidth(222)
	frame:SetHeight(27)
	addon:RegisterBackground(frame)
	
	local bar = CreateFrame("StatusBar",nil,frame)
	bar:SetPoint("TOPLEFT",2,-2)
	bar:SetPoint("BOTTOMRIGHT",-2,2)
	bar:SetMinMaxValues(0,1) 
	bar:SetValue(0)
	self.bar = bar
	addon:RegisterStatusBar(bar)

	local border = CreateFrame("Frame",nil,frame)
	border:SetAllPoints(true)
	addon:RegisterBorder(border)
	border:SetFrameLevel(bar:GetFrameLevel()+1)
	
	local text = bar:CreateFontString(nil,"ARTWORK")
	text:SetPoint("CENTER",frame,"CENTER",0,-4)
	text:SetTextColor(0.6,1,0.2)
	text:SetShadowOffset(1,-1)
	addon:RegisterFontString(text,9)
	self.text = text

	local perc = bar:CreateFontString(nil,"ARTWORK")
	perc:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-5,-3)
	perc:SetShadowOffset(1,-1)
	addon:RegisterFontString(perc,8)
	self.perc = perc

	local status = bar:CreateFontString(nil,"ARTWORK")
	status:SetPoint("TOPLEFT",frame,"TOPLEFT",5,-3)
	status:SetTextColor(1,0.82,0)
	status:SetShadowOffset(1,-1)
	addon:RegisterFontString(status,8)
	self.status = status
	
	for k,v in pairs(prototype) do self[k] = v end
	self.frame = frame
	return self
end
