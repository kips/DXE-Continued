do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "onyxia", 
		zone = L["Onyxia's Lair"], 
		category = L["Kalimdor"],
		name = L["Onyxia"], 
		triggers = {
			yell = L["^How fortuitous. Usually, I must leave my"],
			scan = {
				10184, -- Onyxia
			}, 
		},
		onactivate = {
			tracing = {10184},
			combatstop = true,
		},
	}

	DXE:RegisterEncounter(data)
end


