local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version
local L = DXE.L

local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local backdropBorder = {
   edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	edgeSize = 9,             
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local Windows = {}
DXE.Windows = Windows

local buttonSize = 12
local titleHeight = 15
local inset = 2
local contentInset = 7

---------------------------------------
-- SCRIPT HANDLERS
---------------------------------------

local function onMouseDown(self)
	if IsShiftKeyDown() then
		self.window:StartMoving()
	end
end

local function onMouseUp(self)
	self.window:StopMovingOrSizing()
	DXE:SavePosition(self.window)
end

local function onLeave(self) self:GetNormalTexture():SetVertexColor(1,1,1) end

local function onEnter(self) self:GetNormalTexture():SetVertexColor(0,1,0) end

---------------------------------------
-- API
---------------------------------------

local function AddTitleButton(self,texture,onClick)
	assert(type(texture) == "string")
	assert(type(onClick) == "function")

	local button = CreateFrame("Button",nil,self)
	button:SetWidth(buttonSize)
	button:SetHeight(buttonSize)
	button:SetPoint("RIGHT",self.anchorButton,"LEFT",-2.5,0)
	button:SetScript("OnClick",onClick)
	button:SetNormalTexture(texture)
	button:SetScript("OnEnter",onEnter)
	button:SetScript("OnLeave",onLeave)
	button:SetFrameLevel(button:GetFrameLevel()+5)
	self.anchorButton = button
end

function DXE:CreateWindow(name,width,height)
	assert(type(name) == "string")
	assert(type(width) == "number")
	assert(type(height) == "number")
	if Windows[name] then error("Window already exists") return end
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
	titleBar:SetPoint("TOPLEFT",window,"TOPLEFT",inset,-inset)
	titleBar:SetPoint("BOTTOMRIGHT",window,"TOPRIGHT",-inset, -(titleHeight+inset))
	titleBar:EnableMouse(true)
	titleBar:SetMovable(true)
	titleBar:SetScript("OnMouseDown",onMouseDown)
	titleBar:SetScript("OnMouseUp",onMouseUp)
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
	close:SetScript("OnEnter",onEnter)
	close:SetScript("OnLeave",onLeave)
	close:SetWidth(buttonSize)
	close:SetHeight(buttonSize)
	close:SetPoint("RIGHT",titleBar,"RIGHT",-2,0)

	window.anchorButton = close

	window.AddTitleButton = AddTitleButton

	local content = CreateFrame("Frame",nil,window)
	content:SetPoint("TOPLEFT",window,"TOPLEFT",contentInset,-(titleHeight + contentInset))
	content:SetPoint("BOTTOMRIGHT",window,"BOTTOMRIGHT",-contentInset,contentInset)
	window.content = content

	Windows[name] = window
	return window
end


