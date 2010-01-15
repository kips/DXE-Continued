do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 300,
		key = "archavon", 
		zone = L.zone["Vault of Archavon"],
		category = L.zone["Northrend"],
		name = L.npc_northrend["Archavon"],
		triggers = {
			scan = 31125, -- Archavon
		},
		onactivate = {
			tracing = {31125}, -- Archavon
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 31125,
		},
		userdata = {},
		onstart = {
			{
				"alert","enragecd",
				"alert","stompcd",
			}
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alerts["Enrage"],
				type = "dropdown",
				text = L.alerts["Enrage"],
				time = 300,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			chargewarn = {
				varname = format(L.alerts["%s Warning"],SN[100]),
				type = "simple",
				text = format("%s: #5#",SN[100]),
				time = 1.5,
				sound = "ALERT2",
				icon = ST[100],
			},
			cloudwarn = {
				varname = format(L.alerts["%s Warning"],SN[58965]),
				type = "simple",
				text = format("%s: %s! %s!",SN[58965],L.alerts["YOU"],L.alerts["MOVE"]),
				time = 1.5,
				sound = "ALERT2",
				icon = ST[58965],
			},
			shardswarnself = {
				varname = format(L.alerts["%s on self"],SN[58695]),
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				text = format("%s: %s! %s!",SN[58695],L.alerts["YOU"],L.alerts["MOVE"]),
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[58695],
			},
			shardswarnothers = {
				varname = format(L.alerts["%s on others"],SN[58695]),
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				sound = "ALERT3",
				text = format("%s: &tft_unitname&",SN[58695]),
				icon = ST[58695],
			},
			stompcd = {
				varname = format(L.alerts["%s Cooldown"],SN[58663]),
				type = "dropdown",
				text = format(L.alerts["Next %s"],SN[58663]),
				time = 47,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "BROWN",
				icon = ST[58663],
			},
		},
		timers = {
			shards = {
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 1"},
					"alert","shardswarnself",
				},
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 nil"},
					"alert","shardswarnothers",
				},
			},
		},
		events = {
			-- Stomp
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {58663, 60880}, 
				execute = {
					{
						"alert","stompcd", 
					},
				},
			},
			-- Shards
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 58678,
				execute = {
					{
						"scheduletimer",{"shards",0.2},
					}
				},
			},
			-- Cloud
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {58965, 61672},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","cloudwarn",
					},
				},
			},
			-- Charge
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_EMOTE",
				execute = {
					{
						"alert","chargewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
