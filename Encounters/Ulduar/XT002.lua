do
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "xt002", 
		zone = L["Ulduar"], 
		name = L["XT-002 Deconstructor"], 
		triggers = {
			scan = L["XT-002 Deconstructor"], 
		},
		onactivate = {
			tracing = {L["XT-002 Deconstructor"],},
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
			},
			gravitywarnother = {
				varname = format(L["%s on others"],SN[63024]),
				type = "centerpopup",
				text = format("%s: #5#",SN[63024]),
				time = 9,
				color1 = "GREEN",
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
			},
			lightwarnother = {
				varname = format(L["%s on others"],SN[63018]),
				type = "centerpopup",
				text = format("%s: #5#",SN[63018]),
				time = 9,
				color1 = "CYAN",
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
			},
			hardmodealert = {
				varname = format(L["%s Activation"],L["Hard Mode"]),
				type = "simple",
				text = format(L["%s Activated"],L["Hard Mode"]).."!",
				time = 1.5,
				sound = "ALERT5",
			},
		},
		timers = {
			heartunexposed = {
				{
					{tracing = {L["XT-002 Deconstructor"]}},
				},
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
						{tracing = {L["XT-002 Deconstructor"],L["Heart of the Deconstructor"]}},
					},
				},
			},
			-- Heartbreak
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64193,
				execute = {
					{
						{quash = "exposedwarn"},
						{canceltimer = "heartunexposed"},
						{tracing = {L["XT-002 Deconstructor"]}},
						{alert = "hardmodealert"},
						{set = {heartbroken = "1"}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


