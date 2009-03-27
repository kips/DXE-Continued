--[[
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
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "enragecd"},
				{alert = "flashfreezecd"},
			},
		},
		alerts = {
			flashfreezewarn = {
				var = "flashfreezewarn", 
				varname = "Flash freeze cast", 
				type = "centerpopup", 
				text = "Flash freeze casting", 
				time = 9, 
				flashtime = 0, 
				sound = "ALERT1", 
				color1 = "BLUE", 
			},
			flashfreezecd = {
				var = "flashfreezecd", 
				varname = "Flash freeze cooldown",
				type = "centerpopup", 
				text = "Next flash freeze", 
				time = 35, 
				flashtime = 5,
				sound = "ALERT2", 
				color1 = "TURQUOISE",
				color2 = "RED",
			},
			enragecd = {
				var = "enragecd",
				varname = "Enrage cooldown",
				type = "dropdown",
				text = "Enrage",
				time = 540,
				flashtime = 5,
			},
			frozenblowdur = {
				var = "frozenblowdur", 
				varname = "Frozen blow duration", 
				type = "dropdown", 
				text = "Frozen Blow duration",
				time = 20,
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "MAGENTA",
				color2 = "GREEN",
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
]]
