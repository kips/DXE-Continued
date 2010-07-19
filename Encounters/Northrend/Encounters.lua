local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ARCHAVON
---------------------------------

do
	local data = {
		version = 301,
		key = "archavon",
		zone = L.zone["Vault of Archavon"],
		category = L.zone["Northrend"],
		name = L.npc_northrend["Archavon"],
		triggers = {
			scan = 31125, -- Archavon
		},
		onactivate = {
			tracing = {31125}, -- Archavon
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 31125,
		},
		userdata = {},
		onstart = {
			{
				"alert","enragecd",
				"alert","stompcd",
			}
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 300,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			chargewarn = {
				varname = format(L.alert["%s Warning"],SN[100]),
				type = "simple",
				text = format("%s: #5#",SN[100]),
				time = 1.5,
				sound = "ALERT2",
				icon = ST[100],
			},
			cloudwarn = {
				varname = format(L.alert["%s Warning"],SN[58965]),
				type = "simple",
				text = format("%s: %s! %s!",SN[58965],L.alert["YOU"],L.alert["MOVE"]),
				time = 1.5,
				sound = "ALERT2",
				icon = ST[58965],
			},
			shardswarnself = {
				varname = format(L.alert["%s on self"],SN[58695]),
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				text = format("%s: %s! %s!",SN[58695],L.alert["YOU"],L.alert["MOVE"]),
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[58695],
			},
			shardswarnothers = {
				varname = format(L.alert["%s on others"],SN[58695]),
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				sound = "ALERT3",
				text = format("%s: &tft_unitname&",SN[58695]),
				icon = ST[58695],
			},
			stompcd = {
				varname = format(L.alert["%s Cooldown"],SN[58663]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[58663]),
				time = 47,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "BROWN",
				icon = ST[58663],
			},
		},
		timers = {
			shards = {
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","true true"},
					"alert","shardswarnself",
				},
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","true false"},
					"alert","shardswarnothers",
				},
			},
		},
		events = {
			-- Stomp
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {58663, 60880},
				execute = {
					{
						"alert","stompcd",
					},
				},
			},
			-- Shards
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 58678,
				execute = {
					{
						"scheduletimer",{"shards",0.2},
					}
				},
			},
			-- Cloud
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {58965, 61672},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","cloudwarn",
					},
				},
			},
			-- Charge
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_EMOTE",
				execute = {
					{
						"alert","chargewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- KORALON
---------------------------------

do
	local data = {
		version = 5,
		key = "koralon",
		zone = L.zone["Vault of Archavon"],
		category = L.zone["Northrend"],
		name = L.npc_northrend["Koralon"],
		triggers = {
			scan = {
				35013, -- Koralon
			},
		},
		onactivate = {
			tracing = {35013},
			tracerstart = true,
			combatstop = true,
			defeat = 35013,
		},
		userdata = {
			meteortime = {28,47,loop = false, type = "series"}, -- recheck
			breathtime = {8,47,loop = false, type = "series"}, -- recheck
		},
		onstart = {
			{
				"alert","breathcd",
				"alert","meteorcd",
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			flamingcinderself = {
				varname = format(L.alert["%s on self"],SN[67332]),
				text = format("%s: %s! %s!",SN[67332],L.alert["YOU"],L.alert["MOVE AWAY"]),
				type = "simple",
				time = 3,
				throttle = 3,
				color1 = "ORANGE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[67332],
			},
			meteorcd = {
				varname = format(L.alert["%s Cooldown"],SN[66725]),
				text = format(L.alert["%s Cooldown"],SN[66725]),
				type = "dropdown",
				time = "<meteortime>",
				flashtime = 10,
				color1 = "MAGENTA",
				sound = "ALERT4",
				icon = ST[66725],
			},
			meteorwarn = {
				varname = format(L.alert["%s Casting"],SN[66725]),
				text = format(L.alert["%s Casting"],SN[66725]),
				type = "centerpopup",
				time = 1.5,
				flashtime = 1.5,
				color1 = "BROWN",
				sound = "ALERT3",
				icon = ST[66725],
			},
			meteordur = {
				varname = format(L.alert["%s Duration"],SN[66725]),
				text = format(L.alert["%s Duration"],SN[66725]),
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				color1 = "BROWN",
				sound = "ALERT2",
				icon = ST[66725],
			},
			breathwarn = {
				varname = format(L.alert["%s Casting"],SN[67328]),
				text = format(L.alert["%s Casting"],SN[67328]),
				type = "centerpopup",
				time = 1.5,
				flashtime = 1.5,
				sound = "ALERT5",
				color1 = "YELLOW",
				icon = ST[67328],
			},
			breathdur = {
				varname = format(L.alert["%s Channel"],SN[67328]),
				text = format(L.alert["%s Channel"],SN[67328]),
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[67328],
			},
			breathcd = {
				varname = format(L.alert["%s Cooldown"],SN[67328]),
				text = format(L.alert["%s Cooldown"],SN[67328]),
				type = "dropdown",
				time = "<breathtime>",
				flashtime = 5,
				color1 = "INDIGO",
				icon = ST[67328],
			},
		},
		timers = {
			startbreathchan = {
				{
					"quash","breathwarn",
					"alert","breathdur",
				},
			},
		},
		events = {
			-- Burning Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					66665,
					67328, -- 25
				},
				execute = {
					{
						"quash","breathcd",
						"alert","breathcd",
						"alert","breathwarn",
						"scheduletimer",{"startbreathchan",1.5},
					},
				},
			},
			-- Meteor Fists cast
			{
				type =  "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					68161, -- 25
					66808,
					66725,
					68160,
				},
				execute = {
					{
						"alert","meteorwarn",
					},
				},
			},
			-- Meteor Fists duration
			{
				type =  "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					68161, -- 25
					66808,
					66725,
					68160,
				},
				execute = {
					{
						"quash","meteorwarn",
						"alert","meteordur",
					},
				},
			},
			-- Flaming Cinder
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {67332,66684},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","flamingcinderself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- EMALON
---------------------------------

do
	local data = {
		version = 300,
		key = "emalon",
		zone = L.zone["Vault of Archavon"],
		category = L.zone["Northrend"],
		name = L.npc_northrend["Emalon"],
		triggers = {
			scan = {
				33993, -- Emalon
				33998, -- Tempest Minion
				34049, -- Tempest Minion
			},
		},
		onactivate = {
			tracing = {33993},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 33993,
		},
		userdata = {},
		onstart = {
			{
				"alert","overchargecd",
			}
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			novacd = {
				varname = format(L.alert["%s Cooldown"],SN[64216]),
				type = "dropdown",
				time = 25,
				flashtime = 5,
				text = format(L.alert["%s Cooldown"],SN[64216]),
				color1 = "BLUE",
				color2 = "BLUE",
				sound = "ALERT1",
				icon = ST[421],
			},
			novawarn = {
				varname = format(L.alert["%s Casting"],SN[64216]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				text = format(L.alert["%s Casting"],SN[64216]),
				color1 = "BROWN",
				color2 = "ORANGE",
				sound = "ALERT5",
				icon = ST[57322],
			},
			overchargecd = {
				varname = format(L.alert["%s Cooldown"],SN[64218]),
				type = "dropdown",
				time = 45,
				flashtime = 5,
				text = format(L.alert["Next %s"],SN[64218]),
				color1 = "RED",
				color2 = "DCYAN",
				sound = "ALERT2",
				icon = ST[64218],
			},
			overchargedblastdur = {
				varname = format(L.alert["%s Timer"],SN[64219]),
				type = "centerpopup",
				time = 20,
				flashtime = 5,
				text = SN[64219].."!",
				color1 = "YELLOW",
				color2 = "VIOLET",
				sound = "ALERT3",
				icon = ST[37104],
			},
		},
		events = {
			-- Lightning Nova
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64216,65279},
				execute = {
					{
						"alert","novacd",
						"alert","novawarn",
					},
				},
			},
			-- Overcharge and Overcharged Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64218,
				execute = {
					{
						"alert","overchargecd",
						"alert","overchargedblastdur",
					},
				},
			},
			-- Overcharge Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 64217,
				execute = {
					{
						"quash","overchargedblastdur",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- HALION
---------------------------------

do
	local data = {
		version = 15,
		key = "halion",
		zone = L.zone["The Ruby Sanctum"],
		category = L.zone["Northrend"],
		name = L.npc_northrend["Halion"],
		triggers = {
			scan = {
				39863, -- Halion
				40142, -- Twilight Halion
			},
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			unittracing = { "boss1", "boss2" },
			defeat = L.chat_northrend["^Relish this victory, mortals, for it will"],
		},
		userdata = {
			phase = 1,
		},
		onstart = {
			{
				"alert","meteorcd",
				"alert","debuffcd",
			},
		},
		alerts = {
			fierydur = {
				varname = format(L.alert["%s Duration"],SN[74562]),
				type = "centerpopup",
				text = format("%s: #5#",SN[74562]),
				time = 30,
				flashtime = 30,
				color1 = "RED",
				icon = ST[74562],
			},
			fieryself = {
				varname = format(L.alert["%s on self"],SN[74562]),
				type = "centerpopup",
				text = format("%s: %s!",SN[74562],L.alert["YOU"]).."!",
				time = 30,
				flashtime = 30,
				color1 = "RED",
				sound = "ALERT1",
				icon = ST[74562],
				flashscreen = true,
			},
			souldur = {
				varname = format(L.alert["%s Duration"],SN[74792]),
				type = "centerpopup",
				text = format("%s: #5#",SN[74792]),
				time = 30,
				flashtime = 30,
				color1 = "PURPLE",
				icon = ST[74792],
			},
			soulself = {
				varname = format(L.alert["%s on self"],SN[74792]),
				type = "centerpopup",
				text = format("%s: %s!",SN[74792],L.alert["YOU"]).."!",
				time = 30,
				flashtime = 30,
				color1 = "PURPLE",
				sound = "ALERT2",
				icon = ST[74792],
				flashscreen = true,
			},
			cutterdur = {
				varname = format(L.alert["%s Duration"],SN[77844]),
				type = "centerpopup",
				text = SN[77844],
				time = 11,
				flashtime = 11,
				color1 = "PINK",
				icon = ST[77844],
				behavior = "overwrite",
			},
			cutterwarn = {
				varname = format(L.alert["%s Casting"],SN[77844]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[77844]),
				time = 4.5,
				flashtime = 4.5,
				color1 = "PINK",
				icon = ST[77844],
				sound = "ALERT12",
				flashscreen = true,
				behavior = "overwrite",
			},
			cuttercd = {
				varname = format(L.alert["%s Cooldown"],SN[77844]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[77844]),
				time = 30, -- time from cutter to cutter
				time2 = 35, -- initial
				flashtime = 10,
				color1 = "PINK",
				icon = ST[77844],
				behavior = "overwrite",
			},
			meteorwarn = {
				varname = format(L.alert["%s Warning"],SN[75878]),
				type = "centerpopup",
				text = format(L.alert["%s Soon"],SN[75878]).."!",
				time = 5,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT4",
				icon = ST[75878],
			},
			meteorcd = {
				varname = format(L.alert["%s Cooldown"],SN[75878]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[75878]),
				time = { 20,40, loop=false, type="series"}, -- phase 1
				time2 = 30, -- phase 3 restart time
				flashtime = 10,
				color1 = "ORANGE",
				icon = ST[75878],
			},
			combustionself = {
				varname = format(L.alert["%s on self"],SN[75884]),
				type = "simple",
				text = format("%s: %s! %s!",SN[75884],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				throttle = 4,
				flashscreen = true,
				sound = "ALERT5",
				icon = ST[75884],
			},
			consumptionself = {
				varname = format(L.alert["%s on self"],SN[75876]),
				type = "simple",
				text = format("%s: %s! %s!",SN[75876],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				throttle = 4,
				flashscreen = true,
				sound = "ALERT5",
				icon = ST[75876],
			},
			meteorself = {
				varname = format(L.alert["%s on self"],SN[75952]),
				type = "simple",
				text = format("%s: %s! %s!",SN[75952],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				throttle = 4,
				flashscreen = true,
				sound = "ALERT5",
				icon = ST[75952],
			},
			debuffcd = {
				varname =  format(L.alert["%s Cooldown"],SN[74562].."/"..SN[74792]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[74562]),
				text2 = format(L.alert["%s Cooldown"],SN[74792]),
				text3 = format(L.alert["%s Cooldown"],L.alert["Fiery"].."/"..L.alert["Soul"]),
				time = { 15,25, loop=false, type="series"},
				time10h = { 15,20, loop=false, type="series"},
				time25h = { 15,20, loop=false, type="series"},
				flashtime = 10,
				color1 = "YELLOW",
				icon = ST[32786],
				behavior = "overwrite",
			},
		},
		raidicons = {
			fierymark = {
				varname = SN[74562],
				type = "FRIENDLY",
				persist = 30,
				unit = "#5#",
				icon = 1,
			},
			soulmark = {
				varname = SN[74792],
				type = "FRIENDLY",
				persist = 30,
				unit = "#5#",
				icon = 2,
			},
		},
		announces = {
			fierysay = {
				varname = format(L.alert["Say %s on self"],SN[74562]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[74562]).."!",
			},
			soulsay = {
				varname = format(L.alert["Say %s on self"],SN[74792]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[74792]).."!",
			}
		},
		timers = {
			firecuttercd = {
				{
					"alert","cuttercd",
					--"alert","cutterwarn",
					--"scheduletimer",{"firecutterdur",3},
					"scheduletimer",{"firecuttercd",30},
				},
			},
			firecutterdur = {
				{
					"quash","cutterwarn",
					"alert","cutterdur",
				},
			},
			firedebuffcd = {
				{
					"expect",{"&difficulty&","<=","2"},
					"scheduletimer",{"firedebuffcd",25},
				},
				{
					"expect",{"&difficulty&",">=","3"},
					"scheduletimer",{"firedebuffcd",20},
				},
				{
					"expect",{"<phase>","==","1"},
					"alert","debuffcd",
				},
				{
					"expect",{"<phase>","==","2"},
					"alert",{"debuffcd",text=2},
				},
				{
					"expect",{"<phase>","==","3"},
					"alert",{"debuffcd",text=3},
				},
			},
		},
		events = {
			-- Combustion self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 75884,
				dstisplayerunit = true,
				execute = {
					{
						"expect",{"#2#","==","nil"},
						"alert","combustionself",
					},
				},
			},
			-- Combustion self applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 75884,
				dstisplayerunit = true,
				execute = {
					{
						"expect",{"#2#","==","nil"},
						"alert","combustionself",
					},
				},
			},
			-- Consumption self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 75876,
				dstisplayerunit = true,
				execute = {
					{
						"expect",{"#2#","==","nil"},
						"alert","consumptionself",
					},
				},
			},
			-- Consumption self applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 75876,
				dstisplayerunit = true,
				execute = {
					{
						"expect",{"#2#","==","nil"},
						"alert","consumptionself",
					},
				},
			},

			-- Meteor Strike self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 75952,
				dstisplayerunit = true,
				execute = {
					{
						"expect",{"#2#","==","nil"},
						"alert","meteorself",
					},
				},
			},
			-- Fiery Combustion
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 74562,
				execute = {
					{
						"scheduletimer",{"firedebuffcd",0},
					},
				},
			},
			-- Fiery Combustion application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 74562,
				execute = {
					{
						"raidicon","fierymark",
						"alert",{dstself = "fieryself",dstother = "fierydur"},
						"announce",{dstself = "fierysay"},
					},
				},
			},
			-- Fiery Combustion removed
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 74562,
				execute = {
					{
						"batchquash",{"fierydur","fieryself"},
					},
				}
			},
			-- Soul Consumption
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 74792,
				execute = {
					{
						"scheduletimer",{"firedebuffcd",0},
					},
				},
			},
			-- Soul Consumption application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 74792,
				execute = {
					{
						"raidicon","soulmark",
						"alert",{dstself = "soulself",dstother = "souldur"},
						"announce",{dstself = "soulsay"},
					},
				},
			},
			-- Soul Consumption removed
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 74792,
				execute = {
					{
						"batchquash",{"souldur","soulself"},
					},
				}
			},
			-- Phase 2 start
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["^You will find only suffering"]},
						"alert",{"cuttercd", time = 2},
						"quash","meteorcd",
						"scheduletimer",{"firedebuffcd",0},
						"set",{phase = 2},
					},
				}
			},
			-- Phase 3 start
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["^I am the light and the darkness!"]},
						"set",{phase = 3},
						"alert",{"meteorcd",time=2},
					},
				}
			},
			-- Twilight Cutter
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["^The orbiting spheres pulse with"]},
						"alert","cuttercd",
						"alert","cutterwarn",
						"scheduletimer",{"firecutterdur",4.5},
						"scheduletimer",{"firecuttercd",30},
					},
				},
			},
			-- Meteor Strike
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["^The heavens burn!"]},
						"alert","meteorwarn",
						"alert","meteorcd",
					}
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- MALYGOS
---------------------------------

