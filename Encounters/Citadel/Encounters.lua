local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- BLOOD PRINCES
---------------------------------

do
	-- TODO: Empowered Shock cooldown for 10, 25, and 10h
	local data = {
		version = 20,
		key = "bloodprincecouncil",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Blood Princes"],
		triggers = {
			scan = {
				37970, -- Valanar
				37972, -- Keleseth
				37973, -- Taldaram
			},
		},
		onactivate = {
			combatstop = true,
			tracerstart = true,
			--[[
			tracing = {
				37970, -- Valanar
				37972, -- Keleseth
				37973, -- Taldaram
			},
			]]
			unittracing = {
				"boss3", -- Valanar
				"boss2",
				"boss1",
			},
			defeat = {
				37970, -- Valanar
				37972, -- Keleseth
				37973, -- Taldaram
			},
		},
		userdata = {
			invocationtime = {33,46.5,loop = false, type = "series"},
			shocktext = "",
			empoweredtime = 10,
			prisontext = "",
		},
		onstart = {
			{
				"alert","invocationcd",
				"alert","empoweredshockcd",
				"set",{empoweredtime = 20},
			},
		},
		alerts = {
			invocationwarn = {
				varname = format(L.alert["%s Warning"],SN[70982]),
				type = "simple",
				text = format("%s: #5#! %s!",L.alert["Invocation"],L.alert["SWAP"]),
				time = 3,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[70982],
			},
			invocationcd = {
				varname = format(L.alert["%s Cooldown"],SN[70982]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Invocation"]),
				time = "<invocationtime>",
				flashtime = 10,
				color1 = "MAGENTA",
				sound = "ALERT3",
				icon = ST[70982],
			},
			empoweredshockwarn = {
				varname = format(L.alert["%s Casting"],SN[73037]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[73037]),
				time = 4.5,
				flashtime = 4.5,
				color1 = "GREY",
				sound = "ALERT2",
				icon = ST[73037],
				flashscreen = true,
			},
			empoweredshockcd = {
				varname = format(L.alert["%s Cooldown"],SN[73037]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[73037]),
				time = "<empoweredtime>",
				flashtime = 5,
				color1 = "BLACK",
				sound = "ALERT5",
				icon = ST[73037],
			},
			shockwarn = {
				varname = format(L.alert["%s Cast"],SN[72037]),
				type = "simple",
				text = "<shocktext>",
				time = 6,
				color1 = "BLACK",
				sound = "ALERT4",
				icon = ST[72037],
			},
			infernoself = {
				varname = format(L.alert["%s on self"],L.alert["Inferno Flame"]),
				type = "simple",
				text = format("%s: %s! %s!",SN[39941],L.alert["YOU"],L.alert["RUN"]),
				time = 3,
				color1 = "ORANGE",
				icon = ST[62910],
				flashscreen = true,
			},
			infernowarn = {
				varname = format(L.alert["%s on others"],L.alert["Inferno Flame"]),
				type = "simple",
				text = format("%s: #5#! %s!",SN[39941],L.alert["MOVE AWAY"]),
				time = 3,
				color1 = "ORANGE",
				icon = ST[62910],
				flashscreen = true,
			},
			shadowprisonself = {
				varname = format(L.alert["%s on self"],SN[72999]),
				type = "centerpopup",
				text = "<prisontext>",
				time = 10,
				color1 = "PURPLE",
				icon = ST[72999],
			},
			kineticbombwarn = {
				varname = format(L.alert["%s Cast"],SN[72080]),
				type = "simple",
				text = format(L.alert["%s Cast"],SN[72080]),
				time = 3,
				sound = "ALERT6",
				color1 = "GOLD",
				icon = ST[72080],
			},
			kineticbombcd = {
				varname = format(L.alert["%s Cooldown"],SN[72080]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[72080]),
				time = 17.7,
				flashtime = 10,
				color1 = "YELLOW",
				icon = ST[72080],
			},
		},
		arrows = {
			infernoarrow = {
				varname = L.alert["Inferno Flame"],
				unit = "#5#",
				persist = 10,
				action = "TOWARD",
				msg = L.alert["MOVE TOWARD"],
				spell = L.alert["Inferno Flame"],
			},
			shockarrow = {
				varname = SN[72037],
				unit = "&tft_unitname&",
				persist = 7,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[72037],
				fixed = true,
			},
		},
		windows = {
			proxwindow = true,
		},
		raidicons = {
			shockmark = {
				varname = SN[72037],
				type = "FRIENDLY",
				persist = 5,
				unit = "&tft_unitname&",
				icon = 1,
			},
			infernomark = {
				varname = L.alert["Inferno Flame"],
				type = "FRIENDLY",
				persist = 7.5,
				unit = "#5#",
				icon = 2,
			},
		},
		announces = {
			shocksay = {
				varname = format(L.alert["Say %s on self"],SN[72037]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[72037]).."!",
			},
			infernosay = {
				varname = format(L.alert["Say %s on self"],L.alert["Inferno Flame"]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],L.alert["Inferno Flame"]).."!",
			},
		},
		timers = {
			fireshock = {
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 1"},
					"set",{shocktext = format("%s: %s!",SN[72037],L.alert["YOU"])},
					"raidicon","shockmark",
					"alert","shockwarn",
					"announce","shocksay",
				},
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 nil"},
					"set",{shocktext = format("%s: &tft_unitname&!",SN[72037])},
					"raidicon","shockmark",
					"alert","shockwarn",
					"proximitycheck",{"&tft_unitname&",28},
					"arrow","shockarrow",
				},
				{
					"expect",{"&tft_unitexists&","==","nil"},
					"set",{shocktext = format(L.alert["%s Cast"],SN[72037])},
					"alert","shockwarn",
				},
			},
		},
		events = {
			-- Shadow Prison
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 72999,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{prisontext = format("%s: %s!",SN[72999],L.alert["YOU"])},
						"alert","shadowprisonself",
					},
				},
			},
			-- Shadow Prison applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 72999,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{prisontext = format("%s: %s! %s!",SN[72999],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"quash","shadowprisonself",
						"alert","shadowprisonself",
					},
				},
			},
			-- Shadow Prison removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 72999,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","shadowprisonself",
					},
				},
			},

			-- Shock Vortex
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72037, -- 10/25 (Note the damage entries use a different spellid from the cast)
					71944, -- 10 (Not sure if we really need this at all)
				},
				execute = {
					{
						"scheduletimer",{"fireshock",0.2},
					},
				},
			},
			-- Inferno Flames
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^Empowered Flames speed"]},
						"raidicon","infernomark",
						"expect",{"#5#","==","&playername&"},
						"alert","infernoself",
						"announce","infernosay",
					},
					{
						"expect",{"#1#","find",L.chat_citadel["^Empowered Flames speed"]},
						"expect",{"#5#","~=","&playername&"},
						"alert","infernowarn",
						"arrow","infernoarrow",
					},
				},
			},
			-- Invocation of Blood
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70952, -- Valanar
					70982, -- Taldaram
					70981, -- Keleseth
					70983,
					71582,
					70934,
					71596,
				},
				execute = {
					{
						"alert","invocationcd",
						"alert","invocationwarn",
					},
					{
						"expect",{"&npcid|#4#&","==","37970"}, -- Valanar
						"set",{empoweredtime = 6},
						"alert","empoweredshockcd",
						"set",{empoweredtime = 20},
					},
					{
						"expect",{"&npcid|#4#&","~=","37970"}, -- Valanar
						"quash","empoweredshockcd",
					},
				}
			},
			-- Empowered Shock
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					73037, -- 25
					73039, -- 25h
					72039, -- 10
					73038, -- 10h
				},
				execute = {
					{
						"quash","empoweredshockcd",
						"alert","empoweredshockcd",
						"alert","empoweredshockwarn",
					},
				},
			},
			-- Kinetic Bomb
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#2#","==",SN[72080]},
						"alert","kineticbombwarn",
						"alert","kineticbombcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- DEATHWHISPER
---------------------------------

