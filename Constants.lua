local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version

local Constants = {}
DXE.Constants = Constants

-------------------------
-- Colors
-------------------------

local Colors = {
	AQUA =			{r=0,		g=1,		b=1},
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

Constants.Sounds = Sounds
