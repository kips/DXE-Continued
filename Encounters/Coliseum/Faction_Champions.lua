--[=[
do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 0,
		key = "factionchampions", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Faction Champions"], 
		triggers = {
			scan = {
			}, 
		},
		onactivate = {
			tracing = {--[[todo]]}, -- Up to 10 mobs =(
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