do
	local data = {
		version = 31,
		key = "deathwhisper",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Deathwhisper"],
		triggers = {
			scan = {
				36855, -- Lady Deathwhisper
			},
			yell = L.chat_citadel["^What is this disturbance"],
		},
		userdata = {
			culttime = {7,60,loop = false, type = "series"},
			insignificancetext = "",
			dominatetext = format("%s: #5#!",SN[71289]),
			dominatetime = {38.6,40.4,loop = false,type = "series"},
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"},
				"set",{culttime = {7,45,loop = false, type = "series"}},
			},
			{
				"alert","cultcd",
				"alert","enragecd",
				"scheduletimer",{"firecult",7},
			},
			{
				"expect",{"&difficulty&",">","1"},
				"alert","dominatecd",
			},
		},
		timers = {
			firecult = {
				{
					"alert","cultcd",
					"scheduletimer",{"firecult","<culttime>"},
				},
			},
		},
		onactivate = {
			combatstop = true,
			tracing = {36855,powers={true}}, -- Lady Deathwhisper
			defeat = 36855, -- Lady Deathwhisper
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			dndself = {
				varname = format(L.alert["%s on self"],SN[71001]),
				text = format("%s: %s!",SN[71001],L.alert["YOU"]),
				type = "simple",
				time = 3,
				sound = "ALERT1",
				color1 = "GREEN",
				icon = ST[71001],
				flashscreen = true,
			},
			martyrdomwarn = {
				varname = format(L.alert["%s Casting"],SN[72500]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[72500]),
				time = 4,
				color1 = "WHITE",
				sound = "ALERT9",
				icon = ST[72500],
			},
			cultcd = {
				varname = format(L.alert["%s Spawns"],L.alert["Cult"]),
				text = format(L.alert["%s Spawns"],L.alert["Cult"]),
				type = "dropdown",
				time = "<culttime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "BROWN",
				icon = ST[61131],
			},
			manabarrierwarn = {
				varname = format(L.alert["%s Removal"],SN[70842]),
				text = format(L.alert["%s Removed"],SN[70842]).."!",
				type = "simple",
				time = 3,
				sound = "ALERT3",
				color1 = "TEAL",
				icon = ST[70842],
			},
			summonspiritwarn = {
				varname = format(L.alert["%s Warning"],SN[71426]),
				text = SN[71426].."! "..L.alert["CAREFUL"].."!",
				type = "simple",
				time = 5,
				sound = "ALERT8",
				color1 = "BLACK",
				icon = ST[71426],
				throttle = 3,
			},
			insignificancewarn = {
				varname = format(L.alert["%s Warning"],SN[71204]),
				text = "<insignificancetext>",
				type = "simple",
				time = 3,
				sound = "ALERT4",
				color1 = "TAN",
				icon = ST[71204],
			},
			torporself = {
				varname = format(L.alert["%s on self"],SN[71237]),
				text = format("%s: %s!",SN[71237],L.alert["YOU"]),
				type = "simple",
				time = 3,
				color1 = "PURPLE",
				sound = "ALERT5",
				icon = ST[71237],
			},
			torporwarn = {
				varname = format(L.alert["%s on others"],SN[71237]),
				text = format("%s: #5#!",SN[71237]),
				type = "simple",
				time = 3,
				color1 = "PURPLE",
				sound = "ALERT5",
				icon = ST[71237],
			},
			dominatewarn = {
				varname = format(L.alert["%s Warning"],SN[71289]),
				text = "<dominatetext>",
				type = "simple",
				time = 3,
				color1 = "GREY",
				sound = "ALERT6",
				icon = ST[71289],
				throttle = 3,
			},
			dominatecd = {
				varname = format(L.alert["%s Cooldown"],SN[71289]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71289]),
				time = "<dominatetime>",
				flashtime = 10,
				color1 = "INDIGO",
				icon = ST[71289],
				throttle = 3,
			},
			frostboltwarn = {
				varname = format(L.alert["%s Casting"],SN[72007]),
				text = format(L.alert["%s Casting"],SN[72007]),
				type = "centerpopup",
				time = 2,
				color1 = "BLUE",
				sound = "ALERT7",
				icon = ST[72007],
			},
		},
		raidicons = {
			dominatemark = {
				varname = SN[71289],
				type = "MULTIFRIENDLY",
				persist = 10,
				reset = 5,
				unit = "#5#",
				icon = 1,
				total = 3,
			},
		},
		events = {
			-- Dark Martyrdom
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72500, -- 25h Cult Adherent
					72497, -- 25h Cult Fanatic
					72498, -- 25 Cult Adherent
					72495, -- 25 Cult Fanatic
					72499, -- 10h Cult Adherent
					72496, -- 10h Cult Fanatic
				},
				execute = {
					{
						"alert","martyrdomwarn",
					},
				},
			},
			-- Summon Spirit
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {
					71426, -- 10,10h,25,25h
				},
				execute = {
					{
						"alert","summonspiritwarn",
					},
				},
			},
			-- Death and Decay self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71001, -- 10
					72109, -- 10h
					72108, -- 25
					72110, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","dndself",
					},
				},
			},
			-- Mana Barrier
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 70842,
				execute = {
					{
						"alert","manabarrierwarn",
						"expect",{"&difficulty&","<=","2"},
						"quash","cultcd",
						"canceltimer","firecult",
					},
				},
			},
			-- Touch of Insignificance
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71204,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{insignificancetext = format("%s: %s!",L.alert["Touch"],L.alert["YOU"])},
						"alert","insignificancewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{insignificancetext = format("%s: #5#!",L.alert["Touch"])},
						"alert","insignificancewarn",
					},
				},
			},
			-- Touch of Insignificance stacks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 71204,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{insignificancetext = format("%s: %s! %s!",L.alert["Touch"],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","insignificancewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{insignificancetext = format("%s: #5#! %s!",L.alert["Touch"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","insignificancewarn",
					},
				},
			},
			-- Curse of Torpor
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71237, -- 10/25
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","torporself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","torporwarn",
					},
				},
			},
			-- Dominate Mind
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71289,
				execute = {
					{
						"raidicon","dominatemark",
						"alert","dominatecd",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"invoke",{
							{
								"expect",{"&difficulty&","==","4"}, -- == 25h
								"set",{dominatetext = format(L.alert["%s Cast"],SN[71289])}
							},
							{
								"expect",{"&difficulty&","<=","3"}, -- < 25h
								"set",{dominatetext = format("%s: #5#!",SN[71289])},
							},
						},
						"alert","dominatewarn",
					},
				},
			},
			-- Frostbolt
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					71420, -- 10
					72501, -- 10h
					72007, -- 25
					72502, -- 25h
				},
				execute = {
					{
						"alert","frostboltwarn",
					},
				},
			},
			-- Frostbolt interrupt
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				spellid2 = {
					71420, -- 10
					72501, -- 10h
					72007, -- 25
					72502, -- 25h
				},
				execute = {
					{
						"quash","frostboltwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- FESTERGUT
---------------------------------

do
	local data = {
		version = 11,
		key = "festergut",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Festergut"],
		triggers = {
			scan = {36626}, -- Festergut
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36626}, -- Festergut
			defeat = 36626,
		},
		userdata = {
			inhaletime = {29, 33.5, loop = false, type = "series"}, -- placeholder
			sporetime = {21,40,40,51, loop = false, type = "series"}, -- placeholder
			pungenttime = {133, 138, loop = false, type = "series"},
			gastrictext = "",
		},
		onstart = {
			{
				"alert","gassporecd",
				"alert","inhaleblightcd",
				"alert","pungentblightcd",
				"alert","enragecd",
				"set",{sporetime = {40,40,40,51,loop = true, type = "series"}},
				"set",{inhaletime = {33.5,33.5,33.5,68, loop = true, type = "series"}},
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 300,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			inhaleblightcd = {
				varname = format(L.alert["%s Cooldown"],SN[69165]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[69165]),
				time = "<inhaletime>",
				color1 = "GREY",
				flashtime = 10,
				icon = ST[69165],
			},
			inhaleblightwarn = {
				varname = format(L.alert["%s Casting"],SN[69165]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[69165]),
				time = 3.5,
				flashtime = 3.5,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[69165],
			},
			gassporecd = {
				varname = format(L.alert["%s Cooldown"],SN[71221]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71221]),
				time = "<sporetime>",
				color1 = "YELLOW",
				flashtime = 5,
				icon = ST[71221],
			},
			gassporedur = {
				varname = format(L.alert["%s Duration"],SN[71221]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[71221]),
				time = 12,
				flashtime = 12,
				color1 = "MAGENTA",
				sound = "ALERT2",
				flashscreen = true,
				icon = ST[71221],
			},
			gassporeself = {
				varname = format(L.alert["%s on self"],SN[71221]),
				type = "simple",
				text = format("%s: %s!",SN[71221],L.alert["YOU"]).."!",
				time = 3,
				icon = ST[71221],
				throttle = 10,
			},
			vilegascd = {
				varname = format(L.alert["%s Cooldown"],SN[71218]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71218]),
				time = 20,
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[71288],
				throttle = 2,
			},
			vilegaswarn = {
				varname = format(L.alert["%s Warning"],SN[71218]),
				type = "simple",
				text = format(L.alert["%s Cast"],SN[71218]).."!",
				time = 3,
				color1 = "GREEN",
				sound = "ALERT3",
				icon = ST[71288],
				throttle = 2,
			},
			pungentblightwarn ={
				varname = format(L.alert["%s Casting"],SN[71219]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71219]),
				time = 3,
				flashtime = 3,
				color1 = "PURPLE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[71219],
			},
			pungentblightcd = {
				varname = format(L.alert["%s Cooldown"],SN[71219]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71219]),
				time = "<pungenttime>",
				color1 = "DCYAN",
				flashtime = 10,
				icon = ST[71219],
			},
			gastricbloatwarn = {
				varname = format(L.alert["%s Warning"],SN[72551]),
				type = "simple",
				text = "<gastrictext>",
				time = 3,
				color1 = "GOLD",
				icon = ST[72551],
			},
			malleablegoowarn = {
				varname = format(L.alert["%s Warning"],SN[72615]),
				type = "simple",
				text = format(L.alert["%s Cast"],SN[72615]),
				time = 3,
				sound = "ALERT6",
				color1 = "BLACK",
				icon = ST[72615],
				flashscreen = true,
				throttle = 2,
			},
		},
		windows = {
			proxwindow = true,
		},
		raidicons = {
			vilegasmark = {
				varname = SN[71307],
				type = "MULTIFRIENDLY",
				persist = 6,
				reset = 3,
				unit = "#5#",
				icon = 1,
				total = 5,
			},
			gassporemark = {
				varname = SN[69278],
				type = "MULTIFRIENDLY",
				persist = 12,
				reset = 5,
				unit = "#5#",
				icon = 6,
				total = 3,
			},
		},
		events = {
			-- Inhale Blight
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					69165, -- 25
				},
				execute = {
					{
						"alert","inhaleblightcd",
						"alert","inhaleblightwarn",
					},
				},
			},
			-- Gas Spore
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					71221, -- 25
					69278, -- 10
				},
				execute = {
					{
						"quash","gassporecd",
						"alert","gassporedur",
						"alert","gassporecd",
					},
				},
			},
			-- Gas Spore
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71221, -- 25
					69279, -- 10
				},
				execute = {
					{
						"raidicon","gassporemark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","gassporeself",
					},
				},
			},
			-- Vile Gas
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = { -- Note: Don't use 71307
					71218, -- 25
					69240, -- 10
					73020, -- 25h
				},
				execute = {
					{
						"quash","vilegascd",
						"alert","vilegascd",
						"alert","vilegaswarn",
					},
				},
			},
			-- Vile Gas applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71218, -- 25
					69240, -- 10
					73020, -- 25h
				},
				execute = {
					{
						"raidicon","vilegasmark",
					},
				},
			},
			-- Pungent Blight
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					71219, -- 25
					69195,
					73031,
					73032, -- 25h
				},
				execute = {
					{
						"alert","pungentblightcd",
						"alert","pungentblightwarn",
					},
				},
			},
			-- Gastric Bloat
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72551, -- 25
					72219, -- 10
					72553, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{gastrictext = format("%s: %s!",SN[72551],L.alert["YOU"])},
						"alert","gastricbloatwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{gastrictext = format("%s: #5#!",SN[72551])},
						"alert","gastricbloatwarn",
					},
				},
			},
			-- Gastric Bloat applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					72551, -- 25
					72219, -- 10
					72553, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{gastrictext = format("%s: %s! %s!",SN[72551],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","gastricbloatwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{gastrictext = format("%s: #5#! %s!",SN[72551],format(L.alert["%s Stacks"],"#11#")) },
						"alert","gastricbloatwarn",
					},
				},
			},
			-- Malleable Goo Summon Trigger
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#2#","==",SN[72310]},
						"alert","malleablegoowarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- GUNSHIP BATTLE
---------------------------------

