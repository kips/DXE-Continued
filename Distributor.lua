local AceGUI = LibStub("AceGUI-3.0")
local DXE,BCL,Colors = DXE,BCL,DXE.Constants.Colors
local PlayerName = UnitName("player")

local ipairs, pairs = ipairs, pairs
local insert,remove,wipe = table.insert,table.remove,table.wipe
local match,len,format,split = string.match,string.len,string.format,string.split

----------------------------------
-- INITIALIZATION
----------------------------------

local Distributor = {}
LibStub("AceEvent-3.0"):Embed(Distributor)
LibStub("AceTimer-3.0"):Embed(Distributor)
LibStub("AceComm-3.0"):Embed(Distributor)
LibStub("AceSerializer-3.0"):Embed(Distributor)

----------------------------------
-- CONSTANTS
----------------------------------

local FIRST_MULTIPART, NEXT_MULTIPART, LAST_MULTIPART = "\001", "\002", "\003"
local MAIN_PREFIX = "DXE_Dist"

----------------------------------
-- UTILITY
----------------------------------

-- @return The first word of a string
local function firstword(str)
	return match(str,"[%w']+")
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

function Distributor:StartUpdating(name,bar)
	UpdateStack[name] = bar
	frame:SetScript("OnUpdate",OnUpdate)
end

function Distributor:RemoveFromUpdating(name)
	if not UpdateStack[name] then return end
	UpdateStack[name] = nil
	if not next(UpdateStack) then
		frame:SetScript("OnUpdate",nil)
	end
end

----------------------------------
-- OPTIONS
----------------------------------


