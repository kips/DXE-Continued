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
		version = 2,
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
		userdata = {
			phase = "1",
			stormlingtime = {10,20,loop = false, type = "series"},
		},
		onstart = {
			{
				"alert", "windburstcd",
			},
		},
		alerts = {
			windburstcd = {
				varname = format(L.alert["%s Cooldown"],SN[87770]),
				type = "dropdown",
				text = format("%s Cooldown",SN[87770]),
				time = 25,
				flashtime = 5,
				color1 = "BLACK",
				icon = ST[87770],
			},
			stormlingcd = {
				varname = format(L.alert["%s Cooldown"],SN[87919]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[87919]),
				time = "<stormlingtime>",
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[87919],
			},
			feedbackdur = {
				varname = format(L.alert["%s Duration"],SN[87904]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[87904]),
				time = 20,
				flashtime = 20,
				color1 = "BLUE",
				icon = ST[87904],
			},
		},
		raidicons = {
			rodmark = {
				varname = SN[93294],
				type = "FRIENDLY",
				persist = 5,
				unit = "#5#",
				icon = 1,
			},
		},
		events = {
			-- Wind Burst
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 87770,
				execute = {
					{
						"quash","windburstcd",
						"alert","windburstcd",
					},
				},
			},
			-- Feedback
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 87904,
				execute = {
					{
						"alert","feedbackdur",
					},
				}
			},
			-- Lightning Rod
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 93294,
				execute = {
					{
						"raidicon","rodmark",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Phase 2
					{
						"expect",{"#1#", "find", L.chat_throne["^Your futile persistance angers me!"]},
						"set", {phase = "2"},
						"quash", "windburstcd",
						"alert", "stormlingcd",
					},
					-- Phase 3
					{
						"expect",{"#1#", "find", L.chat_throne["^Enough! I will no longer be contained!"]},
						"quash", "stormlingcd",
						"set", {phase = "3"},
					},
					-- Stormling Summon
					{
						"expect",{"#1#", "find", L.chat_throne["^Storms! I summon you to my side!"]},
						"quash", "stormlingcd",
						"alert", "stormlingcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


