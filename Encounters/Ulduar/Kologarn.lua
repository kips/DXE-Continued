do
	local data = {
		version = "$Rev$",
		key = "kologarn", 
		zone = "Ulduar", 
		name = "Kologarn", 
		title = "Kologarn", 
		tracing = {"Kologarn",},
		triggers = {
			scan = "Kologarn", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			eyebeamdurself = {
				var = "eyebeamdurself",
				varname = "Eyebeam duration on self",
				type = "centerpopup",
				text = "Eyebeam: YOU!",
				time = 10,
				flashtime = 10,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT1",
			},
			eyebeamdurothers = {
				var = "eyebeamdurothers",
				varname = "Eyebeam duration on others",
				type = "centerpopup",
				text = "Eyebeam: #2#",
				time = 10,
				color1 = "BLUE",
			},
			stonegripwarnothers = {
				var = "stonegripothers",
				varname = "Stone Grip warning on others",
				type = "simple",
				text = "Stone Gripped: #5#",
				time = 1.5,
				color1 = "BROWN",
				sound = "ALERT2",
			},
			armsweepcd = {
				var = "armsweepcd",
				varname = "Arm Sweep cooldown",
				type = "dropdown",
				text = "Arm Sweep Cooldown",
				time = 10,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT3",
			},
			shockwavecd = {
				var = "shockwavecd",
				varname = "Next Shockwave",
				type = "dropdown",
				text = "Next Shockwave",
				time = 21,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "GOLD",
				sound = "ALERT4",
			},
			leftarmcd = {
				var = "leftarmcd",
				varname = "Left Arm respawn",
				type = "dropdown",
				text = "Left Arm Respawns",
				time = 60,
				flashtime = 5,
				color1 = "CYAN",
				sound = "ALERT5",
			},
			rightarmcd = {
				var = "rightarmcd",
				varname = "Right Arm respawn",
				type = "dropdown",
				text = "Right Arm Respawns",
				time = 60,
				flashtime = 5,
				color1 = "DCYAN",
				sound = "ALERT5",
			},
		},
		events = {
			-- Stone Grip
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64290,64292},
				execute = {
					[1] = {
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "stonegripwarnothers"},
					},
				},
			},
			-- Focused Eyebeam
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {63343, 63701},
				execute = {
					[1] = {
						{expect = {"#2#","==","&playername&"}},
						{alert = "eyebeamdurself"},
					},
					[2] = {
						{expect = {"#2#","~=","&playername&"}},
						{alert = "eyebeamdurothers"},
					},
				},
			},
			[3] = {
				type = "event",
				event = "YELL",
				execute = {
					-- Left Arm dies
					[1] = {
						{expect = {"#1#","find","^Just a scratch"}},
						{alert = "leftarmcd"},
					},
					-- Right Arm dies
					[2] = {
						{expect = {"#1#","find","^Only a flesh wound"}},
						{alert = "rightarmcd"},
					},
					-- Shockwave
					[3] = {
						{expect = {"#1#","find","^Oblivion"}},
						{alert = "shockwavecd"},
					},
				},
			},
			-- Arm Sweep
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {63766,63983},
				execute = {
					[1] = {
						{alert = "armsweepcd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
