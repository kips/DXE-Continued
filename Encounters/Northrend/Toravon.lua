do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "toravon",
		zone = L.zone["Vault of Archavon"],
		category = L.zone["Northrend"],
		name = L.npc_northrend["Toravon"],
		triggers = {
			scan = {
				38433, -- Toravon
				38456, -- Frozen Orb
			},
		},
		onactivate = {
			tracing = {38433},
			tracerstart = true,
			combatstop = true,
			defeat = 38433,
		},
		userdata = {
			orbtime = {11,32,loop = false, type = "series"},
			whiteouttime = {25,37,loop = false, type = "series"},
		},
		onstart = {
			{
				"alert","orbcd",
				"alert","whiteoutcd",
			},
		},
		alerts = {
			orbcd = {
				varname = format(L.alert["%s Cooldown"], SN[72095]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[72095]),
				time = "<orbtime>",
				flashtime = 10,
				color1 = "BLUE",
				sound = "ALERT4",
				icon = ST[72095],
			},
			orbwarn = {
				varname = format(L.alert["%s Casting"],SN[72095]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[72095]),
				time = 2,
				flashtime = 2,
				color1 = "INDIGO",
				sound = "ALERT1",
				icon = ST[72095],
			},
			whiteoutcd = {
				varname = format(L.alert["%s Cooldown"],SN[72096]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[72096]),
				time = "<whiteouttime>",
				flashtime = 10,
				color1 = "WHITE",
				sound = "ALERT4",
				icon = ST[72096],
			},
			whiteoutwarn = {
				varname = format(L.alert["%s Casting"],SN[72096]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[72096]),
				time = 2.5,
				flashtime = 2.5,
				color1 = "PEACH",
				sound = "ALERT2",
				icon = ST[72096],
			},
		},
		events = {
			-- Frozen Orb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72091,
					72095, -- 25
				},
				execute = {
					{
						"quash","orbcd",
						"alert","orbcd",
						"alert","orbwarn",
					},
				},
			},
			-- Whiteout
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72034,
					72096, -- 25
				},
				execute = {
					{
						"quash","whiteoutcd",
						"alert","whiteoutcd",
						"alert","whiteoutwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
