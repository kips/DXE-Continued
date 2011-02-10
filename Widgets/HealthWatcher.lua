-- Skinning is done externally
local addon = DXE

local HealthWatcher,prototype = {},{}
DXE.HealthWatcher = HealthWatcher

local UnitHealth,UnitHealthMax = UnitHealth,UnitHealthMax
local UnitPower,UnitPowerMax,UnitPowerType = UnitPower,UnitPowerMax,UnitPowerType
local PowerBarColor = PowerBarColor
local UnitIsDead = UnitIsDead
local format = string.format
local DEAD = DEAD:upper()

function HealthWatcher:SetupSecure(parent)
	-- Set up the secure frame for click interaction (Shuang)
	local secure = CreateFrame("Button","hwSecure"..parent.index,parent,"SecureActionButtonTemplate")
	secure:RegisterForClicks("AnyUp", "AnyDown")
	
	-- Set up targetting (Shuang)
	secure:SetAttribute("type1", "macro");
	secure:SetAttribute("macrotext1", "/raid Oops! Something went wrong with DXE targeting");
	-- for an unknown reason the shift left click does not work... (Shuang)
	secure:SetAttribute("type2", "macro");
	secure:SetAttribute("macrotext2", "/raid Oops! Something went wrong with DXE focusing");
	
	secure:SetAllPoints(parent)
	secure:SetWidth(parent:GetWidth())
	secure:SetHeight(parent:GetHeight())
	secure:SetFrameStrata("HIGH")
	
	parent.secure = secure
end

function HealthWatcher:New(parent, index)
	local hw = CreateFrame("Button", "hw"..index , parent)
	hw.index = index
	-- Embed
	for k,v in pairs(prototype) do hw[k] = v end
	hw.events = {}

	hw:SetWidth(220); hw:SetHeight(22)
	addon:RegisterBackground(hw)

	-- Health
	local healthbar = CreateFrame("StatusBar","heatlhbar"..index,hw)
	healthbar:SetMinMaxValues(0,1)
	healthbar:SetPoint("TOPLEFT",2,-2)
	healthbar:SetPoint("BOTTOMRIGHT",-2,2)
	addon:RegisterStatusBar(healthbar)
	hw.healthbar = healthbar

	-- Power
	local powerbar = CreateFrame("StatusBar","powerbar"..index,hw)
	powerbar:SetMinMaxValues(0,1)
	powerbar:SetPoint("BOTTOMLEFT",healthbar,"BOTTOMLEFT")
	powerbar:SetPoint("BOTTOMRIGHT",healthbar,"BOTTOMRIGHT")
	powerbar:SetHeight(5)
	powerbar:SetFrameLevel(healthbar:GetFrameLevel()+1)
	powerbar:Hide()
	addon:RegisterStatusBar(powerbar)
	hw.powerbar = powerbar
	
	local border = CreateFrame("Frame",nil,hw)
	border:SetAllPoints(true)
	border:SetFrameLevel(healthbar:GetFrameLevel()+3)
	addon:RegisterBorder(border)
	hw.border = border

	-- parent for font strings so they appears above powerbar
	local region = CreateFrame("Frame",nil,healthbar)
	region:SetAllPoints(true)
	region:SetFrameLevel(healthbar:GetFrameLevel()+10)

	-- Add title text
	title = region:CreateFontString(nil,"ARTWORK")
	title:SetPoint("LEFT",healthbar,"LEFT",2,0)
	title:SetShadowOffset(1,-1)
	addon:RegisterFontString(title,10)
	hw.title = title

	-- Add health text
	health = region:CreateFontString(nil,"ARTWORK")
	health:SetPoint("RIGHT",healthbar,"RIGHT",-2,0)
	health:SetShadowOffset(1,-1)
	addon:RegisterFontString(health,12)
	hw.health = health

	local tracer = addon.Tracer:New()
	tracer:SetCallback(hw,"TRACER_UPDATE")
	tracer:SetCallback(hw,"TRACER_LOST")
	tracer:SetCallback(hw,"TRACER_ACQUIRED")
	hw.tracer = tracer

	return hw
end

--------------------------
-- PROTOTYPE
--------------------------

