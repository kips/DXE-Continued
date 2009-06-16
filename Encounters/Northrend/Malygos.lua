do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "malygos", 
		zone = L["The Eye of Eternity"], 
		category = L["Northrend"],
		name = L["Malygos"], 
		triggers = {
			scan = {L["Malygos"],L["Nexus Lord"],L["Scion of Eternity"],L["Power Spark"]}, 
		},
		onactivate = {
			tracing = {L["Malygos"]},
			autostart = true,
			autostop = true,
			leavecombat = true,
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
				varname = format(L["%s Cooldown"],SN[56105]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],SN[56105]),
				time = "<vortexcd>", 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "BLUE", 
			},
			staticfieldwarn = {
				var = "staticfieldwarn", 
				varname = format(L["%s Warning"],SN[57430]),
				type = "simple", 
				text = format("%s! %s!",format(L["%s Casted"],SN[57430]),L["MOVE"]),
				time = 1.5, 
				sound = "ALERT2", 
				color1 = "YELLOW",
			},
			surgewarn = { 
				var = "surgewarn", 
				varname = format(L["%s on self"],L["Surge"]),
				type = "centerpopup", 
				text = format("%s: %s! %s!",L["Surge"],L["YOU"],L["CAREFUL"]),
				time = 3,
				flashtime = 3,
				sound = "ALERT1", 
				throttle = 5,
				color1 = "MAGENTA",
			},
			presurgewarn = { 
				var = "surgewarn", 
				varname = format(L["%s on self"],L["Surge"]), 
				type = "simple", 
				text = format("%s: %s! %s!",L["Surge"],L["YOU"],L["SOON"]),
				time = 1.5, 
				sound = "ALERT5", 
				color1 = "TURQUOISE",
			},
			deepbreath = {
				var = "deepbreath", 
				varname = format(L["%s Cooldown"],L["Deep Breath"]), 
				type = "dropdown", 
				text = format(L["Next %s"],L["Deep Breath"]),
				time = 92, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "ORANGE", 
			},
			vortexdur = {
				var = "vortexdur", 
				varname = format(L["%s Duration"],SN[56105]),
				type = "centerpopup", 
				text = format(L["%s Duration"],SN[56105]),
				time = 10, 
				sound = "ALERT1", 
				color1 = "BLUE", 
			},
			powerspark = {
				var = "powerspark", 
				varname = format(L["%s Spawns"],L["Power Spark"]),
				type = "dropdown", 
				text = format(L["Next %s"],L["Power Spark"]),
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
						{quash = "presurgewarn"},
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
						{expect = {"#1#","find",L["I had hoped to end your lives quickly"]}},
						{quash = "vortexdur"},
						{quash = "vortexcd"},
						{quash = "powerspark"},
						{set = {phase = 2}},
						{alert = "deepbreath"},
					},
					[2] = {
						{expect = {"#1#", "find", L["ENOUGH!"]}},
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
			-- Whispers
			[6] = {
				type = "event",
				event = "WHISPER",
				execute = {
					[1] = {
						{expect = {"#1#","find",L["fixes his eyes on you!$"]}},
						{alert = "presurgewarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
