do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 16,
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
			teargas = "0",
			malleabletext = "",
			mutatedtext = "",
			puddletime = 10,
			puddletimeaftergas = {10,15,loop = false, type = "series"},
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
			unboundplaguewarn = {
				varname = format(L.alert["%s Warning"],SN[72855]),
				type = "simple",
				text = format("%s: %s!",SN[72855],"#5#"),
				time = 5,
				icon = SN[72855],
			},
			unboundplagueself = {
				varname = format(L.alert["%s on self"],SN[72855]),
				type = "simple",
				text = format("%s: %s!",SN[72855],L.alert["YOU"]),
				time = 5,
				icon = SN[72855],
				flashscreen = true,
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
			unboundplaguesay = {
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
				spellid = 71615,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{malleabletime = 6, experimenttime = 20, gasbombtime = 16, puddletime = "<puddletimeaftergas>"},
						"alert","malleablegoocd",
						"alert","gasbombcd",
						"alert","puddlecd",
						"set",{malleabletime = 25.5, experimenttime = 37.5, gasbombtime = 35.5, puddletime = 35},
						"expect",{"<teargas>","==","0"},
						"alert","unstableexperimentcd",
						"set",{teargas = "1"},
					},
				},
			},
			-- Gaseous Bloat
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72455, -- 25
					70672, -- 10
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
					72455, -- 25
					70672, -- 10
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
					71966,
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
					70346, -- 10 Slime Puddle
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","mutatedslimeself",
					},
				},
			},
			-- Unbound Plauge
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 72855,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","unboundplagueself",
						"raidicon","unboundplaguemark",
						"announce","unboundplaguesay",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","unboundplaguewarn",
						"raidicon","unboundplaguemark",
					},
				},
			},
			-- Unbound Plauge removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 72855,
				execute = {
					{
						"quash", "unboundplaguewarn",
					},
				},
			}
		},
	}

	DXE:RegisterEncounter(data)
end
