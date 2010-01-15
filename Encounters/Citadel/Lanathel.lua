do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "lanathel", 
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Lana'thel"], 
		triggers = {
			scan = 37955,
			--yell = ,
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {37955},
		},
	}

	DXE:RegisterEncounter(data)
end
