do
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "ignis", 
		zone = L["Ulduar"], 
		name = L["Ignis the Furnace Master"], 
		triggers = {
			scan = L["Ignis the Furnace Master"], 
		},
		onactivate = {
			tracing = {L["Ignis the Furnace Master"],},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			flamejetstime = {24,22.3,loop = false},
			slagpotmessage = "",
		},
		onstart = {
			[1] = {
				{alert = "flamejetscd"},
				{alert = "hardmodeends"},
			},
		},
		alerts = {
			flamejetswarn = {
				var = "flamejetswarn",
				varname = format(L["%s Cast"],SN[62680]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[62680]),
				time = 2.7,
				color1 = "RED",
				sound = "ALERT3",
			},
			flamejetscd = {
				var = "flamejetscd",
				varname = format(L["%s Cooldown"],SN[62680]),
				type = "dropdown",
				time = "<flamejetstime>",
				text = format(L["%s Cooldown"],SN[62680]),
				flashtime = 5,
				color1 = "RED",
				color2 = "MAGENTA",
				sound = "ALERT1",
			},
			scorchwarnself = {
				var = "scorchwarnself",
				varname = format(L["%s on self"],SN[62546]),
				type = "simple",
				text = format("%s: %s!",SN[62546],L["YOU"]),
				time = 1.5,
				color1 = "MAGENTA",
				sound = "ALERT5",
			},
			scorchcd = {
				var = "scorchcd",
				varname = format(L["%s Cooldown"],SN[62546]),
				text = format(L["Next %s"],SN[62546]),
				type = "dropdown",
				time = 25,
				flashtime = 5,
				color1 = "MAGENTA",
				color2 = "YELLOW",
				sound = "ALERT2",
			},
			slagpotdur = {
				var = "slagpotdur",
				varname = format(L["%s Duration"],SN[62717]),
				type = "centerpopup",
				text = "<slagpotmessage>",
				time = 10,
				color1 = "GREEN",
				sound = "ALERT4",
			},
			hardmodeends = {
				var = "hardmodeends",
				varname = format("%s Timer",L["Hard Mode"]),
				type = "dropdown",
				text = format("%s Ends",L["Hard Mode"]),
				time = 240,
				flashtime = 5,
				color1 = "BROWN",
				color2 = "BROWN",
				sound = "ALERT6",
			},
		},
		timers = {
			flamejet = {
				[1] = {
					{alert = "flamejetscd"},
				},
			},
		},
		events = {
			-- Scorch cooldown",
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62546, 63474},
				execute = {
					[1] = {
						{alert = "scorchcd"},
					},
				},
			},
			-- Scorch warning on self
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62548, 63476},
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"},},
						{alert = "scorchwarnself"},
					},
				},
			},
			-- Slag Pot
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62717, 63477},
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{set = {slagpotmessage = format("%s: %s!",SN[62717],L["YOU"])}},
					},
					[2] = {
						{expect = {"#4#","~=","&playerguid&"}},
						{set = {slagpotmessage = format("%s: #5#",SN[62717])}},
					},
					[3] = {
						{alert = "slagpotdur"},
					},
				},
			},
			-- Flame Jets cast
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {63472,62680},
				execute = {
					[1] = {
						{quash = "flamejetscd"},
						{alert = "flamejetswarn",},
						{scheduletimer = {"flamejet",2.7}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
