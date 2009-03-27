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

local floor = math.floor
local gsub,format = string.gsub,string.format
local insert,wipe = table.insert,table.wipe
local setmetatable = setmetatable
local UnitGUID,UnitName,UnitIsFriend,UnitIsDead = UnitGUID,UnitName,UnitIsFriend,UnitIsDead

local Pane

---------------------------------------------
-- UNIT IDS
---------------------------------------------

local rID,rIDtarget = {},{}
for i=1,40 do
	rID[i] = "raid"..i
	rIDtarget[i] = "raid"..i.."target"
end

---------------------------------------------
-- ENCOUNTER DATABASE
---------------------------------------------

local EDB = {}
DXE.EDB = EDB
local Current -- Current Encounter data

local LoadQueue = {}
function DXE:RegisterEncounter(data)
	-- Save for loading after initialization
	if not self.Loaded then LoadQueue[#LoadQueue+1] = data return end
	-- Validate data
	self:ValidateData(data)
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
	if Current.name == name then self:SetActiveEncounter("Default") end
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
	return Current and Current.name or "Default"
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
	if Current and Current.name == name then return end
	self:SetAutoStart(false)
	self:SetAutoStop(false)
	-- Stop the existing encounter
	self:StopEncounter() 
	-- Unregister regen events
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	-- Reset timer
	self:ResetTimer()
	-- Update Current upvalue
	Current = EDB[name]
	-- Update Encounter data
	self.Invoker:SetData(Current)
	-- Set folder value
	Pane.SetFolderValue(name)
	-- Set pane updating and starting/stopping
	if Current.onactivate then
		self:SetAutoStart(Current.onactivate.autostart)
		self:SetAutoStop(Current.onactivate.autostop)
		self:SetRegenChecks(Current.onactivate)
	end

	self:SetTracing(Current.tracing)

	-- For the empty encounter
	if not self.HW[1]:IsShown() then
		self.HW[1]:SetInfoBundle(Current.title,"",1,0,0,1)
		self.HW[1].frame:Show()
	end

	self:LayoutHealthWatchers()
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
-- Auto Activating
---------------------------------------------
local ScanNames = {} -- Activation names. Source: data.triggers.scan
local YellMessages = {} -- Yell activations. Source: data.triggers.yell

--  Helper function for BuildTriggerLists
local function AddData(tbl,info,data)
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

function DXE:BuildTriggerLists()
	-- Get zone name
	local zone = GetRealZoneText()
	local flag_scan,flag_yell = false,false
	for name, data in pairs(EDB) do
		if data.zone == zone then
			if data.triggers then
				local scan = data.triggers.scan
				if scan then 
					AddData(ScanNames,scan,data)
					flag_scan = true
				end
				local yell = data.triggers.yell
				if yell then 
					AddData(YellMessages,yell,data) 
					flag_yell = true
				end
			end
		end
	end
	return flag_scan, flag_yell
end

function DXE:UpdateTriggers()
	-- Clear trigger tables
	wipe(ScanNames)
	wipe(YellMessages)
	self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
	self:CancelTimer(self.scanhandle,true)
	-- Build trigger lists
	local scan, yell = self:BuildTriggerLists()
	-- Start invokers
	if scan then self.scanhandle = self:ScheduleRepeatingTimer("ScanUpdate",2) end
	if yell then self:RegisterEvent("CHAT_MSG_MONSTER_YELL") end
end

-------------------------
-- Core Functions
-------------------------

function DXE:UpgradeEncounters()
	-- Upgrade from stored encounters
	local delete = {}
	for name,data in pairs(RDB) do
		-- Upgrading to new versions
		if not EDB[name] or EDB[name].version < data.version then
			self:UnregisterEncounter(name)
			self:RegisterEncounter(data)
		-- Deleting old versions
		elseif EDB[name] and EDB[name].version > data.version then
			delete[data.name] = true
		end
	end
	-- Actually delete old versions
	for name in pairs(delete) do
		RDB[name] = self.delete(RDB[name])
	end
end


-- Initialization
function DXE:OnInitialize()
	self.Loaded = true
	self.db = LibStub("AceDB-3.0"):New("DXEDB",self.defaults)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("DXE", self.options)
	-- The default encounter
	self:RegisterEncounter({name = "Default", title = "Default", zone = ""})
	for _,data in ipairs(LoadQueue) do self:RegisterEncounter(data) end
	self:UpgradeEncounters()
	self:InitializeHealthWatchers()
end

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

-- Move
local function Move(self)
	if IsShiftKeyDown() then
		self:StartMoving()
	end
end

-- Stop moving
local function StopMove(self)
	self:StopMovingOrSizing()
	DXE:SavePosition(self)
end

-- Registers saving positions in database
function DXE:RegisterMoveSaving(frame)
	frame:SetScript("OnMouseDown",Move)
	frame:SetScript("OnMouseUp",StopMove)
	self.db.profile.Positions[frame:GetName()] = self.db.profile.Positions[frame:GetName()] or {}
end

function DXE:OnEnable()
	--Tracer = Tracer or self.HOT:New()
	--DXE.Tracer = Tracer
	self:CreatePane()
	self:LoadPositions()
	self:RegisterEvent("RAID_ROSTER_UPDATE","UpdateRosterTable")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA","UpdateTriggers")
	self:RegisterEvent("PLAYER_ENTERING_WORLD","UpdateTriggers")
	--[[
	self:RegisterMessage("DXE_Tracer_OnAcquire","OnAcquire")
	self:RegisterMessage("DXE_Tracer_OnTrace","OnTrace")
	self:RegisterMessage("DXE_Tracer_OnLost","OnLost")
	]]
	self:UpdateRosterTable()
	self:SetActiveEncounter("Default")
	Pane:Show()
end

function DXE:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
	self:CancelAllTimers()
	self:StopEncounter()
	Pane:Hide()
end


function DXE:CHAT_MSG_MONSTER_YELL(_,msg)
	for fragment,data in pairs(YellMessages) do
		if msg:find(fragment) then
			self:SetActiveEncounter(data.name)
			self:StartEncounter()
		end
	end
end

function DXE:Scan()
	for i,unit in pairs(self:GetRoster()) do
		local target = rIDtarget[i]
		local name = UnitName(target)
		if UnitExists(target) and 
			ScanNames[name] and 
			not UnitIsDead(target) then
			-- Return name
			return ScanNames[name].name
		end
	end
end

function DXE:ScanUpdate()
	local name = self:Scan()
	if name then self:SetActiveEncounter(name) end
end

---------------------------------------------
-- PANE CREATION
---------------------------------------------

local Backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
   edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	edgeSize = 9,             
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local BackdropNoBorders = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
   --edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
}

