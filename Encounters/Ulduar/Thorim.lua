do
	local data = {
		version = "$Rev$",
		key = "thorim", 
		zone = "Ulduar", 
		name = "Thorim", 
		title = "Thorim", 
		tracing = {"Runic Colossus","Ancient Rune Giant"},
		triggers = {
			scan = {"Jormungar Behemoth","Thorim","Runic Colossus","Ancient Rune Giant","Iron Ring Guard","Dark Rune Thunderer","Dark Rune Commoner"},
			yell = "^Interlopers! You mortals who",
		},
		onactivate = {
			leavecombat = true,
		},
		userdata = {
			chargecount = 1,
			chargetime = 34,
		},
		onstart = {
			[1] = {
				{alert = "hardmodecd"},
				{scheduletimer = {"hardmodefailed", 180}},
			},
		},
		timers = {
			hardmodefailed = {
				[1] = {
					{alert = "enrage2cd"},
				},
			},
		},
		alerts = {
			enrage2cd = {
				var = "enrage2cd", 
				varname = "Enrage", 
				type = "dropdown", 
				text = "Enrage", 
				time = 120, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED",
			},
			hardmodecd = {
				var = "hardmodecd", 
				varname = "Hard mode timeleft", 
				type = "dropdown", 
				text = "Hard Mode Ends", 
				time = 180, 
				flashtime = 5, 
				sound = "ALERT1", 
			},
			hardmodeactivation = {
				var = "hardmodeactivation", 
				varname = "Hard mode activation", 
				type = "simple", 
				text = "Hard Mode Activated", 
				time = 1.5, 
				sound = "ALERT1", 
			},
			chargecd = {
				var = "chargecd", 
				varname = "Lightning Charge warning", 
				type = "dropdown", 
				text = "Next Lightning Charge <chargecount>", 
				time = "<chargetime>", 
				flashtime = 7, 
				sound = "ALERT2",
				color1 = "VIOLET",
			},
			chainlightningcd = {
				var = "chainlightningcd",
				varname = "Chain Lightning cooldown",
				type = "dropdown",
				text = "Chain Lightning Cooldown",
				time = 10,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "ORANGE",
				color2 = "ORANGE",
			},
			frostnovacast = {
				var = "frostnovacast",
				varname = "Frost Nova cast",
				type = "centerpopup",
				text = "Frost Nova Cast",
				time = 2.5,
				flashtime = 2.5,
				sound = "ALERT4",
				color1 = "BLUE",
				color2 = "BLUE",
			},
			strikecd = {
				var = "strikecd",
				varname = "Unbalancing Strike cooldown",
				type = "dropdown",
				text = "Unbalancing Strike Cooldown",
				time = 25,
				flashtime = 5,
				sound = "ALERT5",
				color1 = "BROWN",
				color2 = "BROWN",
			},
		},
		events = {
			[1] = {
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Phase 3
					[1] = {
						{expect = {"#1#","find","^Impertinent"}},
						{quash = "hardmodecd"},
						{quash = "enrage2cd"},
						{canceltimer = "hardmodefailed"},
						{tracing = {"Thorim"}},
						{alert = "chargecd"},
						{set = {chargetime = 15}},
					},
					-- Hard mode activation
					[2] = {
						{expect = {"#1#","find","^Impossible!"}},
						{alert = "hardmodeactivation"},
					},
				},
			},
			-- Lightning Charge
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 62279, 
				execute = {
					[1] = {
						{set = {chargecount = "INCR|1"}},
						{alert = "chargecd"},
					},
				},
			},
			-- Chain Lightning
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64390,
				execute = {
					[1] = {
						{alert = "chainlightningcd"},
					},
				},
			},
			-- Sif's Frost Nova
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62605,62597},
				execute = {
					[1] = {
						{alert = "frostnovacast"},
					},
				},
			},
			-- Unbalancing Strike
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 62130,
				execute = {
					[1] = {
						{alert = "strikecd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

