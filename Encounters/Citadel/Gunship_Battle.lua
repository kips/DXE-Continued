do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "gunshipbattle", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Gunship Battle"], 
		title = L["Gunship Battle"], 
		triggers = {
			scan = 99999,
			yell = {
				L["^Cowardly dogs"], -- Alliance
				-- Horde
			},
		},
		onactivate = {
			combatstop = true,
			--tracing = ,
		},
		alerts = {
			belowzerowarn = {
				varname = format(L["%s Channel"],SN[69705]),
				type = "centerpopup",
				text = format(L["%s Channel"],SN[69705]),
				time = 900,
				flashtime = 900,
				color1 = "BLUE",
				sound = "ALERT5",
				icon = ST[69705],
			},
		},
		events = {
			-- Below Zero
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 69705,
				execute = {
					{
						"alert","belowzerowarn",
					},
				},
			},
			-- Below Zero removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 69705,
				execute = {
					{
						"quash","belowzerowarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
