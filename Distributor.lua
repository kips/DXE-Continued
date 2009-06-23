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
local match,len,format,split = string.match,string.len,string.format,string.split

local locale = GetLocale()

-- Credits to Bazaar for this implementation

----------------------------------
-- INITIALIZATION
----------------------------------

local Distributor = DXE:NewModule("Distributor","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
local StackAnchor

function Distributor:OnInitialize()
	DXE:AddPluginOptions("distributor",self:GetOptions())

	StackAnchor = DXE:CreateLockableFrame("DistributorStackAnchor",200,10,L["Download/Upload Anchor"])
	DXE:RegisterMoveSaving(StackAnchor,"CENTER","UIParent","CENTER",0,300)
end

function Distributor:OnEnable()
	self:RegisterComm("DXE_Dist")
	self:RegisterEvent("CHAT_MSG_ADDON")
end

----------------------------------
-- CONSTANTS
----------------------------------

local FIRST_MULTIPART, NEXT_MULTIPART, LAST_MULTIPART = "\001", "\002", "\003"
local MAIN_PREFIX = "DXE_Dist"

----------------------------------
-- UTILITY
----------------------------------

-- @return string The first word of a string
local function firstword(str)
	return match(str,"[%w'%-]+")
end

----------------------------------
-- UPDATING
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
	if not next(UpdateStack) then
		frame:SetScript("OnUpdate",nil)
	end
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
						for k in pairs(DXE.EDB) do
							if k ~= "default" then
								EncKeys[k] = DXE.EDB[k].name
							end
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
								for k,uid in pairs(Roster.index_to_id) do
									local name = UnitName(uid)
									if name ~= DXE.pName then
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
-- API
----------------------------------
-- The active uploads
local Uploads = {}
-- The queues uploads
local UploadQueue = {}

function Distributor:DispatchDistribute(info)
	local success,key,dist,target = self:Deserialize(info)
	if success then self:Distribute(key,dist,target) end
end

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
	bar:SetText(format(L["Waiting for %s responses"],firstword(data.name)))
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
	self:StartUpdating(key.."UL",bar)
	
	self:SendCommMessage(MAIN_PREFIX, message, dist, target)
end

----------------------------------
-- UPLOADING
----------------------------------

function Distributor:StartUpload(key)
	local ul = Uploads[key]
	if ul.accepts == 0 then self:ULTimeout(key) return end
	local message = ul.serialData
	self:SendCommMessage(format("DXE_DistR_%s",key), message, ul.dist, ul.target)
	ul.bar:SetText(format("Sending %s",ul.name))
	self:RemoveFromUpdating(key.."UL")
end

----------------------------------
-- DOWNLOADING
----------------------------------
-- The active downloads
local Downloads = {}

function Distributor:StartReceiving(key,length,sender,dist,name)
	local prefix = format("DXE_DistR_%s",key)
	if Downloads[key] then self:RemoveDL(key) end

	-- Create download bar
	local bar = self:GetProgressBar()
	bar:SetText(format(L["In queue for %s download"],firstword(name)))
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
	
	self:StartUpdating(key.."DL",bar)
	self:RegisterComm(prefix, "DownloadReceived")
end

function Distributor:DownloadReceived(prefix, msg, dist, sender)
	self:UnregisterComm(prefix)
	local key = match(prefix, "DXE_DistR_([%w'%- ]+)")

	local dl = Downloads[key]
	if not dl then return end

	-- For WHISPER distributions
	if dl.dist == "WHISPER" then
		self:SendCommMessage(prefix,"COMPLETED","WHISPER",sender)
	end

	local success, data = self:Deserialize(msg)
	-- Failed to deserialize
	if not success then DXE:Print(format(L["Failed to load %s after downloading! Request another distribute from %s"],dl.name,dl.sender)) return end

	-- Unregister
	DXE:UnregisterEncounter(key)
	-- Register
	DXE:RegisterEncounter(data)
	-- Store it in SavedVariables
	DXE.RDB[key] = data	

	self:DLCompleted(key,dl.sender,dl.name)

	-- Update versions for everyone
	DXE:BroadcastVersion(key)
end

----------------------------------
-- COMMS
----------------------------------

function Distributor:Respond(msg,sender)
	self:SendCommMessage(MAIN_PREFIX, msg, "WHISPER",sender)
end

function Distributor:OnCommReceived(prefix, msg, dist, sender)
	if sender == DXE.pName then return end
	local type,args = match(msg,"(%w+):(.+)")
	if type == "UPDATE" then
		local key,version,length,name,rlocale = split(":",args)
		length = tonumber(length)
		version = tonumber(version)

		local data = DXE.EDB[key]
		-- Don't want the same version
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
				text = format(L["%s is sharing an update for %s"],sender,firstword(name)),
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
	elseif type == "RESPONSE" and dist == "WHISPER" then
		local key,answer = split(":",args)
		local ul = Uploads[key]
		if not ul then return end
		if answer == "YES" then
			ul.accepts = ul.accepts + 1
		elseif answer == "NO" then
			ul.declines = ul.declines + 1
		end

		ul.bar:SetFormattedText(L["Waiting for %s responses %d/%d"],firstword(ul.name),ul.accepts+ul.declines,ul.dest)

		if ul.dest == ul.accepts + ul.declines then
			self:CancelTimer(ul.timer,true)
			self:StartUpload(key)
		end
	end
end

local find = string.find
function Distributor:CHAT_MSG_ADDON(_,prefix, msg, dist, sender)
	if find(prefix,"DXE_DistR") and (dist == "RAID" or dist == "WHISPER") and (next(Downloads) or next(Uploads)) then
		local key, mark = match(prefix, "DXE_DistR_([%w'%- ]+)(.*)")
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
			self:RemoveFromUpdating(key.."DL")
			dl.received = dl.received + len(msg)
			if mark == FIRST_MULTIPART then
				dl.bar:SetFormattedText(L["%s Progress - %d%%"],firstword(dl.name),0)
				dl.bar:SetColor(Colors.ORANGE)
			elseif mark == NEXT_MULTIPART or mark == LAST_MULTIPART then
				local perc = dl.received/dl.length
				dl.bar:SetValue(perc)
				dl.bar:SetFormattedText(L["%s Progress - %d%%"],firstword(dl.name),perc*100)
			end	
		end

		-- Track uploads
		local ul = Uploads[key]
		if ul and sender == PlayerName then
			ul.sent = ul.sent + len(msg)
			if mark == FIRST_MULTIPART then
				ul.bar:SetFormattedText(L["%s Progress - %d%%"],firstword(ul.name),0)
				ul.bar:SetColor(Colors.YELLOW)
			elseif mark == NEXT_MULTIPART or mark == LAST_MULTIPART then
				local perc = ul.sent/ul.length
				ul.bar:SetValue(perc)
				ul.bar:SetFormattedText(L["%s Progress - %d%%"],firstword(ul.name),perc*100)
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

function Distributor:DLCompleted(key,sender,name)
	DXE:Print(format(L["%s successfully updated from %s"],name,sender))
	self:LoadCompleted(key,Downloads[key],L["Download Completed"],Colors.GREEN,"RemoveDL")
end

function Distributor:DLTimeout(key)
	DXE:Print(format(L["%s updating timed out"],Downloads[key].name))
	self:LoadCompleted(key,Downloads[key],L["Download Timed Out"],Colors.Red,"RemoveDL")
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
	self:LoadCompleted(key,Uploads[key],L["Upload Completed"],Colors.GREEN,"RemoveUL")
	self:QueueNextUL()
end

function Distributor:ULTimeout(key)
	DXE:Print(format(L["%s sending timed out"],Uploads[key].name))
	self:LoadCompleted(key,Uploads[key],L["Upload Timed Out"],Colors.RED,"RemoveUL")
	self:QueueNextUL()
end

function Distributor:LoadCompleted(key,ld,text,color,func)
	if not ld then return end
	local bar = ld.bar
	bar:SetText(text)
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
	self:RemoveFromUpdating(key.."UL")
	self:RemoveFromUpdating(key.."DL")
	local ld = tbl[key]
	if not ld then return end
	self:CancelTimer(ld.timer,true)
	self:RemoveProgressBar(ld.bar)
	AceGUI:Release(ld.bar)
	tbl[key] = nil
end

function Distributor:FadeBar(bar)
	UIFrameFadeOut(bar.frame,2,bar.frame:GetAlpha(),0)
end

----------------------------------
-- PROGRESS BARS
----------------------------------
local ProgressStack = {}

function Distributor:GetProgressBar()
	local bar = AceGUI:Create("DXE_ProgressBar")
	ProgressStack[#ProgressStack+1] = bar
	self:LayoutProgBarStack()
	return bar
end

function Distributor:RemoveProgressBar(bar)
	for i,_alert in ipairs(ProgressStack) do
		if _alert == bar then
			remove(ProgressStack,i)
			break 
		end
	end
	self:LayoutProgBarStack()
end

function Distributor:LayoutProgBarStack()
	local anchor = StackAnchor
	for i=1,#ProgressStack do
		local bar = ProgressStack[i]
		bar:Anchor("TOP",anchor,"BOTTOM")
		anchor = bar.frame
	end
end

DXE.Distributor = Distributor
