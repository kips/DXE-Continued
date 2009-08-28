local addon = DXE
local L = addon.L

local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local backdropBorder = {
   edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	edgeSize = 9,             
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local windows = {}
local buttonSize = 12
local titleHeight = 12
local titleBarInset = 2

---------------------------------------
-- SCRIPT HANDLERS
---------------------------------------

local function OnMouseDown(self)
	if IsShiftKeyDown() then
		self.window:StartMoving()
	end
end

local function OnMouseUp(self)
	self.window:StopMovingOrSizing()
	addon:SavePosition(self.window)
end

local function OnLeave(self) self:GetNormalTexture():SetVertexColor(1,1,1) end

local function OnEnter(self) self:GetNormalTexture():SetVertexColor(0,1,0) end

---------------------------------------
-- API
---------------------------------------

local function AddTitleButton(self,texture,onClick)
	--@debug@
	assert(type(texture) == "string")
	assert(type(onClick) == "function")
	--@end-debug@

	local button = CreateFrame("Button",nil,self)
	button:SetWidth(buttonSize)
	button:SetHeight(buttonSize)
	button:SetPoint("RIGHT",self.anchorButton,"LEFT",-2.5,0)
	button:SetScript("OnClick",onClick)
	button:SetNormalTexture(texture)
	button:SetScript("OnEnter",OnEnter)
	button:SetScript("OnLeave",OnLeave)
	button:SetFrameLevel(button:GetFrameLevel()+5)
	self.anchorButton = button
end

local function SetContentInset(self,inset)
	self.content:ClearAllPoints()
	self.content:SetPoint("TOPLEFT",self.container,"TOPLEFT",inset,-inset)
	self.content:SetPoint("BOTTOMRIGHT",self.container,"BOTTOMRIGHT",-inset,inset)
end

function addon:CreateWindow(name,width,height)
	--@debug@
	assert(type(name) == "string")
	assert(type(width) == "number")
	assert(type(height) == "number")
	--@end-debug@
	local properName = name:gsub(" ","")
	local window = CreateFrame("Frame","DXEWindow" .. properName,UIParent)
	window:SetWidth(width)
	window:SetHeight(height)
	window:SetBackdrop(backdrop)
	window:SetMovable(true)
	window:SetClampedToScreen(true)
	self:LoadPosition("DXEWindow" .. properName)

	local border = CreateFrame("Frame",nil,window)
	border:SetAllPoints(true)
	border:SetFrameLevel(border:GetFrameLevel()+10)
	border:SetBackdrop(backdropBorder)
	border:SetBackdropBorderColor(0.33,0.33,0.33)

	local titleBar = CreateFrame("Frame",nil,window)
	titleBar:SetPoint("TOPLEFT",window,"TOPLEFT",titleBarInset,-titleBarInset)
	titleBar:SetPoint("BOTTOMRIGHT",window,"TOPRIGHT",-titleBarInset, -(titleHeight+titleBarInset))
	titleBar:EnableMouse(true)
	titleBar:SetMovable(true)
	titleBar:SetScript("OnMouseDown",OnMouseDown)
	titleBar:SetScript("OnMouseUp",OnMouseUp)
	titleBar.window = window

	local gradient = titleBar:CreateTexture(nil,"ARTWORK")
	gradient:SetAllPoints(true)
	gradient:SetTexture(0,0,0.82)
	gradient:SetGradient("HORIZONTAL",0,0,1,0,0,0)

	local titleText = titleBar:CreateFontString(nil,"OVERLAY")
	titleText:SetFont(GameFontNormal:GetFont(),8)
	titleText:SetPoint("LEFT",titleBar,"LEFT",5,0)
	titleText:SetText(name)
	titleText:SetShadowOffset(1,-1)
	titleText:SetShadowColor(0,0,0)

	local close = CreateFrame("Button",nil,window)
	close:SetFrameLevel(close:GetFrameLevel()+5)
	close:SetScript("OnClick",function() window:Hide() end)
	close:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Window\\X.tga")
	close:SetScript("OnEnter",OnEnter)
	close:SetScript("OnLeave",OnLeave)
	close:SetWidth(buttonSize)
	close:SetHeight(buttonSize)
	close:SetPoint("RIGHT",titleBar,"RIGHT",-2,0)

	window.anchorButton = close

	window.AddTitleButton = AddTitleButton

	local container = CreateFrame("Frame",nil,window)
	container:SetPoint("TOPLEFT",window,"TOPLEFT",1,-titleHeight-titleBarInset)
	container:SetPoint("BOTTOMRIGHT",window,"BOTTOMRIGHT",-1,1)
	window.container = container

	local content = CreateFrame("Frame",nil,container)
	content:SetPoint("TOPLEFT",container,"TOPLEFT")
	content:SetPoint("BOTTOMRIGHT",container,"BOTTOMRIGHT")
	window.content = content

	window.SetContentInset = SetContentInset

	windows[window] = true
	return window
end

function addon:CloseAllWindows()
	for w in pairs(windows) do w:Hide() end
end

---------------------------------------
-- REGISTRY
---------------------------------------
local registry = {}

function addon:RegisterWindow(name,openFunc)
	--@debug@
	assert(type(name) == "string")
	assert(type(openFunc) == "function")
	--@end-debug@
	registry[name] = openFunc
end

---------------------------------------
-- DROPDOWN MENU
---------------------------------------

do
	local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
	local info

	local function Initialize(self,level)
		level = 1
		if level == 1 then
			info = UIDropDownMenu_CreateInfo()
			info.isTitle = true 
			info.text = L["Windows"]
			info.notCheckable = true 
			info.justifyH = "LEFT"
			UIDropDownMenu_AddButton(info,1)

			for name,openFunc in pairs(registry) do
				info = UIDropDownMenu_CreateInfo()
				info.text = name
				info.notCheckable = true
				info.func = openFunc
				info.owner = self
				UIDropDownMenu_AddButton(info,1)
			end
		end
	end

	function addon:CreateWindowsDropDown()
		local windows = CreateFrame("Frame", "DXEPaneWindows", UIParent, "UIDropDownMenuTemplate") 
		UIDropDownMenu_Initialize(windows, Initialize, "MENU")
		return windows
	end
end

