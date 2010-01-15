do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 298,
		key = "patchwerk", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas["Patchwerk"], 
		triggers = {
			scan = 16028, 
		},
		onactivate = {
			tracing = {16028},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 16028,
		},
		userdata = {},
		onstart = {
			{
				"alert","enragecd",
			}
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown", 
				text = L["Enrage"],
				time = 360, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "RED",
				icon = ST[12317],
			},
			enragewarn = {
				varname = format(L["%s Warning"],L["Enrage"]),
				type = "simple", 
				text = L["Enraged"].."!",
				time = 1.5, 
				sound = "ALERT1", 
				icon = ST[40735],
			},
		},
		events = {
			-- Enrage
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 28131, 
				execute = {
					{
						"alert","enragewarn", 
						"quash","enragecd",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

