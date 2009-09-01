-- Skinning is done externally
local addon = DXE

local HealthWatcher,prototype = {},{}
DXE.HealthWatcher = HealthWatcher

local UnitHealth,UnitHealthMax = UnitHealth,UnitHealthMax
local UnitIsDead = UnitIsDead
local format = string.format
local DEAD = DEAD:upper()

function HealthWatcher:New(parent)
	local hw = CreateFrame("Frame",nil,parent)
	-- Embed
	for k,v in pairs(prototype) do hw[k] = v end
	hw.events = {}

	hw:SetWidth(220); hw:SetHeight(22)

	local bar = CreateFrame("StatusBar",nil,hw)
	bar:SetMinMaxValues(0,1)
	bar:SetPoint("TOPLEFT",2,-2)
	bar:SetPoint("BOTTOMRIGHT",-2,2)
	addon:RegisterStatusBar(bar)
	hw.bar = bar
	
	local border = CreateFrame("Frame",nil,hw)
	border:SetAllPoints(true)
	border:SetFrameLevel(bar:GetFrameLevel()+1)
	hw.border = border

	-- Add title text
	title = bar:CreateFontString(nil,"ARTWORK")
	title:SetPoint("LEFT",bar,"LEFT",2,0)
	title:SetShadowOffset(1,-1)
	addon:RegisterFontString(title,10)
	hw.title = title

	-- Add health text
	health = bar:CreateFontString(nil,"ARTWORK")
	health:SetPoint("RIGHT",bar,"RIGHT",-2,0)
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
function prototype:SetTitle(text) self.title:SetText(text) end
function prototype:IsTitleSet() return self.title:GetText() ~= "..." end
function prototype:GetGoal() return self.tracer.goal end
function prototype:EnableUpdates() self.updates = true end
function prototype:SetNeutralColor(color) self.nr,self.ng,self.nb = unpack(color) end
function prototype:SetLostColor(color) self.lr,self.lg,self.lb = unpack(color) end
function prototype:ApplyNeutralColor() self.bar:SetStatusBarColor(self.nr,self.ng,self.nb) end
function prototype:ApplyLostColor() self.bar:SetStatusBarColor(self.lr,self.lg,self.lb) end
function prototype:IsOpen() return self.tracer:IsOpen() end
function prototype:Open() self.tracer:Open() end
function prototype:Close() self.tracer:Close(); self.title:SetText("") end

function prototype:SetInfoBundle(health,perc)
	self.bar:SetValue(perc)
	self.bar:SetStatusBarColor(perc > 0.5 and ((1 - perc) * 2) or 1, perc > 0.5 and 1 or (perc * 2), 0)
	self.health:SetText(health)
end

-- Events
function prototype:TRACER_ACQUIRED() self:Fire("HW_TRACER_ACQUIRED",self.tracer:First()) end
function prototype:TRACER_LOST() self:ApplyLostColor() end
function prototype:TRACER_UPDATE()
	local unit = self.tracer:First()
	if UnitIsDead(unit) then
		self:SetInfoBundle(DEAD, 0)
	else
		local h, hm = UnitHealth(unit), UnitHealthMax(unit) 
		local perc = h/hm
		self:SetInfoBundle(format("%0.0f%%", perc*100), perc)
	end
	if self.updates then
		self:Fire("HW_TRACER_UPDATE",self.tracer:First())
	end
end

