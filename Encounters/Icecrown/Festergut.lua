do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "festergut", 
		zone = L["Icecrown Citadel"], 
		category = L["Icecrown"], 
		name = L["Festergut"], 
		triggers = {
			scan = {36626}, -- Festergut
			yell = L["^Just an ordinary gas cloud, but watch"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36626}, -- Festergut
		},
	}

	DXE:RegisterEncounter(data)
end
