do
	local data = {
		version = "$Rev$",
		key = "thorim", 
		zone = "Ulduar", 
		name = "Thorim", 
		title = "Thorim", 
		tracing = {"Runic Colossus","Ancient Rune Giant"},
		triggers = {
			scan = "Jormungar Behemoth",
			yell = "^Interlopers",
		},
		onactivate = {
			leavecombat = true,
		},
		userdata = {
			chargecount = 1,
			chargetime = {34,15,loop = false},
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
		-- TODO: Add Impale, Runic Barrier warning?
		alerts = {
			enrage2cd = {
				var = "enrage2cd", 
				varname = "Phase 2 Enrage", 
				type = "dropdown", 
				text = "Enrage", 
				time = 120, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED",
			},
			hardmodecd = {
				var = "hardmodecd", 
				varname = "Hard Mode timeleft", 
				type = "dropdown", 
				text = "Hard Mode Ends", 
				time = 180, 
				flashtime = 5, 
				sound = "ALERT1", 
			},
			phase3start = {
				var = "phase3start", 
				varname = "Phase 3 warning", 
				type = "simple", 
				text = "Thorim Engaged!", 
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
			--[[
			hammerwarnself = {
				var = "hammerwarnself",
				varname = "Storm Hammer on self",
				type = "centerpopup",
				text = "Storm Hammer: YOU!",
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
			]]
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
						{alert = "phase3start"},
						{alert = "chargecd"},
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
			--[[
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
			]]
		},
	}

	DXE:RegisterEncounter(data)
end

