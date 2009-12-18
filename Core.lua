---------------------------------------------
-- DEFAULTS
---------------------------------------------

--@debug@
local debug

local debugDefaults = { 
	CheckForEngage = false,
	CombatStop = false,
	CHAT_MSG_MONSTER_YELL = false,
	RAID_ROSTER_UPDATE = false,
	PARTY_MEMBERS_CHANGED = false,
	BlockBossEmotes = false,
	TriggerDefeat = false,
}
--@end-debug@

local defaults = { 
	global = { 
		Locked = true,
		AdvancedMode = false,
		-- NPC id -> Localized name  
		L_NPC = {},
		--@debug@
		debug = debugDefaults,
		--@end-debug@
	},
	profile = {
		Enabled = true,
		Positions = {},
		Encounters = {},
		Globals = {
			BarTexture = "Blizzard",
			Font = "Franklin Gothic Medium",
			Border = "Blizzard Tooltip",
			BorderColor = {0.33,0.33,0.33,1},
			BackgroundColor = {0,0,0,0.8},
		},
		Pane = {
			Show = true,
			Scale = 1, 
			OnlyInRaid = false, 
			OnlyInParty = false,
			OnlyInRaidInstance = false,
			OnlyInPartyInstance = false,
			OnlyIfRunning = false,
			OnlyOnMouseover = false,
			BarGrowth = "AUTOMATIC",
			FontColor = {1,1,1,1},
			TitleFontSize = 10,
			HealthFontSize = 12,
			NeutralColor = {0,0,1,1},
			LostColor = {0.66,0.66,0.66,1},
		},
		Misc = {['*'] = false},
		Windows = {
			TitleBarColor = {0,0,0.82,1},
		},
		Proximity = {
			BarAlpha = 0.4,
			Range = 10,
			Delay = 0.05,
			ClassFilter = {['*'] = true},
			Invert = false,
		},
		Sounds = {
			ALERT1 = "Bell Toll Alliance",
			ALERT2 = "Bell Toll Horde",
			ALERT3 = "Low Mana",
			ALERT4 = "Low Health",
			ALERT5 = "Zing Alarm",
			ALERT6 = "Wobble",
			ALERT7 = "Bottle",
			ALERT8 = "Lift Me",
			ALERT9 = "Neo Beep",
			ALERT10 = "PvP Flag Taken",
			ALERT11 = "Bad Press",
			VICTORY = "FF1 Victory",
		},
		CustomSounds = {},
	},
}

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local addon = LibStub("AceAddon-3.0"):NewAddon("DXE","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
_G.DXE = addon
addon.version = 409
addon:SetDefaultModuleState(false)
addon.callbacks = LibStub("CallbackHandler-1.0"):New(addon)
addon.defaults = defaults

---------------------------------------------
-- UPVALUES
---------------------------------------------

local wipe,remove,sort = table.wipe,table.remove,table.sort
local match,find,gmatch,sub = string.match,string.find,string.gmatch,string.sub
local _G,select,tostring,type,tonumber = _G,select,tostring,type,tonumber
local GetTime,GetNumRaidMembers,GetNumPartyMembers,GetRaidRosterInfo = GetTime,GetNumRaidMembers,GetNumPartyMembers,GetRaidRosterInfo
local UnitName,UnitGUID,UnitIsEnemy,UnitClass,UnitAffectingCombat,UnitHealth,UnitHealthMax,UnitIsFriend,UnitIsDead,UnitIsConnected = 
		UnitName,UnitGUID,UnitIsEnemy,UnitClass,UnitAffectingCombat,UnitHealth,UnitHealthMax,UnitIsFriend,UnitIsDead,UnitIsConnected
local rawget,unpack = rawget,unpack

local db,gbl,pfl

---------------------------------------------
-- LIBS
---------------------------------------------

local AceTimer = LibStub("AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DXE")
local SM = LibStub("LibSharedMedia-3.0")

-- Localized spell names - caching is unnecessary
local SN = setmetatable({},{
	__index = function(t,k)
		if type(k) ~= "number" then return "nil" end
		local name = GetSpellInfo(k)
		if not name then 
			geterrorhandler()("Invalid spell name attempted to be retrieved") 
			return tostring(k)
		end
		return name 
	end,
})

-- Spell textures - caching is unnecessary
local ST = setmetatable({},{
	__index = function(t,k)
		if type(k) ~= "number" then return "nil" end
		local texture = select(3,GetSpellInfo(k))
		if not texture then
			geterrorhandler()("Invalid spell texture attempted to be retrieved") 
			return "Interface\\Buttons\\WHITE8X8"
		end
		return texture
	end,
})

-- NPC IDs
local GUID_LENGTH = 18
local UT_NPC = 3
local UT_VEHICLE = 5

local NID = setmetatable({},{
	__index = function(t,guid)
		if type(guid) ~= "string" or #guid ~= GUID_LENGTH or not guid:find("%xx%x+") then return end
		local ut = tonumber(sub(guid,5,5),16) % 8
		local isNPC = ut == UT_NPC or ut == UT_VEHICLE
		local npcid = isNPC and tonumber(sub(guid,9,12),16)
		t[guid] = npcid
		return npcid
	end,
})

-- Color name
local class_to_color = {}
for class,color in pairs(RAID_CLASS_COLORS) do
	class_to_color[class] = ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
end

local CN = setmetatable({}, {__index =
	function(t, unit)
		local class = select(2,UnitClass(unit))
		if not class then return unit end
		local name = UnitName(unit)
		local prev = rawget(t,name)
		if prev then return prev end
		t[name] = class_to_color[class]..name.."|r"
		return t[name]
	end,
})

do
	local embeds = { 
		L = L,
		SN = SN,
		NID = NID,
		CN = CN,
		SM = SM,
		ST = ST,
	}
	for k,v in pairs(embeds) do addon[k] = v end
end

---------------------------------------------
-- UTILITY 
---------------------------------------------

local ipairs,pairs = ipairs,pairs

local util = {}
addon.util = util

local function tablesize(t)
	local n = 0
	for _ in pairs(t) do n = n + 1 end
	return n
end

local function search(t,value,i)
	for k,v in pairs(t) do
		if i then
			if type(v) == "table" and v[i] == value then return k end
		elseif v == value then return k end
	end
end

local function blend(c1, c2, factor)
	local r = (1-factor) * c1.r + factor * c2.r
	local g = (1-factor) * c1.g + factor * c2.g
	local b = (1-factor) * c1.b + factor * c2.b
	return r,g,b
end

local function safecall(func,...)
	local success,err = pcall(func,...)
	if not success then geterrorhandler()(err) end
	return success
end

util.tablesize = tablesize
util.search = search
util.blend = blend
util.safecall = safecall

---------------------------------------------
-- MODULES
---------------------------------------------

function addon:EnableAllModules()
	for name in self:IterateModules() do
		self:EnableModule(name)
	end
end

function addon:DisableAllModules()
	for name in self:IterateModules() do
		self:DisableModule(name) 
	end
end

---------------------------------------------
-- PROXIMITY CHECKING
---------------------------------------------

do
	-- 18 yards
	local bandages = {
		[34722] = true, -- Heavy Frostweave Bandage
		[34721] = true, -- Frostweave Bandage
		[21991] = true, -- Heavy Netherweave Bandage
		[21990] = true, -- Netherweave Bandage
		[14530] = true, -- Heavy Runecloth Bandage
		[14529] = true, -- Runecloth Bandage
		[8545] = true, -- Heavy Mageweave Bandage
		[8544] = true, -- Mageweave Bandage
		[6451] = true, -- Heavy Silk Bandage
		[6450] = true, -- Silk Bandage
		[3531] = true, -- Heavy Wool Bandage
		[3530] = true, -- Wool Bandage
		[2581] = true, -- Heavy Linen Bandage
		[1251] = true, -- Linen Bandage
	}
	-- CheckInteractDistance(unit,i)
	-- 2 = Trade, 11.11 yards 
	-- 3 = Duel, 9.9 yards 
	-- 4 = Follow, 28 yards 

	local IsItemInRange = IsItemInRange
	local knownBandage
	-- Keys refer to yards
	local ProximityFuncs = {
		[10] = function(unit) return CheckInteractDistance(unit,3) end,
		[11] = function(unit) return CheckInteractDistance(unit,2) end,
		[18] = function(unit) 
			if knownBandage then
				return IsItemInRange(knownBandage,unit) == 1
			else
				for itemid in pairs(bandages) do
					if IsItemInRange(itemid,unit) == 1 then 
						knownBandage = itemid
						return true
					end
				end
				return false
			end
		end,
		[28] = function(unit) return CheckInteractDistance(unit,4) end,
	}

	function addon:GetProximityFuncs()
		return ProximityFuncs
	end
end

---------------------------------------------
-- FUNCTION THROTTLING
---------------------------------------------

do
	-- Error margin added to ScheduleTimer to ensure it fires after the throttling period
	local _epsilon = 0.2
	-- @param _postcall A boolean determining whether or not the function is called 
	-- 		           after the end of the throttle period if called during it. If this
	--					     is set to true the function should not be passing in arguments
	--         		     because they will be lost
	local function ThrottleFunc(_obj,_func,_time,_postcall)
		--@debug@
		assert(type(_func) == "string","Expected _func to be a string")
		assert(type(_obj) == "table","Expected _obj to be a table")
		assert(type(_obj[_func]) == "function","Expected _obj[func] to be a function")
		assert(type(_time) == "number","Expected _time to be a number")
		assert(type(_postcall) == "boolean","Expected _postcall to be a boolean")
		assert(AceTimer.embeds[_obj],"Expected obj to be AceTimer embedded")
		--@end-debug@
		local _old_func = _obj[_func]
		local _last,_handle = GetTime() - _time
		_obj[_func] = function(self,...)
			local _t = GetTime()
			if _last + _time > _t then
				if _postcall and not _handle then
					_handle = self:ScheduleTimer(_func,_last + _time - _t + _epsilon)
				end
				return
			end
			_last = _t
			self:CancelTimer(_handle,true)
			_handle = nil
			return _old_func(self,...)
		end
	end

	addon.ThrottleFunc = ThrottleFunc
end

---------------------------------------------
-- ENCOUNTER MANAGEMENT
-- Credits to RDX
---------------------------------------------
local EDB = {}
addon.EDB = EDB
-- Current encounter data
local CE 
-- Received database
local RDB

local DEFEAT_NID
local DEFEAT_NIDS

local RegisterQueue = {}
local Initialized = false
function addon:RegisterEncounter(data)
	local key = data.key

	-- Convert version
	data.version = type(data.version) == "string" and tonumber(data.version:match("%d+")) or data.version

	-- Add to queue if we're not loaded yet
	if not Initialized then RegisterQueue[key] = data return end

	--@debug@
	local success = safecall(self.ValidateData,self,data)
	if not success then return end
	--@end-debug@

	-- Upgrading
	if RDB[key] and RDB[key] ~= data then
		if RDB[key].version <= data.version then
			local version = RDB[key].version
			RDB[key] = nil
			if version == data.version then 
				-- Don't need to do anything
				return
			else 
				self:UnregisterEncounter(key) 
			end
		else
			-- RDB version is higher
			return
		end
	end

	-- Unregister before registering the same encounter
	if EDB[key] then error("Encounter "..key.." already exists - Requires unregistering") return end

	-- Only encounters with field key have options
	if key ~= "default" then
		self:AddEncounterDefaults(data)
		self:RefreshDefaults()
		self.callbacks:Fire("OnRegisterEncounter",data)
		self:UpdateTriggers()
	end

	EDB[key] = data
end

--- Remove an encounter previously added with RegisterEncounter.
function addon:UnregisterEncounter(key)
	if key == "default" or not EDB[key] then return end

	-- Swap to default if we're trying to unregister the current encounter
	if CE.key == key then self:SetActiveEncounter("default") end

	self:UpdateTriggers()
	self.callbacks:Fire("OnUnregisterEncounter",EDB[key])
	EDB[key] = nil
end

--- Get the name of the currently-active encounter
function addon:GetActiveEncounter()
	return CE and CE.key or "default"
end

function addon:SetCombat(flag,event,func)
	if flag then self:RegisterEvent(event,func) end
end

function addon:OpenWindows()
	local encdb = pfl.Encounters[CE.key]
	if encdb and encdb.proxwindow.enabled then
		self:Proximity()
	end
end

do
	local frame = CreateFrame("Frame")
	local DEFEAT_YELL
	local DEFEAT_TBL = {}

	frame:SetScript("OnEvent",function(self,event,msg)
		if find(msg,DEFEAT_YELL) then addon:TriggerDefeat() end
	end)

	function addon:ResetDefeat()
		wipe(DEFEAT_TBL)
		DEFEAT_NID = nil
		DEFEAT_NIDS = nil
		DEFEAT_YELL = nil
		frame:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function addon:ResetDefeatTbl() 
		for k in pairs(DEFEAT_TBL) do DEFEAT_TBL[k] = false end
	end

	function addon:TriggerDefeat()
		self:StopEncounter()
		PlaySoundFile(SM:Fetch("sound",pfl.Sounds.VICTORY))
		--@debug@
		debug("TriggerDefeat","key: %s",CE.key)
		--@end-debug@
	end

	function addon:SetDefeat(defeat)
		if not defeat then return end
		if type(defeat) == "number" then
			DEFEAT_NID = defeat
		elseif type(defeat) == "string" then
			DEFEAT_YELL = defeat
		elseif type(defeat) == "table" then
			for k,v in ipairs(defeat) do DEFEAT_TBL[v] = false end
			DEFEAT_NIDS = DEFEAT_TBL
		end

		if DEFEAT_YELL then frame:RegisterEvent("CHAT_MSG_MONSTER_YELL") end
	end
end

--- Change the currently-active encounter.
function addon:SetActiveEncounter(key)
	--@debug@
	assert(type(key) == "string","String expected in SetActiveEncounter")
	--@end-debug@
	-- Check the new encounter
	if not EDB[key] then return end
	-- Already set to this encounter
	if CE and CE.key == key then return end

	CE = EDB[key]

	self:SetTracerStart(false)
	self:SetTracerStop(false)

	self:StopEncounter() 

	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")

	self.Pane.SetFolderValue(key)

	self:OpenWindows()

	self:CloseAllHW()
	self:ResetSortedTracing()

	self:ResetDefeat()

	if CE.onactivate then
		local oa = CE.onactivate
		self:SetTracerStart(oa.tracerstart)
		self:SetTracerStop(oa.tracerstop)

		-- Either could exist but not both
		self:SetSortedTracing(oa.sortedtracing)
		self:SetTracing(oa.tracing or oa.unittracing)

		self:SetCombat(oa.combatstop,"PLAYER_REGEN_ENABLED","CombatStop")
		self:SetCombat(oa.combatstart,"PLAYER_REGEN_DISABLED","CombatStart")

		self:SetDefeat(oa.defeat)
	end
	-- For the empty encounter
	self:ShowFirstHW()
	self:LayoutHealthWatchers()
	self.callbacks:Fire("SetActiveEncounter",CE)
end

-- Start the current encounter
function addon:StartEncounter(...)
	if self:IsRunning() then return end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.callbacks:Fire("StartEncounter",...)
	self:StartTimer()
	self:StartSortedTracing()
	self:UpdatePaneVisibility()
	self:PauseScanning()
end

-- Stop the current encounter
function addon:StopEncounter()
	if not self:IsRunning() then return end
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.callbacks:Fire("StopEncounter")
	self:ClearSortedTracing()
	self:StopSortedTracing()
	self:StopTimer()
	self:UpdatePaneVisibility()
	self:ResumeScanning()
	self:ResetDefeatTbl()
end

do
	local function iter(t,i)
		local k,v = next(t,i)
		if k == "default" then return next(t,k)
		else return k,v end
	end

	function addon:IterateEDB()
		return iter,EDB
	end
end

---------------------------------------------
-- ROSTER
---------------------------------------------
local Roster = {}
addon.Roster = Roster

local rID,pID = {},{}
for i=1,40 do
	rID[i] = "raid"..i
	if i <= 4 then
		pID[i] = "party"..i
	end
end

local targetof = setmetatable({},{
	__index = function(t,k)
		if type(k) ~= "string" then return end
		t[k] = k.."target"
		return t[k]
	end
})

local refreshFuncs = {
	name_to_unit = function(t,id) 
		t[UnitName(id)] = id
	end,
	guid_to_unit = function(t,id)
		local guid = id == "player" and addon.PGUID or UnitGUID(id)
		t[guid] = id
	end,
	unit_to_unittarget = function(t,id)
		t[id] = targetof[id]
	end,
	name_to_class = function(t,id)
		t[UnitName(id)] = select(2,UnitClass(id))
	end,
}

for k in pairs(refreshFuncs) do 
	Roster[k] = {}
end

local numOnline = 0
local numMembers = 0
local prevGroupType = "NONE"
local RosterHandle
addon.GroupType = "NONE"
function addon:RAID_ROSTER_UPDATE()
	--@debug@
	debug("RAID_ROSTER_UPDATE","Invoked")
	--@end-debug@

	local tmpOnline,tmpMembers = 0,GetNumRaidMembers()
	if tmpMembers > 0 then
		addon.GroupType = "RAID"
	else
		tmpMembers = GetNumPartyMembers()
		addon.GroupType = tmpMembers > 0 and "PARTY" or "NONE"
	end

	-- Switches to default if we leave a group
	if prevGroupType ~= "NONE" and addon.GroupType == "NONE" then
		self:SetActiveEncounter("default")
	end
	prevGroupType = addon.GroupType

	if not RosterHandle and tmpMembers > 0 then
		-- Refresh roster tables every half minute to detect offline players
		RosterHandle = self:ScheduleRepeatingTimer("RAID_ROSTER_UPDATE",30)
	elseif tmpMembers == 0 then
		self:CancelTimer(RosterHandle,true)
		RosterHandle = nil
	end

	for k,t in pairs(Roster) do 
		wipe(t)
		refreshFuncs[k](t,"player")
	end

	if addon.GroupType == "RAID" then
		for i=1,tmpMembers do
			local name, rank, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online then
				local unit = rID[i]
				tmpOnline = tmpOnline + 1
				for k,t in pairs(Roster) do
					refreshFuncs[k](t,unit)
				end
			end
		end
	elseif addon.GroupType == "PARTY" then
		for i=1,tmpMembers do
			local name,online = UnitName(pID[i]),UnitIsConnected(pID[i])
			if online then
				local unit = pID[i]
				--@debug@
				debug("PARTY_MEMBERS_CHANGED","name: %s unit: %s guid: %s",name,unit,UnitGUID(unit))
				--@end-debug@
				tmpOnline = tmpOnline + 1
				for k,t in pairs(Roster) do
					refreshFuncs[k](t,unit)
				end
			end
		end
	end

	--- Number of member differences

	if tmpMembers ~= numMembers then
		self:UpdatePaneVisibility()
		self:RefreshVersionList()
	end

	numMembers = tmpMembers

	--- Number of ONLINE member differences

	--[[
	if tmpOnline > numOnline then
	end
	]]

	if tmpOnline < numOnline then
		self:CleanVersions()
	end

	numOnline = tmpOnline
end

function addon:IsPromoted()
	return IsRaidLeader() or IsRaidOfficer()
end

---------------------------------------------
-- TRIGGERING
---------------------------------------------

local TRGS_NPCID = {} -- NPC ids activations. Source: data.triggers.scan
local TRGS_YELL = {} -- Yell activations. Source: data.triggers.yell

do
	local function add_data(tbl,info,key)
		if type(info) == "table" then
			-- Info contains ids
			for _,id in ipairs(info) do
				tbl[id] = key
			end
		else
			-- Info is the id
			tbl[info] = key
		end
	end

	local function BuildTriggerLists()
		local zone = GetRealZoneText()
		local scanFlag,yellFlag = false,false
		for key, data in addon:IterateEDB() do
			if data.zone == zone then
				if data.triggers then
					local scan = data.triggers.scan
					if scan then 
						add_data(TRGS_NPCID,scan,key)
						scanFlag = true
					end
					local yell = data.triggers.yell
					if yell then 
						add_data(TRGS_YELL,yell,key) 
						yellFlag = true
					end
				end
			end
		end
		return scanFlag,yellFlag
	end

	local ScanHandle
	function addon:PauseScanning() 
		if ScanHandle then self:CancelTimer(ScanHandle); ScanHandle = nil end 
	end

	function addon:ResumeScanning() 
		if not ScanHandle then ScanHandle = self:ScheduleRepeatingTimer("ScanUpdate",5) end 
	end

	function addon:UpdateTriggers()
		-- Clear trigger tables
		wipe(TRGS_NPCID)
		wipe(TRGS_YELL)
		self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
		self:CancelTimer(ScanHandle,true)
		ScanHandle = nil
		-- Build trigger lists
		local scan, yell = BuildTriggerLists()
		self.TriggerZone = scan or yell
		-- Start invokers
		if scan then ScanHandle = self:ScheduleRepeatingTimer("ScanUpdate",5) end
		if yell then self:RegisterEvent("CHAT_MSG_MONSTER_YELL") end
	end
	addon:ThrottleFunc("UpdateTriggers",1,true)
end


function addon:Scan()
	for _,unit in pairs(Roster.unit_to_unittarget) do
		if UnitExists(unit) then
			local guid = UnitGUID(unit)
			local npcid = NID[guid]
			if TRGS_NPCID[npcid] and not UnitIsDead(unit) then
				return TRGS_NPCID[npcid]
			end
		end
	end
end

function addon:ScanUpdate()
	local key = self:Scan()
	if key then self:SetActiveEncounter(key) end
end

---------------------------------------------
-- PLAYER CONSTANTS
---------------------------------------------

function addon:SetPGUID(n)
	if n == 0 then return end
	self.PGUID = UnitGUID("player")
	if not self.PGUID then self:ScheduleTimer("SetPGUID",1,n-1) end
end

function addon:SetPlayerConstants()
	self.PGUID = UnitGUID("player")
	-- Just to be safe
	if not self.PGUID then self:ScheduleTimer("SetPGUID",1,5) end
	self.PNAME = UnitName("player")
end

---------------------------------------------
-- GENERIC EVENTS
---------------------------------------------

function addon:PLAYER_ENTERING_WORLD()
	self:UpdatePaneVisibility()
	self:UpdateTriggers()
	self:StopEncounter()
end

---------------------------------------------
-- WARNING BLOCKS
-- Credits: BigWigs
---------------------------------------------

local forceBlockDisable

function addon:AddMessageFilters()
	local OTHER_BOSS_MOD_PTN = "%*%*%*"
	local OTHER_BOSS_MOD_PTN2 = "DBM"

	local RaidWarningFrame_OnEvent = RaidWarningFrame:GetScript("OnEvent")
	RaidWarningFrame:SetScript("OnEvent", function(self,event,msg,...)
		if not forceBlockDisable and pfl.Misc.BlockRaidWarningFrame and 
			type(msg) == "string" and (find(msg,OTHER_BOSS_MOD_PTN) or find(msg,OTHER_BOSS_MOD_PTN2))then
			-- Do nothing
		else
			return RaidWarningFrame_OnEvent(self,event,msg,...)
		end
	end)

	local RaidBossEmoteFrame_OnEvent = RaidBossEmoteFrame:GetScript("OnEvent")
	RaidBossEmoteFrame:SetScript("OnEvent", function(self,event,msg,name,...)
		if not forceBlockDisable and pfl.Misc.BlockBossEmoteFrame
			and type(name) == "string" and addon.TriggerZone then
			-- Do nothing
		else
			return RaidBossEmoteFrame_OnEvent(self,event,msg,name,...)
		end
	end)

	local function OTHER_BOSS_MOD_FILTER(self,event,msg)
		if not forceBlockDisable and pfl.Misc.BlockRaidWarningMessages
			and type(msg) == "string" and (find(msg,OTHER_BOSS_MOD_PTN) or find(msg,OTHER_BOSS_MOD_PTN2)) then 
			return true 
		end
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", OTHER_BOSS_MOD_FILTER)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", OTHER_BOSS_MOD_FILTER)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", OTHER_BOSS_MOD_FILTER)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", OTHER_BOSS_MOD_FILTER)

	local function RAID_BOSS_FILTER(self,event,msg,name)
		if not forceBlockDisable and pfl.Misc.BlockBossEmoteMessages
			and type(name) == "string" and addon.TriggerZone then
			return true
		end
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE",RAID_BOSS_FILTER)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_WHISPER",RAID_BOSS_FILTER)

	self.AddMessageFilters = nil
