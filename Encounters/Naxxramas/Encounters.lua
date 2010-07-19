local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ANUB
---------------------------------

do

	local L_AnubRekhan = L.npc_naxxramas["Anub'Rekhan"]

	local data = {
		version = 300,
		key = "anubrekhan",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Anub'Rekhan"],
		triggers = {
			scan = 15956, -- Anub'Rekhan
		},
		onactivate = {
			tracing = {15956}, -- Anub'Rekhan
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15956,
		},
		userdata = {
			swarmcd = {90, 85, loop = false, type = "series"},
		},
		onstart = {
			{
				"expect",{"&difficulty&","==","1"},
				"set",{swarmcd = {102,85,loop = false, type = "series"}},
			},
			{
				"alert","locustswarmcd",
			},
		},
		alerts = {
			locustswarmcd = {
				varname = format(L.alert["%s Cooldown"],SN[28785]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[28785]),
				time = "<swarmcd>",
				flashtime = 5,
				sound = "ALERT1",
				color1 = "GREEN",
				icon = ST[28785],
			},
			locustswarmwarn = {
				varname = format(L.alert["%s Casting"],SN[28785]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[28785]),
				time = 3,
				sound = "ALERT3",
				color1 = "GREY",
				icon = ST[28785],
			},
			locustswarmdur = {
				varname = format(L.alert["%s Duration"],SN[28785]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[28785]),
				time = 20,
				sound = "ALERT2",
				color1 = "YELLOW",
				icon = ST[28785],
			},
		},
		events = {
			-- Locust Swarm duration
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {28785,54021},
				execute = {
					{
						"expect",{"&npcid|#4#&","==","15956"}, -- Anub'Rekhan
						"alert","locustswarmdur",
						"quash","locustswarmcd",
						"alert","locustswarmcd",
					},
				},
			},
			-- Locust Swarm cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {28785,54021},
				execute = {
					{
						"alert","locustswarmwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- FAERLINA
---------------------------------

do

	local data = {
		version = 299,
		key = "grandwidowfaerlina",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Grand Widow Faerlina"],
		triggers = {
			scan = 15953, -- Grand Widow Faerlina
		},
		onactivate = {
			tracing = {15953}, -- Grand Widow Faerlina
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15953
		},
		userdata = {
			enraged = "false",
		},
		onstart = {
			{
				"alert","enragecd",
			}
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 60,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "RED",
				icon = ST[12317],
			},
			enragewarn = {
				varname = format(L.alert["%s Warning"],L.alert["Enrage"]),
				type = "simple",
				text = format("%s!",L.alert["Enraged"]),
				time = 1.5,
				sound = "ALERT2",
				icon = ST[40735],
			},
			rainwarn = {
				varname = format(L.alert["%s Warning"],SN[39024]),
				type = "simple",
				text = format("%s! %s!",SN[39024],L.alert["MOVE"]),
				time = 1.5,
				sound = "ALERT3",
				flashscreen = true,
				color1 = "BROWN",
				icon = ST[39024],
			},
			silencedur = {
				varname = format(L.alert["%s Duration"],SN[15487]),
				type = "dropdown",
				text = format(L.alert["%s Duration"],SN[15487]),
				time = 30,
				flashtime = 5,
				sound = "ALERT4",
				color1 = "ORANGE",
				icon = ST[29943],
			},
		},
		events = {
			-- Silence
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {28732,54097},
				execute = {
					{
						"expect",{"&npcid|#4#&","==","15953"}, -- Grand Widow Faerlina
						"expect",{"$enraged$","==","true"},
						"set",{enraged = "false"},
						"alert","enragecd",
						"quash","silencedur",
						"alert","silencedur",
					},
				},
			},
			-- Rain
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 54099,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","rainwarn",
					}
				},
			},
			-- Enrage
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 54100,
				execute = {
					{
						"expect",{"&npcid|#4#&","==","15953"}, -- Grand Widow Faerlina
						"quash","enragecd",
						"set",{enraged = "true"},
						"alert","enragewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- FOUR HORSEMEN
---------------------------------

do

	local data = {
		version = 299,
		key = "fourhorsemen",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["The Four Horsemen"],
		triggers = {
			scan = {
				16064, -- Thane Korth'azz
				30549, -- Baron Rivendare
				16065, -- Lady Blaumeux
				16063, -- Sir Zeliek
			},
		},
		onactivate = {
			tracing = {
				16064, -- Thane Korth'azz
				30549, -- Baron Rivendare
				16065, -- Lady Blaumeux
				16063, -- Sir Zeliek
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				16064, -- Thane Korth'azz
				30549, -- Baron Rivendare
				16065, -- Lady Blaumeux
				16063, -- Sir Zeliek
			},
		},
		userdata = {},
		alerts = {
			voidzonecd = {
				varname = format(L.alert["%s Cooldown"],SN[28863]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[28863]),
				time = 12,
				color1 = "MAGENTA",
				icon = ST[28863],
			},
			meteorcd = {
				varname = format(L.alert["%s Cooldown"],SN[28884]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[28884]),
				time = 12,
				color1 = "RED",
				icon = ST[28884],
			},
			wrathcd = {
				varname = format(L.alert["%s Cooldown"],SN[28883]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[28883]),
				time = 12,
				color1 = "YELLOW",
				icon = ST[28883],
			},
		},
		events = {
			-- Void Zone
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28863,57463},
				execute = {
					{
						"alert","voidzonecd",
					},
				},
			},
			-- Meteor
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {28884,57467},
				execute = {
					{
						"alert","meteorcd",
					},
				},
			},
			-- Wrath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28883,57466},
				execute = {
					{
						"alert","wrathcd",
					},
				},
			},
			-- Boss quashes
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","16063"},
						"quash","wrathcd",
					},
					{
						"expect",{"&npcid|#4#&","==","16064"},
						"quash","meteorcd",
					},
					{
						"expect",{"&npcid|#4#&","==","16065"},
						"quash","voidzonecd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- GLUTH
---------------------------------

do
	local L_Gluth = L.npc_naxxramas["Gluth"]
	local data = {
		version = 299,
		key = "gluth",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Gluth"],
		triggers = {
			scan = 15932, -- Gluth
		},
		onactivate = {
			tracing = {15932},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15932,
		},
		userdata = {},
		onstart = {
			{
				"alert","decimatecd",
			}
		},
		alerts = {
			decimatecd = {
				varname = format(L.alert["%s Cooldown"],SN[28374]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[28374]),
				time = 105,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "BROWN",
				throttle = 5,
				icon = ST[28374],
			},
			enragewarn = {
				varname = format(L.alert["%s Warning"],L.alert["Enrage"]),
				type = "simple",
				text = format("%s!",L.alert["Enraged"]),
				time = 1.5,
				color1 = "RED",
				icon = ST[12317],
			},
		},
		events = {
			-- Decimate (hit)
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {28375,54426},
				execute = {
					{
						"alert","decimatecd",
					},
				},
			},
			-- Decimate (miss)
			{
				type = "combatevent",
				eventtype = "SPELL_MISSED",
				spellid = {28375,54426},
				execute = {
					{
						"alert","decimatecd",
					},
				},
			},
			-- Frenzy
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28371,54427},
				execute = {
					{
						"alert","enragewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


---------------------------------
-- GOTHIK
---------------------------------

do

	local data = {
		version = 300,
		key = "gothiktheharvester",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Gothik the Harvester"],
		triggers = {
			scan = 16060, -- Gothik the Harvester
			yell = {
        L.chat_naxxramas["^Foolishly you have sought"],
        L.chat_naxxramas["^Teamanare shi rikk"]
      },
		},
		onactivate = {
			tracing = {16060}, -- Gothik the Harvester
			combatstop = true,
			defeat = 16060,
		},
		userdata = {},
		onstart = {
			{
				"alert","gothikcomesdowncd",
			}
		},
		alerts = {
			gothikcomesdowncd = {
				varname = format(L.alert["%s Arrival"],L.npc_naxxramas["Gothik the Harvester"]),
				type = "dropdown",
				text = L.alert["Arrival"],
				time = 270,
				flashtime = 5,
				color1 = "RED",
				sound = "ALERT1",
				icon = ST[586],
			},
		},
	}
	DXE:RegisterEncounter(data)
end

---------------------------------
-- GROBBULUS
---------------------------------

do

	local L_Grobbulus = L.npc_naxxramas["Grobbulus"]

	local data = {
		version = 301,
		key = "grobbulus",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Grobbulus"],
		triggers = {
			scan = 15931, -- Grobbulus
		},
		onactivate = {
			tracing = {15931},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15931,
		},
		userdata = {},
		onstart = {
			{
				"alert","enragecd",
			}
		},
		alerts = {
			enragecd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Enrage"]),
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 360,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			injectionwarnself = {
				varname = format(L.alert["%s on self"],L.alert["Injection"]),
				type = "centerpopup",
				text = format("%s: %s! %s!",L.alert["Injection"],L.alert["YOU"],L.alert["MOVE"]),
				time = 10,
				flashtime = 10,
				sound = "ALERT1",
				color1 = "RED",
				color2 = "MAGENTA",
				flashscreen = true,
				icon = ST[28169],
			},
			injectionwarnothers = {
				varname = format(L.alert["%s on others"],L.alert["Injection"]),
				type = "centerpopup",
				text = format("%s: #5#",L.alert["Injection"]),
				time = 10,
				color1 = "ORANGE",
				icon = ST[28169],
			},
			cloudcd = {
				varname = format(L.alert["%s Cooldown"],SN[28240]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[28240]),
				time = 15,
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[28240],
			},
		},
		raidicons = {
			injectionmark = {
				varname = SN[28169],
				type = "MULTIFRIENDLY",
				persist = 10,
				unit = "#5#",
				icon = 1,
				reset = 5,
				total = 3,
			},
		},
		events = {
			-- Injection
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 28169,
				execute = {
					{
						"raidicon","injectionmark",
					},
					{
						"expect",{"#4#", "==", "&playerguid&"},
						"alert","injectionwarnself",
					},
					{
						"expect",{"#4#", "~=", "&playerguid&"},
						"alert","injectionwarnothers",
					},
				},
			},
			-- Poison cloud
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 28240,
				execute = {
					{
						"alert","cloudcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


---------------------------------
-- HEIGAN
---------------------------------

do

	local data = {
		version = 300,
		key = "heigantheunclean",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Heigan the Unclean"],
		triggers = {
			scan = 15936, -- Heigan the Unclean
		},
		onactivate = {
			tracing = {15936},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15936,
		},
		userdata = {},
		onstart = {
			{
				"alert","dancebeginscd",
			}
		},
		alerts = {
			dancebeginscd = {
				varname = format(L.alert["%s Begins"],L.alert["Dance"]),
				type = "dropdown",
				text = format(L.alert["%s Begins"],L.alert["Dance"]),
				time = 90,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "MAGENTA",
				icon = ST[29516],
			},
			danceendscd = {
				varname = format(L.alert["%s Ends"],L.alert["Dance"]),
				type = "dropdown",
				text = format(L.alert["%s Ends"],L.alert["Dance"]),
				time = 45,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "DCYAN",
				icon = ST[49838],
			},
		},
		timers = {
			backonfloor = {
				{
					"alert","dancebeginscd",
				}
			}
		},
		events = {
			-- Dance starts
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["^The end is upon you"]},
						"alert","danceendscd",
						"scheduletimer",{"backonfloor", 45},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- KELTHUZAD
---------------------------------

do

	local data = {
		version = 300,
		key = "kelthuzad",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Kel'Thuzad"],
		triggers = {
			yell = L.chat_naxxramas["^Minions, servants, soldiers of the cold dark"],
			scan = {
				15990, -- Kel'Thuzad
				16441, -- Guardian of Icecrown
				16427, -- Soldier of the Frozen Wastes
				23561, -- Soldier of the Frozen Wastes
				16428, -- Unstoppable Abomination
				23562, -- Unstoppable Abomination
				23563, -- Soul Weaver
				16429, -- Soul Weaver
			},
		},
		onactivate = {
			tracing = {15990}, -- Kel'Thuzad
			combatstop = true,
			defeat = 15990,
		},
		userdata = {},
		onstart = {
			{
				"alert","ktarrivescd",
			}
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			fissurewarn = {
				varname = format(L.alert["%s Warning"],SN[27810]),
				type = "simple",
				text = format(L.alert["%s Spawned"],SN[27810]),
				time = 1.5,
				sound = "ALERT1",
				color1 = "BLACK",
				icon = ST[27810],
			},
			frostblastwarn = {
				varname = format(L.alert["%s Warning"],SN[27808]),
				type = "simple",
				text = format(L.alert["%s Cast"],SN[27808]),
				time = 1.5,
				sound = "ALERT2",
				throttle = 5,
				color1 = "BLUE",
				icon = ST[27808],
			},
			detonatewarn = {
				varname = format(L.alert["%s Warning"],SN[29870]),
				type = "centerpopup",
				text = format("%s: %s!",SN[29870],L.alert["YOU"]),
				time = 5,
				sound = "ALERT3",
				color1 = "WHITE",
				flashscreen = true,
				icon = ST[29870],
			},
			ktarrivescd = {
				varname = format(L.alert["%s Arrival"],L.npc_naxxramas["Kel'Thuzad"]),
				type = "dropdown",
				text = format(L.alert["%s Arrives"],L.npc_naxxramas["Kel'Thuzad"]),
				time = 225,
				color1 = "RED",
				flashtime = 5,
				icon = ST[586],
			},
			guardianswarn = {
				varname = format(L.alert["%s Spawns"],SN[4070]),
				type = "centerpopup",
				text = format(L.alert["%s Spawns"],SN[4070]),
				time = 10,
				flashtime = 3,
				sound = "ALERT1",
				color1 = "MAGENTA",
				icon = ST[4070],
			},
		},
		announces = {
			detonatesay = {
				varname = format(L.alert["Say %s on self"],SN[29870]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[29870]).."!",
			},
		},
		events = {
			-- Fissure
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 27810,
				execute = {
					{
						"alert","fissurewarn",
					},
				},
			},
			-- Frost blast
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 27808,
				execute = {
					{
						"alert","frostblastwarn",
					},
				},
			},
			-- Mana detonate
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 27819,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","detonatewarn",
						"announce","detonatesay",
					},
				},
			},
			-- Guardians
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["^Very well. Warriors of the frozen wastes, rise up!"]},
						"alert","guardianswarn",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

---------------------------------
-- LOATHEB
---------------------------------

do

	local data = {
		version = 300,
		key = "loatheb",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Loatheb"],
		triggers = {
			scan = 16011, -- Loatheb
		},
		onactivate = {
			tracing = {16011}, -- Loatheb
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 16011,
		},
		userdata = {
			sporetimer = 15,
		},
		onstart = {
			{
				"alert","sporespawncd",
				"expect",{"&difficulty&","==","1"},
				"set",{sporetimer = 30},
			}
		},
		alerts = {
			necroauradur = {
				varname = format(L.alert["%s Duration"],SN[55593]),
				type = "dropdown",
				text = format(L.alert["%s Fades"],SN[55593]),
				time = 17,
				flashtime = 7,
				sound = "ALERT2",
				color1 = "MAGENTA",
				icon = ST[55593],
			},
			openhealsdur = {
				varname = format(L.alert["%s Duration"],SN[37455]),
				type = "centerpopup",
				text = L.alert["Open Healing"],
				time = 3,
				sound = "ALERT3",
				color1 = "GREEN",
				icon = ST[53765],
			},
			sporespawncd = {
				varname = format(L.alert["%s Timer"],SN[29234]),
				type = "dropdown",
				text = SN[29234],
				time = "<sporetimer>",
				flashtime = 5,
				sound = "ALERT1",
				color1 = "ORANGE",
				icon = ST[35336],
				counter = true,
			},
		},
		timers = {
			healtime = {
				{
					"quash","necroauradur",
					"alert","openhealsdur",
				},
			},
		},
		events = {
			-- Necrotic aura
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 55593,
				execute = {
					{
						"alert","necroauradur",
						"scheduletimer",{"healtime", 17},
					},
				},
			},
			-- Spore
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 29234,
				execute = {
					{
						"alert","sporespawncd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end



---------------------------------
-- MAEXXNA
---------------------------------

do

	local data = {
		version = 299,
		key = "maexxna",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Maexxna"],
		triggers = {
			scan = 15952, -- Maexxna
		},
		onactivate = {
			tracing = {15952}, -- Maexxna
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15952,
		},
		userdata = {},
		onstart = {
			{
				"alert","spraycd",
				"alert","spidercd",
			}
		},
		alerts = {
			spraycd = {
				varname = format(L.alert["%s Cooldown"],SN[29484]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[29484]),
				time = 40,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "YELLOW",
				icon = ST[29484],
			},
			spidercd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Spider"]),
				type = "dropdown",
				text = format(L.alert["%s Spawns"],L.alert["Spider"]),
				time = 30,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "ORANGE",
				icon = ST[51069],
			},
			enragewarn = {
				varname = format(L.alert["%s Warning"],L.alert["Enrage"]),
				type = "simple",
				text = format("%s!",L.alert["Enraged"]),
				time = 1.5,
				sound = "ALERT3",
				icon = ST[12317],
			},
		},
		events = {
			-- Spray
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {29484,54125},
				execute = {
					{
						"alert","spraycd",
						"alert","spidercd",
					},
				},
			},
			-- Enrage
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {54123,54124},
				execute = {
					{
						"alert","enragewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- NOTH
---------------------------------

do

	local data = {
		version = 300,
		key = "noththeplaguebringer",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Noth the Plaguebringer"],
		triggers = {
			scan = {
				15954, -- Noth
				16983, -- Plagued Champion
				16981, -- Plagued Guardian
			},
		},
		onactivate = {
			tracing = {15954}, -- Noth
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15954,
		},
		userdata = {
			roomtime = {90,110,180,loop = false, type = "series"},
			balconytime = {70,95,120,loop = false, type = "series"},
		},
		onstart = {
			{
				"alert","teleportbalccd",
				"expect",{"&difficulty&","==","2"},
				"alert","blinkcd",
			}
		},
		alerts = {
			blinkcd = {
				varname = format(L.alert["%s Cooldown"],SN[29208]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[29208]),
				time = 30,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "MAGENTA",
				icon = ST[29208],
			},
			teleportbalccd = {
				varname = L.alert["Teleport to Balcony"],
				type = "dropdown",
				text = L.alert["Teleport to Balcony"],
				time = "<roomtime>",
				flashtime = 5,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[66548],
			},
			teleportroomcd = {
				varname = L.alert["Teleport to Room"],
				type = "dropdown",
				text = L.alert["Teleport to Room"],
				time = "<balconytime>",
				flashtime = 5,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[29231],
			},
			cursewarn = {
				varname = format(L.alert["%s Warning"],L.alert["Curse"]),
				type = "simple",
				text = format(L.alert["%s Cast"],L.alert["Curse"]).."!",
				time = 1.5,
				sound = "ALERT3",
				icon = ST[29213],
			},
		},
		events = {
			-- Curses
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {29213,54835},
				execute = {
					{
						"alert","cursewarn",
					},
				},
			},
			-- Emotes
			{
				type = "event",
				event = "CHAT_MSG_RAID_BOSS_EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["blinks away"]},
						"alert","blinkcd",
					},
					{
						"expect",{"#1#","find",L.chat_naxxramas["teleports to the balcony"]},
						"quash","blinkcd",
						"alert","teleportroomcd",
					},
					{
						"expect",{"#1#","find",L.chat_naxxramas["teleports back into battle"]},
						"alert","teleportbalccd",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end


---------------------------------
-- PATCHWERK
---------------------------------

do

	local data = {
		version = 299,
		key = "patchwerk",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Patchwerk"],
		triggers = {
			scan = 16028,
		},
		onactivate = {
			tracing = {16028},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 16028,
		},
		userdata = {},
		onstart = {
			{
				"alert","enragecd",
			}
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 360,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "RED",
				icon = ST[12317],
			},
			enragewarn = {
				varname = format(L.alert["%s Warning"],L.alert["Enrage"]),
				type = "simple",
				text = L.alert["Enraged"].."!",
				time = 1.5,
				sound = "ALERT1",
				icon = ST[40735],
			},
		},
		events = {
			-- Enrage
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 28131,
				execute = {
					{
						"alert","enragewarn",
						"quash","enragecd",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end


---------------------------------
-- RAZUVIOUS
---------------------------------

do

	local data = {
		version = 299,
		key = "instructorrazuvious",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Instructor Razuvious"],
		triggers = {
			scan = {
				16061, -- Razuvious
				16803, -- Death Knight Understudy
			},
			yell = L.chat_naxxramas["^The time for practice is over!"],
		},
		onactivate = {
			tracerstop = true,
			combatstop = true,
			tracing = {16061}, -- Razuvious
			defeat = 16061,
		},
		userdata = {},
		onstart = {
			{
				"alert","shoutcd",
			}
		},
		alerts = {
			shoutcd = {
				varname = format(L.alert["%s Cooldown"],SN[55543]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[55543]),
				time = 15,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "MAGENTA",
				icon = ST[55543],
			},
			tauntdur = {
				varname = format(L.alert["%s Duration"],SN[355]),
				type = "dropdown",
				text = format(L.alert["%s Duration"],SN[355]),
				time = 20,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "BLUE",
				icon = ST[355],
			},
			shieldwalldur = {
				varname = format(L.alert["%s Duration"],SN[871]),
				type = "dropdown",
				text = format(L.alert["%s Duration"],SN[871]),
				time = 20,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "YELLOW",
				icon = ST[871],
			},
		},
		events = {
			-- Disrupting shout
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {29107,55543},
				execute = {
					{
						"alert","shoutcd",
					},
				},
			},
			-- Taunt
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 29060,
				execute = {
					{

						"alert","tauntdur",
					},
				},
			},
			-- Shield wall
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 29061,
				execute = {
					{
						"alert","shieldwalldur",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- SAPPHIRON
---------------------------------

do

	local data = {
		version = 300,
		key = "sapphiron",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Sapphiron"],
		triggers = {
			scan = 15989, -- Sapphiron
		},
		onactivate = {
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			tracing = {15989}, -- Sapphiron
			defeat = 15989,
		},
		userdata = {},
		onstart = {
			{
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
				time = 900,
				flashtime = 5,
				color1 = "RED",
				color2 = "RED",
				icon = ST[12317],
			},
			lifedraincd = {
				varname = format(L.alert["%s Cooldown"],SN[28542]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[28542]),
				time = 23,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "MAGENTA",
				icon = ST[28542],
			},
			airphasedur = {
				varname = format(L.alert["%s Duration"],L.alert["Air Phase"]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],L.alert["Air Phase"]),
				time = 15.5,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "YELLOW",
				icon = ST[51475],
			},
			deepbreathwarn = {
				varname = format(L.alert["%s Warning"],L.alert["Deep Breath"]),
				type = "centerpopup",
				text = format("%s! %s!",L.alert["Deep Breath"],L.alert["HIDE"]),
				time = 10,
				flashtime = 6.5,
				sound = "ALERT1",
				color1 = "BLUE",
				flashscreen = true,
				icon = ST[28524],
			},
		},
		raidicons = {
			iceboltmark = {
				varname = SN[28522],
				type = "MULTIFRIENDLY",
				persist = 25,
				unit = "#5#",
				icon = 1,
				total = 5,
				reset = 10,
			},
		},
		announces = {
			iceboltsay = {
				varname = format(L.alert["Say %s on self"],SN[28522]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[28522]).."!",
			},
		},
		events = {
			-- Icebolt
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 28522,
				execute = {
					{
						"raidicon","iceboltmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"announce","iceboltsay",
					},
				},
			},
			-- Life drain
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28542,55665},
				execute = {
					{
						"alert","lifedraincd",
					},
				},
			},
			-- Emotes
			{
				type = "event",
				event = "CHAT_MSG_RAID_BOSS_EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["lifts"]},
						"alert","airphasedur",
						"quash","lifedraincd",
					},
					{
						"expect",{"#1#","find",L.chat_naxxramas["deep"]},
						"quash","airphasedur",
						"alert","deepbreathwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


---------------------------------
-- THADDIUS
---------------------------------

do

	local data = {
		version = 299,
		key = "thaddius",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Thaddius"],
		triggers = {
			scan = {
				15928, -- Thaddius
				15929, -- Stalagg
				15930, -- Feugen
			},
			yell = {
        L.chat_naxxramas["Stalagg crush you!"],
        L.chat_naxxramas["Feed you to master!"]
      },
		},
		onactivate = {
			tracing = {
				15928, -- Thaddius
				15929, -- Stalagg
				15930, -- Feugen
			},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15928,
		},
		userdata = {
			dead = 0,
		},
		onacquired = {
			[15928] = { -- Thaddius
				{
					"resettimer",true,
					"alert","enragecd",
					"quash","tankthrowcd",
					"canceltimer","tankthrow",
					"tracing",{15928}, -- Thaddius
				},
			},
		},
		onstart = {
			{
				"alert","tankthrowcd",
				"scheduletimer",{"tankthrow", 20.6},
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 360,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "RED",
				icon = ST[12317],
			},
			tankthrowcd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Tank Throw"]),
				type = "dropdown",
				text = format(L.alert["Next %s"],L.alert["Tank Throw"]),
				time = 20.6,
				flashtime = 3,
				sound = "ALERT2",
				color1 = "MAGENTA",
				icon = ST[52272],
			},
			polarityshiftwarn = {
				varname = format(L.alert["%s Casting"],SN[28089]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[28089]),
				time = 3,
				flashtime = 3,
				sound = "ALERT1",
				color1 = "BLUE",
				flashscreen = true,
				icon = ST[28089],
			},
		},
		timers = {
			tankthrow = {
				{
					"alert","tankthrowcd",
					"scheduletimer",{"tankthrow", 20.6},
				},
			},
		},
		events = {
			-- Polarity shift
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 28089,
				execute = {
					{
						"alert","polarityshiftwarn",
					},
				},
			},
			-- Emotes
			{
				type = "event",
				event = "CHAT_MSG_RAID_BOSS_EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["overloads"]},
						"set",{dead = "INCR|1"},
						"expect",{"<dead>",">=","2"},
						"quash","tankthrowcd",
						"canceltimer","tankthrow",
						"tracing",{15928}, -- Thaddius
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
