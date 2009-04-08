do
	local data = {
		version = "$Rev$",
		key = "hodir", 
		zone = "Ulduar", 
		name = "Hodir", 
		title = "Hodir", 
		tracing = {"Hodir",},
		triggers = {
			scan = "Hodir", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "enragecd"},
				{alert = "flashfreezecd"},
				{alert = "hardmodeends"},
			},
		},
		alerts = {
			flashfreezewarn = {
				var = "flashfreezewarn", 
				varname = "Flash Freeze cast", 
				type = "centerpopup", 
				text = "Flash Freeze! Hide!", 
				time = 9,
				flashtime = 9,
				sound = "ALERT1", 
				color1 = "BLUE",
				color2 = "GREEN",
			},
			flashfreezecd = {
				var = "flashfreezecd", 
				varname = "Flash freeze cooldown",
				type = "centerpopup", 
				text = "Next Flash Freeze", 
				time = 35, 
				flashtime = 5,
				sound = "ALERT2", 
				color1 = "TURQUOISE",
				color2 = "MAGENTA",
			},
			enragecd = {
				var = "enragecd",
				varname = "Enrage cooldown",
				type = "dropdown",
				text = "Enrage",
				time = 540,
				flashtime = 5,
				color1 = "RED",
			},
			frozenblowdur = {
				var = "frozenblowdur", 
				varname = "Frozen blow duration", 
				type = "dropdown", 
				text = "Frozen Blow Duration",
				time = 20,
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "MAGENTA",
				color2 = "GREEN",
			},
			hardmodeends = {
				var = "hardmodeends",
				varname = "Hard mode ends",
				type = "dropdown",
				text = "Hard Mode Ends",
				time = 165,
				flashtime = 10,
				sound = "ALERT4",
			},
		},
		events = {
			-- Flash Freeze cast
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_START",
				spellid = 61968, 
				execute = {
					[1] = {
						{alert = "flashfreezewarn"},
						{alert = "flashfreezecd"},
					},
				},
			},
			-- Frozen Blow
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {62478,63512},
				execute = {
					[1] = {
						{alert = "frozenblowdur"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
