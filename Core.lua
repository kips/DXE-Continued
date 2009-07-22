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
}
--@end-debug@

local defaults = {
	global = {
		Enabled = true,
		Locked = true,
		PaneScale = 1, 
		ShowPane = true,
		PaneOnlyInRaid = false,
		PaneOnlyInInstance = false,
		PaneScale = 1,
		ShowMinimap = true,
		AdvancedMode = false,
		_Minimap = {},

		-- NPC id -> Localized name
		L_NPC = {},
		--@debug@
		debug = debugDefaults,
		--@end-debug@
	},
	profile = {
		Positions = {},
		Encounters = {},
	},
}

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local addon = LibStub("AceAddon-3.0"):NewAddon("DXE","AceEvent-3.0","AceTimer-3.0","AceConsole-3.0","AceComm-3.0","AceSerializer-3.0")
_G.DXE = addon
addon.version = tonumber(("$Rev$"):match("%d+"))
addon:SetDefaultModuleState(false)
addon.callbacks = LibStub("CallbackHandler-1.0"):New(addon)
addon.defaults = defaults


---------------------------------------------
-- UPVALUES
---------------------------------------------

local wipe,concat,remove = table.wipe,table.concat,table.remove
local match,find,gmatch,sub,split,join = string.match,string.find,string.gmatch,string.sub,string.split,string.join
local _G,select,tostring,type,tonumber = _G,select,tostring,type,tonumber
local GetTime,GetNumRaidMembers,GetRaidRosterInfo = GetTime,GetNumRaidMembers,GetRaidRosterInfo
local UnitName,UnitGUID,UnitIsEnemy,UnitClass,UnitAffectingCombat,UnitHealth,UnitIsFriend,UnitIsDead = 
		UnitName,UnitGUID,UnitIsEnemy,UnitClass,UnitAffectingCombat,UnitHealth,UnitIsFriend,UnitIsDead

local db,gbl,pfl

---------------------------------------------
-- LIBS
---------------------------------------------

local ACD = LibStub("AceConfigDialog-3.0")
local AC = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceTimer = LibStub("AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DXE")
local SM = LibStub("LibSharedMedia-3.0")

-- Localized spell names
local SN = setmetatable({},{
	__index = function(t,k)
		if type(k) ~= "number" then return "nil" end
		local name = GetSpellInfo(k)
		if not name then error("Invalid spell name attempted to be retrieved") end
		t[k] = name
		return name
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
		t[name] = class_to_color[class]..name.."|r"
		return t[name]
	end,
})

do
	local libs = {
		ACD = ACD,
		AC = AC,
		AceGUI = AceGUI,
		AceTimer = AceTimer,
		L = L,
		SN = SN,
		NID = NID,
		CN = CN,
		SM = SM,
	}
	for k,lib in pairs(libs) do
		addon[k] = lib
	end
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
	return nil
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
	-- Keys refer to yards
	local ProximityFuncs = {
		[10] = function(unit) return CheckInteractDistance(unit,3) end,
		[11] = function(unit) return CheckInteractDistance(unit,2) end,
		[18] = function(unit) 
			for itemid in pairs(bandages) do
				if IsItemInRange(itemid,unit) == 1 then
					return true
				end
			end
			return false
		end,
		[28] = function(unit) return CheckInteractDistance(unit,4) end,
	}

	function addon:GetProximityFuncs()
		return ProximityFuncs
	end
end

---------------------------------------------
-- UNIT IDS
---------------------------------------------

local rID,rIDtarget = {},{}
for i=1,40 do
	rID[i] = "raid"..i
	rIDtarget[i] = "raid"..i.."target" 
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
		self:AddEncounterOptions(data)
		self:RefreshDefaults()
	end

	EDB[key] = data

	self:UpdateTriggers()
	self:UpdateVersionString()
end

--- Remove an encounter previously added with RegisterEncounter.
-- There's no need to update the version string because we always register after an unregister
function addon:UnregisterEncounter(key)
	if key == "default" or not EDB[key] then return end

	-- Swap to default if we're trying to unregister the current encounter
	if CE.key == key then self:SetActiveEncounter("default") end

	self:RemoveEncounterOptions(EDB[key])

	ACD:Close("DXE")

	EDB[key] = nil

	self:UpdateTriggers()
	self:UpdateVersionString()
end

function addon:GetEncounterData(key)
	return EDB[key]
end

function addon:SetEncounterData(key,data)
	EDB[key] = data
end

--- Get the name of the currently-active encounter
function addon:GetActiveEncounter()
	return CE and CE.key or "default"
end

