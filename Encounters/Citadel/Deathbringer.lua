do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "deathbringer", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Deathbringer"], 
		triggers = {
			--scan = ,
			--yell = ,
		},
		onactivate = {
			combatstop = true,
			--tracing = ,
		},
	}

	DXE:RegisterEncounter(data)
end
