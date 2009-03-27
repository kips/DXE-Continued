local Constants = {}
DXE.Constants = Constants

-------------------------
-- Colors
-------------------------

local Colors = {
	RED = 			{r=0.9,	g=0,		b=0,		a=1},
	YELLOW = 		{r=1,	 	g=1,		b=0,		a=1},
	ORANGE = 		{r=1,	 	g=0.5,	b=0,		a=1},
	GREEN = 			{r=0,  	g=0.5,	b=0,		a=1},
	BLUE = 			{r=0,  	g=0, 		b=1, 		a=1},
	MAGENTA =   	{r=1, 	g=0, 		b=1,  	a=1},
	WHITE = 			{r=1,  	g=1,		b=1,		a=1},
	BLACK = 			{r=0,  	g=0,		b=0,		a=1},
	GREY = 			{r=.3, 	g=.3, 	b=.3, 	a=1},
	CYAN = 			{r=0,		g=1,		b=1,		a=1},
	DCYAN = 			{r=0,  	g=.6, 	b=.6, 	a=1},
	MIDGREY = 		{r=.5, 	g=.5, 	b=.5, 	a=1},
	BLACK = 			{r=0,		g=0,		b=0,		a=1},
	BROWN = 			{r=.65,  g=.165,  b=.165,	a=1},
	TURQUOISE =  	{r=.251, g=.878,  b=.816,  a=1},
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
}

Constants.Sounds = Sounds
