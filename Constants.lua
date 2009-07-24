local DXE = DXE
local version = tonumber(("$Rev$"):match("%d+"))
DXE.version = version > DXE.version and version or DXE.version

local SM = DXE.SM
local Constants = {}
DXE.Constants = Constants

-------------------------
-- Colors
-------------------------

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
Constants.Colors = Colors

--[[
Grabbed by Localizer

L["BLACK"]
L["BLUE"]
L["BROWN"]
L["CYAN"]
L["DCYAN"]
L["GOLD"]
L["GREEN"]
L["GREY"]
L["INDIGO"]
L["MAGENTA"]
L["MIDGREY"]
L["ORANGE"]
L["PEACH"]
L["PINK"]
L["PURPLE"]
L["RED"]
L["TAN"]
L["TEAL"]
L["TURQUOISE"]
L["VIOLET"]
L["WHITE"]
L["YELLOW"]

]]

-------------------------
-- Sounds
-------------------------

local Sounds = {
	ALERT1 = "Sound\\Doodad\\BellTollAlliance.wav",
	ALERT2 = "Sound\\Doodad\\BellTollHorde.wav",
	ALERT3 = "Interface\\AddOns\\DXE\\Sounds\\LowMana.mp3",
	ALERT4 = "Interface\\AddOns\\DXE\\Sounds\\LowHealth.mp3",
	ALERT5 = "Interface\\AddOns\\DXE\\Sounds\\ZingAlarm.mp3",
	ALERT6 = "Interface\\AddOns\\DXE\\Sounds\\Alarm.mp3",
	ALERT7 = "Interface\\AddOns\\DXE\\Sounds\\Alert.mp3",
	ALERT8 = "Interface\\AddOns\\DXE\\Sounds\\Info.mp3",
	ALERT9 = "Interface\\AddOns\\DXE\\Sounds\\Long.mp3",
}

-- Copied from Omen Threat Meter
SM:Register("sound", "Rubber Ducky", "Sound\\Doodad\\Goblin_Lottery_Open01.wav")
SM:Register("sound", "Cartoon FX", "Sound\\Doodad\\Goblin_Lottery_Open03.wav")
SM:Register("sound", "Explosion", "Sound\\Doodad\\Hellfire_Raid_FX_Explosion05.wav")
SM:Register("sound", "Shing!", "Sound\\Doodad\\PortcullisActive_Closed.wav")
SM:Register("sound", "Wham!", "Sound\\Doodad\\PVP_Lordaeron_Door_Open.wav")
SM:Register("sound", "Simon Chime", "Sound\\Doodad\\SimonGame_LargeBlueTree.wav")
SM:Register("sound", "War Drums", "Sound\\Event Sounds\\Event_wardrum_ogre.wav")
SM:Register("sound", "Cheer", "Sound\\Event Sounds\\OgreEventCheerUnique.wav")
SM:Register("sound", "Humm", "Sound\\Spells\\SimonGame_Visual_GameStart.wav")
SM:Register("sound", "Short Circuit", "Sound\\Spells\\SimonGame_Visual_BadPress.wav")
SM:Register("sound", "Fel Portal", "Sound\\Spells\\Sunwell_Fel_PortalStand.wav")
SM:Register("sound", "Fel Nova", "Sound\\Spells\\SeepingGaseous_Fel_Nova.wav")
SM:Register("sound", "You Will Die!", "Sound\\Creature\\CThun\\CThunYouWillDIe.wav")
SM:Register("sound", "PvP Flag Taken", "Sound\\Spells\\PVPFlagTaken.wav")

for name,file in pairs(Sounds) do SM:Register("sound","DXE "..name,file) end

Constants.Sounds = Sounds

-------------------------
-- FONTS
-------------------------

SM:Register("font", "Bastardus Sans", "Interface\\AddOns\\DXE\\Fonts\\BS.ttf")
SM:Register("font", "Courier New", "Interface\\AddOns\\DXE\\Fonts\\CN.ttf")
SM:Register("font", "Franklin Gothic Medium", "Interface\\AddOns\\DXE\\Fonts\\FGM.ttf")

-------------------------
-- MAP DIMENSIONS
-------------------------

local MapDims= {
	-- Keyed by GetMapInfo()
	Ulduar = {
		-- Keyed by GetCurrentMapDungeonLevel()
		[0] = {w = 3064.9614761023, h = 2039.5413309668}, 	-- Expedition Base Camp
		[1] = {w = 624.19069622949, h = 415.89374357805}, 	-- Antechamber of Ulduar
		[2] = {w = 1238.37427179,   h = 823.90183235628}, 	-- Conservatory of Life
		[3] = {w = 848.38069183829, h = 564.6688835337}, 	-- Prison of Yogg-Saron
		[4] = {w = 1460.4694647684, h = 974.65312886234},  -- Spark of Imagination
	},
	Naxxramas = {
		[1] = {w = 1018.3655494957, h = 679.40523953718}, -- Construct
		[2] = {w = 1019.1310739251, h = 679.18864376555}, -- Arachnid
		[3] = {w = 1118.1083638787, h = 744.57895516418}, -- Military
		[4] = {w = 1117.0809918236, h = 745.97398439776}, -- Plague
		[5] = {w = 1927.3190541014, h = 1284.6530841959}, -- Entrance
		[6] = {w = 610.62737087301, h = 407.3875157986},  -- KT/Sapphiron
	},
	TheObsidianSanctum = {
		[0] = {w = 1081.6334214432, h = 721.79860069158},
	},
	TheEyeofEternity = {
		[1] = {w = 400.728405332355, h = 267.09113174487},
	},
}

Constants.MapDims = MapDims

