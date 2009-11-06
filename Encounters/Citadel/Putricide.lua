do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "putricide", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Putricide"], 
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
