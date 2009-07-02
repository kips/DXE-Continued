---------------------------------------------
-- DEFAULTS
---------------------------------------------

--@debug@
local debug

local debugDefaults = {
	BroadcastAllVersions = false,
	RequestVersions = false,
	CleanVersions = false,
	UpdateVersionString = false,
	CheckForEngage = false,
	CheckForWipe = false,
	CHAT_MSG_MONSTER_YELL = false,
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

local wipe,concat = table.wipe,table.concat
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

util.tablesize = function(t)
	local n = 0
	for _ in pairs(t) do n = n + 1 end
	return n
end

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
function DXE:RegisterEncounter(data)
	local key = data.key

	-- Convert version
	data.version = type(data.version) == "string" and tonumber(data.version:sub(7, -3)) or data.version

	-- Add to queue if we're not loaded yet
	if not self.Loaded then RegisterQueue[key] = data return end

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
		-- RDB version is higher
		else
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
		for key, data in pairs(EDB) do
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

function DXE:RAID_ROSTER_UPDATE()
	self:UpdatePaneVisibility()
	for name,t in pairs (Roster) do wipe(t) end
	for i=1,GetNumRaidMembers() do
		local name, rank, _, _, _, _, _, online = GetRaidRosterInfo(i)
		local unit = rID[i]
		-- For now we only want online units
		if online then
			for k,t in pairs(Roster) do
				refreshFuncs[k](t,i,unit)
			end
		end
	end
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
	self.Loaded = true

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
	self:RegisterEncounter({key = "default", name = L["Default"], title = L["Default"], zone = ""})
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
	self:LoadPositions()
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
	self:UpdateVersionString()
	self:RAID_ROSTER_UPDATE()
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

-- Saves position
function DXE:SavePosition(f)
	local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
	local name = f:GetName()
	self.db.profile.Positions[name].point = point
	self.db.profile.Positions[name].relativeTo = relativeTo and relativeTo:GetName()
	self.db.profile.Positions[name].relativePoint = relativePoint
	self.db.profile.Positions[name].xOfs = xOfs
	self.db.profile.Positions[name].yOfs = yOfs
end

-- Loads position
function DXE:LoadPositions()
	for k,v in pairs(self.db.profile.Positions) do
		local f = _G[k]
		if f then
			f:ClearAllPoints()
			f:SetPoint(v.point,_G[v.relativeTo] or UIParent,v.relativePoint,v.xOfs,v.yOfs)
		end
	end
end

do
	local function startmovingshift(self)
		if IsShiftKeyDown() then
			self:StartMoving()
		end
	end

	local function startmoving(self)
		self:StartMoving()
	end

	local function stopmoving(self)
		self:StopMovingOrSizing()
		DXE:SavePosition(self)
	end

	-- Registers saving positions in database
	function DXE:RegisterMoveSaving(frame,point,relativeTo,relativePoint,xOfs,yOfs,withShift)
		assert(type(frame) == "table","expected 'frame' to be a table")
		assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
		if withShift then
			frame:SetScript("OnMouseDown",startmovingshift)
		else
			frame:SetScript("OnMouseDown",startmoving)
		end
		frame:SetScript("OnMouseUp",stopmoving)
		-- Add default position
		local tbl = {}
		tbl.point = point
		tbl.relativeTo = relativeTo
		tbl.relativePoint = relativePoint
		tbl.xOfs = xOfs
		tbl.yOfs = yOfs
		defaults.profile.Positions[frame:GetName()] = tbl
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

	local function onenter(self)
		GameTooltip:SetOwner(self, calculatepoint(self))
		GameTooltip:AddLine(self._ttTitle)
		GameTooltip:AddLine(self._ttText,1,1,1,true)
		GameTooltip:Show()
	end

	local function onleave(self)
		GameTooltip:Hide()
	end

	function DXE:AddTooltipText(obj,title,text)
		obj._ttTitle = title
		obj._ttText = text
		obj:SetScript("OnEnter",onenter)
		obj:SetScript("OnLeave",onleave) 
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
	function DXE:AddPaneButton(normal,highlight,onclick,name,text)
		local control = CreateFrame("Button",nil,self.Pane)
		control:SetWidth(size)
		control:SetHeight(size)
		control:SetPoint("LEFT",controls[#controls] or self.Pane.timer.frame,"RIGHT")
		control:SetScript("OnClick",onclick)
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
	local Pane = CreateFrame("Frame","DXE_Pane",UIParent)
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
	self:AddTooltipText(Pane,"Pane",L["|cffffff00Shift + Click|r to move"])
	local function onupdate() DXE:LayoutHealthWatchers() end
	Pane:HookScript("OnMouseDown",function(self) self:SetScript("OnUpdate",onupdate) end)
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

	local function onclick(self)
		DXE:SetActiveEncounter(self.value)
		CloseDropDownMenus()
	end

	local YELLOW = "|cffffff00"

	local work,list = {},{}

	local function initialize(self,level)
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
			info.func = onclick
			info.colorCode = YELLOW
			info.owner = self
			UIDropDownMenu_AddButton(info,1)

			for key,data in pairs(EDB) do
				if key ~= "default" then
					work[data.category or data.zone] = true
				end
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

			for key,data in pairs(EDB) do
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
				info.func = onclick
				UIDropDownMenu_AddButton(info,2)
			end
		end
	end

	function DXE:CreateSelector()
		local selector = CreateFrame("Frame", "DXE_Selector", UIParent, "UIDropDownMenuTemplate") 
		UIDropDownMenu_Initialize(selector, initialize, "MENU")
		UIDropDownMenu_SetSelectedValue(selector,"default")
		return selector
	end
end

---------------------------------------------
-- PANE FUNCTIONS
---------------------------------------------
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

local function Timer_OnUpdate(self,elapsed)
	elapsedTime = elapsedTime + elapsed
	self.obj:SetTime(elapsedTime)
end

--- Starts the Pane timer
function DXE:StartTimer()
	elapsedTime = 0
	self.Pane.timer.frame:SetScript("OnUpdate",Timer_OnUpdate)
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

function DXE:CheckForWipe()
	--@debug@
	debug("CheckForWipe","Invoked")
	--@end-debug@
	local key = DXE:Scan()
	if not key then
		self:StopEncounter()	
		return
	end
	if not UnitAffectingCombat("player") then
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
-- TODO Remove auto broadcasting. Allow the gui button to request versions and send in a whisper

-- Cached string of all versions in EDB
local VersionString
-- Contains versions of all online raid members
local RosterVersions = {}
DXE.RosterVersions = RosterVersions

function DXE:GetNumWithAddOn()
	return util.tablesize(RosterVersions)
end

function DXE:CleanVersions()
	--@debug@
	debug("CleanVersions","Invoked")
	--@end-debug@
	for name in pairs(RosterVersions) do
		if not Roster.name_to_unit[name] then
			RosterVersions[name] = nil
		end
	end
end

function DXE:RequestVersions()
	--@debug@
	debug("RequestVersions","Invoked")
	--@end-debug@
	self:SendComm("RequestAllVersions")
end

function DXE:OnCommRequestAllVersions()
	self:BroadcastAllVersions()
end

function DXE:UpdateVersionString()
	--@debug@
	debug("UpdateVersionString","Invoked")
	--@end-debug@
	local work = {}
	work[1] = format("%s,%s","addon",self.version)
	for key, data in pairs(EDB) do
		if key ~= "default" then
			work[#work+1] = format("%s,%s",data.key,data.version)
		end
	end
	VersionString = concat(work,":")

	self.db.global.tempString = VersionString
end
DXE:ThrottleFunc("UpdateVersionString",1,true)

function DXE:BroadcastAllVersions()
	--@debug@
	debug("BroadcastAllVersions","Invoked")
	--@end-debug@
	self:SendComm("AllVersionsBroadcast",VersionString)
end
DXE:ThrottleFunc("BroadcastAllVersions",10,true)

function DXE:OnCommAllVersionsBroadcast(event,commType,sender,versionString)
	RosterVersions[sender] = RosterVersions[sender] or {}
	for key,version in gmatch(versionString,"([^:,]+),([^:,]+)") do
		RosterVersions[sender][key] = tonumber(version)
	end
end

--- Broadcasts a specific encounter version
-- @param key Assumed to exist in EDB. It is only used in Distributor after downloading.
function DXE:BroadcastVersion(key)
	if not EDB[key] then return end
	self:SendComm("VersionBroadcast",key,EDB[key].version)
end

function DXE:OnCommVersionBroadcast(event,commType,sender,key,version)
	RosterVersions[sender] = RosterVersions[sender] or {}
	RosterVersions[sender][key] = version
end

do
	local GREEN = "ff99ff33"
	local BLUE  = "ff3399ff"
	local GREY  = "ff999999"
	local RED   = "ffff3300"
	local color
	local sort = table.sort
	-- TODO: Make a GUI for this
	function DXE:PrintRosterVersions(info, key)
		if GetNumRaidMembers() == 0 then
			self:Print(L["|cffff3300Failed: You are not in a Raid|r"])
			return
		end
		if not EDB[key] and key ~= "addon" then
			self:Print("|cffff3300Failed: Encounter does not exist|r")
			return
		end
		local name = key ~= "addon" and EDB[key].name or L["AddOn"]

		self:Print(format(L["Raid Version Check (%s)"],name))

		local work = {}
		for name in pairs(Roster.name_to_unit) do
			if name ~= self.pName then
				work[#work+1] = name
			end
		end

		sort(work)

		local mversion = key == "addon" and self.version or EDB[key].version
		for _,unit in ipairs(work) do
			if RosterVersions[unit] and RosterVersions[unit][key] then
				local color = BLUE
				local version = RosterVersions[unit][key]
				if version < mversion then
					color = RED 
				elseif version == mversion then
					color = GREEN
				end
				self:Print(format("|c%s%s|r: v%s",color,unit,version))
			else
				self:Print(format("|c%s%s|r: None",GREY,unit))
			end
		end
	end
end

_G.DXE = DXE
