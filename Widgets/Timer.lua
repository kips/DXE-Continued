local AceGUI = LibStub("AceGUI-3.0")

local fmod = math.fmod
local floor = math.floor

do
	local WidgetType = "DXE_Timer"
	local WidgetVersion = 1
	
	local function OnAcquire(self)
		self.frame:Show()
	end

	local function OnRelease(self)
		self.frame:Hide()
		self.frame:ClearAllPoints()
		self.frame:SetParent(nil)
	end
	
	local function SetTime(self,time)
		time = time < 0 and 0 or time
		local dec = (time - floor(time)) * 100
		local min = floor(time/60)
		local sec = fmod(time,60)
		self.left:SetFormattedText("%d:%02d",min,sec)
		self.right:SetFormattedText("%02d",dec)
	end

	local function Constructor()
		local self = {}
		self.type = WidgetType
		local frame = CreateFrame("Frame",nil,UIParent)
		frame:SetWidth(80)
		frame:SetHeight(20)

		local left = frame:CreateFontString(nil,"OVERLAY")
		left:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",20)
		left:SetPoint("LEFT",frame,"LEFT")
		left:SetWidth(60)
		left:SetHeight(20)
		left:SetJustifyH("RIGHT")
		self.left = left

		local right = frame:CreateFontString(nil,"OVERLAY")
		right:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",12)
		right:SetPoint("BOTTOMLEFT",left,"BOTTOMRIGHT",0,2)
		right:SetWidth(20)
		right:SetHeight(12)
		right:SetJustifyH("LEFT")
		self.right = right

		left:SetText("0:00")
		right:SetText("00")

		self.OnAcquire = OnAcquire
		self.OnRelease = OnRelease
		self.SetTime = SetTime
		
		self.frame = frame
		frame.obj = self

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(WidgetType,Constructor,WidgetVersion)
end
