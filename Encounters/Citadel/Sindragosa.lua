do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "sindragosa", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Sindragosa"], 
		triggers = {
			scan = {36853}, -- Sindragosa
			yell = L["^You are fools to have come to this place"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36853}, -- Sindragosa
		},
	}

	DXE:RegisterEncounter(data)
end
