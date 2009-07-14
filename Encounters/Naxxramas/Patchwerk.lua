do
	local L,SN = DXE.L,DXE.SN

	local L_Patchwerk = L["Patchwerk"]

	local data = {
		version = "$Rev$",
		key = "patchwerk", 
		zone = L["Naxxramas"], 
		name = L_Patchwerk, 
		triggers = {
			scan = L_Patchwerk, 
		},
		onactivate = {
			tracing = {L_Patchwerk,},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {},
		onstart = {
			{
				{alert = "enragecd"},
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
			},
			enragewarn = {
				varname = format(L["%s Warning"],L["Enrage"]),
				type = "simple", 
				text = L["Enraged"].."!",
				time = 1.5, 
				sound = "ALERT1", 
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
						{alert = "enragewarn"}, 
						{quash = "enragecd"},
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

