--[=[
do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "jaraxxus", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Lord Jaraxxus"], 
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
