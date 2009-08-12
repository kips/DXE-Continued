--[=[
do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 0,
		key = "twinvalkyr", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Twin Val'kyr"], 
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
