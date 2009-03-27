do
	local data = {
		version = "$Rev$",
		key = "malygos", 
		zone = "The Eye of Eternity", 
		name = "Malygos", 
		title = "Malygos", 
		tracing = {"Malygos"},
		triggers = {
			scan = "Malygos", 
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = { 
			phase = 1,
			vortexcd = {29,59,loop=false},
		},
		onstart = {
			[1] = {
				{alert = "vortexcd"},
			}
		},
		alerts = {
			vortexcd = {
				var = "vortexcd", 
				varname = "Vortex cooldown", 
				type = "dropdown", 
				text = "Vortex cooldown", 
				time = "<vortexcd>", 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "BLUE", 
			},
			staticfieldwarn = {
				var = "staticfieldwarn", 
				varname = "Static field warning", 
				type = "simple", 
				text = "Static field casted. Move!", 
				time = 1.5, 
				flashtime = 0, 
				sound = "ALERT2", 
			},
			surgewarn = { 
				var = "surgewarn", 
				varname = "Surge warning", 
				type = "simple", 
				text = "Surge on you. Careful!", 
				time = 1.5, 
				flashtime = 0, 
				sound = "ALERT1", 
				throttle = 5,
			},
			deepbreath = {
				var = "deepbreath", 
				varname = "Deep breath", 
				type = "dropdown", 
				text = "Deep breath", 
				time = 92, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "ORANGE", 
			},
			vortexdur = {
				var = "vortexdur", 
				varname = "Vortex duration", 
				type = "centerpopup", 
				text = "Vortex duration", 
				time = 10, 
				flashtime = 0, 
				sound = "ALERT1", 
				color1 = "BLUE", 
			},
			powerspark = {
				var = "powerspark", 
				varname = "Power spark", 
				type = "dropdown", 
				text = "Power spark", 
				time = 17, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "WHITE", 
			},
		},
		events = {
			-- Vortex/Power spark
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 56105, 
				execute = {
					[1] = {
						
						{alert = "vortexdur"}, 
						{alert = "vortexcd"}, 
						{quash = "powerspark"},
						{alert = "powerspark"},
					},
				},
			},
			-- Surge
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {57407, 60936}, 
				execute = {
					[1] = {
						{expect = {"#4#","==","&vehicleguid&"}},
						{alert = "surgewarn"},
					},
				},
			},
			-- Static field
			[3] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 57430, 
				execute = {
					[1] = {
						{alert = "staticfieldwarn"},
					},
				},
			},
			-- Yells
			[4] = {
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					[1] = {
						{expect = {"#1#", "find", "I had hoped to end your lives quickly"}},
						{quash = "vortexdur"},
						{quash = "vortexcd"},
						{quash = "powerspark"},
						{set = {phase = 2}},
						{alert = "deepbreath"},
					},
					[2] = {
						{expect = {"#1#", "find", "ENOUGH!"}},
						{quash = "deepbreath"},
						{set = {phase = 3}},
					},
				},
			},
			-- Emotes
			[5] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"<phase>","==","1"}},
						{quash = "powerspark"},
						{alert = "powerspark"},
					},
					[2] = {
						{expect = {"<phase>","==","2"}},
						{alert = "deepbreath"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


