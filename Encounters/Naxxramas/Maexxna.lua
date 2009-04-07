do
	local data = {
		version = "$Rev$",
		key = "maexxna", 
		zone = "Naxxramas", 
		name = "Maexxna", 
		title = "Maexxna", 
		tracing = {"Maexxna",},
		triggers = {
			scan = "Maexxna", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "spraycd"},
				{alert = "spidercd"},
			}
		},
		alerts = {
			spraycd = {
				var = "spraycd", 
				varname = "Web spray cooldown", 
				type = "dropdown", 
				text = "Next Web Spray", 
				time = 40, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "YELLOW", 
			},
			spidercd = {
				var = "spidercd", 
				varname = "Spider cooldown", 
				type = "dropdown", 
				text = "Spiders Spawn", 
				time = 30, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "ORANGE", 
			},
			enragewarn = {
				var = "enragewarn", 
				varname = "Enrage warning", 
				type = "simple", 
				text = "Enraged!", 
				time = 1.5, 
				flashtime = 0, 
				sound = "ALERT3", 
			},
		},
		events = {
			-- Spray
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {29484,54125}, 
				execute = {
					[1] = {
						
						{alert = "spraycd"}, 
						{alert = "spidercd"},
					},
				},
			},
			-- Enraged
			[2] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"#1#","find","becomes enraged"}},
						{alert = "enragewarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
