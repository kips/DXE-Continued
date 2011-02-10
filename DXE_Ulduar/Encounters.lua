local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ALGALON
---------------------------------

do
	local data = {
		version = 305,
		key = "algalon",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Algalon the Observer"],
		triggers = {
			scan = 32871, -- Algalon
		},
		onactivate = {
			tracing = {32871}, -- Algalon
         tracerstart = true,
         tracerstop = true,
			combatstop = true,
			defeat = L.chat_ulduar["^I have seen worlds bathed in the"],
		},
		userdata = {
			cosmicsmashtime = 25,
			bigbangtime = 90,
			punchtext = "",
		},
		onstart = {
			{
				"alert","cosmicsmashcd",
				"alert","bigbangcd",
				"alert","enragecd",
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 360,
				flashtime = 10,
				sound = "ALERT6",
				color1 = "GREY",
				color2 = "GREY",
				icon = ST[12317],
			},
			bigbangwarn = {
				varname = format(L.alert["%s Casting"],SN[64443]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[64443]),
				time = 8,
				flashtime = 8,
				sound = "ALERT5",
				color1 = "ORANGE",
				color2 = "BROWN",
				flashscreen = true,
				icon = ST[64443],
			},
			bigbangcd = {
				varname = format(L.alert["%s Cooldown"],SN[64443]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[64443]),
				time = "<bigbangtime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "BLUE",
				color2 = "BLUE",
				icon = ST[64443],
			},
			cosmicsmashwarn = {
				varname = format(L.alert["%s ETA"],SN[62301]),
				type = "centerpopup",
				text = format(L.alert["%s Hits"],SN[62301]),
				time = 5,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "YELLOW",
				color2 = "RED",
				flashscreen = true,
				icon = ST[62311],
			},
			cosmicsmashcd = {
				varname = format(L.alert["%s Cooldown"],SN[62301]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[62301]),
				time = "<cosmicsmashtime>",
				flashtime = 5,
				sound = "ALERT3",
				color1 = "GREEN",
				color2 = "GREEN",
				icon = ST[62311],
			},
			punchcd = {
				varname = format(L.alert["%s Cooldown"],SN[64412]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[64412]),
				time = 15,
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "PURPLE",
				icon = ST[64412],
				counter = true,
			},
			punchwarn = {
				varname = format(L.alert["%s Warning"],SN[64412]),
				type = "simple",
				text = "<punchtext>",
				time = 3,
				icon = ST[64412],
				sound = "ALERT7",
			},
		},
		events = {
			-- Big Bang
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64443,64584},
				execute = {
					{
						"quash","bigbangcd",
						"alert","bigbangwarn",
						"alert","bigbangcd",
					},
				},
			},
			-- Cosmic Smash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {62301,64598},
				execute = {
					{
						"quash","cosmicsmashcd",
						"alert","cosmicsmashwarn",
						"alert","cosmicsmashcd",
					}
				},
			},
			-- Phase Punch
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64412,
				execute = {
					{
						"alert","punchcd",
					},
				},
			},
			-- Phase Punch application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64412,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{punchtext = format("%s: %s!",SN[64412],L.alert["YOU"])},
						"alert","punchwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{punchtext = format("%s: #5#!",SN[64412])},
						"alert","punchwarn",
					},
				},
			},
			-- Phase Punch Stacks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 64412,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{punchtext = format("%s: %s! %s!",SN[64412],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","punchwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{punchtext = format("%s: #5#! %s!",SN[64412],format(L.alert["%s Stacks"],"#11#")) },
						"alert","punchwarn",
					},
				},
			},
		}
	}
	DXE:RegisterEncounter(data)
end

---------------------------------
-- AURIAYA
---------------------------------

