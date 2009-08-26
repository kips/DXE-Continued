--[=[
do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "anubcoliseum", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Anub'arak"], 
		triggers = {
			scan = {
			}, 
		},
		onactivate = {
			tracing = {--[[todo]]},
			combatstop = true,
		},
		userdata = {},
		onstart = {
		},
		alerts = {

		},
		events = { 
		},
	}

	DXE:RegisterEncounter(data)
end
]=]
