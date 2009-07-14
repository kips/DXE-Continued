do
	local L,SN = DXE.L,DXE.SN

	local L_AnubRekhan = L["Anub'Rekhan"]

	local data = {
		version = "$Rev$",
		key = "anubrekhan", 
		zone = L["Naxxramas"], 
		name = L_AnubRekhan, 
		triggers = {
			scan = L_AnubRekhan, 
		},
		onactivate = {
			tracing = {L_AnubRekhan},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = { 
			swarmcd = {90, 85, loop=false},
		},
		onstart = {
			{
				{expect = {"&difficulty&","==","1"}},
				{set = {swarmcd = {102,85,loop = false}}},
			},
			{
				{alert = "locustswarmcd"},
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
			},
			locustswarmcast = {
				varname = format(L["%s Cast"],SN[28785]), 
				type = "centerpopup", 
				text = format(L["%s Cast"],SN[28785]), 
				time = 3, 
				sound = "ALERT3", 
				color1 = "GREY", 
			},
			locustswarmgain = {
				varname = format(L["%s Duration"],SN[28785]), 
				type = "centerpopup", 
				text = format(L["%s Duration"],SN[28785]), 
				time = 20, 
				sound = "ALERT2", 
				color1 = "YELLOW", 
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
						{expect = {"#5#","==",L_AnubRekhan}},
						{alert = "locustswarmgain"},
						{quash = "locustswarmcd"},
						{alert = "locustswarmcd"}, 
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
						{alert = "locustswarmcast"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
