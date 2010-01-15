do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 299,
		key = "heigantheunclean", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas["Heigan the Unclean"], 
		triggers = {
			scan = 15936, -- Heigan the Unclean
		},
		onactivate = {
			tracing = {15936},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15936,
		},
		userdata = {},
		onstart = {
			{
				"alert","dancebeginscd",
			}
		},
		alerts = {
			dancebeginscd = {
				varname = format(L.alerts["%s Begins"],L.alerts["Dance"]),
				type = "dropdown", 
				text = format(L.alerts["%s Begins"],L.alerts["Dance"]),
				time = 90, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA",
				icon = ST[29516],
			},
			danceendscd = {
				varname = format(L.alerts["%s Ends"],L.alerts["Dance"]),
				type = "dropdown", 
				text = format(L.alerts["%s Ends"],L.alerts["Dance"]),
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
					"alert","dancebeginscd",
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
						"expect",{"#1#","find",L.chat_msg_triggers_naxxramas["^The end is upon you"]},
						"alert","danceendscd", 
						"scheduletimer",{"backonfloor", 45},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
