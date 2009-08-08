do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = "$Rev$",
		key = "heigantheunclean", 
		zone = L["Naxxramas"], 
		name = L["Heigan the Unclean"], 
		triggers = {
			scan = 15936, -- Heigan the Unclean
		},
		onactivate = {
			tracing = {15936},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {},
		onstart = {
			{
				{alert = "dancebegins"},
			}
		},
		alerts = {
			dancebegins = {
				varname = format(L["%s Begins"],L["Dance"]),
				type = "dropdown", 
				text = format(L["%s Begins"],L["Dance"]),
				time = 90, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA",
				icon = ST[29516],
			},
			danceends = {
				varname = format(L["%s Ends"],L["Dance"]),
				type = "dropdown", 
				text = format(L["%s Ends"],L["Dance"]),
				time = 45, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "DCYAN", 
				icon = ST[49838],
			},
		},
		timers = {
			backonfloor = {
				{
					{alert = "dancebegins"},
				}
			}
		},
		events = {
			-- Dance starts
			{
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					{
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
