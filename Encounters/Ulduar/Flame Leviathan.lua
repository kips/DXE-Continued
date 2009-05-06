do
	local data = {
		version = "$Rev$",
		key = "flameleviathan", 
		zone = "Ulduar", 
		name = "Flame Leviathan", 
		title = "Flame Leviathan", 
		tracing = {"Flame Leviathan",},
		triggers = {
			scan = "Flame Leviathan", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			overloaddur = {
				var = "overloaddur", 
				varname = "Overload duration", 
				type = "centerpopup", 
				text = "System Overload! +50% DMG!", 
				time = 20, 
				flashtime = 20,
				sound = "ALERT1", 
				color1 = "BLUE", 
				-- So we get a sound to play
				color2 = "BLUE",
			},
			flameventdur = {
				var = "flameventdur", 
				varname = "Flame vent duration",
				type = "centerpopup", 
				text = "Flame Vents!", 
				time = 10, 
				flashtime = 5,
				sound = "ALERT2", 
				color1 = "RED",
				color2 = "ORANGE",
			},
			pursuedurother = {
				var = "pursuedur", 
				varname = "Pursue duration", 
				type = "dropdown", 
				text = "Pursue: #3#", 
				time = 30, 
				flashtime = 5, 
				color1 = "CYAN",
			},
			pursuedurself = {
				var = "pursuedur", 
				varname = "Pursue duration", 
				type = "centerpopup", 
				text = "Pursue: YOU!", 
				time = 30, 
				flashtime = 5, 
				sound = "ALERT4", 
				color1 = "CYAN",
				color1 = "MAGENTA",
			},
		},
		events = {
			-- Flame vents
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 62396, 
				execute = {
					[1] = {
						{alert = "flameventdur"},
					},
				},
			},
			-- Remove flame vents
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 62396,
				execute = {
					[1] = {
						{quash = "flameventdur"},
					},
				},
			},
			-- Overload circuits
			[3] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 62475, 
				execute = {
					[1] = {
						{alert = "overloaddur"},
					},
				},
			},
			-- Pursue
			[4] = {
				type = "event",
				event = "EMOTE",
				execute = {
					[1] = {
						{expect = {"#1#","find","pursues"}},
						{expect = {"#3#","==","&playername&"}},
						{alert = "pursuedurself"},
					},
					[2] = {
						{expect = {"#1#","find","pursues"}},
						{expect = {"#3#","~=","&playername&"}},
						{alert = "pursuedurother"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
