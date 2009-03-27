---------------------------------------------
-- DEFAULTS
---------------------------------------------

local defaults = {
	global = {
		Enabled = true,
	},
	profile = {
		Positions = {},
		Encounters = {},
		Distributor = {
			AutoAccept = true,
		},
	},
}

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local DXE = LibStub("AceAddon-3.0"):NewAddon("DXE","AceEvent-3.0","AceTimer-3.0","AceConsole-3.0")
DXE.callbacks = LibStub("CallbackHandler-1.0"):New(DXE)
_G.DXE = DXE
DXE.defaults = defaults

---------------------------------------------
-- UTILITY 
---------------------------------------------
local ipairs,pairs = ipairs,pairs

DXE.noop = function() end

-- Requires a ChatWindow named 'DXE Debug'
DXE.debug = function(...)
	local debugframe
	for i=1,NUM_CHAT_WINDOWS do
		local windowName = GetChatWindowInfo(i);
		if windowName == "DXE Debug" then
			debugframe = _G["ChatFrame"..i]
			break
		end
	end
	if debugframe then
		DXE:Print(debugframe,...)
	end
end

do
	local cache = {}
	setmetatable(cache,{__mode = "kv"})
	local new = function()
		local t = next(cache) or {}
		cache[t] = nil
		return t
	end

	local delete = function(t)
		if type(t) ~= "table" then return end
		for k in pairs(t) do
			t[k] = nil
		end
		cache[t] = true
		return nil
	end

	DXE.new = new
	DXE.delete = delete
end

DXE.tablesize = function(t)
	local n = 0
	for _ in pairs(t) do n = n + 1 end
	return n
end

DXE.icons = setmetatable({}, {__index =
	function(self, key)
		if not key then return end
		local value = nil
		if type(key) == "number" then value = select(3, GetSpellInfo(key)) end
		self[key] = value
		return value
	end
})

---------------------------------------------
-- RECEIVED DATABASE
---------------------------------------------

DXERecDB = DXERecDB or {}
local RDB = DXERecDB
DXE.RDB = RDB

---------------------------------------------
-- UPVALUES
---------------------------------------------

local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local insert,wipe = table.insert,table.wipe

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
	if EDB[data.name] then error("Encounter already exists - Requires unregistering") return end
	-- Only encounters with field key have options
	if data.key then
		-- Add options
		self:AddEncounterOptions(data)
		-- Refresh defaults
		self.db:RegisterDefaults(self.defaults)
	end
	-- Replace Rev keyword
	if data.version and type(data.version) == "string" then
		data.version = tonumber(data.version:match("$Rev: (%d+) %$"))
	end
	-- Add data to database
	EDB[data.name] = data
	-- Build trigger lists
	self:UpdateTriggers()
end

--- Remove an encounter previously added with RegisterEncounter.
function DXE:UnregisterEncounter(name)
	-- Sanity checks
	if name == "Default" or not EDB[name] then return end
	-- Swap to default if we're trying to unregister the current encounter
	if CE.name == name then self:SetActiveEncounter("Default") end
	-- Remove options
	self:RemoveEncounterOptions(EDB[name])
	-- Remove from the database
	EDB[name] = self.delete(EDB[name])
	-- Close options
	ACD:Close("DXE")
	-- Update triggers
	self:UpdateTriggers()
end

--- For now, get the encounter module table for distributor
function DXE:GetEncounterData(name)
	return EDB[name]
end

function DXE:SetEncounterData(name,data)
	EDB[name] = data
end

--- Get the name of the currently-active encounter
function DXE:GetActiveEncounter()
	return CE and CE.name or "Default"
end

function DXE:SetRegenChecks(trig)
	if not trig then return end
	if trig.entercombat then
		self:RegisterEvent("PLAYER_REGEN_DISABLED","CheckForEngage")
	end
	if trig.leavecombat then
		self:RegisterEvent("PLAYER_REGEN_ENABLED","CheckForWipe")
	end
end

