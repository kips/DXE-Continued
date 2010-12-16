local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ARGALOTH 
---------------------------------

do
	local data = {
		version = 1,
		key = "argaloth",
		zone = L.zone["Baradin Hold"],
		category = L.zone["Baradin"],
		name = L.npc_baradin["Argaloth"],
		triggers = {
			scan = {
				47120, -- Argaloth 
			},
		},
		onactivate = {
			tracing = {
				47120, -- Argaloth 
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				47120, -- Argaloth 
			},
		},
		--[[userdata = {},
		onstart = {
			{
			}
		},
		windows = {
		},
		alerts = {
		},
		timers = {
		},
		events = {
		},]]
	}

	DXE:RegisterEncounter(data)
end
