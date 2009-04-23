do
	local data = {
		version = "$Rev$",
		key = "emalon", 
		zone = "Vault of Archavon", 
		name = "Emalon the Storm Watcher", 
		title = "Emalon the Storm Watcher", 
		tracing = {"Emalon the Storm Watcher",},
		triggers = {
			scan = "Emalon the Storm Watcher", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "overchargecd"},
			}
		},
		alerts = {
			novacd = {
				var = "novacd",
				varname = "Lightning Nova cooldown",
				type = "dropdown",
				time = 25,
				flashtime = 5,
				text = "Lightning Nova Cooldown",
				color1 = "BLUE",
				color2 = "BLUE",
				sound = "ALERT1",
			},
			overchargecd = {
				var = "overchargecd",
				varname = "Overcharge cooldown",
				type = "dropdown",
				time = 45,
				flashtime = 5,
				text = "Next Overcharge",
				color1 = "RED",
				color2 = "DCYAN",
				sound = "ALERT2",
			},
			overchargedblastdur = {
				var = "overchargedblastdur",
				varname = "Overcharged Blast timeleft",
				type = "centerpopup",
				time = 20,
				flashtime = 5,
				text = "Explosion!",
				color1 = "YELLOW",
				color2 = "VIOLET",
				sound = "ALERT3",
			},
		},
		-- TODO
		-- Add Enrage
		-- Make it remove overchargedblastdur if the aura is removed
		events = {
			-- Lightning Nova
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {65279,64216},
				execute = {
					[1] = {
						{alert = "novacd"},
					},
				},
			},
			-- Overcharge and Overcharged Blast
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64218,
				execute = {
					[1] = {
						{alert = "overchargecd"},
						{alert = "overchargedblastdur"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

