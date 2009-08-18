do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 309,
		key = "jaraxxus", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Lord Jaraxxus"], 
		triggers = {
			scan = {
				34780, -- Jaraxxus
				34826, -- Mistress of Pain
			}, 
		},
		onactivate = {
			tracing = {34780,34826},
			tracerstart = true,
			combatstop = true,
		},
		userdata = {
			eruptiontime = {81,120, loop = false},
			portaltime = {21,120, loop = false},
			fleshtime = {14, 21, loop = false},
			flametime = {10, 30, loop = false},
		},
		onstart = {
			{
				{alert = "portalcd"},
				{alert = "legionflamecd"},
				{alert = "eruptioncd"},
				{alert = "fleshcd"},
			},
		},
		alerts = {
			legionflameself = {
				varname = format(L["%s on self"],SN[68123]),
				text = format("%s: %s!",SN[68123],L["YOU"]),
				type = "centerpopup",
				time = 6,
				flashtime = 6,
				color1 = "GREEN",
				color2 = "MAGENTA",
				flashscreen = true,
				sound = "ALERT1",
				icon = ST[68123],
			},
			legionflamecd = {
				varname = format(L["%s Cooldown"],SN[68123]),
				text = format(L["%s Cooldown"],SN[68123]),
				type = "dropdown",
				time = "<flametime>",
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[68123],
			},
			legionflameproximitywarn = {
				varname = format(L["%s Proximity Warning"],SN[68123]),
				text = format("%s: #5#! %s!",SN[68123],L["MOVE AWAY"]),
				type = "simple",
				time = 2,
				color1 = "GOLD",
				sound = "ALERT3",
				icon = ST[68123],
				flashscreen = true,
			},
			fleshself = {
				varname = format(L["%s on self"],SN[67051]),
				text = format("%s: %s!",SN[67051],L["YOU"]),
				type = "centerpopup",
				time = 12,
				flashtime = 12,
				color1 = "ORANGE",
				color2 = "BLACK",
				flashscreen = true,
				sound = "ALERT2",
				icon = ST[67051],
			},
			fleshothers = {
				varname = format(L["%s on others"],SN[67051]),
				text = format("%s: #5#!",SN[67051]),
				type = "centerpopup",
				time = 12,
				flashtime = 12,
				color1 = "ORANGE",
				icon = ST[67051],
			},
			fleshcd = {
				varname = format(L["%s Cooldown"],SN[67051]),
				text = format(L["%s Cooldown"],SN[67051]),
				type = "dropdown",
				time = "<fleshtime>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[67051],
			},
			eruptioncd = {
				varname = format(L["%s Cooldown"],SN[67901]),
				text = format(L["%s Cooldown"],SN[67901]),
				type = "dropdown",
				time = "<eruptiontime>",
				flashtime = 10,
				color1 = "BROWN",
				icon = ST[67901],
			},
			portalcd = {
				varname = format(L["%s Cooldown"],SN[67898]),
				text = format(L["%s Cooldown"],SN[67898]),
				type = "dropdown",
				time = "<portaltime>",
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[67898],
			},
			netherpowerwarn = {
				varname = format(L["%s Warning"],SN[66228]),
				text = format("%s! %s!",SN[66228],L["DISPEL"]),
				type = "simple",
				time = 3,
				color1 = "WHITE",
				sound = "ALERT4",
				icon = ST[66228],
			},
			mistresstimer = {
				varname = format(L["%s Timer"],L["Mistress of Pain"]),
				text = format(L["%s Spawns"],L["Mistress of Pain"]).."!",
				type = "centerpopup",
				time = 8,
				color1 = "TAN",
				icon = ST[67905],
			},
			touchself = {
				varname = format(L["%s on self"],SN[66209]),
				text = format("%s: %s!",SN[66209],L["YOU"]),
				type = "centerpopup",
				time = 12,
				flashtime = 12,
				color1 = "INDIGO",
				color2 = "PEACH",
				sound = "ALERT5",
				icon = ST[66209],
				flashscreen = true,
			},
			touchproximitywarn = {
				varname = format(L["%s Proximity Warning"],SN[66209]),
				text = format("%s: #5#! %s!",SN[66209],L["MOVE AWAY"]),
				type = "simple",
				time = 3,
				sound = "ALERT7",
				icon = ST[66209],
				flashscreen = true,
			},
		},
		arrows = {
			toucharrow = {
				varname = SN[66209],
				unit = "#5#",
				persist = 3,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = L["Touch"],
				sound = "ALERT6",
			},
			flamearrow = {
				varname = SN[68123],
				unit = "#5#",
				persist = 3,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = SN[68123],
				sound = "ALERT8",
			},
		},
		raidicons = {
			legionflamemark = {
				varname = SN[68123],
				type = "FRIENDLY",
				persist = 6,
				unit = "#5#",
				icon = 7,
			},
			touchmark = {
				varname = SN[66209],
				type = "FRIENDLY",
				persist = 12,
				unit = "#5#",
				icon = 8,
			},
		},
		announces = {
			flamesay = {
				varname = format(L["Say %s on self"],SN[68123]),
				type = "SAY",
				msg = format(L["%s on Me"],SN[68123]).."!",
			},
		},
		events = {
			-- Legion Flame Note: Use spellid with buff description 'Flame begins to spread from your body!'
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					68123,
					68125,
					66197, -- 10 normal
					68124, -- ??
				},
				execute = {
					{
						{alert = "legionflamecd"},
						{raidicon = "legionflamemark"},
					},
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "legionflameself"},
						{announce = "flamesay"},
					},
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{proximitycheck = {"#5#",11}},
						{alert = "legionflameproximitywarn"},
						{arrow = "flamearrow"},
					},
				},
			},
			-- Incinerate Flesh
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67049,
					67050,
					67051,
					66237 -- 10 normal
				},
				execute = {
					{
						{alert = "fleshcd"},
					},
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "fleshself"},
					},
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "fleshothers"},
					},
				},
			},
			-- Incinerate Flesh - Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67049,
					67050,
					67051,
					66237, -- 10 normal
				},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "fleshself"},
					},
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{quash = "fleshothers"},
					},
				},
			},
			-- Infernal Eruption
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					67901,
					67903,
					66258, -- 10 normal
				},
				execute = {
					{
						{alert = "eruptioncd"},
					},
				},
			},
			-- Nether Portal
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					67900,
					67898,
					66269 -- 10 normal
				},
				execute = {
					{
						{alert = "portalcd"},
						{alert = "mistresstimer"},
					},
				},
			},
			-- Nether Power
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 67009, -- 10 man
				execute = {
					{
						{alert = "netherpowerwarn"},
					},
				},
			},
			-- Touch of Jaraxxus
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66209,
				execute = {
					{
						{raidicon = "touchmark"},
					},
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "touchself"},
					},
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{proximitycheck = {"#5#",11}},
						{alert = "touchproximitywarn"},
						{arrow = "toucharrow"},
					},
				},
			},
			-- Touch of Jaraxxus Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 66209,
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "touchself"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