function addon:SetCombat(flag,event,func)
	if flag then self:RegisterEvent(event,func) end
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

	self.Pane.SetFolderValue(key)

	self:CloseAllHW()
	if CE.onactivate then
		local oa = CE.onactivate
		self:SetTracerStart(oa.tracerstart)
		self:SetTracerStop(oa.tracerstop)
		self:SetTracing(oa.tracing)
		self:SetCombat(oa.combatstop,"PLAYER_REGEN_ENABLED","CombatStop")
	end
	-- For the empty encounter
	if key == "default" then self:ShowFirstHW() end
	self:LayoutHealthWatchers()
	self.callbacks:Fire("SetActiveEncounter",CE)
end

-- Start the current encounter
function addon:StartEncounter(...)
	if self:IsRunning() then return end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","UNIT_DIED")
	self.callbacks:Fire("StartEncounter",...)
	self:StartTimer()
end

-- Stop the current encounter
function addon:StopEncounter()
	if not self:IsRunning() then return end
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.callbacks:Fire("StopEncounter")
	self:StopTimer()
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

local refreshFuncs = {
	name_to_unit = function(t,i,id) 
		t[UnitName(id)] = id
	end,
	guid_to_unit = function(t,i,id) 
		t[UnitGUID(id)] = id
	end,
	-- Remember to iterate using pairs
	index_to_unit = function(t,i,id) 
		t[i] = id
	end,
}

for k in pairs(refreshFuncs) do 
	Roster[k] = {}
end

local numOnline = 0
local numMembers = 0
local tmpOnline,tmpMembers
local RosterHandle
function addon:RAID_ROSTER_UPDATE()
	--@debug@
	debug("RAID_ROSTER_UPDATE","Invoked")
	--@end-debug@

	tmpOnline,tmpMembers = 0,GetNumRaidMembers()

	if not RosterHandle and tmpMembers > 0 then
		-- Refresh roster tables every half minute to detect offline players
		RosterHandle = self:ScheduleRepeatingTimer("RAID_ROSTER_UPDATE",30)
	elseif tmpMembers == 0 then
		self:CancelTimer(RosterHandle,true)
		RosterHandle = nil
	end

	for name,t in pairs (Roster) do wipe(t) end
	for i=1,tmpMembers do
		local name, rank, _, _, _, _, _, online = GetRaidRosterInfo(i)
		local unit = rID[i]
		if online then
			tmpOnline = tmpOnline + 1
			for k,t in pairs(Roster) do
				refreshFuncs[k](t,i,unit)
			end
		end
	end

	--- Number of raid member differences

	if tmpMembers ~= numMembers then
		self:UpdatePaneVisibility()
	end

	numMembers = tmpMembers

	--- Number of ONLINE raid member differences

	if tmpOnline > numOnline then
		self:BroadcastVersion("addon")
	end

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
	function addon:UpdateTriggers()
		-- Clear trigger tables
		wipe(TRGS_NPCID)
		wipe(TRGS_YELL)
		self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
		self:CancelTimer(ScanHandle,true)
		-- Build trigger lists
		local scan, yell = BuildTriggerLists()
		-- Start invokers
		if scan then ScanHandle = self:ScheduleRepeatingTimer("ScanUpdate",2) end
		if yell then self:RegisterEvent("CHAT_MSG_MONSTER_YELL") end
	end
	addon:ThrottleFunc("UpdateTriggers",1,true)
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

function addon:Scan()
	for i,unit in pairs(Roster.index_to_unit) do
		local target = rIDtarget[i]
		local guid = UnitGUID(target)
		if guid then
			local npcid = NID[guid]
			if TRGS_NPCID[npcid] and not UnitIsDead(target) then
				return TRGS_NPCID[npcid]
			end
		end
	end
	return nil
end

function addon:ScanUpdate()
	local key = self:Scan()
	if key then self:SetActiveEncounter(key) end
end

---------------------------------------------
-- GENERIC EVENTS
---------------------------------------------

function addon:PLAYER_ENTERING_WORLD()
	self.PGUID = self.PGUID or UnitGUID("player")
	self.PNAME = self.PNAME or UnitName("player")
	self:UpdatePaneVisibility()
	self:UpdateTriggers()
end

---------------------------------------------
-- MAIN
---------------------------------------------

function addon:SetupMinimapIcon()
	local LDB = LibStub("LibDataBroker-1.1")
	self.launcher = LDB:NewDataObject("DXE", 
	{
		type = "launcher",
		icon = "Interface\\Addons\\DXE\\Textures\\Icon",
		OnClick = function(_, button)
			self:ToggleConfig() 
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(L["Deus Vox Encounters"])
			tooltip:AddLine(L["|cffffff00Click|r to toggle the settings window"],1,1,1)
		end,
	})
	local LDBIcon = LibStub("LibDBIcon-1.0",true)
	if LDBIcon then LDBIcon:Register("DXE",self.launcher,gbl._Minimap) end
