do
	local data = {
		version = "$Rev$",
		key = "kelthuzad", 
		zone = "Naxxramas", 
		name = "Kel'Thuzad", 
		title = "Kel'Thuzad", 
		tracing = {"Kel'Thuzad",},
		triggers = {
			yell = "Minions, servants, soldiers of the cold dark", 
		},
		onactivate = {
			autostop = true,
			-- No leavecombat because a hunter could feign during phase 1
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
				text = "Fissure Spawned", 
				time = 1.5, 
				sound = "ALERT1",
				color1 = "BLACK",
			},
			frostblastwarn = {
				var = "frostblastwarn", 
				varname = "Frostblast warning", 
				type = "simple", 
				text = "Frost Blast Casted", 
				time = 1.5, 
				sound = "ALERT2", 
				throttle = 5,
				color1 = "BLUE",
			},
			detonatewarn = {
				var = "detonatewarn", 
				varname = "Detonate warning", 
				type = "centerpopup", 
				text = "Detonate: YOU!", 
				time = 5, 
				sound = "ALERT3", 
				color1 = "WHITE", 
			},
			ktarrives = {
				var = "ktarrives", 
				varname = "Kel'Thuzad arrival", 
				type = "dropdown", 
				text = "Kel'Thuzad Arrives", 
				time = 225, 
				flashtime = 5, 
			},
			guardianswarn = {
				var = "guardianswarn", 
				varname = "Guardians spawn", 
				type = "centerpopup", 
				text = "Guardians Spawn", 
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
						{alert = "guardianswarn"}, 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end
