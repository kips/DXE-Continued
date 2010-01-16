do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 298,
		key = "sapphiron", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas["Sapphiron"], 
		triggers = {
			scan = 15989, -- Sapphiron
		},
		onactivate = {
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			tracing = {15989}, -- Sapphiron
			defeat = 15989,
		},
		userdata = {},
		onstart = {
			{
				"alert","enragecd",
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alerts["Enrage"],
				type = "dropdown",
				text = L.alerts["Enrage"],
				time = 900,
				flashtime = 5,
				color1 = "RED",
				color2 = "RED",
				icon = ST[12317],
			},
			lifedraincd = {
				varname = format(L.alerts["%s Cooldown"],SN[28542]),
				type = "dropdown", 
				text = format(L.alerts["Next %s"],SN[28542]),
				time = 23, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "MAGENTA", 
				icon = ST[28542],
			},
			airphasedur = {
				varname = format(L.alerts["%s Duration"],L.alerts["Air Phase"]),
				type = "centerpopup", 
				text = format(L.alerts["%s Duration"],L.alerts["Air Phase"]), 
				time = 15.5, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "YELLOW", 
				icon = ST[51475],
			},
			deepbreathwarn = {
				varname = format(L.alerts["%s Warning"],L.alerts["Deep Breath"]),
				type = "centerpopup", 
				text = format("%s! %s!",L.alerts["Deep Breath"],L.alerts["HIDE"]),
				time = 10, 
				flashtime = 6.5, 
				sound = "ALERT1", 
				color1 = "BLUE",
				flashscreen = true,
				icon = ST[28524],
			},
		},
		events = {
			-- Life drain
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {28542,55665}, 
				execute = {
					{
						"alert","lifedraincd", 
					},
				},
			},
			-- Emotes
			{
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["lifts"]},
						"alert","airphasedur", 
						"quash","lifedraincd",
					},
					{
						"expect",{"#1#","find",L.chat_naxxramas["deep"]},
						"quash","airphasedur",
						"alert","deepbreathwarn", 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