end

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

	function addon:RefreshProfile()
		pfl = db.profile
		for k,func in ipairs(funcs) do
			func(pfl)
		end
		
		self:LoadAllPositions()
	end
end

-- Initialization
function addon:OnInitialize()
	Initialized = true

	-- Database
	self.db = LibStub("AceDB-3.0"):New("DXEDB",self.defaults)
	db = self.db
	gbl,pfl = db.global,db.profile
	self:SetDBPointers()

	-- Options
	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

	--@debug@
	debug = self:CreateDebugger("Core",gbl,debugDefaults)
	--@end-debug@

	-- Slash Commands
	AC:RegisterOptionsTable(L["Deus Vox Encounters"], self:GetSlashOptions(),"dxe")

	-- Received database
	RDB = self.db:RegisterNamespace("RDB", {global = {}}).global
	self.RDB = RDB

	-- Pane
	self:CreatePane()

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

	-- Minimap
	self:SetupMinimapIcon()

	self:SetEnabledState(gbl.Enabled)
	self:Print(L["Type |cffffff00/dxe|r for slash commands"])
end

function addon:OnEnable()
	self:UpdateTriggers()
	self:UpdateLock()
	self:UpdatePaneScale()
	self:LayoutHealthWatchers()

	-- Events
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RAID_ROSTER_UPDATE()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA","UpdateTriggers")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:SetActiveEncounter("default")
	self:EnableAllModules()
	self:RegisterComm("DXE")
	self:UpdatePaneVisibility()
	self:RequestAddOnVersions()
end

function addon:OnDisable()
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
-- POSITIONING
---------------------------------------------

local frameNames = {}

function addon:SavePosition(f)
	local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
	local name = f:GetName()
	pfl.Positions[name].point = point
	pfl.Positions[name].relativeTo = relativeTo and relativeTo:GetName()
	pfl.Positions[name].relativePoint = relativePoint
	pfl.Positions[name].xOfs = xOfs
	pfl.Positions[name].yOfs = yOfs
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
	end
end

do
	local function startMovingShift(self)
		if IsShiftKeyDown() then
			self:StartMoving()
		end
	end

	local function startMoving(self)
		self:StartMoving()
	end

	local function stopMoving(self)
		self:StopMovingOrSizing()
		addon:SavePosition(self)
	end

	-- Registers saving positions in database
	function addon:RegisterMoveSaving(frame,point,relativeTo,relativePoint,xOfs,yOfs,withShift)
		--@debug@
		assert(type(frame) == "table","expected 'frame' to be a table")
		assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
		--@end-debug@
		if withShift then
			frame:SetScript("OnMouseDown",startMovingShift)
		else
			frame:SetScript("OnMouseDown",startMoving)
		end
		frame:SetScript("OnMouseUp",stopMoving)
		-- Add default position
		local pos = {}
		pos.point = point
		pos.relativeTo = relativeTo
		pos.relativePoint = relativePoint
		pos.xOfs = xOfs
		pos.yOfs = yOfs
		defaults.profile.Positions[frame:GetName()] = pos
		self:RefreshDefaults()
	end
end

---------------------------------------------
-- UNIT UTILITY
---------------------------------------------

function addon:GetUnitID(target)
	if find(target,"0x%x+") then 
		return Roster.guid_to_unit[target]
	else 
		return Roster.name_to_unit[target]
	end
end

---------------------------------------------
-- TOOLTIP TEXT
---------------------------------------------

do
	local function calculatepoint(self)
		local worldscale = UIParent:GetEffectiveScale()
		local midX,midY = worldscale*GetScreenWidth()/2,worldscale*GetScreenHeight()/2
		local scale,x,y = self:GetEffectiveScale(), self:GetCenter()
		x,y = x*scale,y*scale
		if x <= midX and y > midY then -- Top left quadrant
			return "ANCHOR_BOTTOMRIGHT"
		elseif x <= midX and y < midY then -- Bottom left quadrant
			return "ANCHOR_RIGHT"
		elseif x > midX and y <= midY then -- Bottom right quadrant
			return "ANCHOR_LEFT"
		elseif x > midX and y >= midY then -- Top right quadrant
			return "ANCHOR_BOTTOMLEFT"
		end
	end

	local function onEnter(self)
		GameTooltip:SetOwner(self, calculatepoint(self))
		GameTooltip:AddLine(self._ttTitle)
		GameTooltip:AddLine(self._ttText,1,1,1,true)
		GameTooltip:Show()
	end

	local function onLeave(self)
		GameTooltip:Hide()
	end

	function addon:AddTooltipText(obj,title,text)
		obj._ttTitle = title
		obj._ttText = text
		obj:SetScript("OnEnter",onEnter)
		obj:SetScript("OnLeave",onLeave) 
	end