do

	local data = {
		version = 300,
		key = "auriaya",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Auriaya"],
		triggers = {
			scan = {
				33515, -- Auriaya
				34035, -- Feral Defender
				34014, -- Sanctum Sentry
			},
		},
		onactivate = {
			tracing = {
				33515, -- Auriaya
				34035, -- Feral Defender
			},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 33515,
		},
		userdata = {
			screechtime = 32,
			guardianswarmtext = "",
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","feraldefendercd",
				"alert","screechcd",
				"set",{screechtime = 35},
			},
		},
		alerts = {
			screechcd = {
				varname = format(L.alert["%s Cooldown"],SN[64386]),
				text = format(L.alert["%s Cooldown"],SN[64386]),
				type = "dropdown",
				time = "<screechtime>",
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[64386],
			},
			screechwarn = {
				varname = format(L.alert["%s Casting"],SN[64386]),
				text = format(L.alert["%s Casting"],SN[64386]),
				type = "centerpopup",
				time = 2,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[64386],
			},
			sentinelwarn = {
				varname = format(L.alert["%s Casting"],SN[64389]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[64389]).."!",
				time = 2,
				color1 = "BLUE",
				sound = "ALERT2",
				icon = ST[64389],
			},
			sonicscreechwarn = {
				varname = format(L.alert["%s Casting"],SN[64422]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[64422]),
				time = 2.5,
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				sound = "ALERT3",
				icon = ST[64422],
			},
			sonicscreechcd = {
				varname = format(L.alert["%s Cooldown"],SN[64422]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[64422]),
				time = 28,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "INDIGO",
				sound = "ALERT4",
				icon = ST[64422],
			},
			guardianswarmcd = {
				varname = format(L.alert["%s Cooldown"],SN[64396]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[64396]),
				time = 37,
				flashtime = 5,
				color1 = "GREEN",
				color2 = "GREEN",
				sound = "ALERT5",
				icon = ST[64396],
			},
			guardianswarmwarn = {
				varname = format(L.alert["%s Warning"],SN[64396]),
				type = "simple",
				text = format("%s: <guardianswarmtext>",SN[64396]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT8",
				icon = ST[64396],
			},
			feraldefendercd = {
				varname = format(L.alert["%s Spawn"],L.npc_ulduar["Feral Defender"]),
				text = format(L.alert["%s Spawn"],L.npc_ulduar["Feral Defender"]),
				type = "dropdown",
				time = 60,
				flashtime = 5,
				color1 = "DCYAN",
				color2 = "DCYAN",
				sound = "ALERT8",
				icon = ST[64449],
			},
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 5,
				color1 = "RED",
				sound = "ALERT7",
				icon = ST[12317],
			},
		},
		events = {
			-- Terrifying Screech - Fear
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64386,
				execute = {
					{
						"alert","screechcd",
						"alert","screechwarn",
					}
				},
			},
			-- Sentinel Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64389,64678},
				execute = {
					{
						"alert","sentinelwarn",
					},
				},
			},
			-- Sentinel Blast Interruption
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","33515"}, -- Auriaya
						"quash","sentinelwarn",
					},
				},
			},
			-- Sonic Screech
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64422,64688},
				execute = {
					{
						"alert","sonicscreechwarn",
						"quash","sonicscreechcd",
						"alert","sonicscreechcd",
					},
				},
			},
			-- Guardian Swarm
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64396,
				execute = {
					{
						"expect",{"&playerguid&","==","#4#"},
						"set",{guardianswarmtext = L.alert["YOU"].."!"},
					},
					{
						"expect",{"&playerguid&","~=","#4#"},
						"set",{guardianswarmtext = "#5#"},
					},
					{
						"alert","guardianswarmcd",
						"alert","guardianswarmwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- FLAME LEVIATHAN
---------------------------------

do
	local data = {
		version = 301,
		key = "flameleviathan",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Flame Leviathan"],
		triggers = {
			scan = 33113, -- Flame Leviathan
			yell = L.chat_ulduar["^Hostile entities detected. Threat assessment protocol active"],
		},
		onactivate = {
			tracing = {33113}, -- Flame Leviathan
			combatstop = true,
			defeat = 33113,
		},
		userdata = {},
		alerts = {
			overloaddur = {
				varname = format(L.alert["%s Duration"],SN[62475]),
				type = "centerpopup",
				text = SN[62475].."!",
				time = 20,
				flashtime = 20,
				sound = "ALERT1",
				color1 = "BLUE",
				color2 = "BLUE",
				throttle = 5,
				icon = ST[62475],
			},
			flameventdur = {
				varname = format(L.alert["%s Duration"],SN[62396]),
				type = "centerpopup",
				text = SN[62396].."!",
				time = 10,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "RED",
				color2 = "ORANGE",
				icon = ST[62396],
			},
			pursuedurothers = {
				varname = format(L.alert["%s on others"],SN[62374]),
				type = "centerpopup",
				text = format("%s: #5#",SN[62374]),
				time = 30,
				flashtime = 30,
				color1 = "CYAN",
				color2 = "CYAN",
				icon = ST[62374],
			},
			pursuedurself = {
				varname = format(L.alert["%s on self"],SN[62374]),
				type = "centerpopup",
				text = format("%s: %s!",SN[62374],L.alert["YOU"]),
				time = 30,
				flashtime = 30,
				sound = "ALERT4",
				color1 = "CYAN",
				color1 = "MAGENTA",
				flashscreen = true,
				icon = ST[62374],
			},
		},
		events = {
			-- Flame vents
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62396,
				execute = {
					{
						"alert","flameventdur",
					},
				},
			},
			-- Remove flame vents
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 62396,
				execute = {
					{
						"quash","flameventdur",
					},
				},
			},
			-- Overload circuits
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62475,
				execute = {
					{
						"alert","overloaddur",
					},
				},
			},
			-- Pursued
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_ulduar["pursues"]},
						"expect",{"#5#","==","&playername&"},
						"alert","pursuedurself",
					},
					{
						"expect",{"#1#","find",L.chat_ulduar["pursues"]},
						"expect",{"#5#","~=","&playername&"},
						"alert","pursuedurothers",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- FREYA
---------------------------------

do

	local data = {
		version = 302,
		key = "freya",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Freya"],
		triggers = {
			scan = {
				32906, -- Freya
				32916, -- Snaplasher
				32919, -- Storm Lasher
				33202, -- Ancient Water Spirit
				33203, -- Ancient Conservator
				32918, -- Detonating Lasher
			}
		},
		onactivate = {
			tracing = {32906}, -- Freya
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = L.chat_ulduar["^His hold on me dissipates"],
		},
		userdata = {
			spawntime = {10,60,loop = false, type = "series"},
			tremortime = 28,
		},
		onstart = {
			{
				"alert","spawncd",
				"alert","enragecd",
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			spawncd = {
				varname = format(L.alert["%s Timer"],SN[62678]),
				text = SN[62678],
				type = "dropdown",
				time = "<spawntime>",
				flashtime = 5,
				color1 = "MAGENTA",
				icon = ST[31687],
			},
			giftwarn = {
				varname = format(L.alert["%s Warning"],L.npc_ulduar["Eonar's Gift"]),
				type = "simple",
				text = format(L.alert["%s Spawned"],L.npc_ulduar["Eonar's Gift"]).."!",
				time = 3,
				sound = "ALERT2",
				color1 = "VIOLET",
				icon = ST[62584],
			},
			attunedwarn = {
				type = "simple",
				varname = format(L.alert["%s Removal"],SN[62519]),
				text = format(L.alert["%s Removed"],SN[62519]).."!",
				time = 1.5,
				sound = "ALERT9",
				icon = ST[62519],
			},
			naturesfuryself = {
				varname = format(L.alert["%s on self"],SN[62589]),
				text = format("%s: %s! %s!",L.alert["Fury"],L.alert["YOU"],L.alert["MOVE NOW"]),
				type = "centerpopup",
				time = 10,
				flashtime = 10,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[62589],
			},
			naturesfuryproximitywarn = {
				varname = format(L.alert["%s Proximity Warning"],SN[62589]),
				text = format("%s: #5#! %s!",L.alert["Fury"],L.alert["MOVE AWAY"]),
				type = "simple",
				time = 2,
				color1 = "BLACK",
				sound = "ALERT1",
				icon = ST[62589],
			},
			gripwarn = {
				varname = format(L.alert["%s Warning"],SN[62532]),
				type = "simple",
				text = format("%s: %s! %s!",SN[56689],L.alert["YOU"],L.alert["TAKE COVER"]),
				time = 1.5,
				color1 = "GREEN",
				throttle = 5,
				sound = "ALERT6",
				flashscreen = true,
				icon = ST[62532],
			},
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			groundtremorwarn = {
				varname = format(L.alert["%s Casting"],SN[62437]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[62437]),
				time = 2,
				flashtime = 2,
				color1 = "BROWN",
				color2 = "ORANGE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[62437],
			},
			groundtremorcd = {
				varname = format(L.alert["%s Cooldown"],SN[62437]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[62437]),
				time = "<tremortime>",
				flashtime = 5,
				color1 = "TAN",
				color2 = "TAN",
				sound = "ALERT7",
				icon = ST[62437],
			},
			unstablewarnself = {
				varname = format(L.alert["%s on self"],SN[62217]),
				type = "simple",
				text = format("%s: %s! %s!",SN[36514],L.alert["YOU"],L.alert["MOVE"]),
				time = 2,
				throttle = 3,
				color1 = "YELLOW",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[62217],
			},
		},
		arrows = {
			rootarrow = {
				varname = SN[62283],
				unit = "#5#",
				persist = 20,
				action = "TOWARD",
				msg = L.alert["KILL IT"],
				spell = L.alert["Roots"],
				sound = "ALERT4",
			},
		},
		raidicons = {
			rootmark = {
				varname = SN[62283],
				type = "MULTIFRIENDLY",
				persist = 20,
				reset = 3,
				unit = "#5#",
				icon = 1,
				total = 3,
			},
		},
		events = {
			-- Spawn waves
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Ancient Conservator
					{
						"expect",{"#1#","find",L.chat_ulduar["^Eonar, your servant"]},
						"tracing",{32906,33203}, -- Freya, Ancient Conservator
						"quash","spawncd",
						"alert","spawncd",
					},
					-- Detonating Lashers
					{
						"expect",{"#1#","find",L.chat_ulduar["^The swarm of the elements"]},
						"quash","spawncd",
						"alert","spawncd",
					},
					-- Elementals
					{
						"expect",{"#1#","find",L.chat_ulduar["^Children, assist"]},
						"tracing",{32906,33202,32919,32916}, -- Freya, Ancient Water Spirit, Storm Lasher, Snap Lasher
						"quash","spawncd",
						"alert","spawncd",
					},
				},
			},
			-- Eonar's Gift
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_ulduar["begins to grow!$"]},
						"alert","giftwarn",
					},
				},
			},
			-- Nature's Fury from Ancient Conservator
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62589,63571},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","naturesfuryself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"proximitycheck",{"#5#",11},
						"alert","naturesfuryproximitywarn",
					},
				},
			},
			-- Attuned to Nature Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 62519,
				execute = {
					{
						"quash","spawncd",
						"alert","attunedwarn",
						"set",{tremortime = 23},
					},
				},
			},
			-- Ancient Conservator - Conservator's Grip
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62532,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","gripwarn",
					},
				},
			},
			-- Ground Tremor (Hard Mode)
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62437,62859},
				execute = {
					{
						"alert","groundtremorwarn",
						"alert","groundtremorcd",
					},
				},
			},
			-- Unstable Energy
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62865,62451},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","unstablewarnself",
					},
				},
			},
			-- Nature's Fury removed from player
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {62589,63571},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","naturesfuryself",
					},
				},
			},
			-- Iron Roots
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62861,62930,62283,62438},
				execute = {
					{
						"raidicon","rootmark",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"arrow","rootarrow",
					},
				},
			},
			-- Iron Roots Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {62861,62930,62283,62438},
				execute = {
					{
						"removeraidicon","#5#",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"removearrow","#5#",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- GENERAL VEZAX
---------------------------------

do
	local data = {
		version = 308,
		key = "generalvezax",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["General Vezax"],
		triggers = {
			scan = {33271,33524}, -- Vezax, Animus
		},
		onactivate = {
			tracing = {33271}, -- Vezax
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 33271,
		},
		userdata = {
			shadowcrashmessage = "",
		},
		onstart = {
			{
				"alert","darknesscd",
				"alert","vaporcd",
				"alert","enragecd",
				"alert","animuscd",
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 5,
				sound = "ALERT7",
				color1 = "BROWN",
				color2 = "BROWN",
				icon = ST[12317],
			},
			searingflamewarn = {
				varname = format(L.alert["%s Casting"],SN[62661]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[62661]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT1",
				icon = ST[62661],
				counter = true,
			},
			darknesswarn = {
				varname = format(L.alert["%s Casting"],SN[62662]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[62662]),
				time = 3,
				color1 = "VIOLET",
				sound = "ALERT1",
				icon = ST[62662],
			},
			darknessdur = {
				varname = format(L.alert["%s Duration"],SN[62662]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[62662]),
				time = 10,
				flashtime = 10,
				color1 = "VIOLET",
				color2 = "CYAN",
				sound = "ALERT2",
				icon = ST[62662],
			},
			darknesscd = {
				varname = format(L.alert["%s Cooldown"],SN[62662]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[62662]),
				time = 60,
				flashtime = 10,
				color1 = "INDIGO",
				icon = ST[62662],
			},
			animuscd = {
				varname = format(L.alert["%s Timer"],L.npc_ulduar["Saronite Animus"]),
				type = "dropdown",
				text = format(L.alert["%s Spawns"],L.npc_ulduar["Saronite Animus"]),
				time = 199,
				flashtime = 10,
				sound = "ALERT3",
				color1 = "YELLOW",
				icon = ST[63319],
			},
			vaporcd = {
				varname = format(L.alert["%s Cooldown"],L.npc_ulduar["Saronite Vapor"]),
				type = "dropdown",
				text = format(L.alert["Next %s"],L.npc_ulduar["Saronite Vapor"]),
				time = 30,
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[63337],
				counter = true,
			},
			shadowcrashwarn = {
				varname = format(L.alert["%s Warning"],SN[62660]),
				type = "simple",
				text = "<shadowcrashmessage>",
				time = 1.5,
				color1 = "BLACK",
				sound = "ALERT4",
				flashscreen = true,
				icon = ST[62660],
			},
			facelessdurself = {
				varname = format(L.alert["%s on self"],SN[63276]),
				type = "centerpopup",
				time = 10,
				flashtime = 10,
				text = format("%s: %s!",L.alert["Mark"],L.alert["YOU"]),
				sound = "ALERT5",
				color1 = "RED",
				flashscreen = true,
				icon = ST[63276],
			},
			facelessdurothers = {
				varname = format(L.alert["%s on others"],SN[63276]),
				type = "centerpopup",
				text = format("%s: #5#",L.alert["Mark"]),
				time = 10,
				color1 = "RED",
				icon = ST[63276],
			},
			facelessproxwarn = {
				varname = format(L.alert["%s Proximity Warning"],SN[63276]),
				type = "simple",
				text = format("%s: #5#! %s",L.alert["Mark"],L.alert["YOU ARE CLOSE"]).."!",
				time = 1.5,
				color1 = "MAGENTA",
				sound = "ALERT6",
				icon = ST[63276],
			},
		},
		arrows = {
			crasharrow = {
				varname = SN[62660],
				unit = "&tft_unitname&",
				persist = 5,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = L.alert["Crash"],
				fixed = true,
			},
			facelessarrow = {
				varname = SN[63276],
				unit = "#5#",
				persist = 10,
				action = "AWAY",
				msg = L.alert["STAY AWAY"],
				spell = L.alert["Mark"],
			},
		},
		raidicons = {
			crashmark = {
				varname = SN[62660],
				type = "FRIENDLY",
				persist = 5,
				unit = "&tft_unitname&",
				icon = 2,
			},
			facelessmark = {
				varname = SN[63276],
				type = "FRIENDLY",
				persist = 10,
				unit = "#5#",
				icon = 1,
			},
		},
		announces = {
			crashsay = {
				varname = format(L.alert["Say %s on self"],SN[62660]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[62660]).."!",
			},
		},
		timers = {
			shadowcrash = {
				{
					"raidicon","crashmark",
				},
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","true true"},
					"set",{shadowcrashmessage = format("%s: %s! %s!",L.alert["Crash"],L.alert["YOU"],L.alert["MOVE"])},
					"alert","shadowcrashwarn",
					"announce","crashsay",
				},
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","true false"},
					"proximitycheck",{"&tft_unitname&",28},
					"set",{shadowcrashmessage = format("%s: %s! %s!",L.alert["Crash"],"&tft_unitname&",L.alert["CAREFUL"])},
					"alert","shadowcrashwarn",
					"arrow","crasharrow",
				},
				{
					"expect",{"&tft_unitexists&","==","false"},
					"set",{shadowcrashmessage = format("%s: %s!",L.alert["Crash"],UNKNOWN:upper())},
					"alert","shadowcrashwarn",
				},
			},
		},
		events = {
			-- Searing Flame cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 62661,
				execute = {
					{
						"alert","searingflamewarn",
					},
				},
			},
			-- Searing Flame interrupt
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","33271"},
						"quash","searingflamewarn",
					},
				},
			},
			-- Surge of Darkness cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 62662,
				execute = {
					{
						"quash","darknesscd",
						"alert","darknesswarn",
						"alert","darknesscd",
					},
				},
			},
			-- Surge of Darkness gain
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62662,
				execute = {
					{
						"quash","darknesswarn",
						"alert","darknessdur",
					},
				},
			},
			-- Shadow Crash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {60835,62660},
				execute = {
					{
						"scheduletimer",{"shadowcrash",0.1},
					},
				},
			},
			-- Mark of the Faceless
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 63276,
				execute = {
					{
						"raidicon","facelessmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","facelessdurself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","facelessdurothers",
						"proximitycheck",{"#5#",18},
						"alert","facelessproxwarn",
						"arrow","facelessarrow",
					},
				},
			},
			-- Saronite Vapors
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_ulduar["^A cloud of saronite vapors"]},
						"alert","vaporcd",
					},
				},
			},
			-- Saronite Barrier
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63364,
				execute = {
					{
						"tracing",{33271,33524}, -- Vezax, Saronite Animus
					},
				},
			},
			-- NPC Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","33524"}, -- Saronite Animus
						"tracing",{33271},
					},
					{
						"expect",{"&npcid|#4#&","==","33488"}, -- Saronite Vapor
						"quash","animuscd",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

---------------------------------
-- HODIR
---------------------------------

do
	local data = {
		version = 302,
		key = "hodir",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Hodir"],
		triggers = {
			scan = 32845, -- Hodir
		},
		onactivate = {
			tracing = {32845}, -- Hodir
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = L.chat_ulduar["I am released from his grasp"],
		},
		userdata = {},
		onstart = {
			{
				"alert","enragecd",
				"alert","flashfreezecd",
				"alert","hardmodeendscd",
			},
		},
		alerts = {
			flashfreezewarn = {
				varname = format(L.alert["%s Casting"],SN[61968]),
				type = "centerpopup",
				text = format("%s! %s!",SN[61968],L.alert["MOVE"]),
				time = 9,
				flashtime = 9,
				sound = "ALERT1",
				color1 = "BLUE",
				color2 = "GREEN",
				flashscreen = true,
				icon = ST[61968],
			},
			flashfreezecd = {
				varname = format(L.alert["%s Cooldown"],SN[61968]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[61968]),
				time = 50,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "TURQUOISE",
				color2 = "TURQUOISE",
				icon = ST[61968],
			},
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 480,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			frozenblowdur = {
				varname = format(L.alert["%s Duration"],SN[63512]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[63512]),
				time = 20,
				flashtime = 20,
				sound = "ALERT3",
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				icon = ST[63512],
			},
			hardmodeendscd = {
				varname = format(L.alert["%s Timer"],L.alert["Hard Mode"]),
				type = "dropdown",
				text = format(L.alert["%s Ends"],L.alert["Hard Mode"]),
				time = 180,
				flashtime = 10,
				sound = "ALERT4",
				color1 = "YELLOW",
				color2 = "YELLOW",
				icon = ST[20573],
			},
			stormcloudwarnself = {
				varname = format(L.alert["%s on self"],SN[65133]),
				type = "simple",
				text = format("%s: %s! %s!",SN[65133],L.alert["YOU"],L.alert["SPREAD IT"]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT4",
				flashscreen = true,
				icon = ST[65133],
			},
			stormcloudwarnothers = {
				varname = format(L.alert["%s on others"],SN[65133]),
				type = "simple",
				text = format("%s: #5#",SN[65133]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT4",
				icon = ST[65133],
			},
		},
		announces = {
			stormcloudsay = {
				varname = format(L.alert["Say %s on self"],SN[65133]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[65133]).."!",
			},
		},
		arrows = {
			stormcloudarrow = {
				varname = SN[65133],
				unit = "#5#",
				persist = 8,
				action = "TOWARD",
				msg = L.alert["CONVERGE"],
				spell = SN[65133],
			},
		},
		events = {
			-- Flash Freeze cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 61968,
				execute = {
					{
						"alert","flashfreezewarn",
						"alert","flashfreezecd",
					},
				},
			},
			-- Frozen Blow
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62478,63512},
				execute = {
					{
						"alert","frozenblowdur",
					},
				},
			},
			-- Storm Cloud
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {65133,65123},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","stormcloudwarnself",
						"announce","stormcloudsay",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","stormcloudwarnothers",
						"arrow","stormcloudarrow",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- IGNIS
---------------------------------

do

	local data = {
		version = 312,
		key = "ignis",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Ignis the Furnace Master"],
		triggers = {
			scan = 33118, -- Ignis
		},
		onactivate = {
			tracing = {33118}, -- Ignis
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 33118,
		},
		userdata = {
			flamejetstime = {24,22.3,loop = false, type = "series"},
			slagpotmessage = "",
		},
		onstart = {
			{
				"alert","flamejetscd",
				"alert","hardmodeendscd",
			},
		},
		alerts = {
			flamejetswarn = {
				varname = format(L.alert["%s Casting"],SN[62680]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[62680]),
				time = 2.7,
				color1 = "RED",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[62680],
			},
			flamejetscd = {
				varname = format(L.alert["%s Cooldown"],SN[62680]),
				type = "dropdown",
				time = "<flamejetstime>",
				text = format(L.alert["%s Cooldown"],SN[62680]),
				flashtime = 5,
				color1 = "RED",
				color2 = "MAGENTA",
				sound = "ALERT1",
				icon = ST[62680],
			},
			scorchwarnself = {
				varname = format(L.alert["%s on self"],SN[62546]),
				type = "simple",
				text = format("%s: %s!",SN[62546],L.alert["YOU"]),
				time = 1.5,
				color1 = "MAGENTA",
				sound = "ALERT5",
				flashscreen = true,
				throttle = 5,
				icon = ST[62546],
			},
			scorchcd = {
				varname = format(L.alert["%s Cooldown"],SN[62546]),
				text = format(L.alert["Next %s"],SN[62546]),
				type = "dropdown",
				time = 25,
				flashtime = 5,
				color1 = "MAGENTA",
				color2 = "YELLOW",
				sound = "ALERT2",
				icon = ST[62546],
			},
			slagpotdur = {
				varname = format(L.alert["%s Duration"],SN[62717]),
				type = "centerpopup",
				text = "<slagpotmessage>",
				time = 10,
				color1 = "GREEN",
				sound = "ALERT4",
				icon = ST[62717],
			},
			hardmodeendscd = {
				varname = format("%s Timer",L.alert["Hard Mode"]),
				type = "dropdown",
				text = format("%s Ends",L.alert["Hard Mode"]),
				time = 240,
				flashtime = 5,
				color1 = "BROWN",
				color2 = "BROWN",
				sound = "ALERT6",
				icon = ST[20573],
			},
		},
		timers = {
			flamejet = {
				{
					"alert","flamejetscd",
				},
			},
		},
		events = {
			-- Scorch cooldown",
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {62546, 63474},
				execute = {
					{
						"alert","scorchcd",
					},
				},
			},
			-- Scorch warning on self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {62548, 63475},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","scorchwarnself",
					},
				},
			},
			-- Slag Pot
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62717, 63477},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{slagpotmessage = format("%s: %s!",SN[62717],L.alert["YOU"])},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{slagpotmessage = format("%s: #5#",SN[62717])},
					},
					{
						"alert","slagpotdur",
					},
				},
			},
			-- Flame Jets cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {63472,62680},
				execute = {
					{
						"quash","flamejetscd",
						"alert","flamejetswarn",
						"scheduletimer",{"flamejet",2.7},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- IRON COUNCIL
---------------------------------

do
	local data = {
		version = 302,
		key = "ironcouncil",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["The Iron Council"],
		triggers = {
			scan = {
				32867, -- Steelbreaker
				32927, -- Runemaster Molgeim
				32857, -- Stormcaller Brundir
			},
		},
		onactivate = {
			tracing = {
				32867, -- Steelbreaker
				32927, -- Runemaster Molgeim
				32857, -- Stormcaller Brundir
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				32867, -- Steelbreaker
				32927, -- Runemaster Molgeim
				32857, -- Stormcaller Brundir
			},
		},
		userdata = {
			overwhelmtime = 35,
			previoustarget = "",
		},
		onstart = {
			{
				"alert","enragecd",
				"expect",{"&difficulty&","==","1"},
				"set",{overwhelmtime = 60},
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 900,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			fusionpunchwarn = {
				varname = format(L.alert["%s Casting"],SN[61903]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[61903]),
				time = 3,
				color1 = "BROWN",
				sound = "ALERT5",
				icon = ST[61903],
			},
			fusionpunchcd = {
				varname = format(L.alert["%s Cooldown"],SN[61903]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[61903]),
				time = 12,
				flashtime = 5,
				color1 = "BLUE",
				color2 = "GREY",
				icon = ST[61903],
			},
			runeofsummoningwarn = {
				varname = format(L.alert["%s Warning"],SN[62273]),
				type = "simple",
				text = format(L.alert["%s Cast"],SN[62273]).."!",
				sound = "ALERT1",
				color2 = "MAGENTA",
				time = 1.5,
				icon = ST[62273],
			},
			runeofdeathwarn = {
				varname = format(L.alert["%s on self"],SN[62269]),
				type = "simple",
				text = format("%s: %s!",SN[62269],L.alert["YOU"]),
				time = 1.5,
				sound = "ALERT3",
				icon = ST[62269],
			},
			runeofpowerwarn = {
				varname = format(L.alert["%s Casting"],SN[61973]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[61973]),
				sound = "ALERT4",
				color1 = "GREEN",
				time = 1.5,
				icon = ST[61973],
			},
			overloadwarn = {
				varname = format(L.alert["%s Casting"],SN[61869]),
				type = "centerpopup",
				text = format("%s! %s!",SN[61869],L.alert["MOVE AWAY"]),
				time = 6,
				flashtime = 6,
				sound = "ALERT2",
				color1 = "PURPLE",
				icon = ST[61869],
			},
			overloadcd = {
				varname = format(L.alert["%s Cooldown"],SN[61869]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[61869]),
				time = 60,
				flashtime = 5,
				sound = "ALERT9",
				color1 = "PURPLE",
				color2 = "PURPLE",
				icon = ST[61869],
			},
			tendrilsdur = {
				varname = format(L.alert["%s Duration"],SN[61887]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[61887]),
				time = 35,
				color1 = "BLUE",
				icon = ST[61887],
			},
			tendrilswarnself = {
				varname = format(L.alert["%s on self"],SN[61887]),
				type = "simple",
				text = format("%s: %s",SN[61887],L.alert["YOU"]).."!",
				color1 = "YELLOW",
				time = 1.5,
				flashscreen = true,
				icon = ST[61887],
			},
			tendrilswarnothers = {
				varname = format(L.alert["%s on others"],SN[61887]),
				type = "simple",
				text = format("%s: <previoustarget>",SN[61887]),
				color1 = "YELLOW",
				time = 1.5,
				icon = ST[61887],
			},
			whirlwarn = {
				varname = format(L.alert["%s Casting"],SN[61915]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				text = SN[61915].."!",
				color1 = "ORANGE",
				color2 = "ORANGE",
				sound = "ALERT7",
				icon = ST[61915],
			},
			overwhelmdurself = {
				varname = format(L.alert["%s on self"],L.alert["Overwhelm"]),
				type = "centerpopup",
				text = format("%s: %s!",L.alert["Overwhelm"],L.alert["YOU"]),
				time = "<overwhelmtime>",
				flashtime = 25,
				color1 = "DCYAN",
				color2 = "YELLOW",
				sound = "ALERT6",
				flashscreen = true,
				icon = ST[64637],
			},
			overwhelmdurothers = {
				varname = format(L.alert["%s on others"],L.alert["Overwhelm"]),
				type = "centerpopup",
				text = format("%s: #5#",L.alert["Overwhelm"]),
				time = "<overwhelmtime>",
				color1 = "DCYAN",
				icon = ST[64637],
			},
		},
		timers = {
			canceltendril = {
				{
					"canceltimer","tendriltargets",
					"set",{previoustarget = ""},
				},
			},
			-- tft3 = Stormcaller Brundir's Target
			tendriltargets = {
				{
					"expect",{"&tft3_unitexists& &tft3_isplayer&","==","true true"},
					"expect",{"&tft3_unitname&","~=","<previoustarget>"},
					"set",{previoustarget = "&tft3_unitname&"},
					"alert","tendrilswarnself",
				},
				{
					"expect",{"&tft3_unitexists& &tft3_isplayer&","==","true false"},
					"expect",{"&tft3_unitname&","~=","<previoustarget>"},
					"set",{previoustarget = "&tft3_unitname&"},
					"alert","tendrilswarnothers",
				},
				{
					"scheduletimer",{"tendriltargets",0.2},
				},
			},
		},
		events = {
			-- Stormcaller Brundir - Overload cast
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {61869, 63481},
				execute = {
					{
						"alert","overloadwarn",
						"alert","overloadcd",
					},
				},
			},
			-- Stormcaller Brundir - Lightning Whirl +1
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {63483,61915},
				execute = {
					{
						"alert","whirlwarn",
					},
				},
			},
			-- Stormcaller Brundir - Lightning Whirl Interruption +1
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					{
						"expect",{"#10#","==","63483"},
						"quash","whirlwarn",
					},
					{
						"expect",{"#10#","==","61915"},
						"quash","whirlwarn",
					},
				},
			},
			-- Stormcaller Brundir - Lightning Tendrils +2
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {61887, 63486},
				execute = {
					{
						"alert","tendrilsdur",
						"scheduletimer",{"tendriltargets",0},
						"scheduletimer",{"canceltendril",35},
					},
				},
			},
			-- Runemaster Molgeim - Rune of Power
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {61974,61973},
				execute = {
					{
						"alert","runeofpowerwarn",
					},
				},
			},
			-- Runemaster Molgeim - Rune of Death +1
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62269, 63490},
				execute = {
					{
						"expect",{"&playerguid&","==","#4#"},
						"alert","runeofdeathwarn",
					},
				},
			},
			-- Runemaster Molgeim - Rune of Summoning +2
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 62273,
				execute = {
					{
						"alert","runeofsummoningwarn",
					},
				},
			},
			-- Steelbreaker - Overwhelm - +2
			{
				type = "combatevent",
				spellid = {64637, 61888},
				eventtype = "SPELL_AURA_APPLIED",
				execute = {
					{
						"expect",{"&playerguid&","==","#4#"},
						"alert","overwhelmdurself",
					},
					{
						"expect",{"&playerguid&","~=","#4#"},
						"alert","overwhelmdurothers",
					},
				},
			},
			-- Steelbreaker Fusion Punch
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {63493,61903},
				execute = {
					{
						"alert","fusionpunchcd",
						"alert","fusionpunchwarn",
					},
				},
			},
			-- Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","32867"}, -- Steelbreaker
						"quash","fusionpunchcd",
						"quash","fusionpunchwarn",
					},
					{
						"expect",{"&npcid|#4#&","==","32857"}, -- Stormcaller Brundir
						"quash","overloadcd",
						"quash","overloadwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- KOLOGARN
---------------------------------

do
	local data = {
		version = 300,
		key = "kologarn",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Kologarn"],
		triggers = {
			scan = 32930, -- Kologarn
		},
		onactivate = {
			tracing = {
				32930, -- Kologarn
				32934, -- Right Arm
				32933, -- Left Arm
			},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 32930,
		},
		onstart = {
			{
				"expect",{"&difficulty&","==","1"},
				"set",{armrespawntime = 40},
			},
		},
		alerts = {
			stonegripwarnothers = {
				varname = format(L.alert["%s on others"],SN[64290]),
				type = "simple",
				text = format("%s: #5#",SN[64290]),
				time = 1.5,
				color1 = "BROWN",
				sound = "ALERT2",
				icon = ST[64290],
			},
			armsweepcd = {
				varname = format(L.alert["%s Cooldown"],SN[63766]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[63766]),
				time = 10,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT3",
				icon = ST[63766],
			},
			shockwavecd = {
				varname = format(L.alert["%s Cooldown"],SN[63783]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[63783]),
				time = 16,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "GOLD",
				sound = "ALERT4",
				icon = ST[63783],
			},
			leftarmcd = {
				varname = format(L.alert["%s Respawn"],L.npc_ulduar["Left Arm"]),
				type = "dropdown",
				text = format(L.alert["%s Respawns"],L.npc_ulduar["Left Arm"]),
				time = "<armrespawntime>",
				color1 = "CYAN",
				icon = ST[43563],
			},
			rightarmcd = {
				varname = format(L.alert["%s Respawn"],L.npc_ulduar["Right Arm"]),
				type = "dropdown",
				text = format(L.alert["%s Respawns"],L.npc_ulduar["Right Arm"]),
				time = "<armrespawntime>",
				color1 = "DCYAN",
				icon = ST[43563],
			},
		},
		userdata = {
			armrespawntime = 50,
		},
		events = {
			-- Stone Grip
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64290,64292},
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","stonegripwarnothers",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Shockwave
					{
						"expect",{"#1#","find","^OBLIVION"},
						"alert","shockwavecd",
					},
				},
			},
			-- Arm Sweep
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {63766,63983},
				execute = {
					{
						"alert","armsweepcd",
					},
				},
			},
			-- Arm Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","32934"}, -- Right Arm
						"alert","rightarmcd",
					},
					{
						"expect",{"&npcid|#4#&","==","32933"}, -- Left Arm
						"quash","shockwavecd",
						"alert","leftarmcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- MIMIRON
---------------------------------

-- Proximity Mine cooldown. 30.5 seconds
do
	local data = {
		version = 314,
		key = "mimiron",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Mimiron"],
		triggers = {
			yell = {L.chat_ulduar["^We haven't much time, friends"],L.chat_ulduar["^Self%-destruct sequence initiated"]},
			scan = {
				33432, -- Leviathan MK II
				33350, -- Mimiron
				33651, -- VX-001
				33670, -- Aerial Command Unit
				33836, -- Bomb Bot
				34057, -- Assault Bot
				34147, -- Emergency Fire Bot
			},
		},
		onactivate = {
			tracing = {33432}, -- Leviathan Mk II
			combatstop = true,
			defeat = L.chat_ulduar["^It would appear that I've made a slight miscalculation"],
		},
		userdata = {
			plasmablasttime = {14,30,loop = false, type = "series"},
			laserbarragetime = {30,44,loop = false, type = "series"},
			flametime = 6.5,
			phase = "1",
		},
		onstart = {
			-- Phase 1
			{
				"alert","plasmablastcd",
			},
			-- Hard mode activation
			{
				"expect",{"#1#","find",L.chat_ulduar["^Self%-destruct sequence initiated"]},
				"alert","hardmodecd",
				"alert","flamesuppressantcd",
				"alert","flamecd",
				"set",{flametime = 27.5},
				"scheduletimer",{"flames",6.5},
			},
		},
		windows = {
			proxwindow = true,
		},
		timers = {
			flames = {
				{
					"expect",{"<phase>","~=","4"},
					"alert","flamecd",
					"scheduletimer",{"flames",27.5},
				},
				{
					"expect",{"<phase>","==","4"},
					"alert","flamecd",
					"scheduletimer",{"flames",18},
				},
			},
			startbarragedur = {
				{
					"alert","laserbarragedur",
					"quash","spinupwarn",
				},
			},
			startbarragecd = {
				{
					"alert","laserbarragecd",
				},
			},
			startblastcd = {
				{
					"alert","shockblastcd",
				},
			},
			startfrostbombexplodes = {
				{
					"alert","frostbombexplodeswarn",
				},
			},
			startplasmablastdur = {
				{
					"alert","plasmablastdur",
				},
			},
		},
		alerts = {
			flamesuppressantwarn = {
				type = "centerpopup",
				varname = format(L.alert["%s Casting"],SN[64570]),
				text = format(L.alert["%s Casting"],SN[64570]),
				time = 2,
				sound = "ALERT5",
				color1 = "TEAL",
				icon = ST[64570],
			},
			flamesuppressantcd = {
				type = "dropdown",
				varname = format(L.alert["%s Cooldown"],SN[64570]),
				text = format(L.alert["%s Cooldown"],SN[64570]),
				time = 60,
				flashtime = 5,
				color1 = "INDIGO",
				icon = ST[64570],
			},
			frostbombwarn = {
				type = "centerpopup",
				varname = format(L.alert["%s Casting"],SN[64623]),
				text = format(L.alert["%s Casting"],SN[64623]),
				time = 2,
				sound = "ALERT5",
				color1 = "BLUE",
				icon = ST[64623],
			},
			frostbombexplodeswarn = {
				type = "centerpopup",
				varname = format(L.alert["%s Timer"],SN[64623]),
				text = format(L.alert["%s Explodes"],SN[64623]).."!",
				time = 12,
				flashtime = 5,
				sound = "ALERT9",
				color1 = "BLUE",
				color2 = "WHITE",
				flashscreen = true,
				icon = ST[64623],
			},
			flamecd = {
				type = "dropdown",
				varname = format(L.alert["%s Timer"],SN[15643]),
				text = format(L.alert["Next %s Spawn"],SN[15643]),
				time = "<flametime>",
				flashtime = 5,
				sound = "ALERT1",
				color1 = "GREEN",
				color2 = "GREEN",
				icon = ST[22436],
			},
			-- Leviathan MKII
			plasmablastwarn = {
				type = "centerpopup",
				varname = format(L.alert["%s Casting"],SN[62997]),
				text = format(L.alert["%s Casting"],SN[62997]),
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT5",
				icon = ST[62997],
			},
			plasmablastdur = {
				type = "centerpopup",
				varname = format(L.alert["%s Duration"],SN[62997]),
				text = format(L.alert["%s Duration"],SN[62997]),
				time = 6,
				color1 = "ORANGE",
				icon = ST[62997],
			},
			plasmablastcd = {
				type = "dropdown",
				varname = format(L.alert["%s Cooldown"],SN[62997]),
				text = format(L.alert["%s Cooldown"],SN[62997]),
				time = "<plasmablasttime>",
				flashtime = 5,
				color1 = "ORANGE",
				color2 = "RED",
				sound = "ALERT2",
				icon = ST[62997],
			},
			shockblastwarn = {
				varname = format(L.alert["%s Casting"],SN[63631]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[63631]),
				time = 4,
				color1 = "MAGENTA",
				sound = "ALERT5",
				icon = ST[63631],
			},
			--- VX-001
			laserbarragedur = {
				type = "centerpopup",
				varname = format(L.alert["%s Duration"],L.alert["Laser Barrage"]),
				text = format(L.alert["%s Duration"],L.alert["Laser Barrage"]),
				time = 10,
				color1 = "PURPLE",
				sound = "ALERT6",
				icon = ST[63293],
			},
			laserbarragecd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Laser Barrage"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Laser Barrage"]),
				time = "<laserbarragetime>",
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "YELLOW",
				sound = "ALERT3",
				icon = ST[63293],
			},
			shockblastcd = {
				varname = format(L.alert["%s Cooldown"],SN[63631]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[63631]),
				time = 30,
				flashtime = 5,
				color1 = "MAGENTA",
				color2 = "ORANGE",
				sound = "ALERT3",
				icon = ST[63631],
			},
			spinupwarn = {
				varname = format(L.alert["%s Casting"],SN[63414]),
				type = "centerpopup",
				text = SN[63414].."!",
				time = 4,
				color1 = "WHITE",
				color2 = "RED",
				sound = "ALERT4",
				flashscreen = true,
				icon = ST[64385],
			},
			weakeneddur = {
				varname = format(L.alert["%s Duration"],L.alert["Weakened"]),
				type = "centerpopup",
				text = L.alert["Weakened"],
				time = 15,
				flashtime = 15,
				color1 = "GREY",
				color2 = "GREY",
				sound = "ALERT7",
				icon = ST[64436],
			},
			--- Phase Changes
			onetotwocd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Two"]),
				type = "dropdown",
				text = format(L.alert["%s Begins"],L.alert["Phase Two"]),
				time = 40,
				flashtime = 10,
				color1 = "RED",
				icon = ST[3648],
			},
			twotothreecd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Three"]),
				type = "dropdown",
				text = format(L.alert["%s Begins"],L.alert["Phase Three"]),
				time = 25,
				flashtime = 10,
				color1 = "RED",
				icon = ST[3648],
			},
			threetofourcd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Four"]),
				type = "dropdown",
				text = format(L.alert["%s Begins"],L.alert["Phase Four"]),
				time = 25,
				flashtime = 10,
				color1 = "RED",
				icon = ST[3648],
			},
			-- Hard Mode
			hardmodecd = {
				varname = format(L.alert["%s Timer"],L.alert["Hard Mode"]),
				type = "dropdown",
				text = L.alert["Raid Wipe"],
				time = 620,
				flashtime = 10,
				color1 = "BROWN",
				icon = ST[20573],
			},
			-- Bomb bot
			bombbotwarn = {
				varname = format(L.alert["%s Spawns"],L.npc_ulduar["Bomb Bot"]),
				type = "simple",
				text = format(L.alert["%s Spawned"],L.npc_ulduar["Bomb Bot"]).."!",
				time = 5,
				sound = "ALERT8",
				icon = ST[15048],
			},
		},
		events = {
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Transition from Phase 1 to Phase 2
					{
						"expect",{"#1#","find",L.chat_ulduar["^WONDERFUL! Positively"]},
						"set",{phase = "2"},
						"quash","plasmablastcd",
						"quash","flamesuppressantcd",
						"quash","shockblastcd",
						"canceltimer","startblastcd",
						"canceltimer","startplasmablastdur",
						"scheduletimer",{"startbarragecd",40},
						"tracing",{33651}, -- VX-001
						"alert","onetotwocd",
					},
					-- Transition from Phase 2 to Phase 3
					{
						"expect",{"#1#","find",L.chat_ulduar["^Thank you, friends!"]},
						"set",{phase = "3"},
						"tracing",{33670}, -- Aerial Command Unit
						"quash","laserbarragecd",
						"quash","laserbarragedur",
						"quash","spinupwarn",
						"canceltimer","startbarragedur",
						"canceltimer","startbarragecd",
						"canceltimer","startfrostbombexplodes",
						"alert","twotothreecd",
					},
					-- Transition from Phase 3 to Phase 4
					{
						"expect",{"#1#","find",L.chat_ulduar["^Preliminary testing phase complete"]},
						"quash","weakeneddur",
						"set",{phase = "4"},
						"set",{flametime = 18},
						"tracing",{33432,33651,33670}, -- Leviathan Mk II, VX-001, Aerial Command Unit
						"scheduletimer",{"startbarragecd",14},
						"scheduletimer",{"startblastcd",25},
						"alert","threetofourcd",
					},
				},
			},
			--- Phase 1 - Leviathan MKII
			-- Plasma Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62997,64529},
				execute = {
					{
						"alert","plasmablastwarn",
						"alert","plasmablastcd",
						"scheduletimer",{"startplasmablastdur",3},
					},
				},
			},
			-- Shock Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 63631,
				execute = {
					{
						"quash","shockblastcd",
						"alert","shockblastwarn",
						"scheduletimer",{"startblastcd",4},
					},
				},
			},
			--- Phase 2 - VX-001
			-- Spinning Up ->  Laser Barrage
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 63414,
				execute = {
					{
						"alert","spinupwarn",
						"scheduletimer",{"startbarragedur",4},
						"scheduletimer",{"startbarragecd",14},
					},
				},
			},
			-- Flame Suppressant
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64570,
				execute = {
					{
						"alert","flamesuppressantwarn",
						"alert","flamesuppressantcd",
					},
				},
			},
			-- Frost Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64623,
				execute = {
					{
						"alert","frostbombwarn",
						"scheduletimer",{"startfrostbombexplodes",2},
					},
				},
			},
			-- Bomb Bot
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 63811,
				execute = {
					{
						"alert","bombbotwarn",
					},
				},
			},
			-- Weakened
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = 64444,
				execute = {
					{
						"alert","weakeneddur",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


---------------------------------
-- RAZORSCALE
---------------------------------

do
	local data = {
		version = 300,
		key = "razorscale",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Razorscale"],
		triggers = {
			scan = {
				33186, -- Razorscale
				33388, -- Dark Rune Guardian
				33846, -- Dark Rune Sentinel
				33453, -- Dark Rune Watcher
			},
			yell = L.chat_ulduar["^Be on the lookout! Mole machines"],
		},
		onactivate = {
			tracing = {33186}, -- Razorscale
			combatstop = true,
			defeat = 33186,
		},
		onstart = {
			{
				"alert","enragecd",
			},
		},
		userdata = {},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 900,
				flashtime = 5,
				color1 = "RED",
				color2 = "RED",
				sound = "ALERT6",
				icon = ST[12317],
			},
			devourwarnself = {
				varname = format(L.alert["%s on self"],SN[63236]),
				type = "simple",
				text = format("%s: %s! %s!",SN[63236],L.alert["YOU"],L.alert["MOVE"]),
				time = 1.5,
				color1 = "RED",
				sound = "ALERT1",
				flashscreen = true,
				throttle = 3,
				icon = ST[63236],
			},
			breathwarn = {
				varname = format(L.alert["%s Casting"],SN[63317]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[63317]),
				time = 2.5,
				flashtime = 2.5,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT2",
				icon = ST[63317],
			},
			chaindur = {
				varname = format(L.alert["%s Duration"],L.alert["Chain"]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],L.alert["Chain"]),
				time = 38,
				color1 = "BROWN",
				sound = "ALERT3",
				icon = ST[60540],
			},
			permlandwarn = {
				varname = format(L.alert["%s Warning"],L.alert["Permanent Landing"]),
				type = "simple",
				text = format(L.alert["%s Permanently Landed"],L.npc_ulduar["Razorscale"]).."!",
				time = 1.5,
				sound = "ALERT4",
				icon = ST[45753],
			},
			harpoonwarn = {
				varname = format(L.alert["%s Warning"],SN[43993]),
				type = "simple",
				text = format(L.alert["%s Ready"],SN[43993]).."!",
				time = 3,
				sound = "ALERT5",
				color1 = "ORANGE",
				icon = ST[56570],
			},
		},
		events = {
			-- Devouring Flame
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {63236,64704,64733},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","devourwarnself",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Razorscale gets chained
					{
						"expect",{"#1#","find",L.chat_ulduar["^Move quickly"]},
						"alert","chaindur",
					},
					-- Razorscale lifts off
					{
						"expect",{"#1#","find",L.chat_ulduar["^Give us a moment to"]},
						"quash","chaindur",
					},
				},
			},
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_ulduar["deep breath...$"]},
						"alert","breathwarn",
					},
					{
						"expect",{"#1#","find",L.chat_ulduar["grounded permanently!$"]},
						"quash","chaindur",
						"alert","permlandwarn",
					},
					{
						"expect",{"#1#","find",L.chat_ulduar["^Harpoon Turret is ready"]},
						"alert","harpoonwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- THORIM
---------------------------------

do
	local data = {
		version = 306,
		key = "thorim",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Thorim"],
		triggers = {
			scan = {
				32865, -- Thorim,
				32882, -- Jormungar Behemoth,
				32872, -- Runic Colossus,
				32873, -- Ancient Rune Giant,
				32874, -- Iron Ring Guard,
			},
			yell = L.chat_ulduar["^Interlopers! You mortals who"],
		},
		onactivate = {
			tracing = {32872,32873}, -- Runic Colossus, Ancient Rune Giant
			combatstop = true,
			defeat = L.chat_ulduar["Stay your arms"],
		},
		userdata = {
			chargetime = 34,
			enragetime = {369,300,loop = false, type = "series"},
			striketext = "",
		},
		onstart = {
			{
				"alert","hardmodecd",
				"alert","enragecd",
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = "<enragetime>",
				flashtime = 5,
				sound = "ALERT1",
				color1 = "RED",
				icon = ST[12317],
			},
			hardmodecd = {
				varname = format(L.alert["%s Timeleft"],L.alert["Hard Mode"]),
				type = "dropdown",
				text = format(L.alert["%s Ends"],L.alert["Hard Mode"]),
				time = 172.5,
				flashtime = 5,
				color1 = "GREY",
				sound = "ALERT1",
				icon = ST[20573],
			},
			hardmodeactivationwarn = {
				varname = format(L.alert["%s Warning"],L.alert["Hard Mode"]),
				type = "simple",
				text = format(L.alert["%s Activated"],L.alert["Hard Mode"]),
				time = 1.5,
				sound = "ALERT1",
				icon = ST[62972],
			},
			chargecd = {
				varname = format(L.alert["%s Cooldown"],SN[62279]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[62279]),
				time = "<chargetime>",
				flashtime = 7,
				sound = "ALERT2",
				color1 = "VIOLET",
				icon = ST[62279],
				counter = true,
			},
			chainlightningcd = {
				varname = format(L.alert["%s Cooldown"],SN[62131]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[62131]),
				time = 10,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "ORANGE",
				color2 = "ORANGE",
				icon = ST[62131],
			},
			frostnovawarn = {
				varname = format(L.alert["%s Casting"],SN[122]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[122]),
				time = 2.5,
				flashtime = 2.5,
				sound = "ALERT4",
				color1 = "BLUE",
				color2 = "BLUE",
				icon = ST[122],
			},
			strikecd = {
				varname = format(L.alert["%s Cooldown"],SN[62130]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[62130]),
				time = 25,
				flashtime = 5,
				sound = "ALERT5",
				color1 = "BROWN",
				color2 = "BROWN",
				icon = ST[62130],
			},
			strikewarn = {
				varname = format(L.alert["%s Warning"],SN[62130]),
				type = "simple",
				text = "<striketext>",
				time = 3,
				sound = "ALERT6",
				icon = ST[62130],
			},
		},
		events = {
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Phase 2
					{
						"expect",{"#1#","find",L.chat_ulduar["^Impertinent"]},
						"quash","hardmodecd",
						"quash","enragecd",
						"alert","enragecd",
						"tracing",{32865}, -- Thorim
						"alert","chargecd",
						"set",{chargetime = 15},
					},
					-- Hard mode activation
					{
						"expect",{"#1#","find",L.chat_ulduar["^Impossible!"]},
						"alert","hardmodeactivationwarn",
					},
				},
			},
			-- Lightning Charge
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 62279,
				execute = {
					{
						"alert","chargecd",
					},
				},
			},
			-- Chain Lightning
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64390,62131},
				execute = {
					{
						"alert","chainlightningcd",
					},
				},
			},
			-- Sif's Frost Nova
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62605,62597},
				execute = {
					{
						"alert","frostnovawarn",
					},
				},
			},
			-- Unbalancing Strike
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 62130,
				execute = {
					{
						"quash","strikecd",
						"alert","strikecd",
					},
				},
			},
			-- Unbalancing Strike application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62130,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{striketext = format("%s: %s!",SN[62130],L.alert["YOU"])},
						"alert","strikewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{striketext = format("%s: #5#!",SN[62130])},
						"alert","strikewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


