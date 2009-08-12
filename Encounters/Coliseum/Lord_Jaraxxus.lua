do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = "$Rev$",
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
			fleshtime = {14, 23, loop = false},
			flametime = {20, 30, loop = false},
		},
		onstart = {
			{
				{alert = "portalcd"},
				{alert = "legionflamecd"},
				{alert = "eruptioncd"},
				{alert = "portalcd"},
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
		},
		arrows = {
			toucharrow = {
				varname = SN[66209],
				unit = "#5#",
				persist = 12,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = L["Touch"],
				sound = "ALERT6",
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
		events = {
			-- Legion Flame
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {68123,68125,66197 --[[10man]]},
				execute = {
					{
						{alert = "legionflamecd"},
						{raidicon = "legionflamemark"},
					},
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "legionflameself"},
					},
				},
			},
			-- Incinerate Flesh
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {67049,67051,66237 --[[10man]]},
				execute = {
					{
						{alert = "fleshcd"},
					},
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "fleshself"},
					},
				},
			},
			-- Incinerate Flesh - Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {67049,67051,66237},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "fleshself"},
					},
				},
			},
			-- Infernal Eruption
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {67901,67903, 66258--[[10man]]},
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
				spellid = {67900,67898,66269 --[[10man]]},
				execute = {
					{
						{alert = "portalcd"},
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
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{removearrow = "toucharrow"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
