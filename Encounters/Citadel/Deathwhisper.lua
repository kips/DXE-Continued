do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "deathwhisper", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Deathwhisper"], 
		triggers = {
			scan = {
				36855, -- Lady Deathwhisper
			},
			--yell = ,
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36855}, -- Lady Deathwhisper
		},
	}

	DXE:RegisterEncounter(data)
end
