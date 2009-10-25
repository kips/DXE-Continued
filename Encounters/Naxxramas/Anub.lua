do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local L_AnubRekhan = L["Anub'Rekhan"]

	local data = {
		version = 298,
		key = "anubrekhan", 
		zone = L["Naxxramas"], 
		name = L_AnubRekhan, 
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
				varname = format(L["%s Cooldown"],SN[28785]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],SN[28785]), 
				time = "<swarmcd>",
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "GREEN", 
				icon = ST[28785],
			},
			locustswarmcast = {
				varname = format(L["%s Cast"],SN[28785]), 
				type = "centerpopup", 
				text = format(L["%s Cast"],SN[28785]), 
				time = 3, 
				sound = "ALERT3", 
				color1 = "GREY", 
				icon = ST[28785],
			},
			locustswarmgain = {
				varname = format(L["%s Duration"],SN[28785]), 
				type = "centerpopup", 
				text = format(L["%s Duration"],SN[28785]), 
				time = 20, 
				sound = "ALERT2", 
				color1 = "YELLOW", 
				icon = ST[28785],
			},
		},
		events = {
			-- Locust swarm gain
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {28785,54021}, 
				execute = {
					{
						"expect",{"&npcid|#4#&","==","15956"}, -- Anub'Rekhan
						"alert","locustswarmgain",
						"quash","locustswarmcd",
						"alert","locustswarmcd", 
					},
				},
			},
			-- Locust swarm cast
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_START", 
				spellid = {28785,54021}, 
				execute = {
					{
						"alert","locustswarmcast",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