local EncNames,RaidNames = {},{}
local ListSelect,PlayerSelect
local options = {
	dist_group = {
		type = "group",
		name = "Distributor",
		order = 200,
		get = function(info) return DXE.db.profile.Distributor[info[#info]] end,
		set = function(info,value) DXE.db.profile.Distributor[info[#info]] = value end,
		args = {
			AutoAccept = {
				type = "toggle",
				name = "Auto accept",
				order = 50,
			},
			blank = {type="description",name="",order=75},
			ListSelect = {
				type = "select",
				order = 100,
				name = "Select an encounter",
				get = function() return ListSelect end,
				set = function(info,value) ListSelect = value end,
				values = function()
					wipe(EncNames)
					for k in pairs(DXE.EDB) do
						if k ~= "Default" then
							EncNames[k] = k
						end
					end
					return EncNames
				end,
			},
			send_raid_group = {
				type = "group",
				name = "Raid Distributing",
				order = 120,
				inline = true,
				args = {
					DistributeToRaid = {
						type = "execute",
						name = "Send to raid",
						order = 100,
						func = function() Distributor:Distribute(ListSelect) end,
						disabled = function() return not ListSelect end,
					},
					DistributeAllToRaid = {
						type = "execute",
						name = "Send all to raid",
						order = 200,
						func = function() 
									for name in pairs(DXE.EDB) do
										Distributor:Distribute(name)
									end
								 end,
						confirm = true,
						confirmText = "Are you sure you want to do this?",
					},
				},
			},
			send_player_group = {
				type = "group",
				name = "Player Distributing",
				order = 200,
				inline = true,
				disabled = function() return not ListSelect end,
				args = {
					PlayerSelect = {
						type = "select",
						order = 100,
						name = "Select a player",
						get = function() return PlayerSelect end,
						set = function(info,value) PlayerSelect = value end,
						values = function()
							wipe(RaidNames)
							for k,uid in pairs(DXE:GetRoster()) do
								local name = UnitName(uid)
								if UnitExists(uid) and name and name ~= PlayerName then
									 RaidNames[name] = name
								end
							end
							return RaidNames
						end,
					},
					blank = {type="description",name="",order=200},
					DistributeToPlayer = {
						type = "execute",
						order = 300,
						name = "Send to player",
						func = function() Distributor:Distribute(ListSelect, "WHISPER", PlayerSelect) end,
						disabled = function() return not PlayerSelect end,
					},
					DistributeAllToPlayer = {
						type = "execute",
						order = 400,
						name = "Send all to player",
						func = function()
									for name in pairs(DXE.EDB) do
										Distributor:Distribute(name, "WHISPER", PlayerSelect)
									end
								 end,
						disabled = function() return not PlayerSelect end,
						confirm = true,
						confirmText = "Are you sure you want to do this?",
					},
				},
			},
		},
	}
}

DXE:AddPluginOptions("distributor",options)

----------------------------------
-- API
----------------------------------
-- The active uploads
local Uploads = {}
-- The queues uploads
local UploadQueue = {}

function Distributor:Distribute(name, dist, target)
	dist = dist or "RAID"
	local data = DXE:GetEncounterData(name)
	if not data or Uploads[name] or name == "Default" or GetNumRaidMembers() == 0 then return end
	if BCL.tablesize(Uploads) == 4 then UploadQueue[name] = true return end
	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format("UPDATE:%s:%d:%d",name,data.version,length)

	-- Create upload bar
	local bar = self:GetProgressBar()
	bar:SetText(format("Waiting for %s responses",firstword(name)))
	bar:SetColor(Colors.GREY)
	local dest = (channel == "WHISPER") and 1 or (GetNumRaidMembers() - 1)

	Uploads[name] = {
		accepts = 0,
		declines = 0,
		sent = 0,
		length = length,
		bar = bar,
		dest = dest,
		serialData = serialData,
		timer = self:ScheduleTimer("StartUpload",30,name),
		dist = dist,
		target = target,
	}

	bar.userdata.timeleft = 30
	bar.userdata.totaltime = 30
	self:StartUpdating(name.."UL",bar)
	
	self:SendCommMessage(MAIN_PREFIX, message, dist, target)
end

----------------------------------
-- UPLOADING
----------------------------------

function Distributor:StartUpload(name)
	local ul = Uploads[name]
	if ul.accepts == 0 then self:ULTimeout(name) return end
	local message = ul.serialData
	self:SendCommMessage(format("DXE_DistR_%s",name), message, ul.dist, ul.target)
	ul.bar:SetText(format("Sending %s",name))
	self:RemoveFromUpdating(name.."UL")
end

----------------------------------
-- DOWNLOADING
----------------------------------
-- The active downloads
local Downloads = {}

function Distributor:StartReceiving(name,length,sender)
	local prefix = format("DXE_DistR_%s",name)
	if Downloads[name] then self:RemoveDL(name) end

	-- Create download bar
	local bar = self:GetProgressBar()
	bar:SetText(format("In queue for %s download",firstword(name)))
	bar:SetColor(Colors.GREY)

	Downloads[name] = {
		name = name,
		sender = sender,
		received = 0,
		length = length,
		bar = bar,
		timer = self:ScheduleTimer("DLTimeout",40,name)
	}
	bar.userdata.timeleft = 40
	bar.userdata.totaltime = 40
	self:StartUpdating(name.."DL",bar)
	self:RegisterComm(prefix, "DownloadReceived")
end

function Distributor:DownloadReceived(prefix, msg, dist, sender)
	self:UnregisterComm(prefix)
	local name = match(prefix, "DXE_DistR_([%w' ]+)")

	local dl = Downloads[name]
	if not dl then return end

	local success, data = self:Deserialize(msg)
	-- Failed to deserialize
	if not success then return end

	-- Unregister
	DXE:UnregisterEncounter(name)
	-- Register
	DXE:RegisterEncounter(data)
	-- Store it in SavedVariables
	DXERecEncDB[name] = data	

	self:DLCompleted(name)
end

----------------------------------
-- COMMS
----------------------------------

function Distributor:Respond(msg,sender)
	self:SendCommMessage(MAIN_PREFIX, msg, "WHISPER",sender)
end

function Distributor:OnCommReceived(prefix, msg, dist, sender)
	if sender == PlayerName then return end
	local type,args = match(msg,"(%w+):(.+)")
	if type == "UPDATE" then
		local name,version,length = split(":",args)
		length = tonumber(length)
		version = tonumber(version)

		local data = DXE.EDB[name]
		-- Don't want the same version
		if data and data.version >= version then
			self:Respond(format("RESPONSE:%s:%s",name,"NO"),sender)
			return
		end

		if DXE.db.profile.Distributor.AutoAccept then
			self:StartReceiving(name,length,sender)
			self:Respond(format("RESPONSE:%s:%s",name,"YES"),sender)
			return
		end

		local STATIC_CONFIRM = {
			text = format("%s is sharing an update for %s",sender,firstword(name)),
			OnAccept = function() self:StartReceiving(name,length,sender)
										 self:Respond(format("RESPONSE:%s:%s",name,"YES"),sender)
						  end,
			OnCancel = function() self:Respond(format("RESPONSE:%s:%s",name,"NO"),sender) end,
			button1 = "Accept",
			button2 = "Reject",
			timeout = 25,
			whileDead = 1,
			hideOnEscape = 1,
		}

		local popupname = format("DXE_Confirm_%s",name)
		StaticPopupDialogs[popupname] = STATIC_CONFIRM

		StaticPopup_Show(popupname)
	elseif type == "RESPONSE" and dist == "WHISPER" then
		local name,answer = split(":",args)
		local ul = Uploads[name]
		if not ul then return end
		if answer == "YES" then
			ul.accepts = ul.accepts + 1
		elseif answer == "NO" then
			ul.declines = ul.declines + 1
		end

		ul.bar:SetFormattedText("Waiting for %s responses %d/%d",firstword(name),ul.accepts+ul.declines,ul.dest)

		if ul.dest == ul.accepts + ul.declines then
			self:CancelTimer(ul.timer,true)
			self:StartUpload(name)
		end
	end
end

Distributor:RegisterComm("DXE_Dist","OnCommReceived")

-- AceComm-3.0 doesn't give us a method for checking multipart data as it comes in so will watch the prefixes and the event to figure it out
function Distributor:CHAT_MSG_ADDON(_,prefix, msg, dist, sender)
	if (dist == "RAID" or dist == "WHISPER") and (next(Downloads) or next(Uploads)) then
		local name, mark = match(prefix, "DXE_DistR_([%w' ]+)(.)")
		if not name then return end
		-- Track downloads
		local dl = Downloads[name]
		if dl and dl.sender == sender then
			self:RemoveFromUpdating(name.."DL")
			dl.received = dl.received + len(msg)
			if mark == FIRST_MULTIPART then
				dl.bar:SetText("Downloaded 0%")
				dl.bar:SetColor(Colors.ORANGE)
			elseif mark == NEXT_MULTIPART or mark == LAST_MULTIPART then
				local perc = dl.received/dl.length
				dl.bar:SetValue(perc)
				dl.bar:SetFormattedText("Downloaded %s %d%%",firstword(name),perc*100)
			end	
		end

		-- Track uploads
		local ul = Uploads[name]
		if ul and sender == PlayerName then
			ul.sent = ul.sent + len(msg)
			if mark == FIRST_MULTIPART then
				ul.bar:SetText("Uploaded 0%")
				ul.bar:SetColor(Colors.YELLOW)
			elseif mark == NEXT_MULTIPART or mark == LAST_MULTIPART then
				local perc = ul.sent/ul.length
				ul.bar:SetValue(perc)
				ul.bar:SetFormattedText("Uploaded %s %d%%",firstword(name),perc*100)
				if mark == LAST_MULTIPART then
					self:ULCompleted(name)
				end
			end	
		end
	end
end

Distributor:RegisterEvent("CHAT_MSG_ADDON")

----------------------------------
-- COMPLETIONS
----------------------------------

function Distributor:DLCompleted(name)
	DXE:Print(format("%s successfully updated",name))
	self:LoadCompleted(name,Downloads[name],"Download Completed",Colors.GREEN,"RemoveDL")
end

function Distributor:DLTimeout(name)
	DXE:Print(format("%s updating timed out",name))
	self:LoadCompleted(name,Downloads[name],"Download Timeout",Colors.Red,"RemoveDL")
end

function Distributor:QueueNextUL()
	local qname = next(UploadQueue)
	if qname then
		UploadQueue[qname] = nil
		self:ScheduleTimer("Distribute",3.5,qname)
	end
end

function Distributor:ULCompleted(name)
	DXE:Print(format("%s successfully sent",name))
	self:LoadCompleted(name,Uploads[name],"Upload Completed",Colors.GREEN,"RemoveUL")
	self:QueueNextUL()
end

function Distributor:ULTimeout(name)
	DXE:Print(format("%s sending timed out",name))
	self:LoadCompleted(name,Uploads[name],"Upload Timeout",Colors.RED,"RemoveUL")
	self:QueueNextUL()
end

function Distributor:LoadCompleted(name,ld,text,color,func)
	if not ld then return end
	local bar = ld.bar
	bar:SetText(text)
	bar:SetColor(color)
	bar:SetValue(1)
	self:FadeBar(bar)
	self:ScheduleTimer(func,3,name)
end

function Distributor:RemoveDL(name)
	self:RemoveLoad(Downloads,name)
end

function Distributor:RemoveUL(name)
	self:RemoveLoad(Uploads,name)
end

function Distributor:RemoveLoad(tbl,name)
	self:RemoveFromUpdating(name.."UL")
	self:RemoveFromUpdating(name.."DL")
	local ld = tbl[name]
	if not ld then return end
	self:CancelTimer(ld.timer,true)
	self:RemoveProgressBar(ld.bar)
	AceGUI:Release(ld.bar)
	tbl[name] = BCL.deltable(tbl[name])
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
	insert(ProgressStack, bar)
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

-- No cool gradual movement
function Distributor:LayoutProgBarStack()
	local x,y = DXE.Pane:GetCenter()
	local height = GetScreenHeight()/2
	local point = y > height and "TOP" or "BOTTOM"
	local relPoint = y > height and "BOTTOM" or "TOP"
	local anchor = DXE.Pane
	for i=1,#ProgressStack do
		local bar = ProgressStack[i]
		bar:Anchor(point,anchor,relPoint)
		anchor = bar.frame
	end
end

DXE.Distributor = Distributor
