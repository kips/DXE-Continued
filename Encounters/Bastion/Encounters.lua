local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ASCENDANT COUNCIL 
---------------------------------

do
	local data = {
		version = 1,
		key = "ascendcouncil",
		zone = L.zone["The Bastion of Twilight"],
		category = L.zone["Bastion"],
		name = L.npc_bastion["The Ascendant Council"],
		triggers = {
			scan = {
				43687, -- Feludius 
				43686, -- Ignacious 
			},
		},
		onactivate = {
			tracing = {
				43687, -- Feludius 
				43686, -- Ignacious 
				43688, -- Arion
				43689, -- Terrastra
--				43735, -- Elementium Monstrosity, disabled for now can't trace 5 mobs
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				43735, -- Elementium Monstrosity
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
		}, ]]
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- VALIONA & THERALION 
---------------------------------

do
	local data = {
		version = 1,
		key = "val+ther",
		zone = L.zone["The Bastion of Twilight"],
		category = L.zone["Bastion"],
		name = L.npc_bastion["Valiona & Theralion"],
		triggers = {
			scan = {
				45992, -- Valiona
				45993, -- Theralion
			},
		},
		onactivate = {
			tracing = {
				45992, -- Valiona
				45993, -- Theralion
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				45992, -- Valiona
				45993, -- Theralion
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

---------------------------------
-- HALFUS WYRMBREAKER 
---------------------------------

do
	local data = {
		version = 1, 
		key = "halfus",
		zone = L.zone["The Bastion of Twilight"],
		category = L.zone["Bastion"],
		name = L.npc_bastion["Halfus Wyrmbreaker"],
		triggers = {
			scan = {
				44600, -- Halfus Wyrmbreaker 
			},
		},
		onactivate = {
			tracing = {44600},
			tracerstart = true,
			combatstop = true,
			defeat = 44600,
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
		events = {
		}, ]]
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- CHO'GALL 
---------------------------------

do
	local data = {
		version = 1, 
		key = "chogall",
		zone = L.zone["The Bastion of Twilight"],
		category = L.zone["Bastion"],
		name = L.npc_bastion["Cho'gall"],
		triggers = {
			scan = {
				43324, -- Cho'gall 
			},
		},
		onactivate = {
			tracing = {43324},
			tracerstart = true,
			combatstop = true,
			defeat = 43324,
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
		events = {
		}, ]]
	}

	DXE:RegisterEncounter(data)
end

