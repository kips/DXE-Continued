do
	local data = {
		version = "$Rev$",
		key = "thorim", 
		zone = "Ulduar", 
		name = "Thorim", 
		title = "Thorim", 
		tracing = {"Thorim","Jormungar Behemoth"},
		triggers = {
			scan = "Thorim", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			chargecount = 1,
			striketimer = 15,
		},
		onstart = {
			[1] = {
				{expect = {"&difficulty&","==","1"}},
				{set = {striketimer = 6}},
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
				varname = "Phase 2 enrage cooldown", 
				type = "dropdown", 
				text = "Phase 2 Enrage", 
				time = 120, 
				flashtime = 5, 
				sound = "ALERT1", 
			},
			hardmodecd = {
				var = "hardmodecd", 
				varname = "Hard mode timer", 
				type = "dropdown", 
				text = "Hard Mode Ends", 
				time = 180, 
				flashtime = 5, 
				sound = "ALERT1", 
			},
			phase3start = {
				var = "phase3start", 
				varname = "Phase 3 alert", 
				type = "simple", 
				text = "Thorim Engaged!", 
				time = 1.5, 
				sound = "ALERT1", 
			},
			chargewarn = {
				var = "chargewarn", 
				varname = "Lightning charge warning", 
				type = "dropdown", 
				text = "Lightning Charge: <chargecount>", 
				time = 15, 
				flashtime = 5, 
				sound = "ALERT2",
				color1 = "VIOLET",
			},
			hammerwarnself = {
				var = "hammerwarnself",
				varname = "Storm Hammer on self",
				type = "centerpopup",
				text = "Storm Hammer: YOU! Move!",
				time = 16,
				flashtime = 16,
				sound = "ALERT3",
				color1 = "TEAL",
				color2 = "BLUE",
			},
			hammerwarnother = {
				var = "hammerwarnother",
				varname = "Storm Hammer on others",
				type = "centerpopup",
				text = "Storm Hammer: #5#",
				time = 16,
				color1 = "TEAL",
			},
			strikedur = {
				var = "strikedur", 
				varname = "Unbalancing strike duration", 
				type = "dropdown", 
				text = "Unbalancing strike!", 
				time = "<striketimer>", 
				flashtime = 5, 
				sound = "ALERT4",
				color1 = "ORANGE",
			},
		},
		events = {
			[1] = {
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Phase 2
					[1] = {
						{expect = {"#1#","find","^Interlopers!"}},
						{alert = "hardmodecd"},
						{scheduletimer = {"hardmodefailed", 180}},
						{tracing = {"Thorim","Runic Colossus","Ancient Rune Giant"}},
					},
					-- Phase 3
					[2] = {
						{expect = {"#1#","find","^Impertinent"}},
						{quash = "hardmodecd"},
						{quash = "enrage2cd"},
						{canceltimer = "hardmodefailed"},
						{tracing = {"Thorim"}},
						{alert = "phase3start"},
						{alert = "chargewarn"},
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
						{alert = "chargewarn"},
					},
				},
			},
			-- Stormhammer
			[3] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 62042, 
				execute = {
					[1] = {
						{expect = {"#4#", "==", "&playerguid&"}},
						{alert = "hammerwarnself"},
					},
					[2] = {
						{expect = {"#4#", "~=", "&playerguid&"}},
						{alert = "hammerwarnother"},
					},
				},
			},
			-- Unbalancing Strike
			[4] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 62130, 
				execute = {
					[1] = {
						{alert = "strikedur"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

