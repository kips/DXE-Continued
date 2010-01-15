do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local L_AnubRekhan = L.npc_naxxramas["Anub'Rekhan"]

	local data = {
		version = 299,
		key = "anubrekhan", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas_AnubRekhan, 
		triggers = {
			scan = 15956, -- Anub'Rekhan
		},
		onactivate = {
			tracing = {15956}, -- Anub'Rekhan
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15956,
		},
		userdata = { 
			swarmcd = {90, 85, loop=false},
		},
		onstart = {
			{
				"expect",{"&difficulty&","==","1"},
				"set",{swarmcd = {102,85,loop = false}},
			},
			{
				"alert","locustswarmcd",
			},
		},
		alerts = {
			locustswarmcd = {
				varname = format(L.alerts["%s Cooldown"],SN[28785]),
				type = "dropdown", 
				text = format(L.alerts["%s Cooldown"],SN[28785]), 
				time = "<swarmcd>",
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "GREEN", 
				icon = ST[28785],
			},
			locustswarmwarn = {
				varname = format(L.alerts["%s Cast"],SN[28785]), 
				type = "centerpopup", 
				text = format(L.alerts["%s Cast"],SN[28785]), 
				time = 3, 
				sound = "ALERT3", 
				color1 = "GREY", 
				icon = ST[28785],
			},
			locustswarmdur = {
				varname = format(L.alerts["%s Duration"],SN[28785]), 
				type = "centerpopup", 
				text = format(L.alerts["%s Duration"],SN[28785]), 
				time = 20, 
				sound = "ALERT2", 
				color1 = "YELLOW", 
				icon = ST[28785],
			},
		},
		events = {
			-- Locust Swarm duration
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {28785,54021}, 
				execute = {
					{
						"expect",{"&npcid|#4#&","==","15956"}, -- Anub'Rekhan
						"alert","locustswarmdur",
						"quash","locustswarmcd",
						"alert","locustswarmcd", 
					},
				},
			},
			-- Locust Swarm cast
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_START", 
				spellid = {28785,54021}, 
				execute = {
					{
						"alert","locustswarmwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
