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
local buttonSize = 10
local titleHeight = 12
local titleBarInset = 2
local handlers = {}

---------------------------------------
-- API
---------------------------------------

local function AddTitleButton(self,texture,OnClick,text)
	--@debug@
	assert(type(texture) == "string")
	assert(type(OnClick) == "function")
	assert(type(text) == "string")
	--@end-debug@

	local button = CreateFrame("Button",nil,self.frame)
	button:SetWidth(buttonSize)
	button:SetHeight(buttonSize)
	button:SetPoint("RIGHT",self.anchorButton,"LEFT",-1,0)
	button:SetScript("OnClick",OnClick)
	button:SetScript("OnEnter",handlers.Button_OnEnter)
	button:SetScript("OnLeave",handlers.Button_OnLeave)
	button:SetFrameLevel(button:GetFrameLevel()+5)
	button.t = button:CreateTexture(nil,"ARTWORK")
	button.t:SetVertexColor(0.33,0.33,0.33)
	button.t:SetAllPoints(true)
	button.t:SetTexture(texture)
	addon:AddTooltipText(button,text)
	self.anchorButton = button
end

local function SetContentInset(self,inset)
	self.content:ClearAllPoints()
	self.content:SetPoint("TOPLEFT",self.container,"TOPLEFT",inset,-inset)
	self.content:SetPoint("BOTTOMRIGHT",self.container,"BOTTOMRIGHT",-inset,inset)
end

---------------------------------------
-- WINDOW CREATION
---------------------------------------

function addon:CreateWindow(name,width,height)
	--@debug@
	assert(type(name) == "string")
	assert(type(width) == "number")
	assert(type(height) == "number")
	--@end-debug@

	local properName = name:gsub(" ","")

	-- Anchor
	handlers.Anchor_OnSizeChanged = handlers.Anchor_OnSizeChanged or function(self)
		local width = self:GetWidth()
		self:SetWidth(width)
		self:SetHeight(width*self.ratio)
		local s = width / self.owidth
		self.frame:SetScale(s)
	end

	local anchor = CreateFrame("Frame","DXEWindow" ..properName,UIParent)
	anchor:SetWidth(width)
	anchor:SetHeight(height)
	anchor:SetMovable(true)
	anchor:SetClampedToScreen(true)
	anchor:SetResizable(true)
	anchor:SetMinResize(50,50)
	anchor:SetScript("OnSizeChanged", handlers.Anchor_OnSizeChanged)
	anchor.ratio = height/width
	anchor.owidth = width

	-- Inside
	local frame = CreateFrame("Frame","DXEWindow" .. properName,anchor)
	frame:SetWidth(width)
	frame:SetHeight(height)
	frame:SetBackdrop(backdrop)
	frame:SetPoint("TOPLEFT")
	anchor.frame = frame

	-- Corner
	handlers.Corner_OnMouseDown = handlers.Corner_OnMouseDown or function(self)
		self.anchor:StartSizing("BOTTOMRIGHT")
	end

	handlers.Corner_OnMouseUp = handlers.Corner_OnMouseUp or function(self)
		self.anchor:StopMovingOrSizing()
		addon:SavePosition(self.anchor,true)
	end

	--[[
	handlers.Corner_OnEnter = handlers.Corner_OnEnter or function(self) self.t:SetVertexColor(0,1,1) end
	handlers.Corner_OnLeave = handlers.Corner_OnLeave or function(self) self.t:SetVertexColor(1,1,1) end
	]]

	local corner = CreateFrame("Frame", nil, frame)
	corner:SetFrameLevel(frame:GetFrameLevel() + 9)
	corner:EnableMouse(true)
	corner:SetScript("OnMouseDown", handlers.Corner_OnMouseDown)
	corner:SetScript("OnMouseUp", handlers.Corner_OnMouseUp)
	--[[
	corner:SetScript("OnEnter", handlers.Corner_OnEnter)
	corner:SetScript("OnLeave", handlers.Corner_OnLeave)
	]]
	corner:SetHeight(12)
	corner:SetWidth(12)
	corner:SetPoint("BOTTOMRIGHT")
	corner.t = corner:CreateTexture(nil,"ARTWORK")
	corner.t:SetAllPoints(true)
	corner.t:SetTexture("Interface\\Addons\\DXE\\Textures\\ResizeGrip.tga")
	addon:AddTooltipText(corner,L["|cffffff00Click|r to resize"])
	corner.anchor = anchor

	-- Border
	local border = CreateFrame("Frame",nil,frame)
	border:SetAllPoints(true)
	border:SetFrameLevel(border:GetFrameLevel()+10)
	border:SetBackdrop(backdropBorder)
	border:SetBackdropBorderColor(0.33,0.33,0.33)

	-- Title Bar
	local titleBar = CreateFrame("Frame",nil,frame)
	titleBar:SetPoint("TOPLEFT",frame,"TOPLEFT",titleBarInset,-titleBarInset)
	titleBar:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",-titleBarInset, -(titleHeight+titleBarInset))
	titleBar:EnableMouse(true)
	titleBar:SetMovable(true)
	addon:AddTooltipText(titleBar,L["|cffffff00Shift + Click|r to move"])
	self:RegisterMoveSaving(titleBar,"CENTER","UIParent","CENTER",0,0,true,anchor,true)

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

	handlers.Button_OnLeave = handlers.Button_OnLeave or function(self) self.t:SetVertexColor(0.33,0.33,0.33) end
	handlers.Button_OnEnter = handlers.Button_OnEnter or function(self) self.t:SetVertexColor(0,1,0) end

	local close = CreateFrame("Button",nil,frame)
	close:SetFrameLevel(close:GetFrameLevel()+5)
	close:SetScript("OnClick",function() anchor:Hide() end)
	close.t = close:CreateTexture(nil,"ARTWORK")
	close.t:SetAllPoints(true)
	close.t:SetTexture("Interface\\Addons\\DXE\\Textures\\Window\\X.tga")
	close.t:SetVertexColor(0.33,0.33,0.33)
	close:SetScript("OnEnter",handlers.Button_OnEnter)
	close:SetScript("OnLeave",handlers.Button_OnLeave)
	addon:AddTooltipText(close,L["Close"])
	close:SetWidth(buttonSize)
	close:SetHeight(buttonSize)
	close:SetPoint("RIGHT",titleBar,"RIGHT",-2,0)

	anchor.anchorButton = close

	-- Container
	local container = CreateFrame("Frame",nil,frame)
	container:SetPoint("TOPLEFT",frame,"TOPLEFT",1,-titleHeight-titleBarInset)
	container:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-1,1)
	anchor.container = container

	-- Content
	local content = CreateFrame("Frame",nil,container)
	content:SetPoint("TOPLEFT",container,"TOPLEFT")
	content:SetPoint("BOTTOMRIGHT",container,"BOTTOMRIGHT")
	anchor.content = content

	anchor.SetContentInset = SetContentInset
	anchor.AddTitleButton = AddTitleButton

	windows[anchor] = true

	self:LoadPosition(anchor:GetName())

	return anchor
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

