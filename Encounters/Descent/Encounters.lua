local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- OMNITRON DEFENSE SYSTEM 
---------------------------------

do
	local data = {
		version = 1,
		key = "omnitron",
		zone = L.zone["Blackwing Descent"],
		category = L.zone["Descent"],
		name = L.npc_descent["Omnitron Defense System"],
		triggers = {
			scan = {
				42166, -- Arcanotron
				42179, -- Electron
				42178, -- Magmatron
				42180, -- Toxitron
			},
		},
		onactivate = {
			tracing = {
				42166, -- Arcanotron
				42179, -- Electron
				42178, -- Magmatron
				42180, -- Toxitron
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				42166, -- Arcanotron
				42179, -- Electron
				42178, -- Magmatron
				42180, -- Toxitron
			},
		},
		userdata = {},
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
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- MAGMAW 
---------------------------------

do
	local data = {
		version = 1,
		key = "magmaw",
		zone = L.zone["Blackwing Descent"],
		category = L.zone["Descent"],
		name = L.npc_descent["Magmaw"],
		triggers = {
			scan = {
				41570, -- Magmaw
			},
		},
		onactivate = {
			tracing = {41570},
			tracerstart = true,
			combatstop = true,
			defeat = 41570,
		},
		userdata = {
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
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- ATRAMEDES 
---------------------------------

do
	local data = {
		version = 1, 
		key = "atramedes",
		zone = L.zone["Blackwing Descent"],
		category = L.zone["Descent"],
		name = L.npc_descent["Atramedes"],
		triggers = {
			scan = {
				41442, -- Atramedes
			},
		},
		onactivate = {
			tracing = {41442},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 41442,
		},
		userdata = {},
		onstart = {
			{
			}
		},
		windows = {
		},
		alerts = {
		},
		events = {
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- MALORIAK 
---------------------------------

do
	local data = {
		version = 1, 
		key = "maloriak",
		zone = L.zone["Blackwing Descent"],
		category = L.zone["Descent"],
		name = L.npc_descent["Maloriak"],
		triggers = {
			scan = {
				41378, -- Maloriak
			},
		},
		onactivate = {
			tracing = {41378},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 41378,
		},
		userdata = {},
		onstart = {
			{
			}
		},
		windows = {
		},
		alerts = {
		},
		events = {
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- CHIMAERON 
---------------------------------

do
	local data = {
		version = 1, 
		key = "chimaeron",
		zone = L.zone["Blackwing Descent"],
		category = L.zone["Descent"],
		name = L.npc_descent["Chimaeron"],
		triggers = {
			scan = {
				43296, -- Chimaeron 
			},
		},
		onactivate = {
			tracing = {43296},
			tracerstart = true,
			combatstop = true,
			defeat = 43296,
		},
		userdata = {},
		onstart = {
			{
			}
		},
		windows = {
		},
		alerts = {
		},
		events = {
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- NEFARIAN 
---------------------------------

do
	local data = {
		version = 1, 
		key = "nefarian",
		zone = L.zone["Blackwing Descent"],
		category = L.zone["Descent"],
		name = L.npc_descent["Nefarian"],
		triggers = {
			scan = {
				41376, -- Nefarian 
			},
		},
		onactivate = {
			tracing = {41376},
			tracerstart = true,
			combatstop = true,
			defeat = 41376,
		},
		userdata = {},
		onstart = {
			{
			}
		},
		windows = {
		},
		alerts = {
		},
		events = {
		},
	}

	DXE:RegisterEncounter(data)
end