--- Adds a control button to the encounter pane
-- @param normal The normal texture for the button
-- @param highlight The highlight texture for the button
-- @param onclick The function of the OnClick script
-- @param anchor SetPoints the control LEFT, anchor, RIGHT
function DXE:AddPaneControl(normal,highlight,onclick,anchor)
	local size = 17
	local control = CreateFrame("Button",nil,Pane)
	control:SetWidth(size)
	control:SetHeight(size)
	control:SetPoint("LEFT",anchor,"RIGHT")
	control:SetScript("OnClick",onclick)
	control:SetNormalTexture(normal)
	control:SetHighlightTexture(highlight)

	return control
end

function DXE:OpenConfig()
	ACD:Open("DXE")
end

function DXE:SetPlay()
	Pane.startStop:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Play")
	Pane.startStop:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Play")
end

function DXE:SetStop()
	Pane.startStop:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Stop")
	Pane.startStop:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Stop")
end

function DXE:CreatePane()
	Pane = CreateFrame("Frame","DXE_Pane",UIParent)
	Pane:SetClampedToScreen(true)
	Pane:SetBackdrop(Backdrop)
	Pane:SetBackdropBorderColor(0.66,0.66,0.66)
	Pane:SetWidth(220)
	Pane:SetHeight(25)
	Pane:SetPoint("CENTER",UIParent,"CENTER")
	Pane:EnableMouse(true)
	Pane:SetMovable(true)
	-- Register for position saving
	self:RegisterMoveSaving(Pane)
	local function OnUpdate() DXE:LayoutHealthWatchers() end
	Pane:HookScript("OnMouseDown",function(self) self:SetScript("OnUpdate",OnUpdate) end)
	Pane:HookScript("OnMouseUp",function(self) self:SetScript("OnUpdate",nil) end)

  	self.Pane = Pane
	
	
	Pane.timer = LibStub("AceGUI-3.0"):Create("DXE_Timer")
	Pane.timer.frame:SetParent(Pane)
	Pane.timer:SetPoint("BOTTOMLEFT",5,2)--("TOPLEFT",5,-32)-- -27
	Pane.timer.left:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",19)
	Pane.timer.right:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",11)

	local PaneTextures = "Interface\\AddOns\\DXE\\Textures\\Pane\\"

	-- Add StartStop control
	Pane.startStop = self:AddPaneControl(
		PaneTextures.."Play",
		PaneTextures.."Play",
		function() self:ToggleTimer() end,
		Pane.timer.frame
	)
	
	-- Add Config control
	Pane.config = self:AddPaneControl(
		PaneTextures.."Menu",
		PaneTextures.."Menu",
		function() self:OpenConfig() end,
		Pane.startStop
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
		Pane.config
	)

	local TitleHeight = 31 -- 22

	--[[
	-- Add spacer graphic
	local spacer = Pane:CreateTexture(nil,"BORDER")
	spacer:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-Spacer")
	spacer:SetPoint("TOPLEFT", Pane, "TOPLEFT", 2, -(TitleHeight-3))
	spacer:SetPoint("BOTTOMRIGHT", Pane, "TOPRIGHT", -2, -(TitleHeight+3))
	--spacer:SetVertexColor(0.66,0.66,0.66)
	--]]

	--[[
		local sep = Pane:CreateTexture(nil,"BORDER")
		sep:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-Spacer")
		sep:SetHeight(6)
		sep:SetWidth(Pane:GetWidth()-4)
		sep:SetPoint("LEFT",Pane,"LEFT",2,-15)
		--sep:SetPoint("RIGHT",ha,"RIGHT",0,2)
		sep:SetVertexColor(0.66,0.66,0.66)]]
		


	--[[
	-- Add health bar
	Bar = CreateFrame("StatusBar",nil,Pane)
	Bar:SetStatusBarTexture("Interface\\Addons\\DXE\\Textures\\StatusBars\\Ace")
	Bar:SetMinMaxValues(0,1)
	Bar:SetValue(1)
	Bar:SetWidth(Pane:GetWidth()-4)
	Bar:SetHeight(20)
	Bar:SetPoint("TOPLEFT",Pane,"TOPLEFT",2,-4)

	-- Add title text
	TitleText = Bar:CreateFontString(nil,"ARTWORK")
	TitleText:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",12)
	TitleText:SetWidth(Bar:GetWidth() - 40)
	TitleText:SetHeight(1)
	TitleText:SetPoint("LEFT",Bar,"LEFT",2,0)
	TitleText:SetJustifyH("LEFT")

	-- Add health text
	HealthText = Bar:CreateFontString(nil,"ARTWORK")
	HealthText:SetWidth(Bar:GetWidth()-40)
	HealthText:SetHeight(1)
	HealthText:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",12)
	HealthText:SetJustifyH("RIGHT")
	HealthText:SetPoint("RIGHT",Bar,"RIGHT")
	]]
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
-- Has the timer started?
local Running
-- Elapsed time of the timer
local ElapsedTime

