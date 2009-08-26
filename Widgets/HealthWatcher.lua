--[[
	Usage:
		local hw = AceGUI:Create("DXE_HealthWatcher")
		hw:Open("Maexxna")
		hw:EnableUpdates()
]]

local AceGUI = LibStub("AceGUI-3.0")
local UnitHealth,UnitHealthMax = UnitHealth,UnitHealthMax
local UnitIsDead = UnitIsDead
local format = string.format
local DEAD = DEAD:upper()

do
	local WidgetType = "DXE_HealthWatcher"
	local WidgetVersion = 1
	local GRAY = {0.66,0.66,0.66}
	local BLUE = {0,0,1}
	

	local function OnAcquire(self) 
		self.frame:SetParent(UIParent)
		self:SetNeutralColor(BLUE)
		self:SetLostColor(GRAY)
	end

	local function OnRelease(self) 
		self.tracer:Close()
		self.frame:SetParent(nil)
	end

	local function Track(self,trackType,goal)
		self.tracer:Track(trackType,goal)
	end

	local function SetInfoBundle(self,health,perc)
		self.bar:SetValue(perc)
		self.bar:SetStatusBarColor(perc > 0.5 and ((1 - perc) * 2) or 1, perc > 0.5 and 1 or (perc * 2), 0)
		self.health:SetText(health)
	end

	local function SetTitle(self,text)
		self.title:SetText(text)
	end

	local function IsTitleSet(self)
		return self.title:GetText() ~= "..."
	end

	local function TRACER_ACQUIRED(self)
		self:Fire("HW_TRACER_ACQUIRED",self.tracer:First())
	end

	local function TRACER_UPDATE(self)
		local unit = self.tracer:First()
		if UnitIsDead(unit) then
			self:SetInfoBundle(DEAD, 0)
		else
			local h, hm = UnitHealth(unit), UnitHealthMax(unit) 
			local perc = h/hm
			self:SetInfoBundle(format("%0.0f%%", perc*100), perc)
		end
		if self.userdata.updates then
			self:Fire("HW_TRACER_UPDATE",self.tracer:First())
		end
	end

	local function TRACER_LOST(self)
		self:ApplyLostColor()
	end

	local function IsOpen(self)
		return self.tracer:IsOpen()
	end

	local function Open(self)
		self.tracer:Open()
	end

	local function Close(self)
		self.tracer:Close()
		self.title:SetText("")
	end

	local function GetGoal(self)
		return self.tracer.goal
	end

	local function EnableUpdates(self)
		self.userdata.updates = true
	end

	local function OnWidthSet(self,width)
		self.title:SetWidth(width*0.75)
	end

	local function SetNeutralColor(self,color)
		local ud = self.userdata
		ud.nr,ud.ng,ud.nb = unpack(color)
	end

	local function SetLostColor(self,color)
		local ud = self.userdata
		ud.lr,ud.lg,ud.lb = unpack(color)
	end

	local function ApplyNeutralColor(self)
		local ud = self.userdata
		self.bar:SetStatusBarColor(ud.nr,ud.ng,ud.nb)
	end

	local function ApplyLostColor(self)
		local ud = self.userdata
		self.bar:SetStatusBarColor(ud.lr,ud.lg,ud.lb)
	end

	local backdrop = {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",          
		insets = {left = 2, right = 2, top = 2, bottom = 2}
	}

	local backdropborder = {
		edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
		edgeSize = 8,             
		insets = {left = 2, right = 2, top = 2, bottom = 2}
	}

	local function Constructor()
		local self = {}
		self.type = WidgetType
		local frame = CreateFrame("Button",nil,UIParent)
		frame:SetWidth(220)
		frame:SetHeight(22)
		frame:SetBackdrop(backdrop)

		local bar = CreateFrame("StatusBar",nil,frame)
		bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		bar:SetMinMaxValues(0,1)
		bar:SetValue(1)
		bar:SetPoint("TOPLEFT",2,-2)
		bar:SetPoint("BOTTOMRIGHT",-2,2)
		self.bar = bar
		
		local border = CreateFrame("Frame",nil,frame)
		border:SetAllPoints(true)
		border:SetBackdrop(backdropborder)
		border:SetBackdropBorderColor(0.33,0.33,0.33)
		border:SetFrameLevel(bar:GetFrameLevel()+1)
		self.border = border

		-- Add title text
		title = bar:CreateFontString(nil,"ARTWORK")
		title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		title:SetHeight(1)
		title:SetPoint("LEFT",bar,"LEFT",2,0)
		title:SetJustifyH("LEFT")
		title:SetText("...")
		title:SetShadowOffset(1,-1)
		self.title = title

		-- Add health text
		health = bar:CreateFontString(nil,"ARTWORK")
		health:SetHeight(1)
		health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",12)
		health:SetJustifyH("RIGHT")
		health:SetPoint("RIGHT",bar,"RIGHT",-2,0)
		health:SetShadowOffset(1,-1)
		self.health = health
		
		self.TRACER_UPDATE = TRACER_UPDATE
		self.TRACER_LOST = TRACER_LOST
		self.TRACER_ACQUIRED = TRACER_ACQUIRED

		self.tracer = DXE.Tracer:New()
		self.tracer:SetCallback(self,"TRACER_UPDATE")
		self.tracer:SetCallback(self,"TRACER_LOST")
		self.tracer:SetCallback(self,"TRACER_ACQUIRED")

		self.OnAcquire = OnAcquire
		self.OnRelease = OnRelease
		self.Track = Track
		self.SetInfoBundle = SetInfoBundle
		self.EnableUpdates = EnableUpdates
		self.OnWidthSet = OnWidthSet
		self.IsOpen = IsOpen
		self.Open = Open
		self.Close = Close
		self.GetGoal = GetGoal
		self.SetTitle = SetTitle
		self.IsTitleSet = IsTitleSet
		self.ApplyLostColor = ApplyLostColor
		self.ApplyNeutralColor = ApplyNeutralColor
		self.SetNeutralColor = SetNeutralColor
		self.SetLostColor = SetLostColor
		
		self.frame = frame
		frame.obj = self

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(WidgetType,Constructor,WidgetVersion)
end
