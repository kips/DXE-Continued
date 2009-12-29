do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "icctrash", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Trash"], 
		title = L["Trash"],
		triggers = {
			--scan = ,
			--yell = ,
		},
		onactivate = {
			combatstart = true,
			combatstop = true,
			--tracing = ,
		},
	}

	DXE:RegisterEncounter(data)
end