--[[
function DXE:SetInfoBundle(titleText, healthText, perc, r, g, b)
	--if not r then r,g,b = GetGradientColor(perc) end
	Bar:SetValue(perc)
	Bar:SetStatusBarColor(r or (perc > 0.5 and ((1.0 - perc) * 2) or 1.0),g or (perc > 0.5 and 1 or (perc * 2)),b or 0.0)
	TitleText:SetText(titleText)
	HealthText:SetText(healthText)
end
]]

--- Returns the encounter start time based off GetTime()
-- @return A number >= 0
function DXE:GetElapsedTime()
	return ElapsedTime
end

--- Returns whether or not the timer is running
-- @return A boolean
function DXE:IsRunning()
	return Running
end

function DXE:SetRunning(bool)
	Running = bool
end

local function Timer_OnUpdate(self,elapsed)
	ElapsedTime = ElapsedTime + elapsed
	self.obj:SetTime(ElapsedTime)
end

--- Starts the Pane timer
function DXE:StartTimer()
	ElapsedTime = 0
	self:SendMessage("DXE_StartEncTimer",ElapsedTime)
	Pane.timer.frame:SetScript("OnUpdate",Timer_OnUpdate)
	self:SetRunning(true)
	self:SetStop()
end

--- Stops the Pane timer
function DXE:StopTimer()
	Pane.timer.frame:SetScript("OnUpdate",nil)
	self:SetPlay()
	self:SetRunning(false)