--- Change the currently-active encounter.
function DXE:SetActiveEncounter(name)
	assert(type(name) == "string","String expected in SetActiveEncounter")
	-- Check the new encounter
	if not EDB[name] then return end
	-- Already set to this encounter
	if CE and CE.name == name then return end
	self:SetAutoStart(false)
	self:SetAutoStop(false)
	-- Stop the existing encounter
	self:StopEncounter() 
	-- Unregister regen events
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	-- Reset timer
	-- Update CE upvalue
	CE = EDB[name]
	-- Update Encounter data
	self.Invoker:SetData(CE)
	-- Set folder value
	self.Pane.SetFolderValue(name)
	-- Set pane updating and starting/stopping
	if CE.onactivate then
		self:SetAutoStart(CE.onactivate.autostart)
		self:SetAutoStop(CE.onactivate.autostop)
		self:SetRegenChecks(CE.onactivate)
	end

	self:SetTracing(CE.tracing)

	-- For the empty encounter
	if not self.HW[1]:IsShown() then
		self.HW[1]:SetInfoBundle(CE.title,"",1,0,0,1)
		self.HW[1].frame:Show()
	end

	self:LayoutHealthWatchers()
end

function DXE:UpgradeEncounters()
	-- Upgrade from stored encounters
	local deleteQueue = self.new()
	for name,data in pairs(RDB) do
		-- Upgrading to new versions
		if not EDB[name] or EDB[name].version < data.version then
			self:UnregisterEncounter(name)
			self:RegisterEncounter(data,true)
		-- Deleting old versions
		elseif EDB[name] and EDB[name].version > data.version then
			deleteQueue[data.name] = true
		end
	end
	-- Actually delete old versions
	for name in pairs(deleteQueue) do
		RDB[name] = self.delete(RDB[name])
	end
end

function DXE:StartEncounter()
	if self:IsRunning() then return end
	self:SendMessage("DXE_StartEncounter")
	self:StartTimer()
end

--- Stop the current encounter.
function DXE:StopEncounter()
	self:SendMessage("DXE_StopEncounter")
	self:StopTimer()
end

---------------------------------------------
-- TRIGGER BUILDING
---------------------------------------------
local nameTriggers = {} -- Activation names. Source: data.triggers.scan
local yellTriggers = {} -- Yell activations. Source: data.triggers.yell

do
	local function addData(tbl,info,data)
		if type(info) == "table" then
			-- Info contains names
			for _,name in ipairs(info) do
				tbl[name] = data
			end
		else
			-- Info is name
			tbl[info] = data
		end
	end

	local function BuildTriggerLists()
		-- Get zone name
		local zone = GetRealZoneText()
		local hasName,hasYell = false,false
		for name, data in pairs(EDB) do
			if data.zone == zone then
				if data.triggers then
					local scan = data.triggers.scan
					if scan then 
						addData(nameTriggers,scan,data)
						hasName = true
					end
					local yell = data.triggers.yell
					if yell then 
						addData(yellTriggers,yell,data) 
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
-- ACE ADDON FUNCTIONS
---------------------------------------------

-- Initialization
function DXE:OnInitialize()
	self.loaded = true
	self.db = LibStub("AceDB-3.0"):New("DXEDB",self.defaults)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("DXE", self.options)
	-- The default encounter
	self:RegisterEncounter({name = "Default", title = "Default", zone = ""})
	-- Register queued data
	for _,data in ipairs(loadQueue) do self:RegisterEncounter(data) end
	loadQueue = self.delete(loadQueue)
	self:UpgradeEncounters()
	self:InitializeHealthWatchers()
end

function DXE:OnEnable()
	self:BuildPane()
	self:LoadPositions()
	self:UpdateRosterTable()
	self:UpdateTriggers()
	self:RegisterEvent("RAID_ROSTER_UPDATE","UpdateRosterTable")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA","UpdateTriggers")
	self:RegisterEvent("PLAYER_ENTERING_WORLD","UpdateTriggers")
	self:SetActiveEncounter("Default")
end

function DXE:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
	self:CancelAllTimers()
	self:SetActiveEncounter("Default")
	self.Pane:Hide()
end

---------------------------------------------
-- POSITIONING
---------------------------------------------

-- Saves position
function DXE:SavePosition(f)
	local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
	local name = f:GetName()
	self.db.profile.Positions[name].xOfs = xOfs
	self.db.profile.Positions[name].yOfs = yOfs
	self.db.profile.Positions[name].point = point
	self.db.profile.Positions[name].relativeTo = relativeTo
	self.db.profile.Positions[name].relativePoint = relativePoint
end


-- Loads position
function DXE:LoadPositions()
	for k,v in pairs(self.db.profile.Positions) do
		local f = _G[k]
		if f then
			-- Doesn't exist in database
			if not v.point then
				f:ClearAllPoints()
				f:SetPoint("CENTER",UIParent,"CENTER")
			else
				f:ClearAllPoints()
				f:SetPoint(v.point,_G[v.relativeTo] or UIParent,v.relativePoint,v.xOfs,v.yOfs)
			end
		end
	end
