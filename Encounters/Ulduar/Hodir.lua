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
				text = "Flash Freeze! Move!", 
				time = 9,
				flashtime = 9,
				sound = "ALERT1", 
				color1 = "BLUE",
				color2 = "GREEN",
			},
			flashfreezecd = {
				var = "flashfreezecd", 
				varname = "Flash freeze cooldown",
				type = "dropdown", 
				text = "Flash Freeze Cooldown", 
				time = 52, 
				flashtime = 5,
				sound = "ALERT2", 
				color1 = "TURQUOISE",
				color2 = "MAGENTA",
			},
			enragecd = {
				var = "enragecd",
				varname = "Enrage",
				type = "dropdown",
				text = "Enrage",
				time = 480,
				flashtime = 5,
				color1 = "RED",
			},
			frozenblowdur = {
				var = "frozenblowdur", 
				varname = "Frozen blow duration", 
				type = "centerpopup", 
				text = "Frozen Blow Duration",
				time = 20,
				flashtime = 20, 
				sound = "ALERT3", 
				color1 = "MAGENTA",
				color2 = "MAGENTA",
			},
			hardmodeends = {
				var = "hardmodeends",
				varname = "Hard mode ends",
				type = "dropdown",
				text = "Hard Mode Ends",
				time = 120,
				flashtime = 10,
				sound = "ALERT4",
				color1 = "YELLOW",
				color2 = "YELLOW",
			},
			stormcloudwarnself = {
				var = "stormcloudwarn",
				varname = "Storm Cloud warning",
				type = "simple",
				text = "Storm Cloud: YOU!",
				time = 1.5,
				color2 = "ORANGE",
				sound = "ALERT4",
			},
			stormcloudwarnother = {
				var = "stormcloudwarn",
				varname = "Storm Cloud warning",
				type = "simple",
				text = "Storm Cloud: #5#",
				time = 1.5,
				color2 = "ORANGE",
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
			-- Storm Cloud
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 65133,
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "stormcloudwarnself"},
					},
					[2] = {
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "stormcloudwarnother"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
