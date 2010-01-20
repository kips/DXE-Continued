do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 2,
		key = "bloodprincecouncil", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Blood Princes"], 
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
