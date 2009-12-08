do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "lanathel", 
		zone = L["Icecrown Citadel"],
		category = L["Citadel"], 
		name = L["Lana'thel"], 
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