end

do
	-- Move
	local function startmoving(self)
		if IsShiftKeyDown() then
			self:StartMoving()
		end
	end

	-- Stop moving
	local function stopmoving(self)
		self:StopMovingOrSizing()
		DXE:SavePosition(self)
	end

	-- Registers saving positions in database
	function DXE:RegisterMoveSaving(frame)
		frame:SetScript("OnMouseDown",startmoving)
		frame:SetScript("OnMouseUp",stopmoving)
		self.db.profile.Positions[frame:GetName()] = self.db.profile.Positions[frame:GetName()] or {}
	end
end

---------------------------------------------
-- TRIGGERING
---------------------------------------------

local find = string.find
function DXE:CHAT_MSG_MONSTER_YELL(_,msg)
	for fragment,data in pairs(yellTriggers) do
		if find(msg,fragment) then
			self:SetActiveEncounter(data.name)
			self:StartEncounter()
		end
	end
end

local UnitName = UnitName
function DXE:Scan()
	for i,unit in pairs(DXE.Roster) do
		local target = rIDtarget[i]
		local name = UnitName(target)
		if UnitExists(target) and 
			nameTriggers[name] and 
			not UnitIsDead(target) then
			-- Return name
			return nameTriggers[name].name
		end
	end
end

function DXE:ScanUpdate()
	local name = self:Scan()
	if name then self:SetActiveEncounter(name) end
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

--- Adds a control button to the encounter pane
-- @param normal The normal texture for the button
-- @param highlight The highlight texture for the button
-- @param onclick The function of the OnClick script
-- @param anchor SetPoints the control LEFT, anchor, RIGHT
function DXE:AddPaneControl(normal,highlight,onclick,anchor,name,text)
	local size = 17
	local control = CreateFrame("Button",nil,self.Pane)
	control:SetWidth(size)
	control:SetHeight(size)
	control:SetPoint("LEFT",anchor,"RIGHT")
	control:SetScript("OnClick",onclick)
	control:SetNormalTexture(normal)
	control:SetHighlightTexture(highlight)
	self:AddTooltipText(control,name,text)

	return control
end

function DXE:OpenConfig()
	ACD:Open("DXE")
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

function DXE:BuildPane()
	if self.Pane then self.Pane:Show() return end
	local Pane = CreateFrame("Frame","DXE_Pane",UIParent)
	Pane:SetClampedToScreen(true)
	Pane:SetBackdrop(backdrop)
	Pane:SetBackdropBorderColor(0.66,0.66,0.66)
	Pane:SetWidth(220)
	Pane:SetHeight(25)
	Pane:SetPoint("CENTER",UIParent,"CENTER")
	Pane:EnableMouse(true)
	Pane:SetMovable(true)
	self:RegisterMoveSaving(Pane)
	self:AddTooltipText(Pane,"Pane","Shift + Left Click to move")
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
	Pane.startStop = self:AddPaneControl(
		PaneTextures.."Play",
		PaneTextures.."Play",
		function() self:ToggleTimer() end,
		Pane.timer.frame,
		"Start/Stop",
		"Starts the timer or simultaneously stops the timer and encounter"
	)
	
	-- Add Config control
	Pane.config = self:AddPaneControl(
		PaneTextures.."Menu",
		PaneTextures.."Menu",
		function() self:OpenConfig() end,
		Pane.startStop,
		"Configuration",
		"Opens the settings window"
	)

	-- Create dropdown menu for folder
	local selector = self:CreateSelector()
	Pane.SetFolderValue = function(name)
		UIDropDownMenu_SetSelectedValue(selector,name)
	end
	-- Add Folder control
	Pane.folder = self:AddPaneControl(
		PaneTextures.."Folder",
		PaneTextures.."Folder",
		function() ToggleDropDownMenu(1,nil,selector,Pane.folder,0,0) end,
		Pane.config,
		"Selector",
		"Activates an encounter"
	)
end

---------------------------------------------
-- SELECTOR CREATION
---------------------------------------------
local sort = table.sort

