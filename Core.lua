---------------------------------------------
-- DEFAULTS
---------------------------------------------

--@debug@
local debug

local debugDefaults = {
	CheckForEngage = false,
	CheckForWipe = false,
	CHAT_MSG_MONSTER_YELL = false,
	RAID_ROSTER_UPDATE = false,
}
--@end-debug@

local defaults = {
	global = {
		Enabled = true,
		Locked = true,
		Distributor = {
			AutoAccept = true,
		},
		AlertsScale = 1,
		PaneScale = 1, 
		ShowPane = true,
		PaneOnlyInRaid = false,
		PaneOnlyInInstance = false,
		PaneScale = 1,
		ShowMinimap = true,
		_Minimap = {},
		--@debug@
		debug = debugDefaults
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

local DXE = LibStub("AceAddon-3.0"):NewAddon("DXE","AceEvent-3.0","AceTimer-3.0","AceConsole-3.0","AceComm-3.0","AceSerializer-3.0")
DXE.version = tonumber(("$Rev$"):sub(7, -3))
DXE:SetDefaultModuleState(false)
DXE.callbacks = LibStub("CallbackHandler-1.0"):New(DXE)
DXE.defaults = defaults

function DXE:RefreshDefaults()
	self.db:RegisterDefaults(defaults)
end

---------------------------------------------
-- UPVALUES
---------------------------------------------

local wipe,concat,remove = table.wipe,table.concat,table.remove
local match,find,gmatch,sub = string.match,string.find,string.gmatch,string.sub
local _G,select,tostring,type,assert,tonumber = _G,select,tostring,type,assert,tonumber
local GetTime,GetNumRaidMembers,GetRaidRosterInfo = GetTime,GetNumRaidMembers,GetRaidRosterInfo
local UnitName,UnitGUID = UnitName,UnitGUID
local band = bit.band

---------------------------------------------
-- LIBS
---------------------------------------------

local ACD = LibStub("AceConfigDialog-3.0")
local AC = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceTimer = LibStub("AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DXE")

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

--- GUIDS
local GUID_LENGTH = 18
local UT_MASK = 0x00F

-- NPC IDs
local NID = setmetatable({},{
	__index = function(t,guid)
		if type(guid) ~= "string" or #guid ~= GUID_LENGTH or not guid:find("%xx%x+") then
			error("Invalid guid passed into NID") 
		end
		local npcid = tonumber(sub(guid,9,12),16)
		t[guid] = npcid
		return npcid
	end,
})

-- Unit Types
local UT = setmetatable({},{
	__index = function(t,guid)
		if type(guid) ~= "string" or #guid ~= GUID_LENGTH or not guid:find("%xx%x+") then 
			error("Invalid guid passed into UT") 
		end
		local unitType = band(tonumber(sub(guid,3,5),16),UT_MASK)
		t[guid] = unitType
		return unitType
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
		UT = UT,
	}
	for k,lib in pairs(libs) do
		DXE[k] = lib
	end
end

---------------------------------------------
-- UTILITY 
---------------------------------------------
local ipairs,pairs = ipairs,pairs

local util = {}
DXE.util = util

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

util.tablesize = tablesize
util.search = search

---------------------------------------------
-- MODULES
---------------------------------------------

function DXE:EnableAllModules()
	for name in self:IterateModules() do
		self:EnableModule(name)
	end
end

function DXE:DisableAllModules()
	for name in self:IterateModules() do
		self:DisableModule(name)
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
	-- @_postcall A boolean determining whether or not the function is called 
	--            after the end of the throttle period if called during it. If this
	--			     is set to true the function should not be passing in arguments
	--            because they will be lost
	local function ThrottleFunc(_obj,_func,_time,_postcall)
		assert(type(_func) == "string","Expected _func to be a string")
		assert(type(_obj) == "table","Expected _obj to be a table")
		assert(type(_obj[_func]) == "function","Expected _obj[func] to be a function")
		assert(type(_time) == "number","Expected _time to be a number")
		assert(type(_postcall) == "boolean","Expected _postcall to be a boolean")
		assert(AceTimer.embeds[_obj],"Expected obj to be AceTimer embedded")
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

	DXE.ThrottleFunc = ThrottleFunc
end

---------------------------------------------
-- ENCOUNTER MANAGEMENT
-- Credits to RDX
---------------------------------------------
local EDB = {}
DXE.EDB = EDB
-- Current encounter data
local CE 
-- Received database
local RDB

local RegisterQueue = {}
local Initialized = false
function DXE:RegisterEncounter(data)
	local key = data.key

	-- Convert version
	data.version = type(data.version) == "string" and tonumber(data.version:sub(7, -3)) or data.version

	-- Add to queue if we're not loaded yet
	if not Initialized then RegisterQueue[key] = data return end

	self:ValidateData(data)

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
		self:AddEncounterOptions(data)
		self:RefreshDefaults()
	end

	EDB[key] = data

	self:UpdateTriggers()

	self:UpdateVersionString() 
end

--- Remove an encounter previously added with RegisterEncounter.
-- There's no need to update the version string because we always register after an unregister
function DXE:UnregisterEncounter(key)
	if key == "default" or not EDB[key] then return end

	-- Swap to default if we're trying to unregister the current encounter
	if CE.key == key then self:SetActiveEncounter("default") end

	self:RemoveEncounterOptions(EDB[key])

	EDB[key] = nil

	ACD:Close("DXE")

	self:UpdateTriggers()
end

function DXE:GetEncounterData(key)
	return EDB[key]
end

function DXE:SetEncounterData(key,data)
	EDB[key] = data
end

--- Get the name of the currently-active encounter
function DXE:GetActiveEncounter()
	return CE and CE.key or "default"
end

function DXE:SetCombat(flag,event,func)
	if flag then self:RegisterEvent(event,func) end
end

--- Change the currently-active encounter.
function DXE:SetActiveEncounter(key)
	assert(type(key) == "string","String expected in SetActiveEncounter")
	-- Check the new encounter
	if not EDB[key] then return end
	-- Already set to this encounter
	if CE and CE.key == key then return end
	-- Update CE upvalue
	CE = EDB[key]
	-- Autos
	self:SetAutoStart(false)
	self:SetAutoStop(false)
	-- Stop the existing encounter
	self:StopEncounter() 
	-- Unregister regen events
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	-- Set folder value
	self.Pane.SetFolderValue(key)
	-- Set pane updating and starting/stopping
	self:CloseAllHW()
	if CE.onactivate then
		local oa = CE.onactivate
		self:SetAutoStart(oa.autostart)
		self:SetAutoStop(oa.autostop)
		self:SetTracing(oa.tracing)
		self:SetCombat(oa.leavecombat,"PLAYER_REGEN_ENABLED","CheckForWipe")
		self:SetCombat(oa.entercombat,"PLAYER_REGEN_DISABLED","CheckForEngage")
	end
	-- For the empty encounter
	if key == "default" then self:ShowFirstHW() end
	self:LayoutHealthWatchers()
	self.callbacks:Fire("SetActiveEncounter",CE)
end

-- Start the current encounter
function DXE:StartEncounter(...)
	if self:IsRunning() then return end
	self.callbacks:Fire("StartEncounter",...)
	self:StartTimer()
end

-- Stop the current encounter
function DXE:StopEncounter()
	if not self:IsRunning() then return end
	self.callbacks:Fire("StopEncounter")
	self:StopTimer()
end

do
	local function iter(t,i)
		local k,v = next(t,i)
		if k == "default" then return next(t,k)
		else return k,v end
	end

	function DXE:IterateEDB()
		return iter,EDB
	end
end

---------------------------------------------
-- TRIGGER BUILDING
---------------------------------------------
local NameTriggers = {} -- Activation names. Source: data.triggers.scan
local YellTriggers = {} -- Yell activations. Source: data.triggers.yell

do
	local function add_data(tbl,info,key)
		if type(info) == "table" then
			-- Info contains names
			for _,name in ipairs(info) do
				tbl[name] = key
			end
		else
			-- Info is name
			tbl[info] = key
		end
	end

	local function BuildTriggerLists()
		-- Get zone name
		local zone = GetRealZoneText()
		local hasName,hasYell = false,false
		for key, data in DXE:IterateEDB() do
			if data.zone == zone then
				if data.triggers then
					local scan = data.triggers.scan
					if scan then 
						add_data(NameTriggers,scan,key)
						hasName = true
					end
					local yell = data.triggers.yell
					if yell then 
						add_data(YellTriggers,yell,key) 
						hasYell = true
					end
				end
			end
		end
		return hasName,hasYell
	end

	local ScanHandle
	function DXE:UpdateTriggers()
		-- Clear trigger tables
		wipe(NameTriggers)
		wipe(YellTriggers)
		self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
		self:CancelTimer(ScanHandle,true)
		-- Build trigger lists
		local scan, yell = BuildTriggerLists()
		-- Start invokers
		if scan then ScanHandle = self:ScheduleRepeatingTimer("ScanUpdate",2) end
		if yell then self:RegisterEvent("CHAT_MSG_MONSTER_YELL") end
	end
	DXE:ThrottleFunc("UpdateTriggers",1,true)
end


---------------------------------------------
-- ROSTER
---------------------------------------------

local Roster = {}
DXE.Roster = Roster

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
function DXE:RAID_ROSTER_UPDATE()
	--@debug@
	debug("RAID_ROSTER_UPDATE","Invoked")
	--@end-debug@

	tmpOnline,tmpMembers = 0,GetNumRaidMembers()
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

function DXE:IsPromoted()
	return IsRaidLeader() or IsRaidOfficer()
end

---------------------------------------------
-- GENERIC EVENTS
---------------------------------------------

function DXE:PLAYER_ENTERING_WORLD()
	self.pGUID = self.pGUID or UnitGUID("player")
	self.pName = self.pName or UnitName("player")
	self:UpdatePaneVisibility()
	self:UpdateTriggers()
end

---------------------------------------------
-- MAIN
---------------------------------------------
local LDBIcon = LibStub("LibDBIcon-1.0",true)

function DXE:SetupMinimapIcon()
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
	if LDBIcon then LDBIcon:Register("DXE",self.launcher,self.db.global._Minimap) end
end

-- Replace default Print
local print,format = print,string.format
function DXE:Print(s)
	print(format("|cff99ff33DXE|r: %s",s))
end

-- Initialization
function DXE:OnInitialize()
	Initialized = true

	-- Database
	self.db = LibStub("AceDB-3.0"):New("DXEDB",self.defaults)


	-- Options
	self.options = self:GetOptions()
	AC:RegisterOptionsTable("DXE", self.options)
	ACD:SetDefaultSize("DXE", 730,550)

	--@debug@
	debug = self:CreateDebugger("Core",self.db.global,debugDefaults)
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
		if not EDB[key] then
			self:RegisterEncounter(data)
		end
	end

	RegisterQueue = nil

	-- Minimap
	self:SetupMinimapIcon()

	self:SetEnabledState(self.db.global.Enabled)
	self:Print(L["Type |cffffff00/dxe|r for slash commands"])
end

function DXE:OnEnable()
	self:UpdateTriggers()
	self:UpdateLock()
	self:UpdatePaneScale()
	self:LayoutHealthWatchers()

	-- Events
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA","UpdateTriggers")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:SetActiveEncounter("default")
	self:EnableAllModules()
	self:RegisterComm("DXE")
	self:UpdatePaneVisibility()
	self:RequestAddOnVersions()
end

function DXE:OnDisable()
	self:UpdateLockedFrames("Hide")
	self:StopEncounter()
	self:SetActiveEncounter("default")
	self.Pane:Hide()
	self:DisableAllModules()
end

---------------------------------------------
-- POSITIONING
---------------------------------------------

function DXE:SavePosition(f)
	local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
	local name = f:GetName()
	self.db.profile.Positions[name].point = point
	self.db.profile.Positions[name].relativeTo = relativeTo and relativeTo:GetName()
	self.db.profile.Positions[name].relativePoint = relativePoint
	self.db.profile.Positions[name].xOfs = xOfs
	self.db.profile.Positions[name].yOfs = yOfs
end

function DXE:LoadPosition(name)
	local f = _G[name]
	if not f then return end
	f:ClearAllPoints()
	local pos = self.db.profile.Positions[name]
	if not pos then
		f:SetPoint("CENTER",UIParent,"CENTER",0,0)
		self.db.profile.Positions[name] = {}
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
		DXE:SavePosition(self)
	end

	-- Registers saving positions in database
	function DXE:RegisterMoveSaving(frame,point,relativeTo,relativePoint,xOfs,yOfs,withShift)
		assert(type(frame) == "table","expected 'frame' to be a table")
		assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
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
-- TRIGGERING
---------------------------------------------

function DXE:CHAT_MSG_MONSTER_YELL(_,msg,...)
	--@debug@
	debug("CHAT_MSG_MONSTER_YELL",msg,...)
	--@end-debug@
	for fragment,key in pairs(YellTriggers) do
		if find(msg,fragment) then
			self:SetActiveEncounter(key)
			self:StopEncounter()
			self:StartEncounter(msg)
		end
	end
end

local UnitName = UnitName
local UnitIsEnemy = UnitIsEnemy
local FriendlyExceptions = {}

function DXE:AddFriendlyException(name)
	FriendlyExceptions[name] = true
end

function DXE:Scan()
	for i,unit in pairs(Roster.index_to_unit) do
		local target = rIDtarget[i]
		local name = UnitName(target)
		if UnitExists(target) and 
			NameTriggers[name] and 
			not UnitIsDead(target) 
			and (UnitIsEnemy("player",target) or FriendlyExceptions[name]) then
			-- Return name
			return NameTriggers[name]
		end
	end
	return nil
end

function DXE:ScanUpdate()
	local key = self:Scan()
	if key then self:SetActiveEncounter(key) end
end

---------------------------------------------
-- UNIT UTILITY
---------------------------------------------

-- For scanning bosses

-- @return uid The unit id of the name. UnitName(raid<number>target)
-- Can pass in other functions (such as UnitGUID) to compare a
-- different unit attribute
function DXE:UnitID(name, unitattributefunc)
	unitattributefunc = unitattributefunc or UnitName
	if not name then return end
	for i,unit in pairs(Roster.index_to_unit) do
		local uid = rIDtarget[i]
		local _name = unitattributefunc(uid)
		if _name == name then
			return uid
		end
	end
	return nil
end

-- @return name Finds the unit id of the name and returns the name of the unid id's target
function DXE:TargetName(name)
	local uid = self:UnitID(name)
	if not uid then return nil end
	local nextid = uid.."target"
	if UnitExists(nextid) then
		return UnitName(nextid)
	else
		return nil
	end
end

function DXE:GetUnitID(target)
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

	function DXE:AddTooltipText(obj,title,text)
		obj._ttTitle = title
		obj._ttText = text
		obj:SetScript("OnEnter",onEnter)
		obj:SetScript("OnLeave",onLeave) 
	end
end

---------------------------------------------
-- PANE CREATION
---------------------------------------------


function DXE:ToggleConfig()
	ACD[ACD.OpenFrames.DXE and "Close" or "Open"](ACD,"DXE")
end

local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
   edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	edgeSize = 9,             
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

function DXE:UpdatePaneScale()
	local scale = self.db.global.PaneScale
	self.Pane:SetScale(scale)
	DXE:SavePosition(self.Pane)
end

function DXE:UpdatePaneVisibility()
	if self.db.global.ShowPane then
		local func = "Show"
		func = self.db.global.PaneOnlyInRaid and (GetNumRaidMembers() > 0 and "Show" or "Hide") or func
		func = self.db.global.PaneOnlyInInstance and (IsInInstance() and "Show" or "Hide") or func
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
	function DXE:AddPaneButton(normal,highlight,onClick,name,text)
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
function DXE:CreatePane()
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
	local function onUpdate() DXE:LayoutHealthWatchers() end
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
	function DXE:RegisterForLocking(frame)
		assert(type(frame) == "table","expected 'frame' to be a table")
		assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
		LockableFrames[frame] = true
		self:UpdateLockedFrames()
	end

	local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
	function DXE:CreateLockableFrame(name,width,height,text)
		assert(type(name) == "string","expected 'name' to be a string")
		assert(type(width) == "number" and width > 0,"expected 'width' to be a number > 0")
		assert(type(height) == "number" and height > 0,"expected 'height' to be a number > 0")
		assert(type(text) == "string","expected 'text' to be a string")
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

	function DXE:UpdateLock()
		self:UpdateLockedFrames()
		if self.db.global.Locked then
			self:SetLocked()
		else
			self:SetUnlocked()
		end
	end

	function DXE:ToggleLock()
		self.db.global.Locked = not self.db.global.Locked
		self:UpdateLock()
	end

	function DXE:UpdateLockedFrames(func)
		func = func or (self.db.global.Locked and "Hide" or "Show")
		for frame in pairs(LockableFrames) do frame[func](frame) end
	end

	function DXE:SetLocked()
		self.Pane.lock:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Locked")
		self.Pane.lock:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Locked")
	end

	function DXE:SetUnlocked()
		self.Pane.lock:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Unlocked")
		self.Pane.lock:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Unlocked")
	end
end

---------------------------------------------
-- SELECTOR CREATION
---------------------------------------------

do
	local function closeall() CloseDropDownMenus(1) end

	local function onClick(self)
		DXE:SetActiveEncounter(self.value)
		CloseDropDownMenus()
	end

	local YELLOW = "|cffffff00"

	local work,list = {},{}

	local function Initialize(self,level)
		wipe(work)
		wipe(list)

		level = level or 1

		if level == 1 then
			local info = UIDropDownMenu_CreateInfo()
			info.isTitle = true 
			info.text = L["Encounter Selector"]
			info.notCheckable = true 
			info.justifyH = "LEFT"
			UIDropDownMenu_AddButton(info,1)

			local info = UIDropDownMenu_CreateInfo()
			info.text = L["Default"]
			info.value = "default"
			info.func = onClick
			info.colorCode = YELLOW
			info.owner = self
			UIDropDownMenu_AddButton(info,1)

			for key,data in DXE:IterateEDB() do
				work[data.category or data.zone] = true
			end
			for cat in pairs(work) do
				list[#list+1] = cat
			end

			table.sort(list)

			for _,cat in ipairs(list) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = cat
				info.value = cat
				info.hasArrow = true
				info.notCheckable = true
				info.owner = self
				UIDropDownMenu_AddButton(info,1)
			end

			local info = UIDropDownMenu_CreateInfo()
			info.notCheckable = true 
			info.justifyH = "LEFT"
			info.text = L["Cancel"]
			info.func = closeall
			UIDropDownMenu_AddButton(info,1)
		elseif level == 2 then
			local cat = UIDROPDOWNMENU_MENU_VALUE

			for key,data in self:IterateEDB() do
				if (data.category or data.zone) == cat then
					list[#list+1] = data.name
					work[data.name] = key
				end
			end

			table.sort(list)

			for _,name in ipairs(list) do
				local info = UIDropDownMenu_CreateInfo()
				info.hasArrow = false
				info.text = name
				info.owner = self
				info.value = work[name]
				info.func = onClick
				UIDropDownMenu_AddButton(info,2)
			end
		end
	end

	function DXE:CreateSelector()
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
	function DXE:GetElapsedTime()
		return elapsedTime
	end

	--- Returns whether or not the timer is running
	-- @return A boolean
	function DXE:IsRunning()
		return isRunning
	end

	function DXE:SetRunning(val)
		isRunning = val
	end

	local function onUpdate(self,elapsed)
		elapsedTime = elapsedTime + elapsed
		self.obj:SetTime(elapsedTime)
	end

	--- Starts the Pane timer
	function DXE:StartTimer()
		elapsedTime = 0
		self.Pane.timer.frame:SetScript("OnUpdate",onUpdate)
		self:SetRunning(true)
	end

	--- Stops the Pane timer
	function DXE:StopTimer()
		self.Pane.timer.frame:SetScript("OnUpdate",nil)
		self:SetRunning(false)
	end

	--- Resets the Pane timer
	function DXE:ResetTimer()
		elapsedTime = 0
		self.Pane.timer:SetTime(0)
	end
end

---------------------------------------------
-- ALERT TEST
---------------------------------------------

function DXE:AlertTest()
	DXE.Alerts:CenterPopup("AlertTest1", "Decimating. Life Tap Now!", 10, 5, "ALERT1", "DCYAN")
	DXE.Alerts:Dropdown("AlertTest2", "Big City Opening", 20, 5, "ALERT2", "BLUE")
	DXE.Alerts:Simple("Gay",3,"ALERT3","RED")
end

---------------------------------------------
-- HEALTH WATCHERS
---------------------------------------------
local HW = {}
DXE.HW = HW

-- Create health watchers
-- Only four are needed currently. Too many health watchers clutters the screen.
function DXE:CreateHealthWatchers()
	if HW[1] then return end
	for i=1,4 do HW[i] = AceGUI:Create("DXE_HealthWatcher") end

	-- Only the main one sends updates
	HW[1]:SetCallback("HW_TRACER_UPDATE",function(self,event,uid) DXE:TRACER_UPDATE(uid) end)
	HW[1]:EnableUpdates()

	-- OnAcquired
	local onacquire = function(self,event,uid) DXE.callbacks:Fire("HW_TRACER_ACQUIRED",uid) end
	for i,hw in ipairs(HW) do 
		hw:SetCallback("HW_TRACER_ACQUIRED",onacquire) 
		hw.frame:SetParent(self.Pane)
	end
end

function DXE:CloseAllHW()
	for i=1,4 do HW[i]:Close(); HW[i].frame:Hide() end
end

function DXE:ShowFirstHW()
	if not HW[1]:IsShown() then
		HW[1]:SetInfoBundle(CE.title,"",1,0,0,1)
		HW[1].frame:Show()
	end
end

-- Names should be validated to be an array of size 4
function DXE:SetTracing(names)
	if not names then return end
	local n = 0
	for i,name in ipairs(names) do
		-- Prevents overwriting
		if HW[i]:GetName() ~= name then
			HW[i]:SetInfoBundle(name,"",1,0,0,1)
			HW[i]:Open(name)
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

function DXE:LayoutHealthWatchers()
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
	local UnitIsFriend,UnitIsDead,UnitAffectingCombat = UnitIsFriend,UnitIsDead,UnitAffectingCombat
	-- Lookup table so we don't have to concatenate every update
	local targetof = {}
	for i=1,40 do targetof["raid"..i.."target"] = "raid"..i.."targettarget" end
	targetof["focus"] = "focustarget"
	-- The time to wait (seconds) before it auto stops the encounter after auto starting
	local throttle = 5
	-- The last time the encounter was auto started + throttle time
	local last = 0
	function DXE:TRACER_UPDATE(uid)
		local time,running = GetTime(),self:IsRunning()
		if self:IsAutoStart() and not running and UnitIsFriend(targetof[uid],"player") then
			self:StartEncounter()
			last = time + throttle
		elseif (UnitIsDead(uid) or not UnitAffectingCombat(uid)) and self:IsAutoStop() and running and last < time then
			self:StopEncounter()
		end
	end
end

do
	local AutoStart,AutoStop
	function DXE:SetAutoStart(val)
		AutoStart = not not val
	end

	function DXE:SetAutoStop(val)
		AutoStop = not not val
	end

	function DXE:IsAutoStart()
		return AutoStart
	end

	function DXE:IsAutoStop()
		return AutoStop
	end
end

---------------------------------------------
-- REGEN START/STOPPING
-- Credits to BigWigs for these functions
---------------------------------------------

local UnitAffectingCombat = UnitAffectingCombat

-- TODO: Needs testing
function DXE:CheckForWipe()
	--@debug@
	debug("CheckForWipe","Invoked")
	--@end-debug@
	if (UnitHealth("player") > 0 or UnitIsGhost("player")) and not UnitAffectingCombat("player") then
		local key = self:Scan()
		if not key then
			self:StopEncounter()	
			return
		end
		self:ScheduleTimer("CheckForWipe",2)
	elseif UnitIsDead("player") then
		self:ScheduleTimer("CheckForWipe",2)
	end
end

function DXE:CheckForEngage()
	--@debug@
	debug("CheckForEngage","Invoked")
	--@end-debug@
	local key = self:Scan()
	if key then
		self:StartEncounter()
	elseif UnitAffectingCombat("player") then
		self:ScheduleTimer("CheckForEngage",2) 
	end
end

---------------------------------------------
-- COMMS
---------------------------------------------

function DXE:SendComm(commType,...)
	assert(type(commType) == "string","Expected commType to be a string")
	self:SendCommMessage("DXE", self:Serialize(commType,...), "RAID")
end

function DXE:OnCommReceived(prefix, msg, dist, sender)
	print(prefix,msg,dist,sender)
	if dist ~= "RAID" or sender == self.pName then return end
	self:DispatchComm(sender, self:Deserialize(msg))
end

function DXE:DispatchComm(sender,success,commType,...)
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

-- Cached string of all versions in EDB
local VersionString
-- Contains versions of all online raid members
local RVS = {}
DXE.RVS = RVS

local window

function DXE:GetNumWithAddOn()
	return util.tablesize(RVS)
end

function DXE:CleanVersions()
	local n,i = #RVS,1
	while i <= n do
		local v = RVS[i]
		if Roster.name_to_unit[v[1]] then i = i + 1
		else remove(RVS,i); n = n - 1 end
	end
	self:RefreshVersionList()
end

function DXE:RequestAllVersions()
	self:SendComm("RequestAllVersions")
end

function DXE:OnCommRequestAllVersions()
	self:BroadcastAllVersions()
end

function DXE:RequestAddOnVersions()
	self:SendComm("RequestAddOnVersion")
end

function DXE:OnCommRequestAddOnVersion()
	self:BroadcastVersion("addon")
end

function DXE:UpdateVersionString()
	local work = {}
	work[1] = format("%s,%s","addon",self.version)
	for key, data in self:IterateEDB() do
		work[#work+1] = format("%s,%s",data.key,data.version)
	end
	VersionString = concat(work,":")
end
DXE:ThrottleFunc("UpdateVersionString",1,true)

function DXE:BroadcastAllVersions()
	self:SendComm("AllVersionsBroadcast",VersionString)
end

function DXE:OnCommAllVersionsBroadcast(event,commType,sender,versionString)
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

function DXE:BroadcastVersion(key)
	if not EDB[key] and key ~= "addon" then return end
	self:SendComm("VersionBroadcast",key,key == "addon" and self.version or EDB[key].version)
end

function DXE:OnCommVersionBroadcast(event,commType,sender,key,version)
	local k = search(RVS,sender,1)
	if not k then
		k = #RVS+1
		RVS[k] = {sender, versions = {}}
	end

	RVS[k].versions[key] = tonumber(version)

	self:RefreshVersionList()
end

do
	--- Version Check GUI
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
		DXE:RefreshVersionList()
	end


	local function RefreshEncDropdown()
		wipe(list)
		for key,data in DXE:IterateEDB() do
			list[key] = data.name
		end
		dropdown:SetList(list)
	end

	local class_to_color = {}
	for class,color in pairs(RAID_CLASS_COLORS) do
		class_to_color[class] = ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
	end

	local colorName = setmetatable({}, {__index =
		function(t, name)
			local class = select(2,UnitClass(name))
			if not class then return name end
			t[name] = class_to_color[class]..name.."|r"
			return t[name]
		end
	})

	local function colorCode(text)
		if type(text) == "string" then
			return colorName[text]
		elseif type(text) == "number" then
			if text == NONE then
				return GREY..L["None"].."|r"
			else
				local v = value == "addon" and DXE.version or EDB[value].version
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
		FauxScrollFrame_Update(scrollFrame, n, NUM_ROWS, ROW_HEIGHT,nil,nil,nil,nil,nil,nil,true)
		for i = 1, NUM_ROWS do
			local j = i + FauxScrollFrame_GetOffset(scrollFrame)
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
		if sortDir then
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
		local header =  CreateFrame("Button", nil, content)
		header:SetScript("OnClick",function() sortDir = not sortDir; SortColumn(column) end)
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

	function DXE:RefreshVersionList()
		if window and window:IsShown() then
			for k,v in ipairs(RVS) do
				v[2] = v.versions[value] or NONE
			end

			for name in pairs(Roster.name_to_unit) do
				if not search(RVS,name,1) and name ~= self.pName then
					RVS[#RVS+1] = {name,NONE,versions = {}}
				end
			end

			SortColumn(sortIndex)
		end
	end

	function DXE:VersionCheck()
		if window and not window:IsShown() then
			window:Show()
			RefreshEncDropdown()
			self:RefreshVersionList()
		elseif not window then
			window = self:CreateWindow("Version Check",220,295)--175,220)
			window:AddTitleButton("Interface\\Addons\\DXE\\Textures\\Window\\Sync.tga",
											function() self:RequestAllVersions() end)
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
			addonButton:SetScript("OnClick",function(self,button) 
				if button == "LeftButton" then
					SetHeaderText(L["AddOn"],DXE.version)
					value = "addon"
				elseif button == "RightButton" then
					if not dropdown.value then return end
					SetHeaderText(list[dropdown.value],EDB[dropdown.value].version)
					value = dropdown.value
				end
				DXE:RefreshVersionList() 
			end)

			dropdown = AceGUI:Create("Dropdown")
			dropdown:SetPoint("TOPRIGHT",content,"TOPRIGHT")
			dropdown:SetWidth(content:GetWidth()*2/3)
			dropdown:SetCallback("OnValueChanged", dropdownChanged)
			RefreshEncDropdown()
			dropdown:SetValue(next(list))
			dropdown.frame:SetParent(content)

			heading = AceGUI:Create("Heading")
			heading:SetWidth(content:GetWidth())
			SetHeaderText(L["AddOn"],self.version)
			heading:SetPoint("TOPLEFT",addonButton,"BOTTOMLEFT",0,-2)
			heading.frame:SetParent(content)
			heading.label:SetFont(GameFontNormalSmall:GetFont())

			for i=1,2 do headers[i] = CreateHeader(content,i) end
			headers[1]:SetPoint("TOPLEFT",heading.frame,"BOTTOMLEFT")
			headers[1]:SetText(L["Name"])
			headers[1]:SetWidth(120)

			headers[2] = CreateHeader(content,2)
			headers[2]:SetPoint("LEFT",headers[1],"LEFT",content:GetWidth()/2,0)
			headers[2]:SetText(L["Version"])
			headers[2]:SetWidth(80)

			scrollFrame = CreateFrame("ScrollFrame", "DXEVersionCheckScrollFrame", content, "FauxScrollFrameTemplate")
			scrollFrame:SetPoint("TOPLEFT", headers[1], "BOTTOMLEFT")
			scrollFrame:SetPoint("BOTTOMRIGHT",-21,0)
			scrollFrame:SetBackdrop(backdrop)
			scrollFrame:SetBackdropBorderColor(0.33,0.33,0.33)

			scrollFrame:SetScript("OnVerticalScroll", function(self, offset) 
				FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, UpdateScroll) 
			end)

			self:RefreshVersionList()
			UpdateScroll()
		end
	end
end

_G.DXE = DXE
