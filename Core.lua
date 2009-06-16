---------------------------------------------
-- DEFAULTS
---------------------------------------------

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
		debug = {
			BroadcastVersion = false,
			RequestVersions = false,
			DeleteUnusedVersions = false,
			UpdateVersionString = false,
			OnCommReceived = false,
			UpdateRosterTables = false,
			CheckForEngage = false,
			CheckForWipe = false,
			RAID_ROSTER_UPDATE = false,
			CHAT_MSG_MONSTER_YELL = false,
		},
		--@end-debug@
	},
	profile = {
		Positions = {},
		Encounters = {},
	},
}

--@debug@
local debug
--@end-debug@

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local DXE = LibStub("AceAddon-3.0"):NewAddon("DXE","AceEvent-3.0","AceTimer-3.0","AceConsole-3.0","AceComm-3.0")
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
local match,find = string.match,string.find
local _G,select,tostring,type = _G,select,tostring,type

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
		if not k or type(k) ~= "number" then return "nil" end
		local name = GetSpellInfo(k)
		if not name then error("Invalid spell name attempted to be retrieved") end
		t[k] = name
		return name
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
	}
	for k,lib in pairs(libs) do
		DXE[k] = lib
	end
end

---------------------------------------------
-- UTILITY 
---------------------------------------------
local ipairs,pairs = ipairs,pairs

DXE.noop = function() end

do
	local cache = {}
	setmetatable(cache,{__mode = "kv"})
	local new = function()
		local t = next(cache) or {}
		cache[t] = nil
		return t
	end
	local type = type
	local delete = function(t)
		if type(t) == "table" then
			wipe(t)
			t[""] = true
			t[""] = nil
			cache[t] = true
		end
		return nil
	end

	-- Recursive delete
	local rdelete
	rdelete = function(t)
		if type(t) == "table" then
			for k,v in pairs(t) do
				if type(v) == "table" then
					rdelete(v)
				end
				t[k] = nil
			end
			t[""] = true
			t[""] = nil
			cache[t] = true
		end
		return nil
	end

	DXE.new = new
	DXE.delete = delete
	DXE.rdelete = rdelete
end


DXE.tablesize = function(t)
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
-- ENCOUNTER MANAGEMENT
-- Credits to RDX
---------------------------------------------
local EDB = {}
DXE.EDB = EDB
-- Current encounter data
local CE 

