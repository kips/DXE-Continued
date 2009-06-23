local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version
local L = DXE.L

local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
   edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	edgeSize = 9,             
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

function DXE:CreateWindow(name,width,height)
	assert(type(name) == "string")
	assert(type(width) == "number")
	assert(type(height) == "number")

	--[[
	local header = CreateFrame("Frame",format("DXE_%s_Header",name),UIParent)
	header:SetHeight(12.5)
	header:SetWidth(width)
	header:SetMovable(true)
	header:EnableMouse(true)
	header:SetClampedToScreen(true)

	local titleBar = header:CreateTexture(nil,"ARTWORK")
	titleBar:SetAllPoints(true)
	titleBar:SetTexture(0,0,0.82)
	titleBar:SetGradient("HORIZONTAL", 0, 0, 1, 0, 0, 0) 
	]]

	--[[
	local t = f:CreateTexture(nil,"ARTWORK")
	t:SetTexture("Interface\\Addons\\DXE\\Textures\\Window\\X.tga")
	t:SetAllPoints(true)
	]]

	local window = CreateFrame("Frame",nil,UIParent)
	window:SetWidth(width)
	window:SetHeight(height)
	window:SetBackdrop(backdrop)
	window:SetBackdropBorderColor(0.33,0.33,0.33)

	return window
end