do
	local faction = UnitFactionGroup("player")

	local prestart_trigger,start_trigger,defeat_msg,portal_msg,add,portal_icon,faction_npc
	if faction == "Alliance" then
		prestart_trigger = L.chat_citadel["^Fire up the engines! We got"]
		start_trigger = L.chat_citadel["^Cowardly dogs"]
		defeat_msg = L.chat_citadel["^Don't say I didn't warn ya"]
		portal_msg = L.chat_citadel["^Reavers, Sergeants, attack"]
		add = L.alert["Reaver"]
		portal_icon = "Interface\\Icons\\achievement_pvp_h_04"
		faction_npc = "36939" -- Saurfang
	elseif faction == "Horde" then
		prestart_trigger = L.chat_citadel["^Rise up, sons and daughters of the"]
		start_trigger = L.chat_citadel["^ALLIANCE GUNSHIP"]
		defeat_msg = L.chat_citadel["^The Alliance falter"]
		portal_msg = L.chat_citadel["^Marines, Sergeants, attack"]
		add = L.alert["Marine"]
		portal_icon = "Interface\\Icons\\achievement_pvp_a_04"
		faction_npc = "36948" -- Muradin
	end

	local data = {
		version = 12,
		key = "gunshipbattle",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Gunship Battle"],
		title = L.npc_citadel["Gunship Battle"],
		triggers = {
			scan = {
				36939, -- Saurfang
				36948, -- Muradin
			},
			yell = {
				prestart_trigger,
				start_trigger,
			},
		},
		onactivate = {
			combatstop = true,
			unittracing = {"boss1","boss2"},
			defeat = defeat_msg,
		},
		userdata = {
			portaltime = {11.5,60,loop = false, type = "series"},
			belowzerotime = {34,45,loop = false, type = "series"},
			battlefurytext = "",
		},
		onstart = {
			{
				"expect",{"#1#","find",prestart_trigger},
				"alert","zerotoonecd",
			},
			{
				"expect",{"#1#","find",start_trigger},
				"alert","portalcd",
				"alert","belowzerocd",
			},
		},
		alerts = {
			zerotoonecd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase One"]),
				type = "centerpopup",
				text = format(L.alert["%s Begins"],L.alert["Phase One"]),
				time = 45,
				flashtime = 20,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
			belowzerocd = {
				varname = format(L.alert["%s Cooldown"],SN[69705]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[69705]),
				time = "<belowzerotime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "INDIGO",
				icon = ST[69705],
			},
			belowzerowarn = {
				varname = format(L.alert["%s Channel"],SN[69705]),
				type = "centerpopup",
				text = format(L.alert["%s Channel"],SN[69705]),
				time = 900,
				flashtime = 900,
				color1 = "BLUE",
				sound = "ALERT5",
				icon = ST[69705],
			},
			portalcd = {
				varname = format(L.alert["%s Spawns"],add.."/"..L.alert["Sergeant"]),
				type = "dropdown",
				text = format(L.alert["%s Spawns"],add.."/"..L.alert["Sergeant"]),
				time = "<portaltime>",
				flashtime = 10,
				color1 = "GOLD",
				sound = "ALERT1",
				icon = portal_icon,
			},
			battlefurydur = {
				varname = format(L.alert["%s Duration"],SN[69638]),
				type = "centerpopup",
				text = "<battlefurytext>",
				time = 20,
				flashtime = 20,
				color1 = "ORANGE",
				icon = ST[69638],
			},
		},
		events = {
			-- Below Zero
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 69705,
				execute = {
					{
						"alert","belowzerowarn",
						"alert","belowzerocd",
					},
				},
			},
			-- Below Zero 2
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 69705,
				execute = {
					{
						"alert","belowzerowarn",
						"alert","belowzerocd",
					},
				},
			},
			-- Below Zero removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 69705,
				execute = {
					{
						"quash","belowzerowarn",
					},
				},
			},
			-- Portals
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",portal_msg},
						"alert","portalcd",
					},
				},
			},
			-- Battle Fury
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69638, -- 10
					72307, -- 10h
					72306, -- 25
					72308, -- 25h
				},
				execute = {
					{
						"expect",{"&npcid|#4#&","==",faction_npc},
						"set",{battlefurytext = format("%s: #2#!",SN[69638])},
						"alert","battlefurydur",
					},
				},
			},
			-- Battle Fury applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					69638, -- 10
					72307, -- 10h
					72306, -- 25
					72308, -- 25h
				},
				execute = {
					{
						"expect",{"&npcid|#4#&","==",faction_npc},
						"quash","battlefurydur",
						"set",{battlefurytext = format("%s => %s!",SN[69638], format(L.alert["%s Stacks"],"#11#"))},
						"alert","battlefurydur",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- LANATHEL
---------------------------------

do
	local data = {
		version = 23,
		key = "lanathel",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Lana'thel"],
		triggers = {
			scan = 37955, -- Lana'thel
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {37955}, -- Lana'thel
			defeat = 37955,
		},
		onstart = {
			{
				"expect",{"&difficulty&","==","1"},
				"set",{
					essencetime = 75,
					bloodtime = {127,120, loop = false, type = "series"},
					incitetime = {122,115, loop = false, type = "series"},
				},
			},
			{
				"expect",{"&difficulty&","==","3"},
				"set",{
					essencetime = 75,
					bloodtime = {127,120, loop = false, type = "series"},
					incitetime = {122,115, loop = false, type = "series"},
				},
			},
			{
				"alert","enragecd",
				"alert","bloodboltcd",
				"alert","inciteterrorcd",
				"alert","pactcd",
				"alert","swarmingshadowcd",
			},
		},
		userdata = {
			bloodtime = {133,100, loop = false, type = "series"},
			incitetime = {128,95, loop = false, type = "series"},
			firedblood = "0",
			essencetime = 60,
			pacttime = {15,30,loop = false, type = "series"},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 320,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			essenceself = {
				varname = format(L.alert["%s on self"],L.alert["Essence"]),
				type = "centerpopup",
				text = format("%s: %s!",L.alert["Essence"],L.alert["YOU"]),
				time = "<essencetime>",
				flashtime = 10,
				color1 = "PURPLE",
				color2 = "MAGENTA",
				icon = ST[71473]
			},
			pactself = {
				varname = format(L.alert["%s on self"],L.alert["Pact"]),
				type = "simple",
				text = format("%s: %s! %s!",L.alert["Pact"],L.alert["YOU"],L.alert["MOVE"]),
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[71340],
			},
			pactremovalself = {
				varname = format(L.alert["%s on self"],format(L.alert["%s Removal"],L.alert["Pact"])),
				type = "simple",
				text = format(L.alert["%s Removed"],L.alert["Pact"]).."! "..L.alert["YOU"].."!",
				time = 3,
				color1 = "GOLD",
				sound = "ALERT4",
				flashscreen = true,
				icon = ST[71340],
			},
			bloodboltcd = {
				varname = format(L.alert["%s Cooldown"],SN[71772]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71772]),
				time = "<bloodtime>",
				color1 = "BROWN",
				sound = "ALERT2",
				flashtime = 10,
				icon = ST[71772],
			},
			bloodboltdur = {
				varname = format(L.alert["%s Duration"],SN[71772]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[71772]),
				time = 6,
				flashtime = 6,
				color1 = "YELLOW",
				sound = "ALERT3",
				icon = ST[71772],
			},
			swarmingshadowself = {
				varname = format(L.alert["%s on self"],SN[71265]),
				type = "centerpopup",
				text = format("%s: %s!",SN[71265],L.alert["YOU"]),
				time = 8.5,
				flashtime = 8.5,
				color1 = "BLACK",
				color2 = "GREEN",
				flashscreen = true,
				icon = ST[71265],
			},
			swarmingshadowothers = {
				varname = format(L.alert["%s on others"],SN[71265]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[71265]),
				time = 8.5,
				flashtime = 8.5,
				color1 = "BLACK",
				icon = ST[71265],
			},
			pactcd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Pact"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Pact"]),
				time = "<pacttime>",
				flashtime = 5,
				color1 = "BLACK",
				sound = "ALERT5",
				icon = ST[71340],
			},
			swarmingshadowcd = {
				varname = format(L.alert["%s Cooldown"],SN[71265]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71265]),
				time = 30,
				flashtime = 5,
				color1 = "INDIGO",
				icon = ST[71265],
			},
			inciteterrorcd = {
				varname = format(L.alert["%s Cooldown"],SN[73070]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[73070]),
				time = "<incitetime>",
				sound = "ALERT6",
				flashtime = 10,
				color1 = "GREY",
				icon = ST[73070],
			},
		},
		windows = {
			proxwindow = true,
		},
		events = {
			-- Swarming Shadows early
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^Shadows amass and swarm"]},
						"quash","swarmingshadowcd",
						"alert","swarmingshadowcd",
						-- Swarming Shadows self
						"expect",{"#5#","==","&playername&"},
						"alert","swarmingshadowself",
					},
					{
						-- Swarming Shadows others
						"expect",{"#1#","find",L.chat_citadel["^Shadows amass and swarm"]},
						"expect",{"#5#","~=","&playername&"},
						"alert","swarmingshadowothers",
					},
				},
			},
			-- Swarming Shadows others removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 71265,
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","swarmingshadowothers",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","swarmingshadowself",
					},
				},
			},
			-- Pact of the Darkfallen
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 71336, -- 10/25
				execute = {
					{
						"alert","pactcd",
					},
				},
			},
			-- Pact of the Darkfallen applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71340, -- 10/10h/25/25h
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","pactself",
					},
				},
			},
			-- Pact of the Darkfallen removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 71340,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","pactremovalself",
					},
				},
			},
			-- Essence of the Blood Queen
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71473,
					71525,
					70867, -- 10
					71533, -- 25h
					71532, -- 10h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","essenceself",
					},
				},
			},
			-- Bloodbolt Whirl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71772,
				execute = {
					{
						"quash","bloodboltcd",
						"alert","bloodboltdur",
						"expect",{"<firedblood>","==","0"},
						"alert","bloodboltcd",
						"alert","inciteterrorcd",
						"set",{firedblood = 1},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- LICH KING
---------------------------------

do
	local data = {
		version = 52,
		key = "lichking",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Lich King"],
		triggers = {
			scan = 36597, -- Lich King
			yell = L.chat_citadel["^So the Light's vaunted justice has finally arrived"],
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {
				36597, -- Lich King
			},
		},
		onstart = {
			{
				"expect",{"#1#","find",L.chat_citadel["^So the Light's vaunted justice has finally arrived"]},
				"set",{phase = "RP"},
				"alert","zerotoonecd",
			},
			-- backup tracerstart
			{
				"expect",{"<phase>","==","0"},
				"alert","enragecd",
				"alert","infestcd",
				"alert","necroplaguecd",
			},
		},
		userdata = {
			phase = "0",
			nextphase = {"T","2","T","3",loop = false, type = "series"},
			defiletext = "",
			defiletime = 37,
			infesttime = 6,
			soulreapertime = 41,
			valkyrtime = {20,47,loop = false, type = "series"},
			harvesttime = {12.5,75,loop = false, type = "series"},
			viletime = {18.9,30.5, loop = false, type = "series"}, -- most of the time it's 20.5 initially
			harvestsoultext = "",
			ragingtext = "",
			enragecount = 0,
			traptext = "",
		},
		alerts = {
			zerotoonecd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase One"]),
				type = "centerpopup",
				text = format(L.alert["%s Begins"],L.alert["Phase One"]),
				time = 53.5,
				flashtime = 20,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 900,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			necroplaguecd = {
				varname = format(L.alert["%s Cooldown"],SN[70337]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[70337]),
				time = 30,
				flashtime = 10,
				color1 = "MAGENTA",
				icon = ST[70337],
			},
			necroplaguedur = {
				varname = format(L.alert["%s Duration"],SN[70337]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[70338]),
				time = 5,
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[70337],
			},
			necroplagueself = {
				varname = format(L.alert["%s on self"],SN[70337]),
				type = "centerpopup",
				text = format("%s: %s!",SN[70337],L.alert["YOU"]).."!",
				time = 5,
				flashtime = 5,
				color1 = "GREEN",
				sound = "ALERT10",
				icon = ST[70337],
				flashscreen = true,
			},
			shamblinghorrorwarn = {
				varname = format(L.alert["%s Warning"],L.npc_citadel["Shambling Horror"]),
				type = "centerpopup",
				text = SN[70372].."!",
				time = 1,
				color1 = "WHITE",
				icon = ST[70372],
			},
			shamblinghorrorcd = {
				varname = format(L.alert["%s Cooldown"],L.npc_citadel["Shambling Horror"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.npc_citadel["Shambling Horror"]),
				time = 60,
				flashtime = 10,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[70372],
			},
			shamblinghorrorenragewarn = {
				varname = format(L.alert["%s Warning"],format("%s %s",L.npc_citadel["Shambling Horror"],SN[72143])),
				type = "simple",
				text = format("%s: %s",SN[72143],L.npc_citadel["Shambling Horror"]),
				time = 6,
				color1 = "PEACH",
				icon = ST[72143],
			},
			defilewarn = {
				varname = format(L.alert["%s Casting"],SN[72762]),
				type = "centerpopup",
				text = "<defiletext>",
				time = 2,
				flashtime = 2,
				color1 = "PURPLE",
				flashscreen = true,
				sound = "ALERT2",
				icon = ST[72762],
			},
			defileself = {
				varname = format(L.alert["%s on self"],SN[72762]),
				type = "simple",
				text = format("%s: %s! %s!",SN[72762],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				flashscreen = true,
				sound = "ALERT3",
				icon = ST[72762],
			},
			defilecd = {
				varname = format(L.alert["%s Cooldown"],SN[72762]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[72762]),
				time = "<defiletime>",
				flashtime = 10,
				color1 = "PURPLE",
				icon = ST[72762],
			},
			remorsewarn = {
				varname = format(L.alert["%s Warning"],SN[68981]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[68981]),
				time = 2.5,
				color1 = "INDIGO",
				sound = "ALERT4",
				icon = ST[68981],
			},
			remorsedur = {
				varname = format(L.alert["%s Duration"],SN[68981]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[68981]),
				time = 60,
				flashtime = 10,
				color1 = "BLUE",
				icon = ST[68981],
			},
			quakewarn = {
				varname = format(L.alert["%s Warning"],SN[72262]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[72262]),
				time = 1.5,
				color1 = "CYAN",
				sound = "ALERT5",
				icon = ST[72262],
			},
			valkyrwarn = {
				varname = format(L.alert["%s Warning"],SN[69037]),
				type = "simple",
				text = SN[71843].."!",
				time = 4,
				sound = "ALERT6",
				icon = ST[71843],
				throttle = 5,
			},
			valkyrcd = {
				varname = format(L.alert["%s Cooldown"],SN[69037]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[69037]),
				time = "<valkyrtime>",
				flashtime = 10,
				color1 = "BROWN",
				icon = ST[71843],
				throttle = 5,
			},
			soulreapercd = {
				varname = format(L.alert["%s Cooldown"],SN[69409]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[69409]),
				time = "<soulreapertime>",
				flashtime = 10,
				color1 = "ORANGE",
				icon = ST[69409],
			},
			soulreaperwarn = {
				varname = format(L.alert["%s Warning"],SN[69409]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[69409]),
				time = 5,
				color1 = "ORANGE",
				sound = "ALERT7",
				icon = ST[69409],
			},
			ragingspiritself = {
				varname = format(L.alert["%s on self"],SN[69200]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[69200],L.alert["YOU"],L.alert["MOVE"]),
				time = 7.5,
				color1 = "BLACK",
				sound = "ALERT8",
				flashscreen = true,
				icon = ST[69200],
			},
			ragingspiritwarn = {
				varname = format(L.alert["%s on others"],SN[69200]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[69200]),
				time = 7.5,
				color1 = "BLACK",
				sound = "ALERT8",
				icon = ST[69200],
			},
			infestcd = {
				varname = format(L.alert["%s Cooldown"],SN[70541]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[70541]),
				time = "<infesttime>",
				flashtime = 10,
				color1 = "YELLOW",
				icon = ST[70541],
			},
			infestwarn = {
				varname = format(L.alert["%s Warning"],SN[70541]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[70541]),
				time = 2,
				color1 = "YELLOW",
				sound = "ALERT3",
				icon = ST[70541],
			},
			vilespiritwarn = {
				varname = format(L.alert["%s Warning"],SN[70498]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[70498]),
				time = 5.5,
				color1 = "MAGENTA",
				sound = "ALERT9",
				icon = ST[70498],
			},
			vilespiritcd = {
				varname = format(L.alert["%s Cooldown"],SN[70498]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[70498]),
				time = "<viletime>",
				color1 = "PINK",
				icon = ST[70498],
			},
			harvestsoulwarn = {
				varname = format(L.alert["%s Warning"],SN[68980]),
				type = "simple",
				text = "<harvestsoultext>",
				time = 5,
				sound = "ALERT10",
				icon = ST[68980],
			},
			harvestsoulcd = {
				varname = format(L.alert["%s Cooldown"],SN[68980]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[68980]),
				time = "<harvesttime>",
				flashtime = 10,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[68980],
			},
			trapwarn = {
				varname = format(L.alert["%s Casting"],L.alert["Shadow Trap"]),
				type = "simple",
				text = "<traptext>",
				time = 3,
				color1 = "BLACK",
				sound = "ALERT8",
				icon = ST[73539],
				flashscreen = true,
			},
		},
		announces = {
			defilesay = {
				varname = format(L.alert["Say %s on self"],SN[72762]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[72762]).."!",
			},
			trapsay = {
				varname = format(L.alert["Say %s on self"],L.alert["Shadow Trap"]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],L.alert["Shadow Trap"]).."!",
			},
			necroplaguesay = {
				varname = format(L.alert["Say %s on self"],SN[70337]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[70337]).."!",
			},
		},
		raidicons = {
			defilemark = {
				varname = SN[72762],
				type = "FRIENDLY",
				persist = 5,
				unit = "&tft_unitname&",
				icon = 1,
			},
			trapmark = {
				varname = L.alert["Shadow Trap"],
				type = "FRIENDLY",
				persist = 6,
				unit = "&tft_unitname&",
				icon = 1,
			},
			ragingspiritmark = {
				varname = SN[69200],
				type = "FRIENDLY",
				persist = 7.5,
				unit = "#5#",
				icon = 2,
			},
			harvestmark = {
				varname = SN[68980],
				type = "FRIENDLY",
				persist = 6,
				unit = "#5#",
				icon = 3,
			},
			necroplaguemark = {
				varname = SN[70337],
				type = "FRIENDLY",
				persist = 15,
				unit = "#5#",
				icon = 4,
			},
			valkyrmark = {
				varname = SN[69037],
				type = "MULTIENEMY",
				persist = 10,
				reset = 8,
				unit = "#4#",
				icon = 5,
				total = 3,
			}
		},
		arrows = {
			defilearrow = {
				varname = SN[72762],
				unit = "&tft_unitname&",
				persist = 5,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[72762],
				fixed = true,
			},
			traparrow = {
				varname = L.alert["Shadow Trap"],
				unit = "&tft_unitname&",
				persist = 5,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = L.alert["Shadow Trap"],
				fixed = true,
			},
		},
		timers = {
			firedefile = {
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 1"},
					"set",{defiletext = format("%s: %s!",SN[72762],L.alert["YOU"])},
					"raidicon","defilemark",
					"alert","defilewarn",
					"announce","defilesay",
				},
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 nil"},
					"set",{defiletext = format("%s: &tft_unitname&!",SN[72762])},
					"raidicon","defilemark",
					--"arrow","defilearrow",
					"alert","defilewarn",
				},
				{
					"expect",{"&tft_unitexists&","==","nil"},
					"set",{defiletext = format(L.alert["%s Cast"],SN[72762])},
					"alert","defilewarn",
				},
			},
			firetrap = {
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 1"},
					"set",{traptext = format("%s: %s!",L.alert["Shadow Trap"],L.alert["YOU"])},
					"raidicon","trapmark",
					"alert","trapwarn",
					"announce","trapsay",
				},
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 nil"},
					"set",{traptext = format("%s: &tft_unitname&!",L.alert["Shadow Trap"])},
					"raidicon","trapmark",
					"arrow","traparrow",
					"alert","trapwarn",
				},
				{
					"expect",{"&tft_unitexists&","==","nil"},
					"set",{traptext = format(L.alert["%s Casting"],L.alert["Shadow Trap"])},
					"alert","trapwarn",
				},
			},
		},
		events = {
			-- Yell
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^I'll keep you alive to witness the end, Fordring"]},
						"set",{phase = "1"},
						-- just in case
						"quash","enragecd",
						"quash","infestcd",
						"quash","necroplaguecd",
						"alert","enragecd",
						"alert","infestcd",
						"alert","necroplaguecd",
					},
				},
			},
			-- Shadow Trap
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 73539, -- 10h, 25h
				execute = {
					{
						"scheduletimer",{"firetrap",0},
					},
				},
			},
			-- Necrotic Plague
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					70337, --10
					73912, --25
				},
				execute = {
					{
						"raidicon","necroplaguemark",
						"alert","necroplaguecd",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","necroplagueself",
						"announce","necroplaguesay",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","necroplaguedur",
					},
				},
			},
			-- Necrotic Plague dispel
			{
				type = "combatevent",
				eventtype = "SPELL_DISPEL",
				spellid2 = {
					-- Note: there are two different ones for some reason
					-- TODO: fix it when there are two bars. it could quash the wrong one
					70337, -- 10
					70338, -- 10h
					73785, -- 25
					73912, -- 25h
				},
				execute = {
					{
						"quash","necroplaguedur",
						"quash","necroplagueself",
					},
				},
			},
			-- Summon Shambling Horror
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 70372, -- 10/25
				execute = {
					{
						"alert","shamblinghorrorwarn",
					},
				},
			},
			-- Summon Shambling Horror cooldown
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = 70372, -- 10/25
				execute = {
					{
						"quash","shamblinghorrorwarn",
						"alert","shamblinghorrorcd",
					},
				},
			},
			-- Shambling Horror Enrage
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72143, -- 10
					72146, -- 25
					72148, -- 25h
				},
				execute = {
					{
						"alert","shamblinghorrorenragewarn",
						"set",{enragecount = "INCR|1"},
					},
				},
			},
			-- Shambling Horror Enrage removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					72143, -- 10
					72146, -- 25
				},
				execute = {
					{
						"set",{enragecount = "DECR|1"},
						"expect",{"<enragecount>","==","0"},
						"quash","shamblinghorrorenragewarn",
					},
				},
			},
			-- Defile
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72762, -- 10/25
					73708,
					73709,
					73710,
				},
				execute = {
					{
						"scheduletimer",{"firedefile",0.2},
						"set",{defiletime = 32},
						"alert","defilecd",
					},
				},
			},
			-- Defile self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72754, -- 10
					73709, -- 10h
					73708, -- 25
					73710, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","defileself",
					},
				},
			},
			-- Remorseless Winter
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					68981, -- 10 first
					72259, -- 10 second
					74270, -- 25 first
					74273, -- 25 second
					74271,
					74272,
					74274,
					74275,
				},
				execute = {
					{
						"alert","remorsewarn",
						"set",{phase = "<nextphase>"},
						"quash","necroplaguecd",
						"quash","defilecd",
						"quash","valkyrcd",
						"quash","infestcd",
						"quash","soulreapercd",
					},
				},
			},
			-- Remorseless Winter app
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					68981, -- 10 first
					72259, -- 10 second
					74270, -- 25
					74273, -- 25 second
					74271,
					74272,
					74274,
					74275,
				},
				execute = {
					{
						"quash","remorsewarn",
						"alert","remorsedur",
					},
				},
			},
			-- Quake
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 72262, -- 10/25
				execute = {
					{
						"alert","quakewarn",
						"set",{phase = "<nextphase>"},
						"set",{defiletime = 37},
						"alert","defilecd",
					},
					{
						"expect",{"<phase>","==","2"},
						"set",{infesttime = 13},
						"alert","infestcd",
						"alert","valkyrcd",
						"alert","soulreapercd",
					},
					{
						"expect",{"<phase>","==","3"},
						"alert","harvestsoulcd",
						"set",{soulreapertime = 30},
						"alert","soulreapercd",
					},
				},
			},
			-- Summon Val'kyr
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = 69037, -- 10/25
				execute = {
					{
						"alert","valkyrwarn",
						"alert","valkyrcd",
						"raidicon","valkyrmark",
					},
				},
			},
			-- Soul Reaper
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					69409, -- 10
					73797, -- 25
				},
				execute = {
					{
						"quash","soulreapercd",
						"alert","soulreaperwarn",
						"set",{soulreapertime = 30},
						"alert","soulreapercd",
					},
				},
			},
			-- Raging Spirit
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 69200, -- 10/25
				execute = {
					{
						"raidicon","ragingspiritmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","ragingspiritself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","ragingspiritwarn",
					},
				},
			},
			-- Infest
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					70541, -- 10
					73779, -- 25
					73780, -- 10h
					73781, -- 25h
				},
				execute = {
					{
						"quash","infestcd",
						"alert","infestwarn",
						"set",{infesttime = 22},
						"alert","infestcd",
					}
				},
			},
			-- Vile Spirits
			-- .5 second cast + 5 second channel
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 70498, -- 10/25
				execute = {
					{
						"quash","vilespiritcd",
						"alert","vilespiritwarn",
						"alert","vilespiritcd",
					}
				},
			},
			-- Harvest Soul
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					68980, -- 10
					74325, -- 25
					74326, -- 10h?
					74327, -- 25h?
				},
				execute = {
					{
						"raidicon","harvestmark",
						"alert","harvestsoulcd",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{harvestsoultext = format("%s: %s!",SN[68980],L.alert["YOU"])},
						"alert","harvestsoulwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{harvestsoultext = format("%s: #5#!",SN[68980])},
						"alert","harvestsoulwarn",
					},
				},
			}
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- MARROWGAR
---------------------------------