end

---------------------------------------------
-- PANE
---------------------------------------------


function addon:ToggleConfig()
	if not self.options then self:InitializeOptions() end
	ACD[ACD.OpenFrames.DXE and "Close" or "Open"](ACD,"DXE") 
end

local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
   edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	edgeSize = 9,             
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

function addon:UpdatePaneScale()
	local scale = gbl.PaneScale
	self.Pane:SetScale(scale)
	addon:SavePosition(self.Pane)
end

function addon:UpdatePaneVisibility()
	if gbl.ShowPane then
		local func = "Show"
		func = gbl.PaneOnlyInRaid and (GetNumRaidMembers() > 0 and "Show" or "Hide") or func
		func = gbl.PaneOnlyInInstance and (IsInInstance() and "Show" or "Hide") or func
		self.Pane[func](self.Pane)
	else
		self.Pane:Hide()
	end
end

do
	local size = 17
	local controls = {}
	--- Adds a button to the encounter pane
	-- @param normal The normal texture for the button
	-- @param highlight The highlight texture for the button
	-- @param onclick The function of the OnClick script
	-- @param anchor SetPoints the control LEFT, anchor, RIGHT
	function addon:AddPaneButton(normal,highlight,onClick,name,text)
		local control = CreateFrame("Button",nil,self.Pane)
		control:SetWidth(size)
		control:SetHeight(size)
		control:SetPoint("LEFT",controls[#controls] or self.Pane.timer.frame,"RIGHT")
		control:SetScript("OnClick",onClick)
		control:SetNormalTexture(normal)
		control:SetHighlightTexture(highlight)
		self:AddTooltipText(control,name,text)

		controls[#controls+1] = control
		return control
	end
end

-- Idea based off RDX's Pane
function addon:CreatePane()
	if self.Pane then self.Pane:Show() return end
	local Pane = CreateFrame("Frame","DXEPane",UIParent)
	Pane:Hide()
	Pane:SetClampedToScreen(true)
	Pane:SetBackdrop(backdrop)
	Pane:SetBackdropBorderColor(0.33,0.33,0.33)
	Pane:SetWidth(220)
	Pane:SetHeight(25)
	Pane:EnableMouse(true)
	Pane:SetMovable(true)
	Pane:SetPoint("CENTER")
	self:RegisterMoveSaving(Pane,"CENTER","UIParent","CENTER",nil,nil,true)
	self:LoadPosition("DXEPane")
	self:AddTooltipText(Pane,"Pane",L["|cffffff00Shift + Click|r to move"])
	local function onUpdate() addon:LayoutHealthWatchers() end
	Pane:HookScript("OnMouseDown",function(self) self:SetScript("OnUpdate",onUpdate) end)
	Pane:HookScript("OnMouseUp",function(self) self:SetScript("OnUpdate",nil) end)
  	self.Pane = Pane
	
	Pane.timer = AceGUI:Create("DXE_Timer")
	Pane.timer.frame:SetParent(Pane)
	Pane.timer:SetPoint("BOTTOMLEFT",5,2)
	Pane.timer.left:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",19)
	Pane.timer.right:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",11)

	local PaneTextures = "Interface\\AddOns\\DXE\\Textures\\Pane\\"

	-- Add StartStop control
	Pane.startStop = self:AddPaneButton(
		PaneTextures.."Stop",
		PaneTextures.."Stop",
		function() self:StopEncounter() end,
		L["Stop"],
		L["Stops the current encounter"]
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
	local selector = self:CreateSelector()
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

	self:CreateHealthWatchers()
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

	local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
	function addon:CreateLockableFrame(name,width,height,text)
		--@debug@
		assert(type(name) == "string","expected 'name' to be a string")
		assert(type(width) == "number" and width > 0,"expected 'width' to be a number > 0")
		assert(type(height) == "number" and height > 0,"expected 'height' to be a number > 0")
		assert(type(text) == "string","expected 'text' to be a string")
		--@end-debug@
		local frame = CreateFrame("Frame","DXE"..name,UIParent)
		--frame:SetClampedToScreen(true)
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetBackdrop(backdrop)
		frame:SetWidth(width)
		frame:SetHeight(height)
		LockableFrames[frame] = true
		self:UpdateLockedFrames()
		
		local desc = frame:CreateFontString(nil,"ARTWORK")
		desc:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		desc:SetPoint("CENTER")
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

	local function onClick(self)
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
			info.func = onClick
			info.colorCode = YELLOW
			info.owner = self
			UIDropDownMenu_AddButton(info,1)

			for key,data in addon:IterateEDB() do
				work[data.category or data.zone] = true
			end
			for cat in pairs(work) do
				list[#list+1] = cat
			end

			table.sort(list)

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

			table.sort(list)

			for _,name in ipairs(list) do
				info = UIDropDownMenu_CreateInfo()
				info.hasArrow = false
				info.text = name
				info.owner = self
				info.value = work[name]
				info.func = onClick
				UIDropDownMenu_AddButton(info,2)
			end
		end
	end

	function addon:CreateSelector()
		local selector = CreateFrame("Frame", "DXE_Selector", UIParent, "UIDropDownMenuTemplate") 
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

	--- Returns the encounter start time based off GetTime()
	-- @return number >= 0
	function addon:GetElapsedTime()
		return elapsedTime
	end

	--- Returns whether or not the timer is running
	-- @return A boolean
	function addon:IsRunning()
		return isRunning
	end

	function addon:SetRunning(val)
		isRunning = val
	end

	local function onUpdate(self,elapsed)
		elapsedTime = elapsedTime + elapsed
		self.obj:SetTime(elapsedTime)
	end

	--- Starts the Pane timer
	function addon:StartTimer()
		elapsedTime = 0
		self.Pane.timer.frame:SetScript("OnUpdate",onUpdate)
		self:SetRunning(true)
	end

	--- Stops the Pane timer
	function addon:StopTimer()
		self.Pane.timer.frame:SetScript("OnUpdate",nil)
		self:SetRunning(false)
	end

	--- Resets the Pane timer
	function addon:ResetTimer()
		elapsedTime = 0
		self.Pane.timer:SetTime(0)
	end
end

---------------------------------------------
-- HEALTH WATCHERS
---------------------------------------------
local HW = {}
addon.HW = HW
local DEAD = DEAD:upper()

function addon:UNIT_DIED(_, _,eventtype, _, _, _, dstGUID)
	if eventtype ~= "UNIT_DIED" then return end
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and hw:GetGoal() == NID[dstGUID] then
			hw:SetInfoBundle(DEAD,0)
			break
		end
	end
end

-- Only four are needed currently. Too many health watchers clutters the screen.
function addon:CreateHealthWatchers()
	if HW[1] then return end
	for i=1,4 do HW[i] = AceGUI:Create("DXE_HealthWatcher") end

	-- Only the main one sends updates
	HW[1]:SetCallback("HW_TRACER_UPDATE",function(self,event,unit) addon:TRACER_UPDATE(unit) end)
	HW[1]:EnableUpdates()

	-- OnAcquired
	local onacquired = function(self,event,unit) 
		local npcid = self:GetGoal()
		if not self:IsTitleSet() then
			-- Should only enter once
			local name = UnitName(unit)
			gbl.L_NPC[npcid] = name
			self:SetTitle(name)
		end
		addon.callbacks:Fire("HW_TRACER_ACQUIRED",unit,npcid) 
	end
	for i,hw in ipairs(HW) do
		hw:SetCallback("HW_TRACER_ACQUIRED",onacquired) 
		hw.frame:SetParent(self.Pane)
	end
end

function addon:CloseAllHW()
	for i=1,4 do HW[i]:Close(); HW[i].frame:Hide() end
end

function addon:ShowFirstHW()
	if not HW[1]:IsShown() then
		HW[1]:SetInfoBundle("",1,0,0,1)
		HW[1]:SetTitle(CE.title)
		HW[1].frame:Show()
	end
end

function addon:SetTracing(npcids)
	if not npcids then return end
	local n = 0
	for i,npcid in ipairs(npcids) do
		-- Prevents overwriting
		if HW[i]:GetGoal() ~= npcid then
			HW[i]:SetTitle(gbl.L_NPC[npcid] or "...")
			HW[i]:SetInfoBundle("",1,0,0,1)
			HW[i]:Track("npcid",npcid)
			HW[i]:Open()
			HW[i].frame:Show()
		end
		n = n + 1
	end
	for i=n+1,4 do
		HW[i]:Close()
		HW[i].frame:Hide()
	end
	self:LayoutHealthWatchers()
end

function addon:LayoutHealthWatchers()
	local midY = (GetScreenHeight()/2)*UIParent:GetEffectiveScale()
	local x,y = self.Pane:GetCenter()
	local s = self.Pane:GetEffectiveScale()
	x,y = x*s,y*s
	local point = y > midY and "TOP" or "BOTTOM"
	local relPoint = y > midY and "BOTTOM" or "TOP"
	local anchor = self.Pane
	for i,hw in ipairs(self.HW) do
		if hw.frame:IsShown() then
			hw:ClearAllPoints()
			hw:SetPoint(point,anchor,relPoint)
			anchor = hw.frame
		end
	end
end

do
	-- Throttling is needed because sometimes bosses pulsate in and out of combat at the start.
	-- UnitAffectingCombat can return false at the start even if the boss is moving towards a player.

	-- Lookup table so we don't have to concatenate every update
	local targetof = {}
	for i=1,40 do targetof["raid"..i.."target"] = "raid"..i.."targettarget" end
	targetof["focus"] = "focustarget"
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
-- REGEN START/STOPPING
---------------------------------------------

local dead
function addon:CombatStop()
	--@debug@
	debug("CombatStop","Invoked")
	--@end-debug@
	if (UnitHealth("player") > 0 or UnitIsGhost("player")) and not UnitAffectingCombat("player") then
		-- If this doesn't work then scan for the raid for units in combat
		if dead then
			self:ScheduleTimer("CombatStop",3)
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
	self:SendCommMessage("DXE",self:Serialize(commType,...),"RAID")
end

function addon:OnCommReceived(prefix, msg, dist, sender)
	if (dist ~= "RAID" and dist ~= "WHISPER") or sender == self.PNAME then return end
	self:DispatchComm(sender, self:Deserialize(msg))
end

function addon:DispatchComm(sender,success,commType,...)
	if success then
		local callback = "OnComm"..commType
		if self[callback] and type(self[callback]) == "function" then
			self[callback](self,callback,commType,sender,...)
		end
		self.callbacks:Fire(callback,commType,sender,...)
	end
end

---------------------------------------------
-- VERSION CHECKING
---------------------------------------------

-- Roster versions
local RVS = {}
addon.RVS = RVS

local window

function addon:GetNumWithAddOn()
	local n = 0
	for k,v in ipairs(RVS) do
		if v.versions.addon then
			n = n + 1
		end
	end
	return n
end

function addon:CleanVersions()
	local n,i = #RVS,1
	while i <= n do
		local v = RVS[i]
		if Roster.name_to_unit[v[1]] then i = i + 1
		else remove(RVS,i); n = n - 1 end
	end
	self:RefreshVersionList()
end

-- Version string
local VersionString
function addon:UpdateVersionString()
	local work = {}
	work[1] = format("%s,%s","addon",self.version)
	for key, data in self:IterateEDB() do
		work[#work+1] = format("%s,%s",data.key,data.version)
	end
	VersionString = concat(work,":")
end
addon:ThrottleFunc("UpdateVersionString",1,true)

-- All versions

function addon:RequestAllVersions()
	self:SendRaidComm("RequestAllVersions")
end
addon:ThrottleFunc("RequestAllVersions",5,true)

function addon:OnCommRequestAllVersions()
	self:BroadcastAllVersions()
end

function addon:BroadcastAllVersions()
	self:SendRaidComm("AllVersionsBroadcast",VersionString)
end
addon:ThrottleFunc("BroadcastAllVersions",5,true)

function addon:OnCommAllVersionsBroadcast(event,commType,sender,versionString)
	local k = search(RVS,sender,1)
	if not k then 
		k = #RVS+1
		RVS[k] = {sender, versions={}}
	end

	local versions = RVS[k].versions

	for key,version in gmatch(versionString,"([^:,]+),([^:,]+)") do
		versions[key] = tonumber(version)
	end

	self:RefreshVersionList()
end

-- Single versions
function addon:RequestVersions(key)
	if not EDB[key] then return end
	self:SendRaidComm("RequestVersions",key)
end
addon:ThrottleFunc("RequestVersions",1,true)

function addon:OnCommRequestVersions(event,commType,sender,key)
	if not EDB[key] then return end
	self:SendWhisperComm(sender,"VersionBroadcast",key,EDB[key].version)
end

function addon:RequestAddOnVersions()
	self:SendRaidComm("RequestAddOnVersion")
end

function addon:OnCommRequestAddOnVersion()
	self:BroadcastVersion("addon")
end

function addon:BroadcastVersion(key)
	if not EDB[key] and key ~= "addon" then return end
	self:SendRaidComm("VersionBroadcast",key,key == "addon" and self.version or EDB[key].version)
end

function addon:OnCommVersionBroadcast(event,commType,sender,key,version)
	local k = search(RVS,sender,1)
	if not k then
		k = #RVS+1
		RVS[k] = {sender, versions = {}}
	end

	RVS[k].versions[key] = tonumber(version)

	self:RefreshVersionList()
end

----- GUI
-- Thanks to oRA3 for some of the implementation

do
	local dropdown, heading, scrollFrame
	local list,headers = {},{}
	local value = "addon"
	local sortIndex = 1
	local sortDir = true

	local NONE = -1
	local GREEN = "|cff99ff33"
	local BLUE  = "|cff3399ff"
	local GREY  = "|cff999999"
	local RED   = "|cffff3300"
	local NUM_ROWS = 12
	local ROW_HEIGHT = 16

	local function SetHeaderText(name,version)
		heading:SetText(format("%s: |cffffffff%s|r",name,version))
	end

	local function dropdownChanged(widget,event,v)
		value = v
		SetHeaderText(list[v],EDB[v].version)
		addon:RefreshVersionList()
		addon:RequestVersions(value)
	end

	local function RefreshEncDropdown()
		wipe(list)
		for key,data in addon:IterateEDB() do
			list[key] = data.name
		end
		dropdown:SetList(list)
	end


	local function colorCode(text)
		if type(text) == "string" then
			return CN[text]
		elseif type(text) == "number" then
			if text == NONE then
				return GREY..L["None"].."|r"
			else
				local v = value == "addon" and addon.version or EDB[value].version
				if v > text then
					return RED..text.."|r"
				elseif v < text then
					return BLUE..text.."|r"
				else
					return GREEN..text.."|r"
				end
			end
		end
	end

	local function UpdateScroll()
		local n = #RVS
		FauxScrollFrame_Update(scrollFrame, n, NUM_ROWS, ROW_HEIGHT, nil, nil, nil, nil, nil, nil, true)
		local offset = FauxScrollFrame_GetOffset(scrollFrame)
		for i = 1, NUM_ROWS do
			local j = i + offset
			if j <= n then
				for k, header in ipairs(headers) do
					local text = colorCode(RVS[j][k])
					header.rows[i]:SetText(text)
					header.rows[i]:Show()
				end
			else
				for k, header in ipairs(headers) do
					header.rows[i]:Hide()
				end
			end
		end
	end

	local function sortAsc(a,b) return a[sortIndex] < b[sortIndex] end
	local function sortDesc(a,b) return a[sortIndex] > b[sortIndex] end

	local function SortColumn(column)
		local header = headers[column]
		sortIndex = column
		if not header.sortDir then
			table.sort(RVS, sortAsc)
		else
			table.sort(RVS, sortDesc)
		end
		UpdateScroll()
	end

	local function CreateRow(parent)
		local text = parent:CreateFontString(nil,"OVERLAY")
		text:SetHeight(ROW_HEIGHT)
		text:SetFontObject(GameFontNormalSmall)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1,1,1)
		return text
	end

	local function CreateHeader(content,column)
		local header = CreateFrame("Button", nil, content)
		header:SetScript("OnClick",function() header.sortDir = not header.sortDir; SortColumn(column) end)
		header:SetHeight(20)
		local title = header:CreateFontString(nil,"OVERLAY")
		title:SetPoint("LEFT",header,"LEFT",10,0)
		header:SetFontString(title)
		header:SetNormalFontObject(GameFontNormalSmall)
		header:SetHighlightFontObject(GameFontNormal)

		local rows = {}
		header.rows = rows
		local text = CreateRow(header)
		text:SetPoint("TOPLEFT",header,"BOTTOMLEFT",10,-3)
		text:SetPoint("TOPRIGHT",header,"BOTTOMRIGHT",0,-3)
		rows[1] = text

		for i=2,NUM_ROWS do
			text = CreateRow(header)
			text:SetPoint("TOPLEFT", rows[i-1], "BOTTOMLEFT")
			text:SetPoint("TOPRIGHT", rows[i-1], "BOTTOMRIGHT")
			rows[i] = text
		end

		return header
	end

	function addon:RefreshVersionList()
		if window and window:IsShown() then
			for k,v in ipairs(RVS) do
				v[2] = v.versions[value] or NONE
			end

			for name in pairs(Roster.name_to_unit) do
				if not search(RVS,name,1) and name ~= self.PNAME then
					RVS[#RVS+1] = {name,NONE,versions = {}}
				end
			end

			SortColumn(sortIndex)
		end
	end

	function addon:VersionCheck()
		if value ~= "addon" then self:RequestVersions(value) end
		if window and not window:IsShown() then
			window:Show()
			RefreshEncDropdown()
			self:RefreshVersionList()
		elseif not window then
			window = self:CreateWindow("Version Check",220,295)
			--@debug@
			window:AddTitleButton("Interface\\Addons\\DXE\\Textures\\Window\\Sync.tga",
											function() self:RequestAllVersions() end)
			--@end-debug@
			local content = window.content
			local addonButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
			addonButton:SetWidth(content:GetWidth()/3)
			addonButton:SetHeight(25)
			addonButton:SetNormalFontObject(GameFontNormalSmall)
			addonButton:SetHighlightFontObject(GameFontHighlightSmall)
			addonButton:SetDisabledFontObject(GameFontDisableSmall)
			addonButton:SetText("AddOn")
			addonButton:SetPoint("TOPLEFT",content,"TOPLEFT",0,-1)
			addonButton:RegisterForClicks("LeftButtonUp","RightButtonUp")
			addonButton:SetScript("OnClick",function(_,button) 
				if button == "LeftButton" then
					SetHeaderText(L["AddOn"],self.version)
					value = "addon"
				elseif button == "RightButton" then
					if not dropdown.value then return end
					SetHeaderText(list[dropdown.value],EDB[dropdown.value].version)
					value = dropdown.value
					self:RequestVersions(value)
				end
				self:RefreshVersionList() 
			end)

			dropdown = AceGUI:Create("Dropdown")
			dropdown.frame:SetParent(content)
			dropdown.frame:Show()
			dropdown:SetPoint("TOPRIGHT",content,"TOPRIGHT")
			dropdown:SetWidth(content:GetWidth()*2/3)
			dropdown:SetCallback("OnValueChanged", dropdownChanged)
			RefreshEncDropdown()
			dropdown:SetValue(next(list))

			heading = CreateFrame("Frame",nil,content)
			heading:SetWidth(content:GetWidth())
			heading:SetHeight(18)
			heading:SetPoint("TOPLEFT",addonButton,"BOTTOMLEFT",0,-2)
			local label = heading:CreateFontString(nil,"ARTWORK")
		 	label:SetFont(GameFontNormalSmall:GetFont())
			label:SetPoint("CENTER")
			label:SetTextColor(1,1,0)
			function heading:SetText(text) label:SetText(text) end
			SetHeaderText(L["AddOn"],self.version)

			local left = heading:CreateTexture(nil, "BACKGROUND")
			left:SetHeight(8)
			left:SetPoint("LEFT",heading,"LEFT",3,0)
			left:SetPoint("RIGHT",label,"LEFT",-5,0)
			left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
			left:SetTexCoord(0.81, 0.94, 0.5, 1)

			local right = heading:CreateTexture(nil, "BACKGROUND")
			right:SetHeight(8)
			right:SetPoint("RIGHT",heading,"RIGHT",-3,0)
			right:SetPoint("LEFT",label,"RIGHT",5,0)
			right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
			right:SetTexCoord(0.81, 0.94, 0.5, 1)

			for i=1,2 do headers[i] = CreateHeader(content,i) end
			headers[1]:SetPoint("TOPLEFT",heading,"BOTTOMLEFT")
			headers[1]:SetText(L["Name"])
			headers[1]:SetWidth(120)

			headers[2]:SetPoint("LEFT",headers[1],"LEFT",content:GetWidth()/2,0)
			headers[2]:SetText(L["Version"])
			headers[2]:SetWidth(80)

			scrollFrame = CreateFrame("ScrollFrame", "DXEVCScrollFrame", content, "FauxScrollFrameTemplate")
			scrollFrame:SetPoint("TOPLEFT", headers[1], "BOTTOMLEFT")
			scrollFrame:SetPoint("BOTTOMRIGHT",-21,0)
			scrollFrame:SetBackdrop(backdrop)
			scrollFrame:SetBackdropBorderColor(0.33,0.33,0.33)

			local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
			local scrollBarBG = CreateFrame("Frame",nil,scrollBar)
			scrollBarBG:SetBackdrop(backdrop)
			scrollBarBG:SetPoint("TOPLEFT",-3,19)
			scrollBarBG:SetPoint("BOTTOMRIGHT",3,-18)
			scrollBarBG:SetBackdropBorderColor(0.33,0.33,0.33)
			scrollBarBG:SetFrameLevel(scrollBar:GetFrameLevel()-2)

			scrollFrame:SetScript("OnVerticalScroll", function(self, offset) 
				FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, UpdateScroll) 
			end)

			self:RefreshVersionList()
			UpdateScroll()
		end
	end
end

