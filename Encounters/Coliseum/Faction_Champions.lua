--[=[
do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = "$Rev$",
		key = "factionchampions", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Faction Champions"], 
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
