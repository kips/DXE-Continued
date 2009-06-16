do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "kologarn", 
		zone = "Ulduar", 
		name = L["Kologarn"], 
		triggers = {
			scan = L["Kologarn"], 
		},
		onactivate = {
			tracing = {L["Kologarn"],L["Right Arm"],L["Left Arm"]},
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
				varname = format(L["%s on others"],SN[64290]),
				type = "simple",
				text = format("%s: #5#",SN[64290]),
				time = 1.5,
				color1 = "BROWN",
				sound = "ALERT2",
			},
			armsweepcd = {
				var = "armsweepcd",
				varname = format(L["%s Cooldown"],SN[63766]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[63766]),
				time = 10,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT3",
			},
			shockwavecd = {
				var = "shockwavecd",
				varname = format(L["%s Cooldown"],SN[63783]),
				type = "dropdown",
				text = format(L["Next %s"],SN[63783]),
				time = 16,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "GOLD",
				sound = "ALERT4",
			},
			leftarmcd = {
				var = "leftarmcd",
				varname = format(L["%s Respawn"],L["Left Arm"]),
				type = "dropdown",
				text = format(L["%s Respawns"],L["Left Arm"]),
				time = "<armrespawntime>",
				color1 = "CYAN",
			},
			rightarmcd = {
				var = "rightarmcd",
				varname = format(L["%s Respawn"],L["Right Arm"]),
				type = "dropdown",
				text = format(L["%s Respawns"],L["Right Arm"]),
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
						{expect = {"#5#","==",L["Right Arm"]}},
						{alert = "rightarmcd"},
					},
					[2] = {
						{expect = {"#5#","==",L["Left Arm"]}},
						{quash = "shockwavecd"},
						{alert = "leftarmcd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