do
	local data = {
		version = 300,
		key = "malygos",
		zone = L.zone["The Eye of Eternity"],
		category = L.zone["Northrend"],
		name = L.npc_northrend["Malygos"],
		triggers = {
			scan = {
				28859, -- Malygos
				30245, -- Nexus Lord
				30249, -- Scion of Eternity
				30084, -- Power Spark
			},
		},
		onactivate = {
			tracing = {28859}, -- Malygos
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 28859,
		},
		userdata = {
			phase = 1,
			vortexcd = {29,59,loop = false, type = "series"},
		},
		onstart = {
			{
				"alert","vortexcd",
			}
		},
		alerts = {
			vortexcd = {
				varname = format(L.alert["%s Cooldown"],SN[56105]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[56105]),
				time = "<vortexcd>",
				flashtime = 5,
				sound = "ALERT1",
				color1 = "BLUE",
				icon = ST[56105],
			},
			staticfieldwarn = {
				varname = format(L.alert["%s Warning"],SN[57430]),
				type = "simple",
				text = format("%s! %s!",format(L.alert["%s Cast"],SN[57430]),L.alert["MOVE"]),
				time = 1.5,
				sound = "ALERT2",
				color1 = "YELLOW",
				icon = ST[57430],
			},
			surgewarn = {
				varname = format(L.alert["%s on self"],L.alert["Surge"]),
				type = "centerpopup",
				text = format("%s: %s! %s!",L.alert["Surge"],L.alert["YOU"],L.alert["CAREFUL"]),
				time = 3,
				flashtime = 3,
				sound = "ALERT1",
				throttle = 5,
				color1 = "MAGENTA",
				icon = ST[56505],
			},
			presurgewarn = {
				varname = format(L.alert["%s Warning"],L.alert["Surge"]),
				type = "simple",
				text = format("%s: %s! %s!",L.alert["Surge"],L.alert["YOU"],L.alert["SOON"]),
				time = 1.5,
				sound = "ALERT5",
				color1 = "TURQUOISE",
				flashscreen = true,
				icon = ST[56505],
			},
			deepbreathwarn = {
				varname = format(L.alert["%s Cooldown"],L.alert["Deep Breath"]),
				type = "dropdown",
				text = format(L.alert["Next %s"],L.alert["Deep Breath"]),
				time = 92,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "ORANGE",
				icon = ST[57432],
			},
			vortexdur = {
				varname = format(L.alert["%s Duration"],SN[56105]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[56105]),
				time = 10,
				sound = "ALERT1",
				color1 = "BLUE",
				icon = ST[56105],
			},
			powersparkcd = {
				varname = format(L.alert["%s Spawns"],L.npc_northrend["Power Spark"]),
				type = "dropdown",
				text = format(L.alert["Next %s"],L.npc_northrend["Power Spark"]),
				time = 17,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "WHITE",
				icon = ST[56152],
			},
		},
		events = {
			-- Vortex/Power spark
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 56105,
				execute = {
					{
						"alert","vortexdur",
						"alert","vortexcd",
						"quash","powersparkcd",
						"alert","powersparkcd",
					},
				},
			},
			-- Surge
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {57407, 60936},
				execute = {
					{
						"expect",{"#4#","==","&vehicleguid&"},
						"quash","presurgewarn",
						"alert","surgewarn",
					},
				},
			},
			-- Static field
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 57430,
				execute = {
					{
						"alert","staticfieldwarn",
					},
				},
			},
			-- Yells
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["I had hoped to end your lives quickly"]},
						"quash","vortexdur",
						"quash","vortexcd",
						"quash","powersparkcd",
						"set",{phase = 2},
						"alert","deepbreathwarn",
					},
					{
						"expect",{"#1#", "find", L.chat_northrend["ENOUGH!"]},
						"quash","deepbreathwarn",
						"set",{phase = 3},
					},
				},
			},
			-- Emotes
			{
				type = "event",
				event = "CHAT_MSG_RAID_BOSS_EMOTE",
				execute = {
					{
						"expect",{"<phase>","==","1"},
						"quash","powersparkcd",
						"alert","powersparkcd",
					},
					{
						"expect",{"<phase>","==","2"},
						"alert","deepbreathwarn",
					},
				},
			},
			-- Whispers
			{
				type = "event",
				event = "WHISPER",
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["fixes his eyes on you!$"]},
						"alert","presurgewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- SARTHARION
