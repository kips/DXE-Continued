do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 299,
		key = "auriaya", 
		zone = L.zone["Ulduar"], 
		name = L.npc_ulduar["Auriaya"], 
		triggers = {
			scan = {
				33515, -- Auriaya
				34035, -- Feral Defender
				34014, -- Sanctum Sentry
			}, 
		},
		onactivate = {
			tracing = {
				33515, -- Auriaya
				34035, -- Feral Defender
			},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 33515,
		},
		userdata = {
			screechtime = 32,
			guardianswarmtext = "",
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","feraldefendercd",
				"alert","screechcd",
				"set",{screechtime = 35},
			},
		},
		alerts = {
			screechcd = {
				varname = format(L.alert["%s Cooldown"],SN[64386]),
				text = format(L.alert["%s Cooldown"],SN[64386]),
				type = "dropdown",
				time = "<screechtime>",
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[64386],
			},
			screechwarn = {
				varname = format(L.alert["%s Casting"],SN[64386]),
				text = format(L.alert["%s Casting"],SN[64386]),
				type = "centerpopup",
				time = 2,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[64386],
			},
			sentinelwarn = {
				varname = format(L.alert["%s Casting"],SN[64389]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[64389]).."!",
				time = 2,
				color1 = "BLUE",
				sound = "ALERT2",
				icon = ST[64389],
			},
			sonicscreechwarn = {
				varname = format(L.alert["%s Casting"],SN[64422]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[64422]),
				time = 2.5,
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				sound = "ALERT3",
				icon = ST[64422],
			},
			sonicscreechcd = {
				varname = format(L.alert["%s Cooldown"],SN[64422]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[64422]),
				time = 28,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "INDIGO",
				sound = "ALERT4",
				icon = ST[64422],
			},
			guardianswarmcd = {
				varname = format(L.alert["%s Cooldown"],SN[64396]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[64396]),
				time = 37,
				flashtime = 5,
				color1 = "GREEN",
				color2 = "GREEN",
				sound = "ALERT5",
				icon = ST[64396],
			},
			guardianswarmwarn = {
				varname = format(L.alert["%s Warning"],SN[64396]),
				type = "simple",
				text = format("%s: <guardianswarmtext>",SN[64396]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT8",
				icon = ST[64396],
			},
			feraldefendercd = {
				varname = format(L.alert["%s Spawn"],L.npc_ulduar["Feral Defender"]),
				text = format(L.alert["%s Spawn"],L.npc_ulduar["Feral Defender"]),
				type = "dropdown",
				time = 60,
				flashtime = 5,
				color1 = "DCYAN",
				color2 = "DCYAN",
				sound = "ALERT8",
				icon = ST[64449],
			},
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 5,
				color1 = "RED",
				sound = "ALERT7",
				icon = ST[12317],
			},
		},
		events = {
			-- Terrifying Screech - Fear
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64386,
				execute = {
					{
						"alert","screechcd",
						"alert","screechwarn",
					}	
				},
			},
			-- Sentinel Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64389,64678},
				execute = {
					{
						"alert","sentinelwarn",
					},
				},
			},
			-- Sentinel Blast Interruption
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","33515"}, -- Auriaya
						"quash","sentinelwarn",
					},
				},
			},
			-- Sonic Screech
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64422,64688},
				execute = {
					{
						"alert","sonicscreechwarn",
						"quash","sonicscreechcd",
						"alert","sonicscreechcd",
					},
				},
			},
			-- Guardian Swarm
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64396,
				execute = {
					{
						"expect",{"&playerguid&","==","#4#"},
						"set",{guardianswarmtext = L.alert["YOU"].."!"},
					},
					{
						"expect",{"&playerguid&","~=","#4#"},
						"set",{guardianswarmtext = "#5#"},
					},
					{
						"alert","guardianswarmcd",
						"alert","guardianswarmwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