do
	local data = {
		version = 14,
		key = "marrowgar",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Marrowgar"],
		triggers = {
			scan = {36612}, -- Lord Marrowgar
			yell = L.chat_citadel["^The Scourge will wash over this world"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36612}, -- Lord Marrowgar
			defeat = 36612,
		},
		userdata = {
			bonetime = {45,90,loop = false, type = "series"},
			graveyardtime = {16,18.5,loop = true, type = "series"},
			bonedurtime = 18.5,
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"},
				"set",{bonedurtime = 34},
			},
			{
				"alert","graveyardcd",
				"alert","bonestormcd",
			},
		},
		alerts = {
			bonedachievementdur = {
				varname = format(L.alert["%s Achievement"],L.alert["Boned"]),
				type = "centerpopup",
				text = format(L.alert["%s Achievement"],L.alert["Boned"]),
				time = 8,
				flashtime = 8,
				color1 = "BLACK",
				icon = "Interface\\Icons\\Achievement_Boss_LordMarrowgar",
				throttle = 5,
			},
			bonestormwarn = {
				varname = format(L.alert["%s Casting"],SN[69076]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[69076]),
				time = 3,
				flashtime = 3,
				color1 = "GREEN",
				sound = "ALERT5",
				icon = ST[69076],
			},
			-- duration is underministic 36.1, 37.3, 42.6, 34.4
			bonestormdur = {
				varname = format(L.alert["%s Duration"],SN[69076]),
				type = "centerpopup",
				text = format(L.alert["%s Ends Soon"],SN[69076]),
				time = "<bonedurtime>",
				flashtime = 15,
				color1 = "BROWN",
				icon = ST[69075],
			},
			bonestormcd = {
				varname = format(L.alert["%s Cooldown"],SN[69076]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[69076]),
				time = "<bonetime>",
				flashtime = 10,
				color1 = "BLUE",
				sound = "ALERT1",
				icon = ST[69076],
			},
			coldflameself = {
				varname = format(L.alert["%s on self"],SN[70823]),
				type = "simple",
				text = format("%s: %s! %s!",SN[70823],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				color1 = "INDIGO",
				sound = "ALERT2",
				icon = ST[70823],
				flashscreen = true,
			},
			graveyardwarn = {
				varname = format(L.alert["%s Casting"],SN[70826]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[70826]),
				time = 3,
				flashtime = 3,
				color1 = "GREY",
				sound = "ALERT3",
				icon = ST[70826],
			},
			graveyardcd = {
				varname = format(L.alert["%s Cooldown"],SN[70826]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[70826]),
				time = "<graveyardtime>",
				flashtime = 7,
				color1 = "PURPLE",
				icon = ST[70826],
			},
		},
		arrows = {
			impalearrow = {
				varname = SN[69062],
				unit = "#2#",
				persist = 15,
				action = "TOWARD",
				msg = L.alert["KILL IT"],
				spell = SN[69062],
			},
		},
		raidicons = {
			impalemark = {
				varname = SN[69062],
				type = "MULTIFRIENDLY",
				persist = 15,
				reset = 3,
				unit = "#2#",
				icon = 1,
				total = 3,
			},
		},
		events = {
			-- Bone Storm cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					69076, -- 25 hard
				},
				execute = {
					{
						"alert","bonestormwarn",
						"expect",{"&difficulty&","<=","2"},
						"quash","graveyardcd",
					},
				},
			},
			-- Bone Storm duration and cooldown
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69076,
				},
				execute = {
					{
						"quash","bonestormcd",
						"alert","bonestormdur",
						"alert","bonestormcd",
					},
				},
			},
			-- Bone Storm removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					69076,
				},
				execute = {
					{
						"quash","bonestormdur",
					},
				},
			},
			-- Coldflame self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70823, -- 25
					70825, -- 25 hard
					69146, -- 10
					70824, -- 10 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","coldflameself",
					},
				},
			},
			-- Bone Spike Graveyard
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					70826, -- 25
					72089, -- 25 hard
					69057, -- 10
					73144, -- 10 hard
				},
				execute = {
					{
						"alert","graveyardwarn",
						"alert","graveyardcd",
					},
				},
			},
			-- Impale
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {
					69062, -- 10, 25
					72670, -- 10
				},
				execute = {
					{
						"alert","bonedachievementdur",
						"expect",{"#1#","~=","&playerguid&"},
						"raidicon","impalemark",
						"arrow","impalearrow",
					},
				},
			},
			-- Impale removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 69065, -- different spellid from SPELL_SUMMON
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"removeraidicon","#5#",
						"removearrow","#5#",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- PUTRICIDE
