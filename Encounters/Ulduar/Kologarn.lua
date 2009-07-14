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
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		onstart = {
			{
				{expect = {"&difficulty&","==","1"}},
				{set = {armrespawntime = 40}},
			},
		},
		alerts = {
			stonegripwarnothers = {
				varname = format(L["%s on others"],SN[64290]),
				type = "simple",
				text = format("%s: #5#",SN[64290]),
				time = 1.5,
				color1 = "BROWN",
				sound = "ALERT2",
			},
			armsweepcd = {
				varname = format(L["%s Cooldown"],SN[63766]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[63766]),
				time = 10,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT3",
			},
			shockwavecd = {
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
				varname = format(L["%s Respawn"],L["Left Arm"]),
				type = "dropdown",
				text = format(L["%s Respawns"],L["Left Arm"]),
				time = "<armrespawntime>",
				color1 = "CYAN",
			},
			rightarmcd = {
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
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64290,64292},
				execute = {
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "stonegripwarnothers"},
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Shockwave
					{
						{expect = {"#1#","find","^OBLIVION"}},
						{alert = "shockwavecd"},
					},
				},
			},
			-- Arm Sweep
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {63766,63983},
				execute = {
					{
						{alert = "armsweepcd"},
					},
				},
			},
			-- Arm Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						{expect = {"#5#","==",L["Right Arm"]}},
						{alert = "rightarmcd"},
					},
					{
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