end

--- Resets the Pane timer
function DXE:ResetTimer()
	ElapsedTime = 0
	Pane.timer:SetTime(0)
	self:StopTimer()
end

--- Toggles the Pane timer
function DXE:ToggleTimer()
	if Running then
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
	HW[1]:SetCallback("HW_TRACER_UPDATE",function(self,name,uid) DXE:TRACER_UPDATE(uid) end)
	HW[1]:EnableUpdates()
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
	local cutoff = GetScreenHeight()/2
	local x,y = self.Pane:GetCenter()
	local point = y > cutoff and "TOP" or "BOTTOM"
	local relPoint = y > cutoff and "BOTTOM" or "TOP"
	local anchor = self.Pane
	for i,hw in ipairs(self.HW) do
		if hw.frame:IsShown() then
			hw:ClearAllPoints()
			hw:SetPoint(point,anchor,relPoint)
			anchor = hw.frame
		end
	end
end

--[[
function DXE:UpdateHWArea()
	local ha = Pane.hwArea
	local width,height = ha:GetWidth(),ha:GetHeight()
	for _,hw in ipairs(HW) do
		hw.frame:SetFrameLevel(ha:GetFrameLevel()+1)
	end
		--frame:SetScript("OnSizeChanged",function() print("TEST") end)
		--for k,v in ipairs(HW) do
		--	v.frame:SetScript("OnSizeChanged",function() print("TEST") end)
		--end
	local num = 4
	if num == 1 then
		HW[1]:ClearAllPoints()
		HW[1]:SetHeight(height)
		HW[1]:SetPoint("LEFT",ha,"LEFT",0.5,0)
		HW[1]:SetPoint("RIGHT",ha,"RIGHT",-0.5,0)
		--self:SetHWInfoBundle(1,"Stalagg", "100%", 1, 0, 1, 0)
		HW[1].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",12)
		HW[1].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",12)
	elseif num == 2 then
		HW[1]:ClearAllPoints()
		HW[1]:SetHeight((height/2)-1)
		HW[1]:SetWidth(width-2)
		HW[1]:SetPoint("TOP",ha,"TOP")
		self:SetHWInfoBundle(1,"Stalagg", "100%", 1, 0, 1, 0)
		HW[1].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		HW[1].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)

		HW[2]:ClearAllPoints()
		HW[2]:SetHeight((height/2)-1)
		HW[2]:SetWidth(width-2)
		HW[2]:SetPoint("BOTTOM",ha,"BOTTOM")
		self:SetHWInfoBundle(2,"Feugan", "100%", 1, 1, 0, 0)
		HW[2].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		HW[2].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
	elseif num == 3 then
		HW[1]:ClearAllPoints()
		HW[1]:SetHeight((height/3)-1)
		HW[1]:SetWidth(width-2)
		HW[1]:SetPoint("TOPLEFT",ha,"TOPLEFT",1,0)
		self:SetHWInfoBundle(1,"Stalagg", "100%", 1, 0, 1, 0)
		HW[1].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",9)
		HW[1].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",9)

		HW[2]:ClearAllPoints()
		HW[2]:SetHeight((height/3)-1)
		HW[2]:SetWidth(width-2)
		HW[2]:SetPoint("TOPLEFT",HW[1].frame,"BOTTOMLEFT",0,-1)
		self:SetHWInfoBundle(2,"Feugan", "100%", 1, 1, 0, 0)
		HW[2].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",9)
		HW[2].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",9)

		HW[3]:ClearAllPoints()
		HW[3]:SetHeight((height/3)-1)
		HW[3]:SetWidth(width-2)
		HW[3]:SetPoint("TOPLEFT",HW[2].frame,"BOTTOMLEFT",0,-1)
		self:SetHWInfoBundle(3,"Stalagg", "100%", 1, 0, 1, 0)
		HW[3].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",9)
		HW[3].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",9)
	elseif num == 4 then
		HW[1]:ClearAllPoints()
		HW[1]:SetHeight((height/2)-1)
		HW[1]:SetWidth((width/2)-1)
		HW[1]:SetPoint("TOPLEFT",ha,"TOPLEFT")
		self:SetHWInfoBundle(1,"Stalagg", "100%", 1, 0, 1, 0)
		HW[1].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		HW[1].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)

		HW[2]:ClearAllPoints()
		HW[2]:SetHeight((height/2)-1)
		HW[2]:SetWidth((width/2)-1)
		HW[2]:SetPoint("TOPRIGHT",ha,"TOPRIGHT")
		self:SetHWInfoBundle(2,"Feugan", "100%", 1, 1, 0, 0)
		HW[2].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		HW[2].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)

		HW[3]:ClearAllPoints()
		HW[3]:SetHeight((height/2)-1)
		HW[3]:SetWidth((width/2)-1)
		HW[3]:SetPoint("BOTTOMLEFT",ha,"BOTTOMLEFT")
		self:SetHWInfoBundle(3,"Stalagg", "100%", 1, 0, 1, 0)
		HW[3].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		HW[3].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)

		HW[4]:ClearAllPoints()
		HW[4]:SetHeight((height/2)-1)
		HW[4]:SetWidth((width/2)-1)
		HW[4]:SetPoint("BOTTOMRIGHT",ha,"BOTTOMRIGHT")
		self:SetHWInfoBundle(4,"Archavon the Stone Watcher", "100%", 1, 1, 0, 0)
		HW[4].title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		HW[4].health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
	end	
