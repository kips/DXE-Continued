do
	local data = {
		version = "$Rev$",
		key = "auriya", 
		zone = "Ulduar", 
		name = "Auriya", 
		title = "Auriya", 
		tracing = {"Auriya",},
		triggers = {
			scan = "Auriya", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			screechcd = {
				type = "dropdown",
				var = "screechcd",
				varname = "Terrifying Screech cooldown",
				text = "Terrifying Screech Cooldown",
				time = 35,
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "VIOLET",
				sound = "ALERT1",
			},
			sentinelwarn = {
				type = "simple",
				var = "sentinelwarn",
				varname = "Sentinel Blast warning",
				text = "Sentinel Blast Casted!",
				time = 1.5,
				color1 = "BLUE",
			},
		},
		events = {
			-- Terrifying Screech
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64386,
				execute = {
					[1] = {
						{alert = "screechcd"},
					}	
				},
			},
			-- Sentinel Blast
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64389,64678},
				execute = {
					[1] = {
						{alert = "sentinelwarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


