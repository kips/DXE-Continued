do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 308,
		key = "ignis", 
		zone = L["Ulduar"], 
		name = L["Ignis the Furnace Master"], 
		triggers = {
			scan = 33118, -- Ignis
		},
		onactivate = {
			tracing = {33118}, -- Ignis
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {
			flamejetstime = {24,22.3,loop = false},
			slagpotmessage = "",
		},
		onstart = {
			{
				{alert = "flamejetscd"},
				{alert = "hardmodeends"},
			},
		},
		alerts = {
			flamejetswarn = {
				varname = format(L["%s Cast"],SN[62680]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[62680]),
				time = 2.7,
				color1 = "RED",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[62680],
			},
			flamejetscd = {
				varname = format(L["%s Cooldown"],SN[62680]),
				type = "dropdown",
				time = "<flamejetstime>",
				text = format(L["%s Cooldown"],SN[62680]),
				flashtime = 5,
				color1 = "RED",
				color2 = "MAGENTA",
				sound = "ALERT1",
				icon = ST[62680],
			},
			scorchwarnself = {
				varname = format(L["%s on self"],SN[62546]),
				type = "simple",
				text = format("%s: %s!",SN[62546],L["YOU"]),
				time = 1.5,
				color1 = "MAGENTA",
				sound = "ALERT5",
				flashscreen = true,
				throttle = 5,
				icon = ST[62546],
			},
			scorchcd = {
				varname = format(L["%s Cooldown"],SN[62546]),
				text = format(L["Next %s"],SN[62546]),
				type = "dropdown",
				time = 25,
				flashtime = 5,
				color1 = "MAGENTA",
				color2 = "YELLOW",
				sound = "ALERT2",
				icon = ST[62546],
			},
			slagpotdur = {
				varname = format(L["%s Duration"],SN[62717]),
				type = "centerpopup",
				text = "<slagpotmessage>",
				time = 10,
				color1 = "GREEN",
				sound = "ALERT4",
				icon = ST[62717],
			},
			hardmodeends = {
				varname = format("%s Timer",L["Hard Mode"]),
				type = "dropdown",
				text = format("%s Ends",L["Hard Mode"]),
				time = 240,
				flashtime = 5,
				color1 = "BROWN",
				color2 = "BROWN",
				sound = "ALERT6",
				icon = ST[20573],
			},
		},
		timers = {
			flamejet = {
				{
					{alert = "flamejetscd"},
				},
			},
		},
		events = {
			-- Scorch cooldown",
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {62546, 63474},
				execute = {
					{
						{alert = "scorchcd"},
					},
				},
			},
			-- Scorch warning on self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {62548, 63475},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"},},
						{alert = "scorchwarnself"},
					},
				},
			},
			-- Slag Pot
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62717, 63477},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{set = {slagpotmessage = format("%s: %s!",SN[62717],L["YOU"])}},
					},
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{set = {slagpotmessage = format("%s: #5#",SN[62717])}},
					},
					{
						{alert = "slagpotdur"},
					},
				},
			},
			-- Flame Jets cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {63472,62680},
				execute = {
					{
						{quash = "flamejetscd"},
						{alert = "flamejetswarn",},
						{scheduletimer = {"flamejet",2.7}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