---------------------------------

do

	local L_Sartharion = L.npc_northrend["Sartharion"]
	local L_Vesperon = L.npc_northrend["Vesperon"]
	local L_Shadron = L.npc_northrend["Shadron"]
	local L_Tenebron = L.npc_northrend["Tenebron"]

	local data = {
		version = 300,
		key = "sartharion",
		zone = L.zone["The Obsidian Sanctum"],
		category = L.zone["Northrend"],
		name = L.npc_northrend["Sartharion"],
		triggers = {
			scan = {
				28860, -- Sartharion
				30452, -- Tenebron
				30451, -- Shadron
				30449, -- Vesperon
			},
		},
		onactivate = {
			tracing = {28860}, -- Sartharion
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 28860,
		},
		userdata = {
			tenebronarrived = 0,
			shadronarrived = 0,
			vesperonarrived = 0,
			tenebrontimer = 0,
			shadrontimer = 0,
			vesperontimer = 0,
		},
		onstart = {
			{
				"alert","lavawallcd",
			}
		},
		timers = {
			updatetracers = {
				-- Tenebron, Shadron, Vesperon
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 0 1"},
					"tracing",{28860,30449}, -- Sartharion, Vesperon
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 1 0"},
					"tracing",{28860,30451}, -- Sartharion, Shadron
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 1 1"},
					"tracing",{28860,30451,30449}, -- Sartharion, Shadron, Vesperon
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 0 0"},
					"tracing",{28860,30452}, -- Sartharion, Tenebron
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 0 1"},
					"tracing",{28860,30452,30449}, -- Sartharion, Tenebron, Vesperon
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 1 0"},
					"tracing",{28860,30452,30451}, -- Sartharion, Tenebron, Shadron
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 1 1"},
					"tracing",{28860,30452,30451,30449}, -- Sartharion, Tenebron, Shadron, Vesperon
				},
			},
		},
		alerts = {
			lavawallcd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Lava Wall"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Lava Wall"]),
				time = 25,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "ORANGE",
				icon = ST[43114],
			},
			lavawallwarn = {
				varname = format(L.alert["%s Casting"],L.alert["Lava Wall"]),
				type = "centerpopup",
				text = format(L.alert["Incoming %s"],L.alert["Lava Wall"]).."!",
				time = 5,
				sound = "ALERT1",
				color1 = "RED",
				color2 = "ORANGE",
				flashscreen = true,
				icon = ST[43114],
			},
			shadowfissurewarn = {
				varname = format(L.alert["%s Warning"],SN[59127]),
				type = "simple",
				text = format(L.alert["%s Spawned"],SN[59127]).."!",
				sound = "ALERT2",
				color1 = "PURPLE",
				time = 1.5,
				icon = ST[59127],
			},
			flamebreathwarn = {
				varname = format(L.alert["%s Casting"],SN[56908]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[56908]),
				time = 2,
				color1 = "DCYAN",
				sound = "ALERT4",
				icon = ST[56908],
			},
			shadronarrivescd = {
				type = "dropdown",
				varname = format(L.alert["%s Arrival"],L_Shadron),
				text = format(L.alert["%s Arrives"],L_Shadron),
				time = 80,
				color1 = "DCYAN",
				icon = ST[58105],
			},
			tenebronarrivescd = {
				type = "dropdown",
				varname = format(L.alert["%s Arrival"],L_Tenebron),
				text = format(L.alert["%s Arrives"],L_Tenebron),
				time = 30,
				color1 = "CYAN",
				icon = ST[61248],
			},
			vesperonarrivescd = {
				type = "dropdown",
				varname = format(L.alert["%s Arrival"],L_Vesperon),
				text = format(L.alert["%s Arrives"],L_Vesperon),
				time = 120,
				color1 = "GREEN",
				icon = ST[61251],
			},
		},
		events = {
			-- Shadow fissure
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {59127,57579},
				execute = {
					{
						"alert","shadowfissurewarn",
					},
				},
			},
			-- Lava wall
			{
				type = "event",
				event = "CHAT_MSG_RAID_BOSS_EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["lava surrounding"]},
						"alert","lavawallwarn",
						"alert","lavawallcd",
					},
				},
			},
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Tenebron
					{
						"expect",{"#1#","find",L.chat_northrend["It is amusing to watch you struggle. Very well, witness how it is done."]},
						"set",{tenebronarrived = 1},
						"scheduletimer",{"updatetracers",0},
					},
					-- Shadron
					{
						"expect",{"#1#","find",L.chat_northrend["I will take pity on you, Sartharion, just this once"]},
						"set",{shadronarrived = 1},
						"scheduletimer",{"updatetracers",0},
					},
					-- Vesperon
					{
						"expect",{"#1#","find",L.chat_northrend["Father was right about you, Sartharion, you ARE a weakling."]},
						"set",{vesperonarrived = 1},
						"scheduletimer",{"updatetracers",0},
					},
				},
			},
			-- Flame Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {56908,58956},
				execute = {
					{
						"alert","flamebreathwarn",
					},
				},
			},
			-- Drake Arrivals
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {58105, 61248, 61251},
				execute = {
					{
						-- Shadron
						"expect",{"#7# <shadrontimer>","==","58105 0"},
						"set",{shadrontimer = 1},
						"alert","shadronarrivescd",
					},
					{
						-- Tenebron
						"expect",{"#7# <tenebrontimer>","==","61248 0"},
						"set",{tenebrontimer = 1},
						"alert","tenebronarrivescd",
					},
					{
						-- Vesperon
						"expect",{"#7# <vesperontimer>","==","61251 0"},
						"set",{vesperontimer = 1},
						"alert","vesperonarrivescd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- TORAVON
---------------------------------

do
	local data = {
		version = 3,
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
			frostbitetext = "",
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
			frostbitedur = {
				varname = format(L.alert["%s Duration"],SN[72098]),
				type = "centerpopup",
				text = "<frostbitetext>",
				time = 20,
				color1 = "INDIGO",
				icon = ST[72098],
			},
		},
		events = {
			-- Frostbite
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72004, -- 10
					72098, -- 25
				},
				execute = {
					{
						"quash","frostbitedur",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{frostbitetext = format("%s: %s!",SN[72098],L.alert["YOU"])},
						"alert","frostbitedur",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{frostbitetext = format("%s: #5#!",SN[72098])},
						"alert","frostbitedur",
					},
				},
			},
			-- Frostbite applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					72004, -- 10
					72098, -- 25
				},
				execute = {
					{
						"quash","frostbitedur",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{frostbitetext = format("%s: %s! %s!",SN[72098],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","frostbitedur",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{frostbitetext = format("%s: #5#! %s!",SN[72098],format(L.alert["%s Stacks"],"#11#")) },
						"alert","frostbitedur",
					},
				},
			},
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
