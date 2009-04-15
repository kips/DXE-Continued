do
	local data = {
		version = "$Rev$",
		key = "ignis", 
		zone = "Ulduar", 
		name = "Ignis the Furnace Master", 
		title = "Ignis the Furnace Master", 
		tracing = {"Ignis the Furnace Master",},
		triggers = {
			scan = "Ignis the Furnace Master", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			flamejetstime = {25,23.3,loop = false},
			slagpotmessage = "",
		},
		onstart = {
			[1] = {
				{alert = "flamejetscd"},
			},
		},
		alerts = {
			flamejetswarn = {
				var = "flamejetswarn",
				varname = "Flame Jets cast",
				type = "centerpopup",
				text = "Flame Jets Cast",
				time = 2.7,
				color1 = "RED",
				sound = "ALERT3",
			},
			flamejetscd = {
				var = "flamejetscd",
				varname = "Flame Jets cooldown",
				type = "dropdown",
				time = "<flamejetstime>",
				text = "Flame Jets Cooldown",
				flashtime = 5,
				color1 = "RED",
				color2 = "MAGENTA",
				sound = "ALERT1",
			},
			scorchwarnself = {
				var = "scorchwarnself",
				varname = "Scorch warning on self",
				type = "simple",
				text = "Scorched: YOU!",
				time = 1.5,
				color1 = "MAGENTA",
				sound = "ALERT5",
			},
			scorchcd = {
				var = "scorchcd",
				varname = "Scorch cooldown",
				text = "Next Scorch",
				type = "dropdown",
				time = 25,
				flashtime = 5,
				color1 = "MAGENTA",
				color2 = "YELLOW",
				sound = "ALERT2",
			},
			slagpotdur = {
				var = "slagpotdur",
				varname = "Slag Pot duration",
				type = "centerpopup",
				text = "<slagpotmessage>",
				time = 10,
				color1 = "GREEN",
				sound = "ALERT4",
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
						{set = {slagpotmessage = "Slag Pot: YOU!"}},
					},
					[2] = {
						{expect = {"#4#","~=","&playerguid&"}},
						{set = {slagpotmessage = "Slag Pot: #5#"}},
					},
					[3] = {
						{alert = "slagpotdur"},
					},
				},
			},--[[
			-- Flame Jets cooldown
			[4] = {
				type = "event",
				event = "EMOTE",
				execute = {
					[1] = {
						{alert = "flamejetscd"},
					},
				},
			},]]
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
