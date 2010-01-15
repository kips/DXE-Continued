do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "lichking", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = L["Lich King"], 
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
