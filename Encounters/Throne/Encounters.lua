local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- CONCLAVE OF WIND 
---------------------------------

do
	local data = {
		version = 2,
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
		alerts = {
			windblastwarn = {
				varname = format(L.alert["%s Warning"],SN[93138]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[93138]),
				time = 3,
				color1 = "YELLOW",
				sound = "ALERT12",
				icon = ST[93138],
			},
			windblastdur = {
				varname = format(L.alert["%s Duration"],SN[93138]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[93138]),
				time = 6,
				color1 = "YELLOW",
				icon = ST[93138],
			},
			hurricanedur = {
				varname = format(L.alert["%s Duration"],SN[84643]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[84643]),
				time = 15,
				color1 = "ORANGE",
				icon = ST[84643],
			},
		},
		events = {
			-- Wind Blast (initial cast)
			{
				type = "event",
				event = "UNIT_SPELLCAST_CHANNEL_START",
				execute = {
					{
						"expect",{"#2#","==",SN[86193]},
						"expect",{"&channeldur|#1#&","<","4"},
						"alert","windblastwarn",
					}
				},
			},
			-- Wind Blast (effect active cast)
			{
				type = "event",
				event = "UNIT_SPELLCAST_CHANNEL_START",
				execute = {
					{
						"expect",{"#2#","==",SN[86193]},
						"expect",{"&channeldur|#1#&",">=","6"},
						"alert","windblastdur",
					},
				},
			},
			-- Hurricane
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 84643,
				srcnpcid = 45872, -- Rohash	
				execute = {
					{
						"alert","hurricanedur",
					}
				},
			}
		},
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