do
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
			for name,data in pairs(EDB) do
				local info = {}
				if data.zone == "" then
					info.text = name
					info.value = name
					info.func = onclick
					info.colorCode = "|cffffff00"
					info.owner = self
					insert(infoTable,info)
				elseif not cats[data.zone]  then
					cats[data.zone] = true
					info.text = data.zone
					info.value = data.zone
					info.hasArrow = true
					info.notCheckable = true
					info.owner = self
					insert(infoTable,info)
				end
			end
		elseif level == 2 then
			local category = UIDROPDOWNMENU_MENU_VALUE
			for name,data in pairs(EDB) do
				if data.zone == category then
					local info = {}
					info.hasArrow = false
					info.text = name
					info.owner = self
					info.value = name
					info.func = onclick
					insert(infoTable,info)
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
			info.func = CloseDropDownMenus
			UIDropDownMenu_AddButton(info,1)
		end
	end

	function DXE:CreateSelector()
		local selector = CreateFrame("Frame", "DXE_Selector", UIParent, "UIDropDownMenuTemplate") 
		UIDropDownMenu_Initialize(selector, initialize, "MENU")
		UIDropDownMenu_SetSelectedValue(selector,"Default")
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
		self:StopTimer()
		self:StopEncounter()
	else
		self:StartTimer()
	end
end

function DXE:AlertTest()
	DXE.Alerts:CenterPopup("AlertTest1", "Decimating. Life Tap Now!", 10, 5, "ALERT1", "YELLOW", "CYAN")
	DXE.Alerts:Dropdown("AlertTest2", "Big City Opening", 20, 5, "ALERT2", "WHITE")
	DXE.Alerts:Simple("Gay","ALERT3",3)
end

---------------------------------------------
-- HEALTH WATCHERS
---------------------------------------------
local HW = {}
DXE.HW = HW

-- Create health watchers
function DXE:InitializeHealthWatchers()
	HW[1] = AceGUI:Create("DXE_HealthWatcher")
	HW[2] = AceGUI:Create("DXE_HealthWatcher")
	HW[3] = AceGUI:Create("DXE_HealthWatcher")
	HW[4] = AceGUI:Create("DXE_HealthWatcher")

	-- Only the main one sends updates
	HW[1]:SetCallback("HW_TRACER_UPDATE",function(self,event,uid) DXE:TRACER_UPDATE(uid) end)
	HW[1]:EnableUpdates()

	-- OnAcquired
	local onacquire = function(self,event,uid) DXE.callbacks:Fire("HW_TRACER_ACQUIRED",uid) end
	for i=1,4 do HW[i]:SetCallback("HW_TRACER_ACQUIRED",onacquire) end
end

function DXE:CloseAllHW()
	for i=1,4 do HW[i]:Close(); HW[i].frame:Hide() end
end

-- Names should be validated to be an array of size 4
function DXE:SetTracing(names)
	self:CloseAllHW()
	if not names then return end
	for i,name in ipairs(names) do
		HW[i]:SetInfoBundle(name,"",1,0,0,1)
		HW[i]:Open(name)
		HW[i].frame:Show()
	end
	self:LayoutHealthWatchers()
end

function DXE:LayoutHealthWatchers()
	local midY = GetScreenHeight()/2
	local x,y = self.Pane:GetCenter()
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

local UnitIsFriend,UnitIsDead = UnitIsFriend,UnitIsDead
function DXE:TRACER_UPDATE(uid)
	if self:IsAutoStart() and not self:IsRunning() and UnitIsFriend(uid.."target","player") then
		self:StartEncounter()
	elseif self:IsAutoStop() and self:IsRunning() and (UnitIsDead(uid) or not UnitAffectedCombat(uid)) then
		self:StopEncounter()
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
---------------------------------------------

local UnitIsFeignDeath = UnitIsFeignDeath
local UnitAffectingCombat = UnitAffectingCombat

function DXE:CheckForWipe()
	if not UnitIsFeignDeath("player") then
		local name = DXE:Scan()
		if not name then
			self:StopEncounter()	
			return
		end
	end
	if not UnitAffectingCombat("player") then
		self:ScheduleTimer("CheckForWipe",2)
	end
end

function DXE:CheckForEngage()
	local name = self:Scan()
	if name then
		self:StartEncounter()
	elseif UnitAffectingCombat("player") then
		self:ScheduleTimer("CheckForEngage",2) 
	end
end

---------------------------------------------
-- ROSTER
---------------------------------------------
local Roster = {}
DXE.Roster = Roster

function DXE:UpdateRosterTable()
	wipe(Roster)
	for i,id in ipairs(rID) do
		if UnitExists(id) then 
			Roster[i] = id
		end 
	end
end
