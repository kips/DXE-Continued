local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- CONCLAVE OF WIND 
---------------------------------

do
	local data = {
		version = 1,
		key = "windconclave",
		zone = L.zone["Throne of the Four Winds"],
		category = L.zone["Throne"],
		name = L.npc_throne["Conclave of Wind"],
		triggers = {
			scan = {
				45870, -- Anshal
				45871, -- Nezir
				45872, -- Rohash
			},
		},
		onactivate = {
			tracing = {
				45870, -- Anshal
				45871, -- Nezir
				45872, -- Rohash
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				45870, -- Anshal
				45871, -- Nezir
				45872, -- Rohash
			},
		},
		--[[ userdata = {},
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
		}, ]]
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- AL'AKIR 
---------------------------------

do
	local data = {
		version = 1,
		key = "alakir",
		zone = L.zone["Throne of the Four Winds"],
		category = L.zone["Throne"],
		name = L.npc_throne["Al'Akir"],
		triggers = {
			scan = {
				46753, -- Al'Akir 
			},
		},
		onactivate = {
			tracing = {
				46753, -- Al'Akir 
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				46753, -- Al'Akir 
			},
		},
		--[[ userdata = {
		},
		onstart = {
			{
			},
		},
		windows = {
		},
		alerts = {
		},
		timers = {
		},
		events = {
		}, ]]
	}

	DXE:RegisterEncounter(data)
end


