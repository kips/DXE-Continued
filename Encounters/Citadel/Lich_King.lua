do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 42,
		key = "lichking", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Lich King"], 
		triggers = {
			scan = 36597, -- Lich King
			yell = L.chat_citadel["^So the Light's vaunted justice has finally arrived"],
		},
		onactivate = {
			combatstop = true,
			tracing = {
				36597, -- Lich King
			},
		},
		onstart = {
			{
				"alert","zerotoonecd",
			},
		},
		userdata = {
			phase = "1",
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
				color1 = "RED",
				icon = ST[12317],
			},
			necroplaguedur = {
				varname = format(L.alert["%s Duration"],SN[70337]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[70338]), 
				time = 15,
				flashtime = 15,
				color1 = "GREEN",
				icon = ST[70337],
			},
			necroplagueself = {
				varname = format(L.alert["%s on self"],SN[70337]),
				type = "centerpopup",
				text = format("%s: %s!",SN[70337],L.alert["YOU"]).."!",
				time = 15,
				flashtime = 15,
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
				varname = format(L.alert["%s Warning"],SN[72762]),
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
				text = format(L.alert["%s Warning"],SN[69409]),
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
		},
		announces = {
			defilesay = {
				varname = format(L.alert["Say %s on self"],SN[72762]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[72762]).."!",
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
		},
		events = {
			-- Yell
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^I'll keep you alive to witness the end, Fordring"]},
						"alert","enragecd",
						"alert","infestcd",
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
						"expect",{"#4#","==","&playerguid&"},
						"alert","necroplagueself",
						"raidicon","necroplaguemark",
						"announce","necroplaguesay",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","necroplaguedur",
						"raidicon","necroplaguemark",
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
					70337, --10
					70338, --10
					73785, --25
					73912, --25
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
				spellid = 72762, -- 10/25
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
					73708, -- 25
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
				},
				execute = {
					{
						"alert","remorsewarn",
						"set",{phase = "<nextphase>"},
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