end

---------------------------------------------
-- MAIN
---------------------------------------------


-- Replace default Print
local print,format = print,string.format
function addon:Print(s)
	print(format("|cff99ff33DXE|r: %s",s)) -- 0.6, 1, 0.2
end

do
	local funcs = {}
	function addon:AddToRefreshProfile(func)
		--@debug@
		assert(type(func) == "function")
		--@end-debug@
		funcs[#funcs+1] = func
	end

	function addon:RefreshProfilePointers()
		for k,func in ipairs(funcs) do func(db) end
	end

	function addon:RefreshProfile()
		pfl = db.profile
		self:RefreshProfilePointers()
		
		self:LoadAllPositions()
		self.Pane:SetScale(pfl.Pane.Scale)
		self:LayoutHealthWatchers()
		self:SkinPane()
		self:UpdatePaneVisibility()

		self[pfl.Enabled and "Enable" or "Disable"](self)
	end
end

-- Initialization
function addon:OnInitialize()
	Initialized = true

	-- Database
	self.db = LibStub("AceDB-3.0"):New("DXEDB",self.defaults)
	db = self.db
	gbl,pfl = db.global,db.profile

	self:RefreshProfilePointers()

	-- Options
	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

	--@debug@
	debug = self:CreateDebugger("Core",gbl,debugDefaults)
	--@end-debug@

	-- Received database
	RDB = self.db:RegisterNamespace("RDB", {global = {}}).global
	self.RDB = RDB

	-- Pane
	self:CreatePane()
	self:SkinPane()

	self:SetupSlashCommands()

	-- The default encounter
	self:RegisterEncounter({key = "default", name = L["Default"], title = L["Default"]})
	self:SetActiveEncounter("default")

	--@debug@
	-- Register addon/received encounter data
	for key,data in pairs(RegisterQueue) do
		if RDB[key] and RDB[key].version > data.version then
			self:RegisterEncounter(RDB[key])
		else
			self:RegisterEncounter(data)
			RDB[key] = nil
		end

		RegisterQueue[key] = nil
	end
	--@end-debug@

	-- The rest that don't exist
	for key,data in pairs(RDB) do
		-- nil out old RDB data that uses data.name as the key
		if key:find("[A-Z]") then
			RDB[key] = nil
		elseif not EDB[key] then
			self:RegisterEncounter(data)
		end
	end

	RegisterQueue = nil

	self:AddMessageFilters()

	self:SetEnabledState(pfl.Enabled)
	self:Print(L["Loaded - Type |cffffff00/dxe|r for slash commands"])
	self.OnInitialize = nil
end

function addon:OnEnable()
	-- Patch to refresh Pane texture
	self:NotifyBarTextureChanged(pfl.Globals.BarTexture)
	self:NotifyFontChanged(pfl.Globals.Font)
	self:NotifyBorderChanged(pfl.Globals.Border)

	forceBlockDisable = false
	self:SetPlayerConstants()
	self:UpdateTriggers()
	self:UpdateLock()
	self:LayoutHealthWatchers()

	-- Events
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED","RAID_ROSTER_UPDATE")
	self:RAID_ROSTER_UPDATE()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA","UpdateTriggers")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:SetActiveEncounter("default")
	self:EnableAllModules()
	self:RegisterComm("DXE")
	self:UpdatePaneVisibility()
end

function addon:OnDisable()
	forceBlockDisable = true
	self:UpdateLockedFrames("Hide")
	self:StopEncounter()
	self:SetActiveEncounter("default")
	self.Pane:Hide()
	self:DisableAllModules()
	RosterHandle = nil
end

function addon:RefreshDefaults()
	self.db:RegisterDefaults(defaults)
end

---------------------------------------------
-- POSITIONING + DIMENSIONS
---------------------------------------------

do
	local frameNames = {}

	function addon:SavePosition(f,dims)
		local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
		local name = f:GetName()
		local pos = pfl.Positions[name]
		pos.point = point
		pos.relativeTo = relativeTo and relativeTo:GetName()
		pos.relativePoint = relativePoint
		pos.xOfs = xOfs
		pos.yOfs = yOfs
		if dims then
			pos.width = f:GetWidth()
			pos.height = f:GetHeight()
		end
		f:SetUserPlaced(false)
	end

	-- Used after the profile is changed
	function addon:LoadAllPositions()
		for name in pairs(frameNames) do
			self:LoadPosition(name)
		end
	end

	function addon:LoadPosition(name)
		local f = _G[name]
		if not f then return end
		frameNames[name] = true
		f:ClearAllPoints()
		local pos = pfl.Positions[name]
		if not pos then
			f:SetPoint("CENTER",UIParent,"CENTER",0,0)
			pfl.Positions[name] = {
				point = "CENTER",
				relativeTo = "UIParent",
				relativePoint = "CENTER",
				xOfs = 0,
				yOfs = 0,
			}
		else
			f:SetPoint(pos.point,_G[pos.relativeTo] or UIParent,pos.relativePoint,pos.xOfs,pos.yOfs)
			if pos.width and pos.height then
				f:SetWidth(pos.width)
				f:SetHeight(pos.height)
			end
		end
	end

	local function StartMovingShift(self)
		if IsShiftKeyDown() then
			if self.__redirect then
				self.__redirect:StartMoving()
			else
				self:StartMoving()
			end
		end
	end

	local function StartMoving(self)
		if self.__redirect then
			self.__redirect:StartMoving()
		else
			self:StartMoving()
		end
	end

	local function StopMoving(self)
		if self.__redirect then
			self.__redirect:StopMovingOrSizing()
			addon:SavePosition(self.__redirect,self.__dims)
		else
			self:StopMovingOrSizing()
			addon:SavePosition(self,self.__dims)
		end
	end

	-- Registers saving positions in database
	function addon:RegisterMoveSaving(frame,point,relativeTo,relativePoint,xOfs,yOfs,withShift,redirect,dims)
		--@debug@
		assert(type(frame) == "table","expected 'frame' to be a table")
		assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
		if redirect then
			assert(type(redirect) == "table","expected 'redirect' to be a table")
			assert(redirect.IsObjectType and redirect:IsObjectType("Region"),"'frame' is not a blizzard frame")
		end
		--@end-debug@
		frame.__redirect = redirect
		frame.__dims = dims
		if withShift then
			frame:SetScript("OnMouseDown",StartMovingShift)
		else
			frame:SetScript("OnMouseDown",StartMoving)
		end
		frame:SetScript("OnMouseUp",StopMoving)

		-- Add default position
		local pos = {
			point = point,
			relativeTo = relativeTo,
			relativePoint = relativePoint,
			xOfs = xOfs,
			yOfs = yOfs,
		}

		if dims then
			pos.width = redirect and redirect:GetWidth() or frame:GetWidth()
			pos.height = redirect and redirect:GetHeight() or frame:GetHeight()
		end

		defaults.profile.Positions[redirect and redirect:GetName() or frame:GetName()] = pos
		self:RefreshDefaults()
	end
end

---------------------------------------------
-- TOOLTIP TEXT
---------------------------------------------

do
	local function OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self._ttTitle then GameTooltip:AddLine(self._ttTitle,nil,nil,nil,true) end
		if self._ttText then GameTooltip:AddLine(self._ttText,1,1,1,true) end
		GameTooltip:Show()
	end

	local function OnLeave(self)
		GameTooltip:Hide()
	end

	function addon:AddTooltipText(obj,title,text)
		obj._ttTitle = title
		obj._ttText = text
		obj:HookScript("OnEnter",OnEnter)
		obj:HookScript("OnLeave",OnLeave) 
	end
end

---------------------------------------------
-- PANE
---------------------------------------------
local Pane

function addon:ToggleConfig()
	--[===[@non-debug@
	if select(6,GetAddOnInfo("DXE_Options")) == "MISSING" then self:Print((L["Missing %s"]):format("DXE_Options")) return end
	if not IsAddOnLoaded("DXE_Options") then self.Loader:Load("DXE_Options") end
	--@end-non-debug@]===]
	addon.Options:ToggleConfig()
end

function addon:ScalePaneAndCenter()
	local x,y = Pane:GetCenter()
	local escale = Pane:GetEffectiveScale()
	x,y = x*escale,y*escale
	Pane:SetScale(pfl.Pane.Scale)
	escale = Pane:GetEffectiveScale()
	x,y = x/escale,y/escale
	Pane:ClearAllPoints()
	Pane:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y)
	addon:SavePosition(Pane)
