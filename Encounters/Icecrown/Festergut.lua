do
	local SN,ST = DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "festergut", 
		zone = "Icecrown Citadel", 
		category = "Icecrown",
		name = "Festergut", 
		triggers = {
			scan = {36626},
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36626},
		},
	}

	DXE:RegisterEncounter(data)
end
