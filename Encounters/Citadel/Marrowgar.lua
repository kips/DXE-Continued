do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "marrowgar", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Marrowgar"], 
		triggers = {
			scan = {36612}, -- Lord Marrowgar
			yell = {L["^The Scourge will wash over this world"]},
		},
		onactivate = {
			combatstop = true,
			tracing = {36612}, -- Lord Marrowgar
		},
	}

	DXE:RegisterEncounter(data)
end
