do
	local data = {
		version = "$Rev$",
		key = "kologarn", 
		zone = "Ulduar", 
		name = "Kologarn", 
		title = "Kologarn", 
		tracing = {"Kologarn","Right Arm","Left Arm"},
		triggers = {
			scan = "Kologarn", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		onstart = {
			[1] = {
				{expect = {"&difficulty&","==","1"}},
				{set = {armrespawntime = 40}},
			},
		},
		alerts = {
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
				text = "Shockwave Cooldown",
				time = 16,
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
				time = "<armrespawntime>",
				color1 = "CYAN",
			},
			rightarmcd = {
				var = "rightarmcd",
				varname = "Right Arm respawn",
				type = "dropdown",
				text = "Right Arm Respawns",
				time = "<armrespawntime>",
				color1 = "DCYAN",
			},
		},
		userdata = {
			armrespawntime = 50,
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
			[2] = {
				type = "event",
				event = "YELL",
				execute = {
					-- Shockwave
					[1] = {
						{expect = {"#1#","find","^OBLIVION"}},
						{alert = "shockwavecd"},
					},
				},
			},
			-- Arm Sweep
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {63766,63983},
				execute = {
					[1] = {
						{alert = "armsweepcd"},
					},
				},
			},
			-- Arm Deaths
			[4] = {
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					[1] = {
						{expect = {"#5#","==","Right Arm"}},
						{alert = "rightarmcd"},
					},
					[2] = {
						{expect = {"#5#","==","Left Arm"}},
						{alert = "leftarmcd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