---------------------------------

do
	local data = {
		version = 35,
		key = "putricide",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Putricide"],
		triggers = {
			scan = {
				36678, -- Putricide
			},
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36678},
			defeat = 36678,
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","unstableexperimentcd",
				"alert","puddlecd",
				"set",{experimenttime = 37.5, puddletime = 35},
			},
		},
		userdata = {
			oozeaggrotext = {format(L.alert["%s Aggros"],L.npc_citadel["Volatile Ooze"]),format(L.alert["%s Aggros"],L.npc_citadel["Gas Cloud"]),loop = true, type = "series"},
			experimenttime = 25,
			malleabletime = 6,
			gasbombtime = 16,
			transitioned = "0",
			malleabletext = "",
			mutatedtext = "",
			puddletime = 10,
			puddletimeaftertransition = {10,15,loop = false, type = "series"},
			puddletimeperphase = {35,20,loop = false, type = "series"},
			plaguetimeaftertrans = {60,30,loop = false, type = "series"},
			plaguetime = 60,
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			unstableexperimentwarn = {
				varname = format(L.alert["%s Casting"],SN[71966]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71966]),
				sound = "ALERT1",
				color1 = "MAGENTA",
				time = 2.5,
				flashtime = 2.5,
				icon = ST[71966],
			},
			unstableexperimentcd = {
				varname = format(L.alert["%s Cooldown"],SN[71966]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71966]),
				time = "<experimenttime>",
				flashtime = 10,
				color1 = "PINK",
				icon = ST[71966],
			},
			mutatedslimeself = {
				varname = format(L.alert["%s on self"],SN[72456]),
				type = "simple",
				text = format("%s: %s!",SN[72456],L.alert["YOU"]),
				color1 = "GREEN",
				time = 3,
				sound = "ALERT2",
				icon = ST[72456],
				flashscreen = true,
				throttle = 4,
			},
			oozeaggrocd = {
				varname = format(L.alert["%s Timer"],format(L.alert["%s Aggros"],L.npc_citadel["Volatile Ooze"].."/"..L.npc_citadel["Gas Cloud"])),
				type = "centerpopup",
				text = "<oozeaggrotext>",
				color1 = "ORANGE",
				time = 8.5, -- 11 from Unstable Experiment Cast
				flashtime = 8.5,
				icon = ST[72218],
			},
			oozeadhesivecastwarn = {
				varname = format(L.alert["%s Casting"],SN[72836]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[72836]),
				time = 3,
				color1 = "DCYAN",
				icon = ST[72836],
			},
			oozeadhesiveappwarn = {
				varname = format(L.alert["%s on others"],SN[72836]),
				type = "simple",
				text = format("%s: #5#!",SN[72836]),
				color1 = "CYAN",
				sound = "ALERT3",
				time = 3,
				icon = ST[72836],
				flashscreen = true,
			},
			bloatcastwarn = {
				varname = format(L.alert["%s Casting"],SN[72455]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[72455]),
				time = 3,
				color1 = "BROWN",
				icon = ST[72455],
			},
			bloatappself = {
				varname = format(L.alert["%s on self"],SN[72455]),
				type = "simple",
				text = format("%s: %s! %s!",SN[72455],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				sound = "ALERT4",
				color1 = "BROWN",
				icon = ST[72455],
				flashscreen = true,
			},
			bloatappwarn = {
				varname = format(L.alert["%s on others"],SN[72455]),
				type = "simple",
				text = format("%s: #5#!",SN[72455]),
				time = 3,
				sound = "ALERT4",
				color1 = "BROWN",
				icon = ST[72455],
			},
			gasbombwarn = {
				varname = format(L.alert["%s Explodes"],SN[71255]),
				type = "centerpopup",
				text = format(L.alert["%s Explodes"],SN[71255]),
				time = 10,
				sound = "ALERT5",
				color1 = "YELLOW",
				icon = ST[71255],
			},
			gasbombcd = {
				varname = format(L.alert["%s Cooldown"],SN[71255]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71255]),
				time = "<gasbombtime>",
				flashtime = 5,
				color1 = "GOLD",
				icon = ST[71255],
			},
			malleablegoowarn = {
				varname = format(L.alert["%s Warning"],SN[72615]),
				type = "simple",
				text = "<malleabletext>",
				time = 3,
				sound = "ALERT6",
				color1 = "BLACK",
				icon = ST[72615],
			},
			malleablegoocd = {
				varname = format(L.alert["%s Cooldown"],SN[72615]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[72615]),
				time = "<malleabletime>",
				flashtime = 5,
				color1 = "GREY",
				icon = ST[72615],
			},
			teargaswarn = {
				varname = format(L.alert["%s Casting"],SN[71617]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71617]),
				time = 2.5,
				sound = "ALERT7",
				color1 = "INDIGO",
				icon = ST[71617],
			},
			teargasdur = {
				varname = format(L.alert["%s Duration"],SN[71617]),
				type = "centerpopup",
				text = format(L.alert["%s Ends Soon"],SN[71617]),
				time = 16,
				color1 = "INDIGO",
				icon = ST[71617],
			},
			mutatedwarn = {
				varname = format(L.alert["%s Warning"],SN[72463]),
				type = "simple",
				text = "<mutatedtext>",
				time = 3,
				sound = "ALERT8",
				icon = ST[72463],
			},
			puddlecd = {
				varname = format(L.alert["%s Cooldown"],SN[70343]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[70343]),
				time = "<puddletime>",
				flashtime = 10,
				color1 = "TAN",
				throttle = 10,
				icon = ST[70341],
			},
			unboundplagueself = {
				varname = format(L.alert["%s on self"],SN[72855]),
				type = "simple",
				text = format("%s: %s!",SN[72855],L.alert["YOU"]),
				time = 5,
				color1 = "WHITE",
				icon = ST[72855],
				flashscreen = true,
			},
			unboundplaguecd = {
				varname = format(L.alert["%s Cooldown"],SN[72855]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[72855]),
				time = "<plaguetime>",
				flashtime = 10,
				color1 = "MIDGREY",
				icon = ST[72855],
			},
			putricideaggrocd = {
				varname = format(L.alert["%s Aggros"],L.npc_citadel["Putricide"]),
				type = "centerpopup",
				text = format(L.alert["%s Aggros"],L.npc_citadel["Putricide"]),
				color1 = "PEACH",
				time = 10,
				flashtime = 10,
				color1 = "TAN",
				icon = "Interface\\Icons\\Achievement_Boss_ProfPutricide",
			},
		},
		raidicons = {
			oozeadhesivemark = {
				varname = SN[72836],
				type = "FRIENDLY",
				persist = 30,
				unit = "#5#",
				icon = 1,
			},
			gaseousbloatmark = {
				varname = SN[72455],
				type = "FRIENDLY",
				persist = 30,
				unit = "#5#",
				icon = 2,
			},
			malleablemark = {
				varname = SN[72615],
				type = "FRIENDLY",
				persist = 5,
				unit = "&tft_unitname&",
				icon = 3,
			},
			unboundplaguemark = {
				varname = SN[72855],
				type = "FRIENDLY",
				persist = 20,
				unit = "#5#",
				icon = 4,
			},
		},
		arrows = {
			malleablearrow = {
				varname = SN[72615],
				unit = "&tft_unitname&",
				persist = 5,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[72615],
				fixed = true,
			},
		},
		announces = {
			malleablegoosay = {
				varname = format(L.alert["Say %s on self"],SN[72615]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[72615]).."!",
			},
			plaguesay = {
				varname = format(L.alert["Say %s on self"],SN[72855]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[72855]).."!",
			},
		},
		timers = {
			fireoozeaggro = {
				{
					"alert","oozeaggrocd",
				},
			},
			firemalleable = {
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 1"},
					"set",{malleabletext = format("%s: %s!",SN[72615],L.alert["YOU"])},
					"raidicon","malleablemark",
					"alert","malleablegoowarn",
					"announce","malleablegoosay",
				},
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 nil"},
					"set",{malleabletext = format("%s: &tft_unitname&!",SN[72615])},
					"raidicon","malleablemark",
					"arrow","malleablearrow",
					"alert","malleablegoowarn",
				},
				{
					"expect",{"&tft_unitexists&","==","nil"},
					"set",{malleabletext = format(L.alert["%s Cast"],SN[72615])},
					"alert","malleablegoowarn",
				},
			},
			fireputraggro = {
				{
					"alert","putricideaggrocd",
				},
			},
			heroictrans = {
				{
					"set",{malleabletime = 6, experimenttime = 20, gasbombtime = 11, puddletime = "<puddletimeaftertransition>", plaguetime = "<plaguetimeaftertrans>"},
					"alert","malleablegoocd",
					"alert","gasbombcd",
					"alert","puddlecd",
					"alert","unboundplaguecd",
					"set",{malleabletime = 20, experimenttime = 37.5, gasbombtime = 35.5, puddletime = "<puddletimeperphase>", plaguetime = 60},
					"expect",{"<transitioned>","==","0"},
					"alert","unstableexperimentcd",
					"set",{transitioned = "1"},
				},
			},
		},
		events = {
			-- Slime Puddle
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					70341, -- 10/25
					70343, -- 10/25
				},
				execute = {
					{
						"alert","puddlecd",
					},
				},
			},
			-- Mutated Plague
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72463, -- 25
					72451, -- 10
					72671, -- 10h
					72672, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{mutatedtext = format("%s: %s!",SN[72463],L.alert["YOU"])},
						"alert","mutatedwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{mutatedtext = format("%s: #5#!",SN[72463])},
						"alert","mutatedwarn",
					},
				},
			},
			-- Mutated Plague stacks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					72463, -- 25
					72451, -- 10
					72672, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{mutatedtext = format("%s: %s! %s!",SN[72463],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","mutatedwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{mutatedtext = format("%s: #5#! %s!",SN[72463],format(L.alert["%s Stacks"],"#11#")) },
						"alert","mutatedwarn",
					},
				},
			},
			-- Malleable Goo
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					72615, -- 25
					72295, -- 10
					74280, -- 10h
					74281, -- 25h
				},
				execute = {
					{
						"quash","malleablegoocd",
						"alert","malleablegoocd",
						"scheduletimer",{"firemalleable",0.2},
					},
				},
			},
			-- Choking Gas Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 71255,
				execute = {
					{
						"quash","gasbombcd",
						"alert","gasbombwarn",
						"alert","gasbombcd",
					},
				},
			},
			-- Tear Gas
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71617, -- 10/25
				execute = {
					{
						"quash","puddlecd",
						"quash","oozeaggrocd", -- don't cancel timer
						"quash","malleablegoocd",
						"quash","unstableexperimentcd",
						"quash","gasbombcd",
						"alert","teargaswarn",
					},
				},
			},
			-- Volatile Experiment
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid ={
					72843, -- 25h
					72842, -- 10h
				},
				execute = {
					{
						"quash","puddlecd",
						"quash","oozeaggrocd", -- don't cancel timer
						"quash","malleablegoocd",
						"quash","unstableexperimentcd",
						"quash","gasbombcd",
						"quash","unboundplaguecd",
					},
				},
			},
			-- Tear Gas duration
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71615,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","teargasdur",
					},
				},
			},
			-- Tear Gas removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					71615, -- Tear Gas
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{malleabletime = 6, experimenttime = 20, gasbombtime = 16, puddletime = "<puddletimeaftertransition>"},
						"alert","malleablegoocd",
						"alert","gasbombcd",
						"alert","puddlecd",
						"set",{malleabletime = 25.5, experimenttime = 37.5, gasbombtime = 35.5, puddletime = "<puddletimeperphase>"},
						"expect",{"<transitioned>","==","0"},
						"alert","unstableexperimentcd",
						"set",{transitioned = "1"},
					},
				},
			},
			--[[
			-- Variable removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					74118, -- Ooze Variable
					74119, -- Gas Variable
				},
				execute = {
					{
					},
				},
			},
			]]
			-- Create Concoction/Guzzle Potions
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72851, -- Create Concoction 10h
					72852, -- Create Concoction 25h
					73121, -- Guzzle Potions 10h
					73122, -- Guzzle Potions 25h
				},
				execute = {
					{
						"scheduletimer",{"fireputraggro",30},
						"scheduletimer",{"heroictrans",40}, -- 30s cast + 10s wait time
					},
				},
			},
			-- Gaseous Bloat
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					70672, -- 10
					72832, -- 10h
					72455, -- 25
					72833, -- 25h
				},
				execute = {
					{
						"quash","oozeaggrocd",
						"alert","bloatcastwarn",
					},
				},
			},
			-- Gaseous Bloat application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70672, -- 10
					72455, -- 25
					72832, -- 10h
					72833, -- 25h
				},
				execute = {
					{
						"raidicon","gaseousbloatmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","bloatappself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","bloatappwarn",
					},
				},
			},
			-- Gaseous Bloat removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					72455, -- 25
					70672, -- 10
					72832, -- 10h
					72833, -- 25h
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Volatile Ooze Adhesive
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72836, -- 25
					70447, -- 10
					72837, -- 10h
					72838, -- 25h
				},
				execute = {
					{
						"quash","oozeaggrocd",
						"alert","oozeadhesivecastwarn",
					},
				},
			},
			-- Volatile Ooze Adhesive application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72836, -- 25
					70447, -- 10
					72837, -- 10h
					72838, -- 25h
				},
				execute = {
					{
						"raidicon","oozeadhesivemark",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","oozeadhesivecastwarn",
						"alert","oozeadhesiveappwarn",
					},
				},
			},
			-- Volatile Ooze Adhesive removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					72836, -- 25
					70447, -- 10
					72837, -- 10h
					72838, -- 25h
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Unstable Experiment
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					71966,
					70351,
					71967, -- 10h
					71968, -- 25h
				},
				execute = {
					{
						"quash","unstableexperimentcd",
						"alert","unstableexperimentwarn",
						"alert","unstableexperimentcd",
						"scheduletimer",{"fireoozeaggro",2.5},
					},
				},
			},
			-- Mutated Slime self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					72456, -- 25
					72869, -- 25h Slime Puddle
					70346, -- 10 Slime Puddle
					72868, -- 10h Slime Puddle
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","mutatedslimeself",
					},
				},
			},
			-- Unbound Plague
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					72855, -- 10h
					72856, -- 25h
				},
				execute = {
					{
						"alert","unboundplaguecd",
					},
				},
			},
			-- Unbound Plague application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72855, -- 10h
					72856, -- 25h
				},
				execute = {
					{
						"raidicon","unboundplaguemark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","unboundplagueself",
						"announce","plaguesay",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


---------------------------------
-- ROTFACE
---------------------------------

do
	local data = {
		version = 12,
		key = "rotface",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Rotface"],
		triggers = {
			scan = {
				36627, -- Rotface
			},
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36627},
			defeat = 36627,
		},
		userdata = {
			slimetime = {16,20, loop = false, type = "series"},
			viletime = {24,30, loop = false, type = "series"},
		},
		onstart = {
			{
				"alert","slimespraycd",
				"alert","enragecd",
				"expect",{"&difficulty&",">=","3"},
				"alert","vilegascd",
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 420,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			infectionself = {
				varname = format(L.alert["%s on self"],SN[69674]),
				type = "centerpopup",
				text = format("%s: %s!",SN[69674],L.alert["YOU"]),
				time = 12,
				flashtime = 12,
				color1 = "GREEN",
				color2 = "PEACH",
				sound = "ALERT1",
				icon = ST[69674],
				flashscreen = true,
			},
			infectiondur = {
				varname = format(L.alert["%s on others"],SN[69674]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[69674]),
				time = 12,
				flashtime = 12,
				color1 = "TEAL",
				icon = ST[69674],
			},
			slimespraycastwarn = {
				varname = format(L.alert["%s Casting"],SN[69508]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[69508]),
				time = 1.5,
				flashtime = 1.5,
				sound = "ALERT2",
				color1 = "CYAN",
				icon = ST[69508],
			},
			slimespraychanwarn = {
				varname = format(L.alert["%s Channel"],SN[69508]),
				type = "centerpopup",
				text = format(L.alert["%s Channel"],SN[69508]),
				time = 5,
				flashtime = 5,
				color1 = "CYAN",
				icon = ST[69508],
			},
			slimesprayself = {
				varname = format(L.alert["%s on self"],SN[71213]),
				type = "simple",
				text = format("%s: %s! %s!",SN[71213],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[71213],
				throttle = 4,
			},
			slimespraycd = {
				varname = format(L.alert["%s Cooldown"],SN[71213]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[71213]),
				time = "<slimetime>",
				color1 = "BROWN",
				flashtime = 5,
				icon = ST[71213],
			},
			oozefloodself = {
				varname = format(L.alert["%s on self"],SN[71215]),
				type = "simple",
				text = format("%s: %s! %s!",SN[71215],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				color1 = "BLACK",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[71215],
				throttle = 3,
			},
			unstableoozewarn = {
				varname = format(L.alert["%s Casting"],SN[69839]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[69839]).."! "..L.alert["MOVE"].."!",
				time = 4,
				flashtime = 4,
				color1 = "MAGENTA",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[69839],
			},
			unstableoozestackwarn = {
				varname = format(L.alert["%s Stacks"],SN[69558]),
				type = "simple",
				text = format("%s => %s!",SN[69558],format(L.alert["%s Stacks"],"#11#")),
				time = 3,
				color1 = "YELLOW",
				icon = ST[69558],
			},
			vilegascd = {
				varname = format(L.alert["%s Cooldown"],SN[71218]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71218]),
				time = "<viletime>",
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[71288],
				throttle = 3,
			},
		},
		timers = {
			fireslimespraychan = {
				{
					"quash","slimespraycastwarn",
					"alert","slimespraychanwarn",
				},
			},
		},
		raidicons = {
			infectionmark = {
				varname = SN[69674],
				type = "MULTIFRIENDLY",
				persist = 12,
				reset = 7,
				unit = "#5#",
				icon = 1,
				total = 4, -- safety
			},
		},
		events = {
			-- Mutated Infection
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69674, -- 10
					71224, -- 25
					73023, -- 25h
				},
				execute = {
					{
						"raidicon","infectionmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","infectionself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","infectiondur",
					},
				},
			},
			-- Mutated Infection removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					69674, -- 10
					71224, -- 25
					73023, -- 25h
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Slime Spray
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 69508,
				execute = {
					{
						"alert","slimespraycd",
						"alert","slimespraycastwarn",
						"scheduletimer",{"fireslimespraychan",1.5},
					},
				},
			},
			-- Slime Spray self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					71213, -- 25
					73190, -- 25h
					69507, -- 10
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","slimesprayself",
					},
				},
			},
			-- Ooze Flood self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71215, -- 25
					69789, -- 10
					71588, -- 25h
					71208, -- 25h Sticky Ooze  use the same warning
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","oozefloodself",
					},
				},
			},
			-- Ooze Flood self applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					71588, -- 25h
					71208, -- 25h Sticky Ooze  use the same warning
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","oozefloodself",
					},
				},
			},
			-- Unstable Ooze Explosion
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 69839, -- 25
				execute = {
					{
						"alert","unstableoozewarn",
					},
				},
			},
			-- Unstable Ooze stacks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 69558, -- 10/25
				execute = {
					{
						"alert","unstableoozestackwarn",
					},
				},
			},
			-- Vile Gas
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#2#","==",SN[72287]},
						"alert","vilegascd",
					},
				},
			},
		},
	}


	DXE:RegisterEncounter(data)
