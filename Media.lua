local addon = DXE

local SM = addon.SM
local Media = {}
addon.Media = Media

-------------------------
-- Colors
-------------------------

do
	local Colors = {
		BLACK = 			{r=0,  	g=0,		b=0},
		BLUE = 			{r=0,  	g=0, 		b=1},
		BROWN = 			{r=.65,  g=.165,  b=.165},
		CYAN = 			{r=0,		g=1,		b=1},
		DCYAN = 			{r=0,  	g=.6, 	b=.6},
		GOLD = 			{r=1,		g=0.843,	b=0},
		GREEN = 			{r=0,  	g=0.5,	b=0},
		GREY = 			{r=.3, 	g=.3, 	b=.3},
		INDIGO = 		{r=0,		g=0.25,	b=0.71},
		MAGENTA =   	{r=1, 	g=0, 		b=1},
		MIDGREY = 		{r=.5, 	g=.5, 	b=.5},
		ORANGE = 		{r=1,	 	g=0.5,	b=0},
		PEACH = 			{r=1,		g=0.9,	b=0.71},
		PINK = 			{r=1,		g=0,		b=1},
		PURPLE = 		{r=0.627,g=0.125,	b=0.941},
		RED = 			{r=0.9,	g=0,		b=0},
		TAN = 			{r=0.82,	g=0.71,	b=0.55},
		TEAL = 			{r=0,		g=0.5,	b=0.5},
		TURQUOISE =  	{r=.251, g=.878,  b=.816},
		VIOLET = 		{r=0.55, g=0,     b=1},
		WHITE = 			{r=1,  	g=1,		b=1},
		YELLOW = 		{r=1,	 	g=1,		b=0},
	}
	Media.Colors = Colors

	--[[
	Grabbed by Localizer

	L["BLACK"] 	L["BLUE"] 		L["BROWN"]	 	L["CYAN"]
	L["DCYAN"] 	L["GOLD"] 		L["GREEN"] 		L["GREY"]
	L["INDIGO"] L["MAGENTA"] 	L["MIDGREY"] 	L["ORANGE"]
	L["PEACH"] 	L["PINK"] 		L["PURPLE"] 	L["RED"]
	L["TAN"] 	L["TEAL"] 		L["TURQUOISE"] L["VIOLET"]
	L["WHITE"] 	L["YELLOW"] 

	]]
end

-------------------------
-- Sounds
-------------------------

do
	local Sounds = {
		ALERT1 = "Sound\\Doodad\\BellTollAlliance.wav",
		ALERT2 = "Sound\\Doodad\\BellTollHorde.wav",
		ALERT3 = "Interface\\AddOns\\DXE\\Sounds\\LowMana.mp3",
		ALERT4 = "Interface\\AddOns\\DXE\\Sounds\\LowHealth.mp3",
		ALERT5 = "Interface\\AddOns\\DXE\\Sounds\\ZingAlarm.mp3",
		ALERT6 = "Interface\\Addons\\DXE\\Sounds\\Wobble.mp3",
		ALERT7 = "Interface\\AddOns\\DXE\\Sounds\\Bottle.mp3",
		ALERT8 = "Interface\\AddOns\\DXE\\Sounds\\LiftMe.mp3",
		ALERT9 = "Interface\\AddOns\\DXE\\Sounds\\NeoBeep.mp3",
		ALERT10 = "Sound\\Spells\\PVPFlagTaken.wav",
		ALERT11 = "Sound\\Spells\\SimonGame_Visual_BadPress.wav",
	}
	Media.Sounds = Sounds
	for name,file in pairs(Sounds) do SM:Register("sound","DXE "..name,file) end
end

-------------------------
-- FONTS
-------------------------

do
	SM:Register("font", "Bastardus Sans", "Interface\\AddOns\\DXE\\Fonts\\BS.ttf")
	SM:Register("font", "Courier New", "Interface\\AddOns\\DXE\\Fonts\\CN.ttf")
	SM:Register("font", "Franklin Gothic Medium", "Interface\\AddOns\\DXE\\Fonts\\FGM.ttf")
end

-------------------------
-- GLOBALS
-------------------------
local bgBackdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", insets = {left = 2, right = 2, top = 2, bottom = 2}}
local borderBackdrop = {edgeSize = 8, insets = {left = 2, right = 2, top = 2, bottom = 2}}

local gbl
local function RefreshProfile(db) 
	gbl = db.global 
	borderBackdrop.edgeFile = SM:Fetch("border",gbl.Border)
end
addon:AddToRefreshProfile(RefreshProfile)

do
	local reg = {}
	function addon:RegisterFontString(fontstring,size,flags)
		reg[#reg+1] = fontstring
		fontstring:SetFont(SM:Fetch("font",gbl.Font),size,flags)
	end

	function addon:NotifyFontChanged()
		local font = SM:Fetch("font",gbl.Font)
		for _,fontstring in ipairs(reg) do 
			local _,size,flags = fontstring:GetFont()
			fontstring:SetFont(font,size,flags)
		end
	end
end

do
	local reg = {}
	function addon:RegisterStatusBar(statusbar)
		reg[#reg+1] = statusbar
		statusbar:SetStatusBarTexture(SM:Fetch("statusbar",gbl.BarTexture))
	end

	function addon:NotifyBarTextureChanged(name)
		local texture = SM:Fetch("statusbar",name)
		for _,statusbar in ipairs(reg) do statusbar:SetStatusBarTexture(texture) end
	end
end

do
	local reg = {}
	function addon:RegisterBorder(frame)
		reg[#reg+1] = frame
		local r,g,b,a = unpack(gbl.BorderColor)
		frame:SetBackdrop(borderBackdrop)
		frame:SetBackdropBorderColor(r,g,b,a)
	end

	function addon:NotifyBorderChanged(edgeFile)
		borderBackdrop.edgeFile = SM:Fetch("border",edgeFile)
		local r,g,b,a = unpack(gbl.BorderColor)
		for _,frame in ipairs(reg) do 
			frame:SetBackdrop(borderBackdrop)
			frame:SetBackdropBorderColor(r,g,b,a)
		end
	end

	function addon:NotifyBorderColorChanged(r,g,b,a)
		for _,frame in ipairs(reg) do 
			frame:SetBackdropBorderColor(r,g,b,a)
		end
	end
end

do
	local reg = {}
	function addon:RegisterBackground(widget)
		reg[#reg+1] = widget
		local r,g,b,a = unpack(gbl.BackgroundColor)
		if widget:IsObjectType("Frame") then
			widget:SetBackdrop(bgBackdrop)
			widget:SetBackdropColor(r,g,b,a)
		elseif widget:IsObjectType("Texture") then
			widget:SetTexture(bgBackdrop.bgFile)
			widget:SetVertexColor(r,g,b,a)
		end
	end

	function addon:NotifyBackgroundColorChanged(r,g,b,a)
		local r,g,b,a = unpack(gbl.BackgroundColor)
		for _,widget in ipairs(reg) do 
			if widget:IsObjectType("Frame") then
				widget:SetBackdropColor(r,g,b,a)
			elseif widget:IsObjectType("Texture") then
				widget:SetVertexColor(r,g,b,a)
			end
		end
	end
end
