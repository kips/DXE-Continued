--[[
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
		},
		userdata = {},
		onstart = {},
		alerts = {
			overloaddur = {
				var = "overloaddur", 
				varname = "Overload duration", 
				type = "dropdown", 
				text = "Overload Circuits!", 
				time = 20, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "BLUE", 
				color2 = "WHITE",
			},
			flameventdur = {
				var = "flameventdur", 
				varname = "Flame vent duration",
				type = "centerpopup", 
				text = "Flame vents!", 
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
				text = "#5# is being pursued", 
				time = 30, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "CYAN",
				color2 = "CYAN",
			},
			pursuedurself = {
				var = "pursuedur", 
				varname = "Pursue duration", 
				type = "centerpopup", 
				text = "You are being pursued!", 
				time = 30, 
				flashtime = 5, 
				sound = "ALERT4", 
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
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 62374, 
				execute = {
					[1] = {
						{expect = {"&playerguid&","==","#4#"}},
						{alert = "pursuedurself"},
					},
					[2] = {
						{expect = {"&playerguid&","not_==","#4#"}},
						{alert = "pursuedurother"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
]]