end

---------------------------------
-- SAURFANG
---------------------------------

do
	local faction = UnitFactionGroup("player")

	local prestart_trigger,prestart_time
	if faction == "Alliance" then
		prestart_trigger = L.chat_citadel["^Let's get a move on then"]
		prestart_time = 47
	elseif faction == "Horde" then
		prestart_trigger = L.chat_citadel["^Kor'kron, move out! Champions, watch your backs"]
		prestart_time = 98
	end

	local data = {
		version = 16,
		key = "saurfang",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Saurfang"],
		triggers = {
			scan = {
				37813, -- Deathbringer Saurfang
			},
			yell = prestart_trigger,
		},
		userdata = {
			bloodtext = "",
			markfallentext = "",
			runebloodtime = {22,20,loop = false, type = "series"},
			enragetime = 480,
			started = 0,
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {37813,powers={true}}, -- Deathbringer Saurfang
			defeat = 37813,
		},
		onstart = {
			{
				"expect",{"#1#","find",prestart_trigger},
				"alert","zerotoonecd",
				"scheduletimer",{"fireinitial",prestart_time},
				"set",{started = 1},
			},
			{
				"expect",{"<started>","~=","1"},
				"alert","zerotoonecd",
				"scheduletimer",{"fireinitial",0},
			},
		},
		timers = {
			fireinitial = {
				{
					"expect",{"&difficulty&",">=","3"},
					"set",{enragetime = 360},
				},
				{
					"alert","bloodbeastcd",
					"alert","enragecd",
					"alert","runeofbloodcd",
				},
			},
		},
		alerts = {
			zerotoonecd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase One"]),
				type = "centerpopup",
				text = format(L.alert["%s Begins"],L.alert["Phase One"]),
				time = prestart_time,
				flashtime = 20,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = "<enragetime>",
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			bloodbeastwarn = {
				varname = format(L.alert["%s Warning"],SN[72172]),
				text = format(L.alert["%s Cast"],SN[72172]).."!",
				type = "simple",
				time = 3,
				sound = "ALERT5",
				icon = ST[72172],
			},
			bloodbeastcd = {
				varname = format(L.alert["%s Cooldown"],SN[72172]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[72172]),
				time = 40,
				flashtime = 10,
				color1 = "PURPLE",
				icon = ST[72173],
			},
			runeofbloodwarn = {
				varname = format(L.alert["%s Warning"],SN[72410]),
				type = "simple",
				text = "<bloodtext>",
				time = 3,
				color1 = "BROWN",
				sound = "ALERT3",
				icon = ST[72410],
			},
			runeofbloodcd = {
				varname = format(L.alert["%s Cooldown"],SN[72410]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[72410]),
				time = "<runebloodtime>",
				flashtime = 5,
				color1 = "MAGENTA",
				sound = "ALERT7",
				icon = ST[72410],
			},
			markfallenwarn = {
				varname = format(L.alert["%s Casting"],SN[28836]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[28836]),
				time = 1.5,
				flashtime = 1.5,
				color1 = "ORANGE",
				sound = "ALERT1",
				icon = ST[72293],
			},
			markfallen2warn = {
				varname = format(L.alert["%s Warning"],SN[28836]),
				type = "simple",
				text = "<markfallentext>",
				time = 3,
				color1 = "PEACH",
				sound = "ALERT4",
				icon = ST[72293],
			},
			frenzywarn = {
				varname = format(L.alert["%s Warning"],SN[72737]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[72737]),
				time = 3,
				sound = "ALERT6",
				color1 = "ORANGE",
				icon = ST[72737],
			},
			boilingbloodwarn = {
				varname = format(L.alert["%s Warning"],SN[72385]),
				type = "simple",
				text = format(L.alert["%s Cast"],SN[72385]),
				time = 3,
				sound = "ALERT9",
				color1 = "BLACK",
				icon = ST[72443],
			},
		},
		raidicons = {
			fallenmark = {
				varname = SN[72293],
				type = "MULTIFRIENDLY",
				persist = 1000,
				reset = 1000,
				unit = "#5#",
				icon = 1,
				total = 8,
			},
		},
		windows = {
			proxwindow = true,
		},
		events = {
			-- Boiling Blood
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					72443, -- 25h
					72441, -- 25
					72385, -- 10
				},
				execute = {
					{
						"alert","boilingbloodwarn",
					}
				},
			},
			-- Call Blood Beast
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				-- There are five different spellids for this
				-- 72172, 72173, 72356, 72357, 72358
				spellid = {
					72172, -- 25
				},
				execute = {
					{
						"alert","bloodbeastwarn",
						"alert","bloodbeastcd",
					},
				},
			},
			-- Rune of Blood
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72410, -- 25 and 25 hard
				},
				execute = {
					{
						"alert","runeofbloodcd",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{bloodtext = format("%s: #5#!",SN[72410])},
						"alert","runeofbloodwarn",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{bloodtext = format("%s: %s!",SN[72410],L.alert["YOU"])},
						"alert","runeofbloodwarn",
					},
				},
			},
			-- Mark of the Fallen
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 72293, -- 25 and 25 hard
				execute = {
					{
						"alert","markfallenwarn",
					},
				},
			},
			-- Mark of the Fallen applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 72293,
				execute = {
					{
						"raidicon","fallenmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{markfallentext = format("%s: %s!",SN[28836],L.alert["YOU"])},
						"alert","markfallen2warn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{markfallentext = format("%s: #5#!",SN[28836])},
						"alert","markfallen2warn",
					},
				},
			},
			-- Frenzy
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 72737,
				execute = {
					{
						"alert","frenzywarn",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

---------------------------------
-- SINDRAGOSA
---------------------------------

do
	local data = {
		version = 33,
		key = "sindragosa",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Sindragosa"],
		triggers = {
			scan = {36853}, -- Sindragosa
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36853}, -- Sindragosa
			defeat = 36853, -- Sindragosa
		},
		userdata = {
			chilledtext = "",
			airtime = {50,110,loop = false, type = "series"},
			phase = "1",
			instabilitytext = "",
			unchainedtime = 30,
			frostbeacontext = "",
			icygriptime = {33.8,67.2, loop = false, type = "series"},
			bombcount = "1",
			instabilitytime = 8,
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","aircd",
			},
			{
				"expect",{"&difficulty&",">=","3"},
				"set",{instabilitytime = 5},
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			icetombwarn = {
				varname = format(L.alert["%s Casting"],SN[69712]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[69712]),
				time = 1,
				flashtime = 1,
				color1 = "INDIGO",
				sound = "ALERT1",
				icon = ST[69712],
			},
			frostbeacondur = {
				varname = format(L.alert["%s Duration"],SN[70126]),
				type = "centerpopup",
				text = "<frostbeacontext>",
				time = 7,
				flashtime = 7,
				color1 = "GOLD",
				throttle = 2,
				icon = ST[70126],
			},
			frostbeaconself = {
				varname = format(L.alert["%s on self"],SN[70126]),
				type = "simple",
				text = format("%s: %s!",SN[70126],L.alert["YOU"]).."!",
				time = 3,
				icon = ST[70126],
				sound = "ALERT7",
				flashscreen = true,
			},
			icygripcd = {
				varname = format(L.alert["%s Cooldown"],SN[70117]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[70117]),
				time = "<icygriptime>",
				flashtime = 10,
				color1 = "GREY",
				icon = ST[70117],
			},
			blisteringcoldwarn = {
				varname = format(L.alert["%s Casting"],SN[71047]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71047]),
				time = 5,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT2",
				icon = ST[71047],
			},
			unchainedself = {
				varname = format(L.alert["%s on self"],SN[69762]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[69762],L.alert["YOU"],L.alert["CAREFUL"]),
				time = 30,
				flashtime = 30,
				color1 = "TURQUOISE",
				flashscreen = true,
				sound = "ALERT3",
				icon = ST[69762],
			},
			unchainedcd = {
				varname = format(L.alert["%s Cooldown"],SN[69762]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[69762]),
				time = "<unchainedtime>",
				flashtime = 10,
				color1 = "WHITE",
				sound = "ALERT5",
				icon = ST[69762],
			},
			instabilityself = {
				varname = format(L.alert["%s on self"],SN[69766]),
				type = "centerpopup",
				text = "<instabilitytext>",
				time = "<instabilitytime>",
				flashtime = 4,
				color1 = "VIOLET",
				icon = ST[69766],
			},
			chilledstackself = {
				varname = format(L.alert["%s Stacks"],L.alert["Chilled"]).." == 4",
				type = "simple",
				text = format("%d "..L.alert["%s Stacks"].."! %s!",4,L.alert["Chilled"],L.alert["CAREFUL"]),
				time = 3,
				color1 = "CYAN",
				icon = ST[70106],
				flashscreen = true,
			},
			chilledself = {
				varname = format(L.alert["%s on self"],L.alert["Chilled"]),
				type = "centerpopup",
				text = "<chilledtext>",
				time = 8,
				flashtime = 8,
				color1 = "CYAN",
				icon = ST[70106],
			},
			aircd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Air Phase"]),
				type = "dropdown",
				text = format("Next %s",L.alert["Air Phase"]),
				time = "<airtime>",
				flashtime = 10,
				color1 = "YELLOW",
				icon = "Interface\\Icons\\INV_Misc_Toy_09",
			},
			airdur = {
				varname = format(L.alert["%s Duration"],L.alert["Air Phase"]),
				type = "dropdown",
				text = L.alert["Air Phase"],
				time = 47,
				flashtime = 10,
				color1 = "MAGENTA",
				icon = "Interface\\Icons\\INV_Misc_Toy_09",
			},
			frostbombwarn = {
				varname = format(L.alert["%s ETA"],SN[71053]),
				type = "centerpopup",
				text = format(L.alert["%s Hits"],SN[71053]).." <bombcount>",
				time = 5.85, -- average: ranges from 5.3 to 6.5
				flashtime = 5.85,
				color1 = "BLUE",
				sound = "ALERT5",
				icon = ST[71053],
				throttle = 3,
			},
			-- 6.4 until frost bomb is summoned
			frostbreathwarn = {
				varname = format(L.alert["%s Casting"],SN[71056]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71056]),
				time = 1.5,
				flashtime = 1.5,
				color1 = "BROWN",
				sound = "ALERT4",
				icon = ST[71056],
			},
			mysticbuffetcd = {
				varname = format(L.alert["%s Timer"],SN[72528]),
				type = "centerpopup",
				text = format(L.alert["Next %s"],SN[72528]),
				time = 6,
				color1 = "PINK",
				icon = ST[72528],
				throttle = 4,
			},
		},
		windows = {
			proxwindow = true,
		},
		raidicons = {
			frostbeaconmark = {
				varname = SN[70126],
				type = "MULTIFRIENDLY",
				persist = 7,
				reset = 2,
				unit = "#5#",
				icon = 1,
				total = 6,
			},
		},
		arrows = {
			westarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["West"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["West"],
				fixed = true,
				xpos = 0.35448017716408,
				ypos = 0.23266260325909,
			},
			northarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["North"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["North"],
				fixed = true,
				xpos = 0.3654870390892,
				ypos = 0.2162726521492,
			},
			eastarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["East"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["East"],
				fixed = true,
				xpos = 0.37621337175369,
				ypos = 0.23285666108131,
			},
			southarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["South"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["South"],
				fixed = true,
				xpos = 0.36525920033455,
				ypos = 0.250081539154054,
			},
			southsoutharrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["South"].." "..L.alert["South"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["South"].." "..L.alert["South"],
				fixed = true,
				xpos = 0.36546084284782,
				ypos = 0.27346137166023,
			},
			easteastarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["East"].." "..L.alert["East"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["East"].." "..L.alert["East"],
				fixed = true,
				xpos = 0.39097648859024,
				ypos = 0.23303273320198,
			},
			beaconarrow = {
				varname = format("%s %s",SN[70126],L.alert["Phase Three"]),
				unit = "#5#",
				persist = 7,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[70126],
			},
		},
		timers = {
			checkbeacon = {
				{
					-- This is dependent on multi raid icons being set and consistent across all users
					-- Icon positioning is the following:
					--     1
					--
					-- 3       4    6
					--
					--     2
					--
					--     5
					"expect",{"&playerdebuff|"..SN[70126].."&","==","true"},
					"invoke",{
						{
							"expect",{"&hasicon|player|1&","==","true"}, -- Skull
							"arrow","northarrow",
						},
						{
							"expect",{"&hasicon|player|2&","==","true"}, -- Cross
							"arrow","southarrow",
						},
						{
							"expect",{"&hasicon|player|3&","==","true"}, -- Square
							"arrow","westarrow",
						},
						{
							"expect",{"&hasicon|player|4&","==","true"}, -- Moon
							"arrow","eastarrow",
						},
						{
							"expect",{"&hasicon|player|5&","==","true"}, -- Triangle
							"arrow","southsoutharrow",
						},
						{
							"expect",{"&hasicon|player|6&","==","true"}, -- Diamond
							"arrow","easteastarrow",
						},
					},
				},
			},
			firefrostbomb = {
				{
					"set",{bombcount = "INCR|1"},
					"alert","frostbombwarn",
					"expect",{"<bombcount>","<","4"},
					"scheduletimer",{"firefrostbomb",6.4},
				},
			},
		},
		events = {
			-- Mystic Buffet
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72529,
					70127,
					72528, -- 25
					72530, -- 25h
				},
				execute = {
					{
						"expect",{"&timeleft|mysticbuffetcd&","<","3"},
						"quash","mysticbuffetcd",
					},
					{
						"alert","mysticbuffetcd",
					},
				},
			},
			-- Mystic Buffet
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					72529,
					70127,
					72528, -- 25
					72530, -- 25h
				},
				execute = {
					{
						"expect",{"&timeleft|mysticbuffetcd&","<","3"},
						"quash","mysticbuffetcd",
					},
					{
						"alert","mysticbuffetcd",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Air phase
					{
						"expect",{"#1#","find",L.chat_citadel["^Your incursion ends here"]},
						"quash","aircd",
						"quash","unchainedcd",
						"set",{unchainedtime = 55},
						"alert","unchainedcd",
						"set",{unchainedtime = 30},
						"alert","aircd",
						"alert","airdur",
					},
					-- Last Phase
					{
						"expect",{"#1#","find",L.chat_citadel["^Now, feel my master's limitless power"]},
						"set",{phase = "2", unchainedtime = 80},
						"quash","aircd",
						"alert","icygripcd",
						"tracing",{36853,36980}, -- Sindragosa, Ice Tomb
					},
				},
			},
			-- Ice Tomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					69712, -- 10,25,25h
				},
				execute = {
					{
						"alert","icetombwarn",
					},
				},
			},
			-- Ice Tomb app
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 70157, -- 25,25h
				execute = {
					{
						-- fires 2 to 5 times within 0.1 seconds
						"expect",{"<phase>","==","1"},
						"set",{bombcount = "1"},
						"alert","frostbombwarn",
						"scheduletimer",{"firefrostbomb",6.4},
					},
				},
			},
			-- Frost Beacon
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70126, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"<phase>","==","1"},
						"set",{frostbeacontext = format(L.alert["%s Duration"],SN[70126])},
					},
					{
						"expect",{"<phase>","==","2"},
						"invoke",{
							{
								"expect",{"#4#","~=","&playerguid&"},
								"set",{frostbeacontext = format("%s: #5#!",SN[70126])},
								"arrow","beaconarrow",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"set",{frostbeacontext = format("%s: %s!",SN[70126],L.alert["YOU"])},
							},
						}
					},
					{
						"raidicon","frostbeaconmark",
						"alert","frostbeacondur",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","frostbeaconself",
						"expect",{"<phase>","==","1"},
						"invoke",{
							{
								"expect",{"&difficulty&","==","4"}, -- 25h
								"scheduletimer",{"checkbeacon",0.2}, -- allow time for raid icon to set
							},
							{
								"expect",{"&difficulty&","==","2"}, -- 25
								"scheduletimer",{"checkbeacon",0.2}, -- allow time for raid icon to set
							},
						},
					},
				},
			},
			-- Frost Beacon removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					70126, -- 10,25,25h
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Icy Grip
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					70117, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"<phase>","==","2"},
						"alert","icygripcd",
					},
				},
			},
			-- Blistering Cold
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					70123, -- 10
					71048, -- 10h
					71047, -- 25
					71049, -- 25h
				},
				execute = {
					{
						"alert","blisteringcoldwarn",
					},
				},
			},
			-- Unchained Magic
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					69762, -- 10,25,25h
				},
				execute = {
					{
						"alert","unchainedcd",
					},
				},
			},
			-- Unchained Magic application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69762, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","unchainedself",
					},
				},
			},
			-- Instability
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69766, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{instabilitytext = format("%s: %s!",SN[69766],L.alert["YOU"])},
						"alert","instabilityself",
					},
				},
			},
			-- Instability applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					69766, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","instabilityself",
						"set",{instabilitytext = format("%s: %s! %s!",SN[69766],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","instabilityself",
					},
				},
			},
			-- Instability removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					69766, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","instabilityself",
					},
				},
			},
			-- Chilled to the Bone
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70106, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{chilledtext = format("%s: %s!",L.alert["Chilled"],L.alert["YOU"])},
						"alert","chilledself",
					},
				},
			},
			-- Chilled to the Bone applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					70106, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","chilledself",
						"set",{chilledtext = format("%s: %s! %s!",L.alert["Chilled"],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","chilledself",
						"expect",{"#11#","==","4"},
						"alert","chilledstackself",
					},
				},
			},
			--[[
			-- Frost Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {
					69845, -- 10
					71053, -- 25
				},
				execute = {
					{
						"alert","frostbombwarn",
					},
				},
			},
			]]
			-- Frost Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					69649, -- 10
					71056, -- 25
					71057, -- 10h
					71058, -- 25h
				},
				execute = {
					{
						"alert","frostbreathwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- VALITHRIA
---------------------------------

do
	local data = {
		version = 12,
		key = "valithria",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = L.npc_citadel["Valithria"],
		triggers = {
			scan = 36789,
			yell = L.chat_citadel["^Heroes, lend me your aid"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36789},
			defeat = L.chat_citadel["^I AM RENEWED!"],
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","portalcd",
				--"alert","blazingskeletoncd",
				--"scheduletimer",{"fireblazing",35},
			},
		},
		userdata = {
			portaltime = {33,45, loop = false, type = "series"},
			corrosiontext = "",
			blazingtime = {35,60, loop = false, type = "series"}, -- unknown
			nightmaretext = "";
		},
		timers = {
			firelaywaste = {
				{
					"quash","laywastewarn",
					"alert","laywastedur",
				}
			},
			fireportaldur = {
				{
					"quash","portalwarn",
					"alert","portaldur",
				}
			},
			fireblazing = {
				{
					"alert","blazingskeletoncd",
					"scheduletimer",{"fireblazing",60},
				},
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Soft Enrage"],
				type = "dropdown",
				text = L.alert["Soft Enrage"],
				time = 420,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			blazingskeletoncd = {
				varname = format(L.alert["%s Spawns"],L.npc_citadel["Blazing Skeleton"]),
				type = "dropdown",
				text = format(L.alert["%s Spawns"],L.npc_citadel["Blazing Skeleton"]),
				time = 35,
				flashtime = 10,
				color1 = "YELLOW",
				icon = ST[49264],
			},
			portalcd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Portals"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Portals"]),
				time = "<portaltime>",
				flashtime = 10,
				sound = "ALERT1",
				color1 = "GREEN",
				icon = ST[57676],
			},
			portalwarn = {
				varname = format(L.alert["%s Warning"],L.alert["Portals"]),
				type = "centerpopup",
				text = format(L.alert["%s Soon"],L.alert["Portals"]).."!",
				time = 15,
				sound = "ALERT2",
				color1 = "GREEN",
				icon = ST[57676],
			},
			portaldur = {
				varname =  format(L.alert["%s Duration"],L.alert["Portals"]),
				type = "centerpopup",
				text =  format(L.alert["%s Duration"],L.alert["Portals"]),
				time = 10,
				sound = "ALERT7",
				color1 = "GREEN",
				icon = ST[57676],
			},
			manavoidself = {
				varname = format(L.alert["%s on self"],SN[71743]),
				type = "simple",
				text = format("%s: %s! %s!",SN[71743],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				sound = "ALERT3",
				color1 = "PURPLE",
				flashscreen = true,
				throttle = 2,
				icon = ST[71743],
			},
			laywastewarn = {
				varname = format(L.alert["%s Warning"],SN[69325]),
				type =  "centerpopup",
				text = format(L.alert["%s Soon"],SN[69325]),
				time = 2,
				sound = "ALERT4",
				color1 = "ORANGE",
				icon = ST[69325],
			},
			laywastedur = {
				varname = format(L.alert["%s Duration"],SN[69325]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[69325]),
				time = 12,
				flashtime = 12,
				color1 = "ORANGE",
				icon = ST[69325],
			},
			gutspraywarn = {
				varname = format(L.alert["%s Warning"],SN[70633]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[70633]),
				time = 3,
				sound = "ALERT5",
				icon = ST[70633],
			},
			corrosionself = {
				varname = format(L.alert["%s on self"],SN[70751]),
				type = "centerpopup",
				text = "<corrosiontext>",
				time = 6,
				flashtime = 6,
				sound = "ALERT6",
				color1 = "CYAN",
				icon = ST[70751],
			},
			nightmaredur = {
				varname = format(L.alert["%s Duration"],SN[71940]),
				type = "centerpopup",
				text = "<nightmaretext>",
				time = 40,
				color1 = "GREY",
				icon = ST[71940],
			},
		},
		events = {
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^I have opened a portal into the Dream"]},
						"alert","portalwarn",
						"alert","portalcd",
						"scheduletimer",{"fireportaldur",15},
					},
				},
			},
			-- Twisted Nightmare
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71941, -- there seem to be two spellids, don't use 71940
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{nightmaretext = format("%s: %s!",SN[71941],L.alert["YOU"])},
						"alert","nightmaredur",
					},
				}
			},
			-- Twisted Nightmare stacks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 71941, -- there seem to be two spellids, don't use 71940
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{nightmaretext = format("%s: %s! %s",SN[71941],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"quash","nightmaredur",
						"alert","nightmaredur",
					},
				}
			},
			-- Twisted Nightmare removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 71941, -- there seem to be two spellids, don't use 71940
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","nightmaredur",
					},
				}
			},
			-- Mana Void (hit)
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					71086, -- 10
					72029, -- 10h
					71743, -- 25
					72030, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","manavoidself",
					},
				},
			},
			-- Mana Void (miss)
			{
				type = "combatevent",
				eventtype = "SPELL_MISSED",
				spellid = {
					71086, -- 10
					72029, -- 10h
					71743, -- 25
					72030, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","manavoidself",
					},
				},
			},
			-- Lay Waste
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69325, -- 10, 10h
					71730, -- 25, 25h
				},
				execute = {
					{
						"alert","laywastewarn",
						"scheduletimer",{"firelaywaste",2},
					},
				},
			},
			-- Lay Waste removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					69325, -- 10, 10h
					71730, -- 25, 25h
				},
				execute = {
					{
						"quash","laywastewarn",
						"canceltimer","firelaywaste",
						"quash","laywastedur",
					},
				},
			},
			-- Gut Spray
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					70633, -- 10
					72025, -- 10h
					71283, -- 25
					72026, -- 25h
				},
				execute = {
					{
						"alert","gutspraywarn",
					}
				},
			},
			-- Corrosion
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70751, -- 10
					72021, -- 10h
					71738, -- 25
					72022, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{corrosiontext = format("%s: %s!",SN[70751],L.alert["YOU"])},
						"alert","corrosionself",
					},
				},
			},
			-- Corrosion applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					70751, -- 10
					72021, -- 10h
					71738, -- 25
					72022, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","corrosionself",
						"set",{corrosiontext = format("%s: %s! %s!",SN[70751],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","corrosionself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- TRASH
---------------------------------


do
	local data = {
		version = 3,
		key = "icctrash",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = format(L.alert["%s (T)"],L.npc_citadel["Deathbound Ward"]),
		triggers = {
			scan = {
				37007, -- Deathbound Ward
			},
		},
		onactivate = {
			tracing = {37007}, -- Deathbound Ward
			tracerstart = true,
			combatstop = true,
		},
		alerts = {
			disruptshoutwarn = {
				varname = format(L.alert["%s Casting"],SN[71022]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71022]),
				time = 3,
				flashtime = 3,
				color1 = "ORANGE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[71022],
			},
		},
		events = {
			-- Disrupting Shout
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71022, -- 10/25
				execute = {
					{
						"alert","disruptshoutwarn"
					},
				}
			}
		},
	}

	DXE:RegisterEncounter(data)
