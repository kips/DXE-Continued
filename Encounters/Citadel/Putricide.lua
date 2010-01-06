do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "putricide", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Putricide"], 
		triggers = {
			scan = {
				36678, -- Putricide
			},
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36678},
			defeat = 36678,
		},
		alerts = {
			unstableexperimentwarn = {
				varname = format(L["%s Cast"],SN[71966]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71966]),
				sound = "ALERT1",
				color1 = "MAGENTA",
				time = 2.5,
				flashtime = 2.5,
				icon = ST[71966],
				flashscreen = true,
			},
		},
		events = {
			-- Unstable Experiment
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71966,
				execute = {
					{
						"alert","unstableexperimentwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
