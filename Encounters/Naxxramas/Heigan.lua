do
	local L,SN = DXE.L,DXE.SN

	local L_HeiganTheUnclean = L["Heigan the Unclean"]

	local data = {
		version = "$Rev$",
		key = "heigantheunclean", 
		zone = L["Naxxramas"], 
		name = L_HeiganTheUnclean, 
		triggers = {
			scan = L_HeiganTheUnclean, 
		},
		onactivate = {
			tracing = {L_HeiganTheUnclean,},
			autostart = true,
			autostop = true,
			leavecombat = true,
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
				varname = format(L["%s Begins"],L["Dance"]),
				type = "dropdown", 
				text = format(L["%s Begins"],L["Dance"]),
				time = 90, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
			},
			danceends = {
				var = "danceends", 
				varname = format(L["%s Ends"],L["Dance"]),
				type = "dropdown", 
				text = format(L["%s Ends"],L["Dance"]),
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
						{expect = {"#1#","find",L["^The end is upon you"]}},
						{alert = "danceends"}, 
						{scheduletimer = {"backonfloor", 45}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