end

do
	local decimate_event = {
		type = "combatevent",
		eventtype = "SPELL_CAST_START",
		spellid = 71123, -- 10/25
		execute = {
			{
				"alert","decimatewarn"
			},
		}
	}

	local mortal_wound_event = {
		type = "combatevent",
		eventtype = "SPELL_AURA_APPLIED",
		spellid = 71127,
		execute = {
			{
				"expect",{"#4#","==","&playerguid&"},
				"set",{mortaltext = format("%s: %s!",SN[71127],L.alert["YOU"])},
				"alert","mortalwarn",
			},
			{
				"expect",{"#4#","~=","&playerguid&"},
				"set",{mortaltext = format("%s: #5#!",SN[71127])},
				"alert","mortalwarn",
			},
		},
	}

	local mortal_wound_dose_event = {
		type = "combatevent",
		eventtype = "SPELL_AURA_APPLIED_DOSE",
		spellid = 71127,
		execute = {
			{
				"expect",{"#4#","==","&playerguid&"},
				"set",{mortaltext = format("%s: %s! %s!",SN[71127],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
				"alert","mortalwarn",
			},
			{
				"expect",{"#4#","~=","&playerguid&"},
				"set",{mortaltext = format("%s: #5#! %s!",SN[71127],format(L.alert["%s Stacks"],"#11#")) },
				"alert","mortalwarn",
			},
		},
	}

	local decimatewarn = {
		varname = format(L.alert["%s Casting"],SN[71123]),
		type = "centerpopup",
		text = format(L.alert["%s Casting"],SN[71123]),
		time = 3,
		flashtime = 3,
		color1 = "PURPLE",
		sound = "ALERT5",
		flashscreen = true,
		icon = ST[71123],
	}
	local mortalwarn = {
		varname = format(L.alert["%s Warning"],SN[71127]),
		type = "simple",
		text = "<mortaltext>",
		time = 3,
		color1 = "RED",
		icon = ST[71127],
	}

	do
		local data = {
			version = 4,
			key = "icctrashtwo",
			zone = L.zone["Icecrown Citadel"],
			category = L.zone["Citadel"],
			name = format(L.alert["%s (T)"],L.npc_citadel["Stinky"]),
			triggers = {
				scan = {
					37025, -- Stinky
				},
			},
			onactivate = {
				tracing = {
					37025, -- Stinky
				},
				tracerstart = true,
				combatstop = true,
			},
			userdata = {
				mortaltext = "",
			},
			alerts = {
				decimatewarn = decimatewarn,
				mortalwarn = mortalwarn,
			},
			events = {
				-- Decimate
				decimate_event,
				-- Mortal Wound
				mortal_wound_event,
				-- Mortal Wounds applications
				mortal_wound_dose_event,
			},
		}

		DXE:RegisterEncounter(data)
	end

	do
		local data = {
			version = 2,
			key = "icctrashthree",
			zone = L.zone["Icecrown Citadel"],
			category = L.zone["Citadel"],
			name = format(L.alert["%s (T)"],L.npc_citadel["Precious"]),
			triggers = {
				scan = {
					37217, -- Precious
				},
			},
			onactivate = {
				tracing = {
					37217, -- Precious
				},
				tracerstart = true,
				combatstop = true,
			},
			userdata = {
				mortaltext = "",
				awakentime = {28,20,loop = false, type = "series"},
			},
			alerts = {
				decimatewarn = decimatewarn,
				mortalwarn = mortalwarn,
				awakencd = {
					varname = format(L.alert["%s Cooldown"],SN[71159]),
					type = "dropdown",
					text = format(L.alert["%s Cooldown"],SN[71159]),
					time = "<awakentime>",
					flashtime = 10,
					color1 = "GREY",
					icon = ST[71159],
				}
			},
			events = {
				-- Decimate
				decimate_event,
				-- Mortal Wound
				mortal_wound_event,
				-- Mortal Wounds applications
				mortal_wound_dose_event,
				-- Awaken Plagued Zombie
				{
					type = "event",
					event = "EMOTE",
					execute = {
						{
							"expect",{"#2#","==",L.npc_citadel["Precious"]},
							"alert","awakencd",
						},
					},
				},
			},
		}

		DXE:RegisterEncounter(data)
	end
end

do
	local data = {
		version = 1,
		key = "icctrashfour",
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"],
		name = format(L.alert["%s (T)"],L.npc_citadel["Deathspeaker High Priest"]),
		triggers = {
			scan = {
				36829, -- Deathspeaker High Priest 
			},
		},
		onactivate = {
			tracing = {36829}, -- Deathspeaker High Priest 
			tracerstart = true,
			combatstop = true,
		},
		alerts = {
			darkreckoningwarn = {
				varname = format(L.alert["%s on others"],SN[69483]),
				type = "simple",
				text = format("%s: #5#!",SN[69483]),
				time = 8,
				color1 = "PURPLE",
				sound = "ALERT5",
				icon = ST[69483],
			},
			darkreckoningself = {
				varname = format(L.alert["%s on self"],SN[69483]),
				type = "simple",
				text = format("%s: %s! %s!",SN[69483],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 8,
				color1 = "PURPLE",
				sound = "ALERT5",
				icon = ST[69483],
				flashscreen = true,
			},
		},
		raidicons = {
			darkreckoningmark = {
				varname = SN[69483],
				type = "FRIENDLY",
				persist = 8,
				unit = "#5#",
				icon = 1,
			},
		},
		events = {
			-- Dark Reckoning 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 69483, -- 10/25
				execute = {
					{
						"raidicon","darkreckoningmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","darkreckoningself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","darkreckoningwarn",
					},
				}
			}
		},
	}

	DXE:RegisterEncounter(data)
end
