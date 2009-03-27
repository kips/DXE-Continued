do
	local data = {
		version = "$Rev$",
		key = "instructorrazuvious", 
		zone = "Naxxramas", 
		name = "Instructor Razuvious", 
		title = "Instructor Razuvious", 
		tracing = {"Instructor Razuvious",},
		triggers = {
			scan = "Instructor Razuvious", 
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "shoutcd"},
			}
		},
		alerts = {
			shoutcd = {
				var = "shoutcd", 
				varname = "Shout cooldown", 
				type = "dropdown", 
				text = "Disrupting shout", 
				time = 15, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
			},
			tauntdur = {
				var = "tauntdur", 
				varname = "Taunt duration", 
				type = "dropdown", 
				text = "Taunt done", 
				time = 20, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "BLUE", 
			},
			shieldwalldur = {
				var = "shieldwalldur", 
				varname = "Shield wall duration", 
				type = "dropdown", 
				text = "Shield wall done", 
				time = 20, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "YELLOW", 
			},
		},
		events = {
			-- Disrupting shout
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {29107,55543}, 
				execute = {
					[1] = {
						{alert = "shoutcd"}, 
					},
				},
			},
			-- Taunt
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 29060, 
				execute = {
					[1] = {
						
						{alert = "tauntdur"}, 
					},
				},
			},
			-- Shield wall
			[3] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 29061, 
				execute = {
					[1] = {
						{alert = "shieldwalldur"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
