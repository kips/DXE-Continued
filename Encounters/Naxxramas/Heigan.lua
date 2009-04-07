do
	local data = {
		version = "$Rev$",
		key = "heigantheunclean", 
		zone = "Naxxramas", 
		name = "Heigan the Unclean", 
		title = "Heigan the Unclean", 
		tracing = {"Heigan the Unclean",},
		triggers = {
			scan = "Heigan the Unclean", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "dancebegins"},
			}
		},
		alerts = {
			dancebegins = {
				var = "dancebegins", 
				varname = "Dance begins", 
				type = "dropdown", 
				text = "Dance Begins", 
				time = 90, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
			},
			danceends = {
				var = "danceends", 
				varname = "Dance ends", 
				type = "dropdown", 
				text = "Dance Ends", 
				time = 45, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "DCYAN", 
			},
		},
		timers = {
			backonfloor = {
				[1] = {
					{alert = "dancebegins"},
				}
			}
		},
		events = {
			-- Dance starts
			[1] = {
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					[1] = {
						{expect = {"#1#","find","The end is upon you"}},
						{alert = "danceends"}, 
						{scheduletimer = {"backonfloor", 45}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
