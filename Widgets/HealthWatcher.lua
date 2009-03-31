--[[
	Usage:
		local hw = AceGUI:Create("DXE_HealthWatcher")
		hw:Open("Maexxna")
		hw:EnableUpdates()
]]

local AceGUI = LibStub("AceGUI-3.0")
local UnitHealth,UnitHealthMax=UnitHealth,UnitHealthMax
local UnitIsFriend,UnitIsDead=UnitIsFriend,UnitIsDead
local UnitName = UnitName
local format = string.format

do
	local WidgetType = "DXE_HealthWatcher"
	local WidgetVersion = 1
	

	local function OnAcquire(self) 
		self.frame:SetParent(UIParent)
	end

	local function OnRelease(self) 
		self.tracer:Close()
		self.frame:SetParent(nil)
	end

	local function TrackUnitName(self,name)
		self.tracer:TrackUnitName(name)
	end

	local function SetInfoBundle(self,title,health,perc,r,g,b)
		self.bar:SetValue(perc)
		self.bar:SetStatusBarColor(r or (perc > 0.5 and ((1.0 - perc) * 2) or 1.0),
											g or (perc > 0.5 and 1 or (perc * 2)),
											b or 0.0)
		self.title:SetText(title)
		self.health:SetText(health)
	end

	local function TRACER_ACQUIRED(self)
		self:Fire("HW_TRACER_ACQUIRED",self.tracer:First())
	end

	local function TRACER_UPDATE(self)
		local uid = self.tracer:First()
		local h, hm = UnitHealth(uid), UnitHealthMax(uid) 
		local fh = h/hm
		self:SetInfoBundle(UnitName(uid), format("%0.0f%%", fh*100), fh)
		if self.userdata.updates then
			self:Fire("HW_TRACER_UPDATE",self.tracer:First())
		end
	end

	local function TRACER_LOST(self)
		self.bar:SetStatusBarColor(0.66,0.66,0.66)
	end

	local function Open(self,name)
		assert(name,"Missing 'name' paramater - got '"..tostring(name).."'")
		self.tracer:TrackUnitName(name)
		self.tracer:Open()
	end

	local function Close(self)
		self.tracer:Close()
	end

	local function GetName(self)
		return self.tracer.name
	end

	local function EnableUpdates(self)
		self.userdata.updates = true
	end

	local function OnWidthSet(self,width)
		self.title:SetWidth(width*0.75)
	end

	local backdrop = {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",          
		insets = {left = 2, right = 2, top = 3, bottom = 2}
	}

	local backdropborder = {
		edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
		edgeSize = 9,             
		insets = {left = 2, right = 2, top = 3, bottom = 2}
	}

	local function Constructor()
		local self = {}
		self.type = WidgetType
		local frame = CreateFrame("Frame",nil,UIParent)
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
		border:SetFrameLevel(bar:GetFrameLevel()+1)

		-- Add title text
		title = bar:CreateFontString(nil,"ARTWORK")
		title:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		title:SetHeight(1)
		title:SetPoint("LEFT",bar,"LEFT",2,0)
		title:SetJustifyH("LEFT")
		self.title = title

		-- Add health text
		health = bar:CreateFontString(nil,"ARTWORK")
		health:SetHeight(1)
		health:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",12)
		health:SetJustifyH("RIGHT")
		health:SetPoint("RIGHT",bar,"RIGHT",-2,0)
		self.health = health
		
		self.TRACER_UPDATE = TRACER_UPDATE
		self.TRACER_LOST = TRACER_LOST
		self.TRACER_ACQUIRED = TRACER_ACQUIRED

		self.tracer = DXE.HOT:New()
		self.tracer:SetCallback(self,"TRACER_UPDATE")
		self.tracer:SetCallback(self,"TRACER_LOST")
		self.tracer:SetCallback(self,"TRACER_ACQUIRED")

		self.OnAcquire = OnAcquire
		self.OnRelease = OnRelease
		self.TrackUnitName = TrackUnitName
		self.SetInfoBundle = SetInfoBundle
		self.EnableUpdates = EnableUpdates
		self.OnWidthSet = OnWidthSet
		self.Open = Open
		self.Close = Close
		self.GetName = GetName
		
		self.frame = frame
		frame.obj = self

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(WidgetType,Constructor,WidgetVersion)
end
