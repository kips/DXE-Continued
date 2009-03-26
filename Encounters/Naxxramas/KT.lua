do
	local data = {
		version = "$Rev: 22 $",
		key = "kelthuzad", 
		zone = "Naxxramas", 
		name = "Kel'Thuzad", 
		title = "Kel'Thuzad", 
		tracing = {
			name = "Kel'Thuzad", 
		},
		triggers = {
			yell = "Minions, servants, soldiers of the cold dark", 
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "ktarrives"},
			}
		},
		alerts = {
			fissurewarn = {
				var = "fissurewarn", 
				varname = "Fissure warning", 
				type = "simple", 
				text = "Fissure spawned", 
				time = 1.5, 
				flashtime = 0, 
				sound = "ALERT1", 
			},
			frostblastwarn = {
				var = "frostblastwarn", 
				varname = "Frostblast warning", 
				type = "simple", 
				text = "Frostblast casted", 
				time = 1.5, 
				flashtime = 0, 
				sound = "ALERT2", 
				throttle = 5,
			},
			detonatewarn = {
				var = "detonatewarn", 
				varname = "Detonate warning", 
				type = "centerpopup", 
				text = "You have detonate!", 
				time = 5, 
				flashtime = 0, 
				sound = "ALERT3", 
				color1 = "BLUE", 
			},
			ktarrives = {
				var = "ktarrives", 
				varname = "Kel'Thuzad arrives", 
				type = "dropdown", 
				text = "Kel'Thuzad arrives", 
				time = 225, 
				flashtime = 5, 
			},
			guardiansinc = {
				var = "guardiansinc", 
				varname = "Guardians incoming", 
				type = "centerpopup", 
				text = "Guardians incoming", 
				time = 10, 
				flashtime = 3, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
			},
		},
		events = {
			-- Fissure
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 27810, 
				execute = {
					[1] = {
						{alert = "fissurewarn"}, 
					},
				},
			},
			-- Frost blast
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 27808, 
				execute = {
					[1] = {
						{alert = "frostblastwarn"}, 
					},
				},
			},
			-- Mana detonate
			[3] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 27819, 
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "detonatewarn"}, 
					},
				},
			},
			-- Guardians
			[4] = {
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					[1] = {
						{expect = {"#1#","find","Very well. Warriors of the frozen wastes, rise up!"}},
						{alert = "guardiansinc"}, 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end
