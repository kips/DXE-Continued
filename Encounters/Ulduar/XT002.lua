do
	local data = {
		version = "$Rev$",
		key = "xt002", 
		zone = "Ulduar", 
		name = "XT-002 Deconstructor", 
		title = "XT-002 Deconstructor", 
		tracing = {"XT-002 Deconstructor",},
		triggers = {
			scan = "XT-002 Deconstructor", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			heartbroken = "0",
		},
		onstart = {
			[1] = {
				{alert = "enragecd"},
			},
		},
		alerts = {
			enragecd = {
				var = "enragecd",
				varname = "Enrage",
				type = "dropdown",
				text = "Enrage",
				time = 600,
				flashtime = 5,
				sound = "ALERT5",
				color1 = "RED",
				color2 = "RED",
			},
			gravitywarnself = {
				var = "gravitywarnself",
				varname = "Gravity Bomb on self",
				type = "centerpopup",
				text = "Gravity Bomb: YOU! Move!",
				time = 9,
				flashtime = 9,
				sound = "ALERT1",
				color1 = "GREEN",
				color2 = "PINK",
			},
			gravitywarnother = {
				var = "gravitywarnother",
				varname = "Gravity Bomb on others",
				type = "centerpopup",
				text = "Gravity Bomb: #5#",
				time = 9,
				color1 = "GREEN",
			},
			lightwarnself = {
				var = "lightwarnself",
				varname = "Light Bomb on self",
				type = "centerpopup",
				text = "Light Bomb: YOU! Move!",
				time = 9,
				flashtime = 9,
				sound = "ALERT3",
				color1 = "CYAN",
				color2 = "MAGENTA",
			},
			lightwarnother = {
				var = "lightwarnother",
				varname = "Light Bomb on others",
				type = "centerpopup",
				text = "Light Bomb: #5#",
				time = 9,
				color1 = "CYAN",
			},
			tympanicwarn = {
				var = "tympanicwarn",
				varname = "Tympanic Tantrum cast",
				type = "centerpopup",
				text = "Tantrum Cast",
				time = 12,
				flashtime = 12,
				color1 = "YELLOW",
				color2 = "YELLOW",
				sound = "ALERT2",
			},
			tympaniccd = {
				var = "tympaniccd",
				varname = "Tympanic Tantrum cooldown",
				type = "dropdown",
				text = "Tantrum Cooldown",
				time = "65",
				flashtime = 5,
				color1 = "ORANGE",
				color2 = "ORANGE",
				sound = "ALERT6",
			},
			exposedwarn = {
				var = "exposedwarn",
				varname = "Heart exposed warning",
				type = "centerpopup",
				text = "Heart Exposed!",
				time = 30,
				flashtime = 30,
				sound = "ALERT4",
				color1 = "BLUE",
				color2 = "RED",
			},
			hardmodealert = {
				var = "hardmodealert",
				varname = "Hard mode activation",
				type = "simple",
				text = "Hard Mode Activated!",
				time = 1.5,
				sound = "ALERT5",
			},
		},
		timers = {
			heartunexposed = {
				[1] = {
					{tracing = {"XT-002 Deconstructor"}},
				},
			},
		},
		events = {
			-- Gravity Bomb
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63024, 64234},
				execute = {
					[1] = {
						{expect = {"#4#", "==", "&playerguid&"}},
						{alert = "gravitywarnself"},
					},
					[2] = {
						{expect = {"#4#", "~=", "&playerguid&"}},
						{alert = "gravitywarnother"},
					},
				},
			},
			-- Light Bomb
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63018,65121},
				execute = {
					[1] = {
						{expect = {"#4#", "==", "&playerguid&"}},
						{alert = "lightwarnself"},
					},
					[2] = {
						{expect = {"#4#", "~=", "&playerguid&"}},
						{alert = "lightwarnother"},
					},
				},
			},
			-- Tympanic
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62776},
				execute = {
					[1] = {
						{alert = "tympanicwarn"},
						{expect = {"<heartbroken>","==","1"}},
						{alert = "tympaniccd"},
					},
				},
			},
			-- Heart Exposed
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63849,
				execute = {
					[1] = {
						{alert = "exposedwarn"},
						{scheduletimer = {"heartunexposed", 30}},
						{tracing = {"XT-002 Deconstructor","Heart of the Deconstructor"}},
					},
				},
			},
			-- Heartbreak
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64193,
				execute = {
					[1] = {
						{quash = "exposedwarn"},
						{canceltimer = "heartunexposed"},
						{tracing = {"XT-002 Deconstructor"}},
						{alert = "hardmodealert"},
						{set = {heartbroken = "1"}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


