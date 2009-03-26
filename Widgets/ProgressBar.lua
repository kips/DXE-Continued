local AceGUI = LibStub("AceGUI-3.0")
local UIParent = UIParent

local Backdrop = {
	bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
	tileSize=16,
	edgeSize=16, 
	insets= {left=4,right=4,top=4,bottom=4}
}

local White = {r = 1, g = 1, b = 1}
local Blue = {r = 0, g = 0, b = 1} 

do
	local WidgetType = "DXE_ProgressBar"
	local WidgetVersion = 1
	
	local function OnAcquire(self)
		self.frame:Show()
		self.frame:SetParent(UIParent)
		self:SetColor(Blue,White)
	end

	local function OnRelease(self)
		self.frame:Hide()
		self.frame:ClearAllPoints()
		self.bar:SetValue(0)
		self:SetAlpha(1)
		UIFrameFadeRemoveFrame(self.frame)
	end

	local function SetText(self,text)
		self.text:SetText(text)
	end

	local function SetFormattedText(self,text,...)
		self.text:SetFormattedText(text,...)
	end

	local function SetColor(self,c1,c2)
		if c1 then
			self.userdata.c1 = c1
			self.bar:SetStatusBarColor(c1.r,c1.g,c1.b)
		end
		if c2 then self.userdata.c2 = c2 end
	end

	local function Anchor(self,relPoint,frame,relTo)
		self.userdata.animFunc = nil
		self.frame:ClearAllPoints()
		self.frame:SetPoint(relPoint,frame,relTo)
	end
	
	local function SetAlpha(self,alpha)
		self.frame:SetAlpha(alpha)
	end

	local function SetValue(self,value)
		self.bar:SetValue(value)
	end

	local function Constructor()
		local self = {}
		self.type = WidgetType
		local frame = CreateFrame("Frame",nil,UIParent)

		frame:SetWidth(222) 
		frame:SetHeight(30)
		frame:SetBackdrop(Backdrop)
		
		local bar = CreateFrame("StatusBar",nil,frame)
		bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		bar:SetPoint("TOPLEFT",5,-5)
		bar:SetPoint("BOTTOMRIGHT",-5,5)
		bar:SetMinMaxValues(0,1) 
		bar:SetValue(0)
		self.bar = bar
		
		local text = bar:CreateFontString(nil,"ARTWORK")
		text:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
		text:SetPoint("CENTER",frame,"CENTER")
		self.text = text
		
		self.OnAcquire = OnAcquire
		self.OnRelease = OnRelease
		self.SetText = SetText
		self.SetColor = SetColor
		self.Anchor = Anchor
		self.SetAlpha = SetAlpha
		self.SetValue = SetValue
		self.SetFormattedText = SetFormattedText
		
		self.frame = frame
		frame.obj = self

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(WidgetType,Constructor,WidgetVersion)
end
