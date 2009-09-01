
do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "koralon", 
		zone = L["Vault of Archavon"], 
		category = L["Northrend"],
		name = L["Koralon"], 
		triggers = {
			scan = {
				35013, -- Koralon
			}, 
		},
		onactivate = {
			tracing = {35013},
			tracerstart = true,
			combatstop = true,
		},
	}

	DXE:RegisterEncounter(data)
end