---------------------------------
-- XT002
---------------------------------

do

	local data = {
		version = 302,
		key = "xt002",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["XT-002 Deconstructor"],
		triggers = {
			scan = {33293,33329}, -- XT-002 Deconstructor, Heart of the Deconstructor
		},
		onactivate = {
			tracing = {33293}, -- XT-002 Deconstructor
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 33293,
		},
		userdata = {
			heartbroken = "0",
		},
		onstart = {
			{
				"alert","enragecd",
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 5,
				sound = "ALERT5",
				color1 = "RED",
				color2 = "RED",
				icon = ST[12317],
			},
			gravitywarnself = {
				varname = format(L.alert["%s on self"],SN[63024]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[63024],L.alert["YOU"],L.alert["MOVE"]),
				time = 9,
				flashtime = 9,
				sound = "ALERT1",
				color1 = "GREEN",
				color2 = "PINK",
				flashscreen = true,
				icon = ST[63024],
			},
			gravitywarnothers = {
				varname = format(L.alert["%s on others"],SN[63024]),
				type = "centerpopup",
				text = format("%s: #5#",SN[63024]),
				time = 9,
				color1 = "GREEN",
				icon = ST[63024],
			},
			lightwarnself = {
				varname = format(L.alert["%s on self"],SN[63018]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[63018],L.alert["YOU"],L.alert["MOVE"]),
				time = 9,
				flashtime = 9,
				sound = "ALERT3",
				color1 = "CYAN",
				color2 = "MAGENTA",
				flashscreen = true,
				icon = ST[63018],
			},
			lightwarnothers = {
				varname = format(L.alert["%s on others"],SN[63018]),
				type = "centerpopup",
				text = format("%s: #5#",SN[63018]),
				time = 9,
				color1 = "CYAN",
				icon = ST[63018],
			},
			tympanicwarn = {
				varname = format(L.alert["%s Casting"],SN[62776]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],L.alert["Tantrum"]),
				time = 12,
				flashtime = 12,
				color1 = "YELLOW",
				color2 = "YELLOW",
				sound = "ALERT2",
				icon = ST[62776],
			},
			tympaniccd = {
				varname = format(L.alert["%s Cooldown"],SN[62776]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Tantrum"]),
				time = 64,
				flashtime = 5,
				color1 = "ORANGE",
				color2 = "ORANGE",
				sound = "ALERT6",
				icon = ST[62776],
			},
			exposedwarn = {
				varname = format(L.alert["%s Timer"],L.alert["Heart"]),
				type = "centerpopup",
				text = format(L.alert["%s Exposed"],L.alert["Heart"]).."!",
				time = 30,
				flashtime = 30,
				sound = "ALERT4",
				color1 = "BLUE",
				color2 = "RED",
				icon = ST[63849],
			},
			hardmodewarn = {
				varname = format(L.alert["%s Activation"],L.alert["Hard Mode"]),
				type = "simple",
				text = format(L.alert["%s Activated"],L.alert["Hard Mode"]).."!",
				time = 1.5,
				sound = "ALERT5",
				icon = ST[62972],
			},
		},
		timers = {
			heartunexposed = {
				{
					"tracing",{33293},
				},
			},
		},
		announces = {
			lightsay = {
				varname = format(L.alert["Say %s on self"],SN[63018]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[63018]).."!",
			},
			gravitysay = {
				varname = format(L.alert["Say %s on self"],SN[63024]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[63024]).."!",
			},
		},
		events = {
			-- Gravity Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63024, 64234},
				execute = {
					{
						"expect",{"#4#", "==", "&playerguid&"},
						"alert","gravitywarnself",
						"announce","gravitysay",
					},
					{
						"expect",{"#4#", "~=", "&playerguid&"},
						"alert","gravitywarnothers",
					},
				},
			},
			-- Light Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63018,65121},
				execute = {
					{
						"expect",{"#4#", "==", "&playerguid&"},
						"alert","lightwarnself",
						"announce","lightsay",
					},
					{
						"expect",{"#4#", "~=", "&playerguid&"},
						"alert","lightwarnothers",
					},
				},
			},
			-- Tympanic
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62776},
				execute = {
					{
						"alert","tympanicwarn",
						"expect",{"<heartbroken>","==","1"},
						"alert","tympaniccd",
					},
				},
			},
			-- Heart Exposed
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63849,
				execute = {
					{
						"alert","exposedwarn",
						"scheduletimer",{"heartunexposed", 30},
						"tracing",{33293,33329}, -- XT-002, Heart of the Deconstructor
					},
				},
			},
			-- Heartbreak
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64193,65737},
				execute = {
					{
						"quash","exposedwarn",
						"canceltimer","heartunexposed",
						"tracing",{33293},
						"alert","hardmodewarn",
						"set",{heartbroken = "1"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- YOGGSARON
---------------------------------

do
	local data = {
		version = 309,
		key = "yoggsaron",
		zone = L.zone["Ulduar"],
		name = L.npc_ulduar["Yogg-Saron"],
		triggers = {
			yell = L.chat_ulduar["^The time to strike at the head of the beast"],
			scan = {
				33134, -- Sara
				33288, -- Yogg-Saron
				33890, -- Brain of Yogg-Saron
				33966, -- Crusher Tentacle
				33985, -- Corruptor Tentacle
				33983, -- Constrictor Tentacle
				33136, -- Guardian of Yogg-Saron
			},
		},
		onactivate = {
			tracing = {33134}, -- Sara
			combatstop = true,
			defeat = 33288,
		},
		userdata = {
			portaltime = {73,90,loop = false, type = "series"},
			portaltext = {format(L.alert["%s Soon"],L.alert["Portals"]),format(L.alert["Next %s"],L.alert["Portals"]), loop = false, type = "series"},
			crushertime = {14,55,loop = false, type = "series"},
			phase = "1",
		},
		onstart = {
			{
				"alert","enragecd",
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 900,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			-- Phase 1
			fervorwarn = {
				varname = format(L.alert["%s on self"],SN[63138]),
				type = "simple",
				text = format("%s: %s!",SN[63138],L.alert["YOU"]),
				time = 2,
				sound = "ALERT4",
				color1 = "PURPLE",
				flashscreen = true,
				icon = ST[63138],
			},
			blessingwarn = {
				varname = format(L.alert["%s on self"],SN[63134]),
				type = "simple",
				text = format("%s: %s!",SN[63134],L.alert["YOU"]),
				time = 2,
				sound = "ALERT8",
				color1 = "CYAN",
				flashscreen = true,
				icon = ST[63134],
			},
			-- Phase 2
			brainlinkdur = {
				varname = format(L.alert["%s on self"],SN[63802]),
				type = "centerpopup",
				text = format("%s: %s!",SN[63802],L.alert["YOU"]),
				time = 30,
				flashtime = 30,
				color1 = "BLUE",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[63802],
			},
			portalcd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Portals"]),
				type = "dropdown",
				text = "<portaltext>",
				time = "<portaltime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				icon = ST[66634],
			},
			weakeneddur = {
				varname = format(L.alert["%s Duration"],L.alert["Weakened"]),
				type = "centerpopup",
				text = L.alert["Weakened"].."!",
				time = "&timeleft|inducewarn&",
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[64173],
			},
			inducewarn = {
				varname = format(L.alert["%s Casting"],SN[64059]),
				type = "dropdown",
				text = format(L.alert["%s Casting"],SN[64059]),
				time = 60,
				flashtime = 5,
				color1 = "BROWN",
				color2 = "MIDGREY",
				sound = "ALERT6",
				icon = ST[64059],
			},
			squeezewarn = {
				varname = format(L.alert["%s on others"],SN[64126]),
				type = "simple",
				text = format("%s: #5#",SN[64126]),
				time = 4,
				color1 = "YELLOW",
				sound = "ALERT7",
				icon = ST[64126],
			},
			maladywarn = {
				varname = format(L.alert["%s Warning"],SN[63830]),
				type = "simple",
				text = format("%s: #5#! %s",L.alert["Malady"],L.alert["MOVE AWAY"]),
				time = 3,
				sound = "ALERT5",
				color1 = "GREEN",
				flashscreen = true,
				icon = ST[63830],
			},
			crushertentaclewarn = {
				varname = format(L.alert["%s Spawns"],L.npc_ulduar["Crusher Tentacle"]),
				type = "dropdown",
				text = format(L.alert["%s Spawns"],L.npc_ulduar["Crusher Tentacle"]).."!",
				time = "<crushertime>",
				flashtime = 7,
				color1 = "DCYAN",
				color2 = "INDIGO",
				icon = ST[50234],
			},
			-- Phase 3
			empoweringshadowscd = {
				varname = format(L.alert["%s Timer"],SN[64486]),
				type = "centerpopup",
				text = format(L.alert["Next %s"],SN[64486]),
				time = 10,
				flashtime = 5,
				color1 = "INDIGO",
				color2 = "RED",
				icon = ST[64486],
			},
			shadowbeaconcd = {
				varname = format(L.alert["%s Cooldown"],SN[64465]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[64465]),
				time = 45,
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[64465],
			},
			deafeningcd = {
				varname = format(L.alert["%s Cooldown"],SN[64189]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[64189]),
				time = 60,
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[64189],
			},
			deafeningwarn = {
				varname = format(L.alert["%s Casting"],SN[64189]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[64189]),
				time = 2.3,
				color1 = "ORANGE",
				sound = "ALERT5",
				icon = ST[64189],
			},
			lunaticgazewarn = {
				varname = format(L.alert["%s Casting"],SN[64163]),
				type = "centerpopup",
				text = format("%s! %s!",SN[64163],L.alert["LOOK AWAY"]),
				time = 4,
				color1 = "PURPLE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[64163],
			},
			lunaticgazecd = {
				varname = format(L.alert["%s Cooldown"],SN[64163]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[64163]),
				time = 11,
				flashtime = 5,
				color1 = "GREEN",
				color2 = "YELLOW",
				icon = ST[64163],
			},
		},
		arrows = {
			maladyarrow = {
				varname = SN[63830],
				unit = "#5#",
				persist = 4,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = L.alert["Malady"],
			},
		},
		raidicons = {
			maladymark = {
				varname = SN[63830],
				type = "FRIENDLY",
				persist = 4,
				unit = "#5#",
				icon = 1,
			}
		},
		events = {
			-- Sara's Fervor
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63138,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","fervorwarn",
					},
				},
			},
			-- Sara's Blessing
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63134,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","blessingwarn",
					},
				},
			},
			-- Lunatic Gaze
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64163,64164},
				execute = {
					{
						"alert","lunaticgazewarn",
						"alert","lunaticgazecd",
					},
				},
			},
			-- Brain Link
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63802,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","brainlinkdur",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Phase 2
					{
						"expect",{"#1#","find",L.chat_ulduar["^I am the lucid dream"]},
						"tracing",{33288,33890}, -- Yogg-Saron, Brain of Yogg-Saron
						"alert","portalcd",
						"alert","crushertentaclewarn",
						"set",{phase = "2"},
					},
					-- Phase 3
					{
						"expect",{"#1#","find",L.chat_ulduar["^Look upon the true face"]},
						"tracing",{33288}, -- Yogg-Saron
						"quash","crushertentaclewarn",
						"quash","inducewarn",
						"quash","portalcd",
						"quash","weakeneddur",
						"alert","shadowbeaconcd",
						"set",{phase = "3"},
						"expect",{"&difficulty&","==","2"},
						"alert","deafeningcd",
					},
				},
			},
			{
				type = "event",
				event = "EMOTE",
				execute = {
					-- Portal
					{
						"expect",{"#1#","find",L.chat_ulduar["^Portals open"]},
						"alert","portalcd",
					},
					-- Weakened
					{
						"expect",{"#1#","find",L.chat_ulduar["^The illusion shatters and a path"]},
						"alert","weakeneddur",
						"quash","inducewarn",

						"expect",{"&timeleft|weakeneddur&",">","&timeleft|crushertentaclewarn&"},
						"set",{crushertime = "&timeleft|weakeneddur|5&"},
						"quash","crushertentaclewarn",
						"alert","crushertentaclewarn",
					},
				},
			},
			-- Squeeze
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64126,64125},
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","squeezewarn",
					},
				},
			},
			-- Malady of the Mind
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63830,63881},
				execute = {
					{
						"raidicon","maladymark",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"proximitycheck",{"#5#",28},
						"alert","maladywarn",
						"arrow","maladyarrow",
					},
				},
			},
			-- Induce Madness
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64059,
				execute = {
					{
						"alert","inducewarn",
					},
				},
			},
			-- Brain Link removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {63802,63803,63804},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","brainlinkdur",
					},
				},
			},
			-- Crusher Tentacle spawn -> Focused Anger
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {57688,57689},
				execute = {
					{
						"expect",{"<phase>","==","2"},
						"quash","crushertentaclewarn",
						"alert","crushertentaclewarn",
					},
				},
			},
			-- Deafening Roar
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64189,
				execute = {
					{
						"quash","deafeningcd",
						"alert","deafeningwarn",
						"alert","deafeningcd",
					},
				},
			},
			-- Shadow Beacon, Empowering Shadows
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64465,
				execute = {
					{
						"quash","shadowbeaconcd",
						"alert","shadowbeaconcd",
						"alert","empoweringshadowscd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