local loadQueue = {}
-- @param forcedValid Used with received encounters since they've already been validated.
function DXE:RegisterEncounter(data,forceValid)
	-- Save for loading after initialization
	if not self.loaded then loadQueue[#loadQueue+1] = data return end
	-- Validate data
	if not forceValid then self:ValidateData(data) end
	-- Unregister before registering the same
	if EDB[data.key] then error("Encounter already exists - Requires unregistering") return end
	-- Only encounters with field key have options
	if data.key ~= "default" then
		-- Add options
		self:AddEncounterOptions(data)
		-- Refresh defaults
		self:RefreshDefaults()
	end
	-- Replace Rev keyword
	if data.version and type(data.version) == "string" then
		data.version = tonumber(data.version:sub(7, -3))
	end
	-- Add data to database
	EDB[data.key] = data
	-- Build trigger lists
	self:UpdateTriggers()
	if self.enabled then self:UpdateVersionString() end
end

--- Remove an encounter previously added with RegisterEncounter.
-- There's no need to update the version string because we always register after an unregister
function DXE:UnregisterEncounter(key)
	-- Sanity checks
	if key == "default" or not EDB[key] then return end
	-- Swap to default if we're trying to unregister the current encounter
	if CE.key == key then self:SetActiveEncounter("default") end
	-- Remove options
	self:RemoveEncounterOptions(EDB[key])
	-- Remove from the database
	EDB[key] = self.rdelete(EDB[key])
	-- Close options
	ACD:Close("DXE")
	-- Update triggers
	self:UpdateTriggers()
end

--- For now, get the encounter module table for distributor
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

function DXE:SetCombat(bool,event,func)
	if bool then self:RegisterEvent(event,func) end
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

function DXE:UpgradeEncounters()
	for key,data in pairs(RDB) do
		-- Upgrading to new versions
		if not EDB[key] or EDB[key].version < data.version then
			self:UnregisterEncounter(key)
			self:RegisterEncounter(data)
		-- Deleting old versions
		elseif EDB[key] and EDB[key].version >= data.version then
			RDB[key] = self.rdelete(RDB[key])
		end
	end
end

-- Start the current encounter
function DXE:StartEncounter()
	if self:IsRunning() then return end
	self.callbacks:Fire("StartEncounter")
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
local nameTriggers = {} -- Activation names. Source: data.triggers.scan
local yellTriggers = {} -- Yell activations. Source: data.triggers.yell

do
	local function addData(tbl,info,key)
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
						addData(nameTriggers,scan,key)
						hasName = true
					end
					local yell = data.triggers.yell
					if yell then 
						addData(yellTriggers,yell,key) 
						hasYell = true
					end
				end
			end
		end
		return hasName,hasYell
	end

	function DXE:UpdateTriggers()
		-- Clear trigger tables
		wipe(nameTriggers)
		wipe(yellTriggers)
		self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
		self:CancelTimer(self.scanhandle,true)
		-- Build trigger lists
		local scan, yell = BuildTriggerLists()
		-- Start invokers
		if scan then self.scanhandle = self:ScheduleRepeatingTimer("ScanUpdate",2) end
		if yell then self:RegisterEvent("CHAT_MSG_MONSTER_YELL") end
	end
end

---------------------------------------------
-- GENERIC EVENTS
---------------------------------------------

do
	local prevNumRaidMembers = 0
	local GetNumRaidMembers = GetNumRaidMembers
	function DXE:RAID_ROSTER_UPDATE()
		local numRaidMembers = GetNumRaidMembers()
		-- Raid members changed
		if numRaidMembers ~= prevNumRaidMembers then
			--@debug@
			debug("RAID_ROSTER_UPDATE","Raid members changed")
			--@end-debug@
			self:UpdatePaneVisibility()
			self:UpdateRosterTables()
		end
		-- Raid member joined the raid
		if numRaidMembers > prevNumRaidMembers then
			--@debug@
			debug("RAID_ROSTER_UPDATE","Raid member joined")
			--@end-debug@
			self:BroadcastVersion()
		end

		-- Raid member left the raid
		if numRaidMembers < prevNumRaidMembers then
			--@debug@
			debug("RAID_ROSTER_UPDATE","Raid member left")
			--@end-debug@
			self:DeleteUnusedVersions()
		end
		prevNumRaidMembers = numRaidMembers
	end
end

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
	self.loaded = true
	-- Options
	self.db = LibStub("AceDB-3.0"):New("DXEDB",self.defaults)
	self.options = self:InitializeOptions()
	self.InitializeOptions = nil
	-- Received database
	RDB = self.db:RegisterNamespace("RDB", {global = {}})
	RDB = RDB.global
	DXE.RDB = RDB
	-- Pane
	self:CreatePane()
	-- GUI Options
	AC:RegisterOptionsTable("DXE", self.options)
	ACD:SetDefaultSize("DXE", 730,500)
	-- Slash Commands
	AC:RegisterOptionsTable(L["Deus Vox Encounters"], self:GetSlashOptions(),"dxe")
	self.GetSlashOptions = nil
	-- The default encounter
	self:RegisterEncounter({key = "default", name = "Default", title = "Default", zone = ""})
	self:SetActiveEncounter("default")
	-- Register queued data 
	-- TODO: Check for versions between RDB and EDB before registering
	for _,data in ipairs(loadQueue) do self:RegisterEncounter(data) end
	loadQueue = self.delete(loadQueue)
	-- Upgrade
	self:UpgradeEncounters()
	-- Health watchers
	self:SetEnabledState(self.db.global.Enabled)
	-- Minimap
	self:SetupMinimapIcon()
	self:Print(L["Type |cffffff00/dxe|r for slash commands"])

	--@debug@
	debug = DXE:CreateDebugger("Core",self.db.global)
	--@end-debug@
end

function DXE:OnEnable()
	self.enabled = true
	self:LoadPositions()
	self:UpdateTriggers()
	self:UpdateLock()
	self:UpdatePaneVisibility()
	self:UpdatePaneScale()
	self:LayoutHealthWatchers()
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA","UpdateTriggers")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetActiveEncounter("default")
	self:EnableAllModules()
	self:RegisterComm("DXE_Core","OnCommReceived")
	self:UpdateVersionString()
	self:RequestVersions()
	self:UpdateRosterTables()
	self:BroadcastVersion()
end

function DXE:OnDisable()
	self.enabled = false
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
		local tbl = self.new()
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
	for fragment,data in pairs(yellTriggers) do
		if find(msg,fragment) then
			self:SetActiveEncounter(data.key)
			self:StopEncounter()
			self:StartEncounter()
		end
	end
end

local UnitName = UnitName
local UnitIsEnemy = UnitIsEnemy
local friendlyExceptions = {
	[L["Algalon the Observer"]] = true
}
function DXE:Scan()
	for i,unit in pairs(DXE.Roster) do
		local target = rIDtarget[i]
		local name = UnitName(target)
		if UnitExists(target) and 
			nameTriggers[name] and 
			not UnitIsDead(target) 
			-- Hack to get Algalon to activate
			and (UnitIsEnemy("player",target) or friendlyExceptions[name]) then
			-- Return name
			return nameTriggers[name]
		end
	end
	return nil
end

function DXE:ScanUpdate()
	local key = self:Scan()
	if key then self:SetActiveEncounter(key) end
end

---------------------------------------------
-- EXPLICIT SCANNING
---------------------------------------------

-- For scanning bosses

-- @return uid The unit id of the name. UnitName(raid<number>target)
-- Can pass in other functions (such as UnitGUID) to compare a
-- different unit attribute
function DXE:UnitID(name, unitattributefunc)
	unitattributefunc = unitattributefunc or UnitName
	if not name then return end
	for i,unit in pairs(DXE.Roster) do
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

function DXE:SetPlay()
	self.Pane.startStop:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Play")
	self.Pane.startStop:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Play")
end

function DXE:SetStop()
	self.Pane.startStop:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Stop")
	self.Pane.startStop:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Stop")
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
	--Pane:SetBackdropBorderColor(0.66,0.66,0.66)
	Pane:SetBackdropBorderColor(0.33,0.33,0.33)
	Pane:SetWidth(220)
	Pane:SetHeight(25)
	Pane:EnableMouse(true)
	Pane:SetMovable(true)
	Pane:SetPoint("CENTER")
	self:RegisterMoveSaving(Pane,"CENTER","UIParent","CENTER",nil,nil,true)
	self:AddTooltipText(Pane,"Pane","|cffffff00Shift + Click|r to move")
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
		PaneTextures.."Play",
		PaneTextures.."Play",
		function() self:ToggleTimer() end,
		"Start/Stop",
		"Starts the timer or simultaneously stops the timer and encounter"
	)
	
	-- Add Config control
	Pane.config = self:AddPaneButton(
		PaneTextures.."Menu",
		PaneTextures.."Menu",
		function() self:ToggleConfig() end,
		"Configuration",
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
		"Selector",
		"Activates an encounter"
	)

	Pane.lock = self:AddPaneButton(
		PaneTextures.."Locked",
		PaneTextures.."Locked",
		function() self:ToggleLock() end,
		"Locking",
		"Toggle frame anchors"
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
local sort = table.sort

do
	local function CloseAll()
		CloseDropDownMenus(1)
	end

	local function onclick(self)
		DXE:SetActiveEncounter(self.value)
		CloseDropDownMenus()
	end

	local function textsort(a,b)
		return a.text < b.text
	end

	-- Selector tables
	local infoTable = {}
	local cats = {}
	local function initialize(self,level)
		wipe(infoTable)
		wipe(cats)
		level = level or 1
		if level == 1 then
			local info = UIDropDownMenu_CreateInfo()
			info.isTitle = true 
			info.text = "Encounter Selector"
			info.notCheckable = true 
			info.justifyH = "LEFT"
			UIDropDownMenu_AddButton(info,level)
			for key,data in pairs(EDB) do
				local info = DXE.new()
				if data.zone == "" then
					info.text = data.name
					info.value = key
					info.func = onclick
					info.colorCode = "|cffffff00"
					info.owner = self
					infoTable[#infoTable+1] = info
				elseif not cats[data.zone]  then
					cats[data.zone] = true
					info.text = data.zone
					info.value = data.zone
					info.hasArrow = true
					info.notCheckable = true
					info.owner = self
					infoTable[#infoTable+1] = info
				end
			end
		elseif level == 2 then
			local category = UIDROPDOWNMENU_MENU_VALUE
			for key,data in pairs(EDB) do
				if data.zone == category then
					local info = DXE.new()
					info.hasArrow = false
					info.text = data.name
					info.owner = self
					info.value = key
					info.func = onclick
					infoTable[#infoTable+1] = info
				end
			end
		end
		sort(infoTable,textsort)
		local incombat = InCombatLockdown()
		for _,button in ipairs(infoTable) do	
		if incombat then button.disabled = true end
		UIDropDownMenu_AddButton(button,level) end
		if level == 1 then
			local info = UIDropDownMenu_CreateInfo()
			info.notCheckable = true 
			info.justifyH = "LEFT"
			info.text = "Cancel"
			info.func = CloseAll
			UIDropDownMenu_AddButton(info,1)
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
-- @return A number >= 0
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
	self:SetStop()
end

--- Stops the Pane timer
function DXE:StopTimer()
	self.Pane.timer.frame:SetScript("OnUpdate",nil)
	self:SetPlay()
	self:SetRunning(false)
end

--- Resets the Pane timer
function DXE:ResetTimer()
	elapsedTime = 0
	self.Pane.timer:SetTime(0)
end

--- Toggles the Pane timer
function DXE:ToggleTimer()
	if self:IsRunning() then
		self:StopEncounter()
	else
		self:StartTimer()
	end
end

function DXE:AlertTest()
	DXE.Alerts:CenterPopup("AlertTest1", "Decimating. Life Tap Now!", 10, 5, "ALERT1", "YELLOW", "CYAN")
	DXE.Alerts:Dropdown("AlertTest2", "Big City Opening", 20, 5, "ALERT2", "WHITE")
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
	local UnitIsFriend,UnitIsDead,UnitAffectingCombat,GetTime = UnitIsFriend,UnitIsDead,UnitAffectingCombat,GetTime
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
-- ROSTER
---------------------------------------------
local UnitGUID = UnitGUID
-- Keys are [1-40]
local Roster = {}
DXE.Roster = Roster
-- Keys are the names
local NameRoster = {}
DXE.NameRoster = NameRoster
-- Keys are the GUIDs
local GUIDRoster = {}
DXE.GUIDRoster = GUIDRoster
-- Keys are unit names
local SortedRoster = {}

-- Raid Version Tracking
-- Keys are the names
-- Values are the versions for the mod
local RosterVersions = {}
DXE.RosterVersions = RosterVersions

local sort = table.sort
local UnitIsConnected = UnitIsConnected
function DXE:UpdateRosterTables()
	--@debug@
	debug("UpdateRosterTables","Invoked")
	--@end-debug@
	wipe(Roster)
	wipe(NameRoster)
	wipe(GUIDRoster) 
	wipe(SortedRoster)
	for i,id in ipairs(rID) do
		-- Exists and is connected
		if UnitExists(id) and UnitIsConnected(id) then 
			Roster[i] = id
			NameRoster[UnitName(id)] = id
			GUIDRoster[UnitGUID(id)] = id
			SortedRoster[#SortedRoster+1] = UnitName(id)
		end 
	end
	sort(SortedRoster)
end

function DXE:GetUnitID(target)
	if find(target,"0x%x+") then 
		return GUIDRoster[target]
	else 
		return NameRoster[target]
	end
end

-- TODO: It should categorize them
function DXE:PrintRosterVersions(info, encname)
	local color = "ff99ff33"
	if encname == "" then
		encname = "DXE"
	end
	local L_name = EDB[encname]

	print(format("|cff99ff33DXE|r: Raid Version Check (%s)", encname))

	-- Check that the command is valid (i.e. in a raid with a valid encounter name)
	if GetNumRaidMembers() == 0 then
		print(L["|cffff3300Failed: You are not in a Raid|r"])
		return
	end
	if encname ~= "DXE" and not L_name then
		print(format(L["|cffff3300Failed: %s is not a known encounter|r"], encname))
		return
	end

	for _, unitname in ipairs(SortedRoster) do
		if RosterVersions[unitname] and RosterVersions[unitname][L_name] then
			local vers = RosterVersions[unitname][L_name]
			local myvers = encname == "DXE" and DXE.version or EDB[encname].version
			if vers < myvers then
				color = "ffff3300" -- red
			elseif vers == myvers then
				color = "ff99ff33" -- green
			else
				color = "ff3399ff" -- blue - above your version
			end

			print(format("|c%s%s|r: v%s",color,unitname,vers))
		else
			color = "ff999999"
			print(format("|c%s%s|r: None",color,unitname))
		end
	end
end



----------------------------------
-- COMMS
----------------------------------

-- TODO Recode comm system

-- Redo system to use a dispatch system for comms

function DXE:RequestVersions()
	--@debug@
	debug("RequestVersions","Invoked")
	--@end-debug@
	self:SendCommMessage("DXE_Core", "REQUESTVERSIONS:ARGS", "RAID")
end

function DXE:DeleteUnusedVersions()
	--@debug@
	debug("DeleteUnusedVersions","Invoked")
	--@end-debug@
	for name in pairs(RosterVersions) do
		if not NameRoster[name] then
			RosterVersions[name] = self.delete(RosterVersions[name])
		end
	end
end

local versionString
function DXE:UpdateVersionString()
	--@debug@
	debug("UpdateVersionString","Invoked")
	--@end-debug@
	local tbl = self.new()
	tbl[1] = "VERSIONBROADCAST"
	tbl[2] = format("%s,%s","DXE",DXE.version)
	for key, data in pairs(EDB) do
		if key ~= "default" then
			tbl[#tbl+1] = format("%s,%s",data.name,data.version)
		end
	end
	versionString = concat(tbl,":")
	tbl = self.delete(tbl)
end

--- Broadcasts all or a specific one. Throttles broadcasting all.
-- @param name Assumed to exist in EDB. It is only used in Distributor after downloading.
do
	-- Time since we last broadcasted
	local last = 0
	-- How long to wait to broadcast
	local waitTime = 4
	-- ScheduleTimer handle
	local handle

	function DXE:BroadcastVersion(key)
		--@debug@
		debug("BroadcastVersion","name: %s",name) 
		--@end-debug@
		local msg
		-- Broadcasts all
		if not name then
			-- Throttling
			local t = GetTime()
			if last + waitTime - 0.5 > t then
				if not handle then
					handle = self:ScheduleTimer("BroadcastVersion",waitTime)
				end
				return
			end
			handle = nil
			last = t
			msg = versionString
		-- Broadcasts a single one
		else
			if not EDB[key] then return end
			local data = EDB[key]
			msg = format("VERSIONBROADCAST:%s,%s",data.name,data.version)
		end
		self:SendCommMessage("DXE_Core", msg, "RAID")
	end
end

function DXE:OnCommReceived(prefix, msg, dist, sender)
	local commType,args = match(msg,"^(%w+):(.+)$")
	
	if commType == "VERSIONBROADCAST" then
		if not RosterVersions[sender] then
			RosterVersions[sender] = self.new()
		end
		-- TODO: Should inform you that you can get an upgrade from raid member x
		for name, vers in args:gmatch("([^:,]+),([^:,]+)") do
			RosterVersions[sender][name] = tonumber(vers)
		end
	elseif commType == "REQUESTVERSIONS" and sender ~= self.pName then
		self:BroadcastVersion()
	end
	--@debug@
	if type(args) == "string" then args = #args > 10 and args:sub(1,15).."..." or args end
	debug("OnCommReceived","type: %s sender: %s args: %s",commType,sender,args)
	--@end-debug@
end

_G.DXE = DXE
