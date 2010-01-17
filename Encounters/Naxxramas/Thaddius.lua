do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 298,
		key = "thaddius", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas["Thaddius"], 
		triggers = {
			scan = {
				15928, -- Thaddius
				15929, -- Stalagg
				15930, -- Feugen
			},
			yell = {
        L.chat_naxxramas["Stalagg crush you!"],
        L.chat_naxxramas["Feed you to master!"]
      },
		},
		onactivate = {
			tracing = {
				15928, -- Thaddius
				15929, -- Stalagg
				15930, -- Feugen
			},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15928,
		},
		userdata = { 
			dead = 0,
		},
		onacquired = {
			[15928] = { -- Thaddius
				{
					"resettimer",true,
					"alert","enragecd",
					"quash","tankthrowcd",
					"canceltimer","tankthrow",
					"tracing",{15928}, -- Thaddius
				},
			},
		},
		onstart = {
			{
				"alert","tankthrowcd",
				"scheduletimer",{"tankthrow", 20.6},
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown", 
				text = L.alert["Enrage"],
				time = 360, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "RED",
				icon = ST[12317],
			},
			tankthrowcd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Tank Throw"]),
				type = "dropdown", 
				text = format(L.alert["Next %s"],L.alert["Tank Throw"]),
				time = 20.6, 
				flashtime = 3, 
				sound = "ALERT2", 
				color1 = "MAGENTA", 
				icon = ST[52272],
			},
			polarityshiftwarn = {
				varname = format(L.alert["%s Cast"],SN[28089]),
				type = "centerpopup", 
				text = format(L.alert["%s Cast"],SN[28089]),
				time = 3, 
				flashtime = 3, 
				sound = "ALERT1", 
				color1 = "BLUE", 
				flashscreen = true,
				icon = ST[28089],
			},
		},
		timers = {
			tankthrow = {
				{
					"alert","tankthrowcd",
					"scheduletimer",{"tankthrow", 20.6},
				},
			},
		},
		events = {
			-- Polarity shift
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_START", 
				spellid = 28089, 
				execute = {
					{
						"alert","polarityshiftwarn", 
					},
				},
			},
			-- Emotes
			{
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["overloads"]},
						"set",{dead = "INCR|1"},
						"expect",{"<dead>",">=","2"},
						"quash","tankthrowcd",
						"canceltimer","tankthrow",
						"tracing",{15928}, -- Thaddius
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

