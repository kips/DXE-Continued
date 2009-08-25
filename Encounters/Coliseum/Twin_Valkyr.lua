do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "twinvalkyr", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Twin Val'kyr"], 
		triggers = {
			scan = {
				34496, -- Eydis Darkbane
				34497, -- Fjola Lightbane
			}, 
		},
		onactivate = {
			tracing = {
				34496, -- Eydis Darkbane
				34497, -- Fjola Lightbane
			},
			tracerstart = true,
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
