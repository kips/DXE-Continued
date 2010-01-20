do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST 

	local data = {
		version = 299,
		key = "grandwidowfaerlina", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas["Grand Widow Faerlina"],
		triggers = {
			scan = 15953, -- Grand Widow Faerlina
		},
		onactivate = {
			tracing = {15953}, -- Grand Widow Faerlina
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15953
		},
		userdata = { 
			enraged = "false",
		},
		onstart = {
			{
				"alert","enragecd",
			}
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown", 
				text = L.alert["Enrage"],
				time = 60, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED", 
				icon = ST[12317],
			},
			enragewarn = {
				varname = format(L.alert["%s Warning"],L.alert["Enrage"]),
				type = "simple", 
				text = format("%s!",L.alert["Enraged"]), 
				time = 1.5, 
				sound = "ALERT2",
				icon = ST[40735],
			},
			rainwarn = {
				varname = format(L.alert["%s Warning"],SN[39024]),
				type = "simple", 
				text = format("%s! %s!",SN[39024],L.alert["MOVE"]),
				time = 1.5, 
				sound = "ALERT3", 
				flashscreen = true,
				color1 = "BROWN",
				icon = ST[39024],
			},
			silencedur = {
				varname = format(L.alert["%s Duration"],SN[15487]),
				type = "dropdown", 
				text = format(L.alert["%s Duration"],SN[15487]),
				time = 30, 
				flashtime = 5, 
				sound = "ALERT4", 
				color1 = "ORANGE",
				icon = ST[29943],
			},
		},
		events = {
			-- Silence
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {28732,54097}, 
				execute = {
					{
						"expect",{"&npcid|#4#&","==","15953"}, -- Grand Widow Faerlina
						"expect",{"$enraged$","==","true"},
						"set",{enraged = "false"}, 
						"alert","enragecd", 
						"quash","silencedur",
						"alert","silencedur", 
					},
				},
			},
			-- Rain
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 54099,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","rainwarn",
					}
				},
			},
			-- Enrage
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 54100,
				execute = {
					{
						"expect",{"&npcid|#4#&","==","15953"}, -- Grand Widow Faerlina
						"quash","enragecd",
						"set",{enraged = "true"}, 
						"alert","enragewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
