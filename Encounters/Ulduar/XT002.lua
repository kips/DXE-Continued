do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 297,
		key = "xt002", 
		zone = L["Ulduar"], 
		name = L["XT-002 Deconstructor"], 
		triggers = {
			scan = {33293,33329}, -- XT-002 Deconstructor, Heart of the Deconstructor
		},
		onactivate = {
			tracing = {33293}, -- XT-002 Deconstructor
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {
			heartbroken = "0",
		},
		onstart = {
			{
				{alert = "enragecd"},
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 600,
				flashtime = 5,
				sound = "ALERT5",
				color1 = "RED",
				color2 = "RED",
				icon = ST[12317],
			},
			gravitywarnself = {
				varname = format(L["%s on self"],SN[63024]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[63024],L["YOU"],L["MOVE"]),
				time = 9,
				flashtime = 9,
				sound = "ALERT1",
				color1 = "GREEN",
				color2 = "PINK",
				flashscreen = true,
				icon = ST[63024],
			},
			gravitywarnother = {
				varname = format(L["%s on others"],SN[63024]),
				type = "centerpopup",
				text = format("%s: #5#",SN[63024]),
				time = 9,
				color1 = "GREEN",
				icon = ST[63024],
			},
			lightwarnself = {
				varname = format(L["%s on self"],SN[63018]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[63018],L["YOU"],L["MOVE"]),
				time = 9,
				flashtime = 9,
				sound = "ALERT3",
				color1 = "CYAN",
				color2 = "MAGENTA",
				flashscreen = true,
				icon = ST[63018],
			},
			lightwarnother = {
				varname = format(L["%s on others"],SN[63018]),
				type = "centerpopup",
				text = format("%s: #5#",SN[63018]),
				time = 9,
				color1 = "CYAN",
				icon = ST[63018],
			},
			tympanicwarn = {
				varname = format(L["%s Cast"],SN[62776]),
				type = "centerpopup",
				text = format(L["%s Cast"],L["Tantrum"]),
				time = 12,
				flashtime = 12,
				color1 = "YELLOW",
				color2 = "YELLOW",
				sound = "ALERT2",
				icon = ST[62776],
			},
			tympaniccd = {
				varname = format(L["%s Cooldown"],SN[62776]),
				type = "dropdown",
				text = format(L["%s Cooldown"],L["Tantrum"]),
				time = "65",
				flashtime = 5,
				color1 = "ORANGE",
				color2 = "ORANGE",
				sound = "ALERT6",
				icon = ST[62776],
			},
			exposedwarn = {
				varname = format(L["%s Timer"],L["Heart"]),
				type = "centerpopup",
				text = format(L["%s Exposed"],L["Heart"]).."!",
				time = 30,
				flashtime = 30,
				sound = "ALERT4",
				color1 = "BLUE",
				color2 = "RED",
				icon = ST[63849],
			},
			hardmodealert = {
				varname = format(L["%s Activation"],L["Hard Mode"]),
				type = "simple",
				text = format(L["%s Activated"],L["Hard Mode"]).."!",
				time = 1.5,
				sound = "ALERT5",
				icon = ST[62972],
			},
		},
		timers = {
			heartunexposed = {
				{
					{tracing = {33293}},
				},
			},
		},
		announces = {
			lightsay = {
				varname = format(L["Say %s on self"],SN[63018]),
				type = "SAY",
				msg = format(L["%s on Me"],SN[63018]).."!",
			},
			gravitysay = {
				varname = format(L["Say %s on self"],SN[63024]),
				type = "SAY",
				msg = format(L["%s on Me"],SN[63024]).."!",
			},
		},
		events = {
			-- Gravity Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63024, 64234},
				execute = {
					{
						{expect = {"#4#", "==", "&playerguid&"}},
						{alert = "gravitywarnself"},
						{announce = "gravitysay"},
					},
					{
						{expect = {"#4#", "~=", "&playerguid&"}},
						{alert = "gravitywarnother"},
					},
				},
			},
			-- Light Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63018,65121},
				execute = {
					{
						{expect = {"#4#", "==", "&playerguid&"}},
						{alert = "lightwarnself"},
						{announce = "lightsay"},
					},
					{
						{expect = {"#4#", "~=", "&playerguid&"}},
						{alert = "lightwarnother"},
					},
				},
			},
			-- Tympanic
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62776},
				execute = {
					{
						{alert = "tympanicwarn"},
						{expect = {"<heartbroken>","==","1"}},
						{alert = "tympaniccd"},
					},
				},
			},
			-- Heart Exposed
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63849,
				execute = {
					{
						{alert = "exposedwarn"},
						{scheduletimer = {"heartunexposed", 30}},
						{tracing = {33293,33329}}, -- XT-002, Heart of the Deconstructor
					},
				},
			},
			-- Heartbreak
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64193,65737},
				execute = {
					{
						{quash = "exposedwarn"},
						{canceltimer = "heartunexposed"},
						{tracing = {33293}},
						{alert = "hardmodealert"},
						{set = {heartbroken = "1"}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