end

do
	function addon:UpdatePaneVisibility()
		if pfl.Pane.Show then
			local op = 0
			local instanceType = select(2,IsInInstance())
			op = op + (pfl.Pane.OnlyInRaid and (addon.GroupType == "RAID"	and 1  or 0) or 1)
			op = op + (pfl.Pane.OnlyInParty and ((addon.GroupType == "PARTY" or addon.GroupType == "RAID") and 2 or 0) or  2)
			op = op + (pfl.Pane.OnlyInRaidInstance	and (instanceType == "raid" and 4  or 0) or 4)
			op = op + (pfl.Pane.OnlyInPartyInstance and (instanceType == "party"	and 8  or 0) or 8)
			op = op + (pfl.Pane.OnlyIfRunning and (self:IsRunning() and 16 or 0) or 16)
			local show = op == 31
			Pane[show and "Show" or "Hide"](Pane)

			-- Fading
			UIFrameFadeRemoveFrame(Pane)
			local fadeTable = Pane.fadeTable
			fadeTable.fadeTimer = 0
			local a = pfl.Pane.OnlyOnMouseover and (addon.Pane.MouseIsOver and 1 or 0) or 1
			local p_a = Pane:GetAlpha()
			if not show and p_a > 0 then
				fadeTable.startAlpha = p_a
				fadeTable.endAlpha = 0
				fadeTable.finishedFunc = Pane.Hide
				UIFrameFade(Pane,fadeTable)
			elseif show and a ~= p_a then
				fadeTable.startAlpha = p_a
				fadeTable.endAlpha = a
				UIFrameFade(Pane,fadeTable)
			end
		else
			self.Pane:SetAlpha(0)
			self.Pane:Hide()
		end
	end
