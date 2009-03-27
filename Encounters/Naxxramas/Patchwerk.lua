do
	local data = {
		version = "$Rev$",
		key = "patchwerk", 
		zone = "Naxxramas", 
		name = "Patchwerk", 
		title = "Patchwerk", 
		tracing = {"Patchwerk",},
		triggers = {
			scan = "Patchwerk", 
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
			}
		},
		alerts = {
			enragecd = {
				var = "enragecd", 
				varname = "Enrage cooldown", 
				type = "dropdown", 
				text = "Enrage", 
				time = 360, 
				flashtime = 5, 
				sound = "ALERT2", 
			},
			enragewarn = {
				var = "enragewarn", 
				varname = "Enrage cooldown", 
				type = "simple", 
				text = "Enraged!", 
				time = 1.5, 
				flashtime = 0, 
				sound = "ALERT1", 
			},
		},
		events = {
			-- Enrage
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 28131, 
				execute = {
					[1] = {
						{alert = "enragewarn"}, 
						{quash = "enragecd"},
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