function prototype:SetCallback(event, func) self.events[event] = func end
function prototype:Fire(event, ...) if self.events[event] then self.events[event](self,event,...) end end
function prototype:Track(trackType,goal) self.tracer:Track(trackType,goal) end
function prototype:SetTitle(text) 
	self.title:SetText(text) 
	
	-- set the macro text attributes here since it isn't being properly set elsewhere
	if not self.counter and not InCombatLockdown() and text ~= "Default" then
		-- set up the secure stuff *after* the non-secure so the watching works
		HealthWatcher:SetupSecure(self)
		self.secure:HookScript("OnEnter",function(self) addon.Pane.MouseIsOver = true; addon:UpdatePaneVisibility() end)
		self.secure:HookScript("OnLeave",function(self) addon.Pane.MouseIsOver = false; addon:UpdatePaneVisibility()end)

		self.secure:SetAttribute("macrotext1", format("/targetexact %s", text));
		self.secure:SetAttribute("macrotext2", format("/targetexact %s\n/focus\n/targetlasttarget ", text));
	end
end
function prototype:IsTitleSet() return self.title:GetText() ~= "..." end
function prototype:GetGoal() return self.tracer.goal end
function prototype:EnableUpdates() self.updates = true end
function prototype:SetNeutralColor(color) self.nr,self.ng,self.nb = unpack(color) end
function prototype:SetLostColor(color) self.lr,self.lg,self.lb = unpack(color) end

function prototype:ApplyNeutralColor() 
	self.healthbar:SetStatusBarColor(self.nr,self.ng,self.nb) 
	if not self.powercolor and self.power then self.powerbar:SetStatusBarColor(self.nr,self.ng,self.nb) end
end

function prototype:ApplyLostColor()
	self.healthbar:SetStatusBarColor(self.lr,self.lg,self.lb) 
	if not self.powercolor and self.power then self.powerbar:SetStatusBarColor(self.lr,self.lg,self.lb) end
end

function prototype:IsOpen() return self.tracer:IsOpen() end

function prototype:ShowPower()
	self.power = true
	self.powerbar:Show()
	self.powercolor = nil
end

function prototype:Open(power)
	self.tracer:Open() 
end

function prototype:Close() 
	self.tracer:Close()
	self.title:SetText("")
	if self.power then
		self.power = nil
		self.powercolor = nil
		self.powerbar:Hide()
		self.powerbar:SetValue(0)
	end
end

function prototype:SetInfoBundle(health,hperc,pperc)
	if not self.counter then
		self.healthbar:SetValue(hperc)
		self.healthbar:SetStatusBarColor(hperc > 0.5 and ((1 - hperc) * 2) or 1, hperc > 0.5 and 1 or (hperc * 2), 0)
		self.health:SetText(health)
		if self.power and pperc then self.powerbar:SetValue(pperc) end
	else -- hijack function for counter data... (Shuang)
		local current 	= tonumber(health)
		if not current then return end
		local total		= hperc
		local percent 	= current / total
		local text		= tostring(current).. " / "..tostring(total)
		
		self.healthbar:SetValue(percent)
		self.healthbar:SetStatusBarColor(percent > 0.5 and ((1 - percent) * 2) or 1, percent > 0.5 and 1 or (percent * 2), 0)
		self.health:SetText(text)
	end
end

-- Counter code
function prototype:ShowCounter(counter)
	self.counter = counter
end

-- Events
function prototype:TRACER_LOST() self:ApplyLostColor() end

function prototype:TRACER_ACQUIRED() 
	local unit = self.tracer:First()
	self:Fire("HW_TRACER_ACQUIRED",unit)
	if not self.powercolor and self.power then
		-- Saurfang apparently returns three extra arguments
		local ix,type,r,g,b = UnitPowerType(unit)
		if r and g and b then
			self.powerbar:SetStatusBarColor(r,g,b)
		else
			-- numeric indexes are fallbacks according to blizzard
			local c = PowerBarColor[type] or PowerBarColor[ix]
			if not c then return end
			self.powerbar:SetStatusBarColor(c.r,c.g,c.b)
		end
		self.powercolor = true
	end
end

function prototype:TRACER_UPDATE()
	if self.counter then
		local current 	= tonumber(DXE.Invoker.userdata[self.counter.."_current"])
		local total		= tonumber(DXE.Invoker.userdata[self.counter.."_total"])
		self:SetInfoBundle(current, total)
		return
	end

	local unit = self.tracer:First()
	if UnitIsDead(unit) then
		self:SetInfoBundle(DEAD, 0, 0)
	else
		local h, hm = UnitHealth(unit), UnitHealthMax(unit) 
		local hperc = h/hm
		local pperc
		if self.power then pperc = UnitPower(unit)/UnitPowerMax(unit) end
		self:SetInfoBundle(format("%0.0f%%", hperc*100), hperc, pperc)
	end
	if self.updates then
		self:Fire("HW_TRACER_UPDATE",self.tracer:First())
	end
end