end

do
	local size = 17
	local buttons = {}
	--- Adds a button to the encounter pane
	-- @param normal The normal texture for the button
	-- @param highlight The highlight texture for the button
	-- @param onclick The function of the OnClick script
	-- @param anchor SetPoints the control LEFT, anchor, RIGHT
	function addon:AddPaneButton(normal,highlight,OnClick,name,text)
		local control = CreateFrame("Button",nil,self.Pane)
		control:SetWidth(size)
		control:SetHeight(size)
		control:SetPoint("LEFT",buttons[#buttons] or self.Pane.timer,"RIGHT")
		control:SetScript("OnClick",OnClick)
		control:RegisterForClicks("AnyUp")
		control:SetNormalTexture(normal)
		control:SetHighlightTexture(highlight)
		self:AddTooltipText(control,name,text)
		control:HookScript("OnEnter",function(self) addon.Pane.MouseIsOver = true; addon:UpdatePaneVisibility() end)
		control:HookScript("OnLeave",function(self) addon.Pane.MouseIsOver = false; addon:UpdatePaneVisibility()end)

		buttons[#buttons+1] = control
		return control
	end
end

-- Idea based off RDX's Pane
function addon:CreatePane()
	Pane = CreateFrame("Frame","DXEPane",UIParent)
	Pane:SetAlpha(0)
	Pane:Hide()
	Pane:SetClampedToScreen(true)
	addon:RegisterBackground(Pane)
	Pane.border = CreateFrame("Frame",nil,Pane)
	Pane.border:SetAllPoints(true)
	addon:RegisterBorder(Pane.border)
	Pane:SetWidth(220)
	Pane:SetHeight(25)
	Pane:EnableMouse(true)
	Pane:SetMovable(true)
	Pane:SetPoint("CENTER")
	Pane:SetScale(pfl.Pane.Scale)
	self:RegisterMoveSaving(Pane,"CENTER","UIParent","CENTER",nil,nil,true)
	self:LoadPosition("DXEPane")
	Pane:SetUserPlaced(false)
	self:AddTooltipText(Pane,"Pane",L["|cffffff00Shift + Click|r to move"])
	local function OnUpdate() addon:LayoutHealthWatchers() end
	Pane:HookScript("OnMouseDown",function(self) self:SetScript("OnUpdate",OnUpdate) end)
	Pane:HookScript("OnMouseUp",function(self) self:SetScript("OnUpdate",nil) end)
	Pane:HookScript("OnEnter",function(self) self.MouseIsOver = true; addon:UpdatePaneVisibility() end)
	Pane:HookScript("OnLeave",function(self) self.MouseIsOver = false; addon:UpdatePaneVisibility() end)
	Pane.fadeTable = {timeToFade = 0.5, finishedArg1 = Pane}
  	self.Pane = Pane
	
	Pane.timer = addon.Timer:New(Pane)
	Pane.timer:SetPoint("BOTTOMLEFT",5,2)
	Pane.timer.left:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",19)
	Pane.timer.right:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",11)

	local PaneTextures = "Interface\\AddOns\\DXE\\Textures\\Pane\\"

	-- Add StartStop control
	Pane.startStop = self:AddPaneButton(
		PaneTextures.."Stop",
		PaneTextures.."Stop",
		function(self,button) 
			if button == "LeftButton" then
				addon:StopEncounter() 
			elseif button == "RightButton" then
				addon.Alerts:QuashByPattern("^custom")
			end
		end,
		L["Stop"],
		L["|cffffff00Click|r stops the current encounter"].."\n"..L["|cffffff00Right-Click|r stops all custom bars"]
	)
	
	-- Add Config control
	Pane.config = self:AddPaneButton(
		PaneTextures.."Menu",
		PaneTextures.."Menu",
		function() self:ToggleConfig() end,
		L["Configuration"],
		L["Toggles the settings window"]
	)

	-- Create dropdown menu for folder
	local selector = self:CreateSelectorDropDown()
	Pane.SetFolderValue = function(key)
		UIDropDownMenu_SetSelectedValue(selector,key)
	end
	-- Add Folder control
	Pane.folder = self:AddPaneButton(
		PaneTextures.."Folder",
		PaneTextures.."Folder",
		function() ToggleDropDownMenu(1,nil,selector,Pane.folder,0,0) end,
		L["Selector"],
		L["Activates an encounter"]
	)

	Pane.lock = self:AddPaneButton(
		PaneTextures.."Locked",
		PaneTextures.."Locked",
		function() self:ToggleLock() end,
		L["Locking"],
		L["Toggle frame anchors"]
	)

	local windows = self:CreateWindowsDropDown()
	Pane.windows = self:AddPaneButton(
		PaneTextures.."Windows",
		PaneTextures.."Windows",
		function() ToggleDropDownMenu(1,nil,windows,Pane.windows,0,0) end,
		L["Windows"],
		L["Make windows visible"]
	)

	self:CreateHealthWatchers(Pane)

	self.CreatePane = nil
end

function addon:SkinPane()
	local db = pfl.Pane

	-- Health watchers
	for i,hw in ipairs(addon.HW) do
		hw:SetNeutralColor(db.NeutralColor)
		hw:SetLostColor(db.LostColor)
		hw:ApplyNeutralColor()

		hw.title:SetFont(hw.title:GetFont(),db.TitleFontSize)
		hw.title:SetVertexColor(unpack(db.FontColor))
		hw.health:SetFont(hw.health:GetFont(),db.HealthFontSize)
		hw.health:SetVertexColor(unpack(db.FontColor))
	end
end

---------------------------------------------
-- HEALTH WATCHERS
---------------------------------------------
local HW = {}
addon.HW = HW
local DEAD = DEAD:upper()

-- Holds a list of tables
-- Each table t has three values
-- t[1] = npcid
-- t[2] = last known perc
local SortedCache = {}
local SeenNIDS = {}
--@debug@
addon.SortedCache = SortedCache
addon.SeenNIDS = SeenNIDS
--@end-debug@

-- Currently, only four are needed. We don't want to clutter the screen
local UNKNOWN = _G.UNKNOWN
function addon:CreateHealthWatchers(Pane)
	local function OnMouseDown() if IsShiftKeyDown() then Pane:StartMoving() end end
	local function OnMouseUp() Pane:StopMovingOrSizing(); addon:SavePosition(Pane) end

	local function OnAcquired(self,event,unit) 
		local goal = self:GetGoal()
		if not self:IsTitleSet() then
			if type(goal) == "number" then
				-- Should only enter once per name
				local name = UnitName(unit)
				if name ~= UNKNOWN then
					gbl.L_NPC[goal] = name
					self:SetTitle(name)
				end
			elseif type(goal) == "string" then
				local name = UnitName(goal)
				if name ~= UNKNOWN then
					self:SetTitle(name)
				end
			end
		end
		addon.callbacks:Fire("HW_TRACER_ACQUIRED",unit,goal) 
	end

	for i=1,4 do 
		local hw = addon.HealthWatcher:New(Pane)
		self:AddTooltipText(hw,"Pane",L["|cffffff00Shift + Click|r to move"])
		hw:HookScript("OnEnter",function(self) Pane.MouseIsOver = true; addon:UpdatePaneVisibility() end)
		hw:HookScript("OnLeave",function(self) Pane.MouseIsOver = false; addon:UpdatePaneVisibility()end)
		hw:SetScript("OnMouseDown",OnMouseDown)
		hw:SetScript("OnMouseUp",OnMouseUp)
		hw:SetParent(Pane)
		hw:SetCallback("HW_TRACER_ACQUIRED",OnAcquired) 
		HW[i] = hw
	end

	-- Only the main one sends updates
	HW[1]:SetCallback("HW_TRACER_UPDATE",function(self,event,unit) addon:TRACER_UPDATE(unit) end)
	HW[1]:EnableUpdates()
	self.CreateHealthWatchers = nil
end

function addon:CloseAllHW()
	for i=1,4 do HW[i]:Close(); HW[i]:Hide() end
end

function addon:ShowFirstHW()
	if not HW[1]:IsShown() then
		HW[1]:SetInfoBundle("",1)
		HW[1]:ApplyNeutralColor()
		HW[1]:SetTitle(CE.title)
		HW[1]:Show()
	end
end

do
	local n = 0
	local handle
	local e = 1e-10
	local UNACQUIRED = 1

	--[[
	Convert percentages to negatives so we can achieve something like
		HW[4] => Neutral color
		HW[3] => DEAD
		HW[2] => DEAD
		HW[1] => 56%
	]]

	-- Stable sort by comparing npc ids
	-- When comparing two percentages we convert back to positives
	local function sortFunc(a,b)
		local v1,v2 = a[2],b[2] -- health perc
		if v1 == v2 then
			return a[1] < b[1] -- npc ids
		elseif v1 < 0 and v2 < 0 then 
			return -v1 < -v2
		else 
			return v1 < v2 
		end
	end

	local function Execute()
		for _,unit in pairs(Roster.unit_to_unittarget) do
			-- unit could not exist and still return a valid guid
			if UnitExists(unit) then
				local npcid = NID[UnitGUID(unit)]
				if npcid then 
					SeenNIDS[npcid] = true
					local k = search(SortedCache,npcid,1)
					if k then
						local h,hm = UnitHealth(unit),UnitHealthMax(unit)
						if hm == 0 then hm = 1 end
						SortedCache[k][2] = -(h / hm)
					end
				end
			end
		end

		sort(SortedCache,sortFunc)

		local flag -- Whether or not we should layout health watchers
		for i=1,n do
			if i <= 4 then
				local hw,info = HW[i],SortedCache[i]
				local npcid,perc = info[1],info[2]
				-- Conditional is entered sparsely during a fight
				if perc ~= UNACQUIRED and hw:GetGoal() ~= npcid and SeenNIDS[npcid] then
					hw:SetTitle(gbl.L_NPC[npcid] or "...")
					-- Has been acquired
					if perc then
						if perc < 0 then
							hw:SetInfoBundle(format("%0.0f%%", -perc*100), -perc)
							hw:ApplyLostColor()
						else
							hw:SetInfoBundle(DEAD,0)
						end
					-- Hasn't been acquired
					else
						hw:SetInfoBundle("",1)
						hw:ApplyNeutralColor()
					end
					hw:Track("npcid",npcid)
					hw:Open()
					if not hw:IsShown() then 
						hw:Show()
						flag = true
					end
				end
			else break end
		end
		if flag then addon:LayoutHealthWatchers() end
	end

	function addon:StartSortedTracing()
		if n == 0 or handle then return end
		handle = self:ScheduleRepeatingTimer(Execute,0.5)
	end

	function addon:StopSortedTracing()
		if not handle then return end
		self:CancelTimer(handle,true)
		handle = nil
	end

	function addon:ClearSortedTracing()
		wipe(SeenNIDS)
		for i in ipairs(SortedCache) do
			SortedCache[i][2] = UNACQUIRED
		end
	end

	function addon:ResetSortedTracing()
		wipe(SeenNIDS)
		self:StopSortedTracing()
		for i in ipairs(SortedCache) do
			SortedCache[i][1] = nil
			SortedCache[i][2] = UNACQUIRED
		end
		n = 0
	end

	function addon:SetSortedTracing(npcids)
		if not npcids then return end
		n = #npcids
		for i,npcid in ipairs(npcids) do 
			SortedCache[i] = SortedCache[i] or {}
			SortedCache[i][1] = npcid
			SortedCache[i][2] = UNACQUIRED
		end
		for i=n+1,#SortedCache do SortedCache[i] = nil end
	end
end

function addon:SetTracing(targets)
	if not targets then return end
	self:ResetSortedTracing()
	local n = 0
	for i,tgt in ipairs(targets) do
		-- Prevents overwriting
		local hw = HW[i]
		if hw:GetGoal() ~= tgt then
			hw:SetTitle(gbl.L_NPC[tgt] or "...")
			hw:SetInfoBundle("",1)
			hw:ApplyNeutralColor()
			if type(tgt) == "number" then
				hw:Track("npcid",tgt)
			elseif type(tgt) == "string" then
				hw:Track("unit",tgt)
			end
			hw:Open()
			hw:Show()
		end
		n = n + 1
	end
	for i=n+1,4 do
		HW[i]:Close()
		HW[i]:Hide()
	end
	self:LayoutHealthWatchers()
end

function addon:LayoutHealthWatchers()
	local anchor,point,relpoint = Pane
	local growth = pfl.Pane.BarGrowth
	if growth == "AUTOMATIC" then
		local midY = (GetScreenHeight()/2)*UIParent:GetEffectiveScale()
		local x,y = Pane:GetCenter()
		local s = Pane:GetEffectiveScale()
		x,y = x*s,y*s
		point = y > midY and "TOP" or "BOTTOM"
		relpoint = y > midY and "BOTTOM" or "TOP"
	elseif growth == "UP" then
		point,relpoint = "BOTTOM","TOP"
	elseif growth == "DOWN" then
		point,relpoint = "TOP","BOTTOM"
	end
	for i,hw in ipairs(self.HW) do
		if hw:IsShown() then
			hw:ClearAllPoints()
			hw:SetPoint(point,anchor,relpoint)
			anchor = hw
		end
	end
end

do
	-- Throttling is needed because sometimes bosses pulsate in and out of combat at the start.
	-- UnitAffectingCombat can return false at the start even if the boss is moving towards a player.

	-- The time to wait (seconds) before it auto stops the encounter after auto starting
	local throttle = 5
	-- The last time the encounter was auto started + throttle time
	local last = 0
	function addon:TRACER_UPDATE(unit)
		local time,running = GetTime(),self:IsRunning()
		if self:IsTracerStart() and not running and UnitIsFriend(targetof[unit],"player") then
			self:StartEncounter()
			last = time + throttle
		elseif (UnitIsDead(unit) or not UnitAffectingCombat(unit)) and self:IsTracerStop() and running and last < time then
			self:StopEncounter() 
		end
	end
end

do
	local AutoStart,AutoStop
	function addon:SetTracerStart(val)
		AutoStart = not not val
	end

	function addon:SetTracerStop(val)
		AutoStop = not not val
	end

	function addon:IsTracerStart()
		return AutoStart
	end

	function addon:IsTracerStop()
		return AutoStop
	end
end

---------------------------------------------
-- LOCK
---------------------------------------------

do
	local LockableFrames = {}
	function addon:RegisterForLocking(frame)
		--@debug@
		assert(type(frame) == "table","expected 'frame' to be a table")
		assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
		--@end-debug@
		LockableFrames[frame] = true
		self:UpdateLockedFrames()
	end

	function addon:CreateLockableFrame(name,width,height,text)
		--@debug@
		assert(type(name) == "string","expected 'name' to be a string")
		assert(type(width) == "number" and width > 0,"expected 'width' to be a number > 0")
		assert(type(height) == "number" and height > 0,"expected 'height' to be a number > 0")
		assert(type(text) == "string","expected 'text' to be a string")
		--@end-debug@
		local frame = CreateFrame("Frame","DXE"..name,UIParent)
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetUserPlaced(false)
		addon:RegisterBackground(frame)
		frame.border = CreateFrame("Frame",nil,frame)
		frame.border:SetAllPoints(true)
		addon:RegisterBorder(frame.border)
		frame:SetWidth(width)
		frame:SetHeight(height)
		LockableFrames[frame] = true
		self:UpdateLockedFrames()
		
		local desc = frame:CreateFontString(nil,"ARTWORK")
		desc:SetShadowOffset(1,-1)
		desc:SetPoint("BOTTOM",frame,"TOP")
		self:RegisterFontString(desc,9)
		desc:SetText(text)
		return frame
	end

	function addon:UpdateLock()
		self:UpdateLockedFrames()
		if gbl.Locked then
			self:SetLocked()
		else
			self:SetUnlocked()
		end
	end

	function addon:ToggleLock()
		gbl.Locked = not gbl.Locked
		self:UpdateLock()
	end

	function addon:UpdateLockedFrames(func)
		func = func or (gbl.Locked and "Hide" or "Show")
		for frame in pairs(LockableFrames) do frame[func](frame) end
	end

	function addon:SetLocked()
		self.Pane.lock:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Locked")
		self.Pane.lock:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Locked")
	end

	function addon:SetUnlocked()
		self.Pane.lock:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Unlocked")
		self.Pane.lock:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Unlocked")
	end
end

---------------------------------------------
-- SELECTOR
---------------------------------------------

do
	local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
	local function closeall() CloseDropDownMenus(1) end

	local function OnClick(self)
		addon:SetActiveEncounter(self.value)
		CloseDropDownMenus()
	end

	local YELLOW = "|cffffff00"

	local work,list = {},{}
	local info

	local function Initialize(self,level)
		wipe(work)
		wipe(list)

		level = level or 1

		if level == 1 then
			info = UIDropDownMenu_CreateInfo()
			info.isTitle = true 
			info.text = L["Encounter Selector"]
			info.notCheckable = true 
			info.justifyH = "LEFT"
			UIDropDownMenu_AddButton(info,1)

			info = UIDropDownMenu_CreateInfo()
			info.text = L["Default"]
			info.value = "default"
			info.func = OnClick
			info.colorCode = YELLOW
			info.owner = self
			UIDropDownMenu_AddButton(info,1)

			for key,data in addon:IterateEDB() do
				work[data.category or data.zone] = true
			end
			for cat in pairs(work) do
				list[#list+1] = cat
			end

			sort(list)

			for _,cat in ipairs(list) do
				info = UIDropDownMenu_CreateInfo()
				info.text = cat
				info.value = cat
				info.hasArrow = true
				info.notCheckable = true
				info.owner = self
				UIDropDownMenu_AddButton(info,1)
			end

			info = UIDropDownMenu_CreateInfo()
			info.notCheckable = true 
			info.justifyH = "LEFT"
			info.text = L["Cancel"]
			info.func = closeall
			UIDropDownMenu_AddButton(info,1)
		elseif level == 2 then
			local cat = UIDROPDOWNMENU_MENU_VALUE

			for key,data in addon:IterateEDB() do
				if (data.category or data.zone) == cat then
					list[#list+1] = data.name
					work[data.name] = key
				end
			end

			sort(list)

			for _,name in ipairs(list) do
				info = UIDropDownMenu_CreateInfo()
				info.hasArrow = false
				info.text = name
				info.owner = self
				info.value = work[name]
				info.func = OnClick
				UIDropDownMenu_AddButton(info,2)
			end
		end
	end

	function addon:CreateSelectorDropDown()
		local selector = CreateFrame("Frame", "DXEPaneSelector", UIParent, "UIDropDownMenuTemplate") 
		UIDropDownMenu_Initialize(selector, Initialize, "MENU")
		UIDropDownMenu_SetSelectedValue(selector,"default")
		return selector
	end
end

---------------------------------------------
-- PANE FUNCTIONS
---------------------------------------------
do
	local isRunning,elapsedTime

	-- @return number >= 0
	function addon:GetElapsedTime()
		return elapsedTime
	end

	--- Returns whether or not the timer is running
	-- @return A boolean
	function addon:IsRunning()
		return isRunning
	end

	local function OnUpdate(self,elapsed)
		elapsedTime = elapsedTime + elapsed
		self:SetTime(elapsedTime)
	end

	--- Starts the Pane timer
	function addon:StartTimer()
		elapsedTime = 0
		self.Pane.timer:SetScript("OnUpdate",OnUpdate)
		isRunning = true
	end

	--- Stops the Pane timer
	function addon:StopTimer()
		self.Pane.timer:SetScript("OnUpdate",nil)
		isRunning = false
	end

	--- Resets the Pane timer
	function addon:ResetTimer()
		elapsedTime = 0
		self.Pane.timer:SetTime(0)
	end
end

---------------------------------------------
-- REGEN START/STOPPING
---------------------------------------------

local dead
-- PLAYER_REGEN_ENABLED
function addon:CombatStop()
	--@debug@
	debug("CombatStop","Invoked")
	--@end-debug@
	if UnitHealth("player") > 0 and not UnitAffectingCombat("player") then
		-- If this doesn't work then scan the raid for units in combat
		if dead then
			self:ScheduleTimer("CombatStop",4)
			dead = nil
			return
		end
		local key = self:Scan()
		if not key then
			self:StopEncounter()	
			return
		end
		self:ScheduleTimer("CombatStop",2)
	elseif UnitIsDead("player") then
		dead = true
		self:ScheduleTimer("CombatStop",2)
	end
end

-- PLAYER_REGEN_DISABLED
function addon:CombatStart()
	local key = self:Scan()
	if key then 
		self:StartEncounter()
	elseif UnitAffectingCombat("player") then
		self:ScheduleTimer("CombatStart", 0.2)
	end
end

---------------------------------------------
-- COMMS
---------------------------------------------

function addon:SendWhisperComm(target,commType,...)
	--@debug@
	assert(type(target) == "string")
	assert(type(commType) == "string")
	--@end-debug@
	self:SendCommMessage("DXE",self:Serialize(commType,...),"WHISPER",target)
end

function addon:SendRaidComm(commType,...)
	--@debug@
	assert(type(commType) == "string")
	--@end-debug@
	if addon.GroupType == "NONE" then return end
	self:SendCommMessage("DXE",self:Serialize(commType,...),addon.GroupType)
end

function addon:OnCommReceived(prefix, msg, dist, sender)
	if (dist ~= "RAID" and dist ~= "PARTY" and dist ~= "WHISPER") or sender == self.PNAME then return end
	self:DispatchComm(sender, self:Deserialize(msg))
end

function addon:DispatchComm(sender,success,commType,...)
	if success then
		local callback = "OnComm"..commType
		self.callbacks:Fire(callback,commType,sender,...)
	end
end

---------------------------------------------
-- ENCOUNTER DEFAULTS
---------------------------------------------

do
	local EncDefaults = {
		alerts = { 
			L = L["Bars"], 
			order = 100, 
			defaultEnabled = true ,
			defaults = {
				color1 = "Clear",
				color2 = "Off",
				sound = "None",
				flashscreen = false,
				counter = false,
			},
		},
		raidicons = { 
			L = L["Raid Icons"], 
			order = 200, 
			defaultEnabled = true,
			defaults = {},
		},
		arrows = { 
			L = L["Arrows"], 
			order = 300, 
			defaultEnabled = true,
			defaults = {
				sound = "None",
			},
		},
		announces = {
			L = L["Announces"],
			order = 400,
			defaultEnabled = true,
			defaults = {},
		},

		-- always add options
		windows = {
			L = L["Windows"],
			order = 500,
			override = true,
			list = {
				proxwindow = {
					defaultEnabled = false,
					varname = L["Proximity"],
				},
			}
		}
	}

	addon.EncDefaults = EncDefaults

	function addon:AddEncounterDefaults(data)
		local defaults = {}
		self.defaults.profile.Encounters[data.key] = defaults

		------------------------------------------------------------
		-- Sound upgrading from versions < 375
		if pfl.Encounters[data.key] then
			for var,info in pairs(pfl.Encounters[data.key]) do
				if type(info) == "table" then
					if info.sound and info.sound:find("^DXE ALERT%d+") then
						info.sound = (info.sound:gsub("DXE ",""))
					end
				elseif type(info) == "boolean" then
					-- It should never be a boolean
					pfl.Encounters[data.key][var] = nil
				end
			end
		end
		------------------------------------------------------------
		
		for optionType,optionInfo in pairs(EncDefaults) do
			local optionData = data[optionType]
			if optionData and not optionInfo.override then
				for var,info in pairs(optionData) do
					defaults[var] = {}
					-- Add setting defaults
					defaults[var].enabled = optionInfo.defaultEnabled
					for k,varDefault in pairs(EncDefaults[optionType].defaults) do
						defaults[var][k] = info[k] or varDefault
					end
				end
			end
		end

		for var,winData in pairs(EncDefaults.windows.list) do
			defaults[var] = {}
			if data.windows and data.windows[var] then
				defaults[var].enabled = data.windows[var]
			else
				defaults[var].enabled = winData.defaultEnabled
			end
		end
	end
end

---------------------------------------------
-- SHARED EVENTS
---------------------------------------------

function addon:COMBAT_LOG_EVENT_UNFILTERED(_, _,eventtype, _, _, _, dstGUID)
	if eventtype ~= "UNIT_DIED" then return end
	local npcid = NID[dstGUID]
	if not npcid then return end

	-- Health watchers
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and hw:GetGoal() == npcid then
			hw:SetInfoBundle(DEAD,0)
			local k = search(SortedCache,npcid,1)
			if k then SortedCache[k][2] = 0 end
			break
		end
	end

	if not DEFEAT_NID then return end
	if DEFEAT_NID == npcid then 
		addon:TriggerDefeat()
	elseif DEFEAT_NIDS and DEFEAT_NIDS[npcid] == false then 
		DEFEAT_NIDS[npcid] = true
		local flag = true
		for k,v in pairs(DEFEAT_NIDS) do
			if not v then flag = false; break end
		end
		if flag then addon:TriggerDefeat() end
	end
end

function addon:CHAT_MSG_MONSTER_YELL(_,msg,...)
	--@debug@
	debug("CHAT_MSG_MONSTER_YELL",msg,...)
	--@end-debug@
	for fragment,key in pairs(TRGS_YELL) do
		if find(msg,fragment) then
			self:SetActiveEncounter(key)
			self:StopEncounter()
			self:StartEncounter(msg)
		end
	end
end

---------------------------------------------
-- SLASH COMMANDS
---------------------------------------------

function addon:SetupSlashCommands()
	DXE_SLASH_HANDLER = function(msg)
		local cmd = msg:match("[^ ]*"):lower()
		if cmd == L["enable"]:lower() then
			addon.db.profile.Enabled = true
			addon:Enable()
			local ACR = LibStub("AceConfigRegistry-3.0",true)
			if ACR then ACR:NotifyChange("DXE") end
		elseif cmd == L["disable"]:lower() then
			addon.db.profile.Enabled = false
			addon:Disable()
			local ACR = LibStub("AceConfigRegistry-3.0",true)
			if ACR then ACR:NotifyChange("DXE") end
		elseif cmd == L["config"]:lower() then
			addon:ToggleConfig()
		elseif cmd == L["version"]:lower() then
			addon:VersionCheck()
		elseif cmd == L["proximity"]:lower() then
			addon:Proximity()
		else
			ChatFrame1:AddMessage("|cff99ff33"..L["DXE Slash Commands"].."|r: |cffffff00/dxe|r |cffffd200<"..L["option"]..">|r")
			ChatFrame1:AddMessage(" |cffffd200"..L["enable"].."|r - "..L["Enable addon"])
			ChatFrame1:AddMessage(" |cffffd200"..L["disable"].."|r - "..L["Disable addon"])
			ChatFrame1:AddMessage(" |cffffd200"..L["config"].."|r - "..L["Toggles configuration"])
			ChatFrame1:AddMessage(" |cffffd200"..L["version"].."|r - "..L["Show version check window"])
			ChatFrame1:AddMessage(" |cffffd200"..L["proximity"].."|r - "..L["Show proximity window"])
		end
	end
	self.SetupSlashCommands = nil
end