end
]]

function DXE:TRACER_UPDATE(uid)
	if self:IsAutoStart() and not self:IsRunning() and UnitIsFriend(uid.."target","player") then
		self:StartEncounter()
	elseif self:IsAutoStop() and self:IsRunning() and (UnitIsDead(uid) or not UnitAffectedCombat(uid)) then
		self:StopEncounter()
	end
end

--[[
function DXE:TrackUnitName(name)
	Tracer:TrackUnitName(name)
end
]]

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

--[[
function DXE:OnAcquire(_,tr)
	if tr ~= Tracer then return end
	-- Do nothing
end

local function clamp(n, min, max)
	if (type(n) ~= "number") then return min end
	if(n < min) then 
		return min
	elseif(n > max) 
		then return max
	else 
		return n 
	end
end

function DXE:OnTrace(_,tr)
	if tr ~= Tracer then return end
	if AutoStart then
		if not self:IsRunning() then
			if UnitIsFriend(tr:First() .. "target", "player") then
				self:StartEncounter()
			end
		end
	end

	if AutoStop then
		if self:IsRunning() then
			if UnitIsDead(tr:First()) then
				self:StopEncounter()
			end
		end
	end

	if AutoUpdate then
		local uid = tr:First()
		local h, hm = UnitHealth(uid), UnitHealthMax(uid); if hm < 1 then hm = 1; end
		local fh = clamp(h/hm, 0, 1) 
		local name = UnitName(uid)
		self:SetInfoBundle(name, format("%0.0f%%", fh*100), fh)
	end
end

function DXE:OnLost(_,tr)
	if tr ~= Tracer then return end
	if not AutoUpdate then return end
	Bar:SetStatusBarColor(0.66,0.66,0.66)
end
]]

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

function DXE:GetRoster()
	return Roster
end

function DXE:UpdateRosterTable()
	wipe(Roster)
	for i,id in ipairs(rID) do
		if UnitExists(id) then 
			Roster[i] = id
		end 
	end
end

