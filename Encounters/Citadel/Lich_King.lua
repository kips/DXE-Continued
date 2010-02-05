do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 3,
		key = "lichking", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Lich King"], 
		triggers = {
			scan = 36597, -- Lich King
			yell = L.chat_citadel["^I'll keep you alive to witness the end, Fordring"],
		},
		onactivate = {
			combatstop = true,
			tracing = {
				36597, -- Lich King
			},
		},
		userdata = {
			phase = "1",
			defiletext = "",
			necroplaguetext = "",
		},
		alerts = {
			necroplaguedur = {
				varname = format(L.alert["%s Duration"],SN[70337]),
				type = "centerpopup",
				text = "<necroplaguetext>",
				time = 15,
				flashtime = 15,
				color1 = "GREEN",
				icon = ST[70337],
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
			defilewarn = {
				varname = format(L.alert["%s Warning"],SN[72762]),
				type = "centerpopup",
				text = "<defiletext>",
				time = 2,
				flashtime = 2,
				color1 = "PURPLE",
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
			},
		},
		announces = {
			defilesay = {
				varname = format(L.alert["Say %s on self"],SN[72762]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[72762]).."!",
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
					"arrow","defilearrow",
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
			-- Necrotic Plague
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 70337,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{necroplaguetext = format("%s: %s!",SN[70338],L.alert["YOU"])},
						"alert","necroplaguedur",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{necroplaguetext = format("%s: #5#!",SN[70338])},
						"alert","necroplaguedur",
					},
				},
			},
			-- Necrotic Plague dispel
			{
				type = "combatevent",
				eventtype = "SPELL_DISPEL",
				spellid = {
					-- Note: there are two different ones for some reason
					70337,
					70338,
				},
				execute = {
					{
						"quash","necroplaguedur",
					},
				},
			},
			-- Summon Shambling Horror
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 70372, -- 25
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
				spellid = 70372, -- 25
				execute = {
					{
						"quash","shamblinghorrorwarn",
						"alert","shamblinghorrorcd",
					},
				},
			},
			-- Defile
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 72762, -- 10
				execute = {
					{
						"scheduletimer",{"firedefile",0.2},
					},
				},
			},
			-- Defile self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 72762, -- 10
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
				spellid = 68981, -- 10
				execute = {
					{
						"alert","remorsewarn",
					},
				},
			},
			-- Remorseless Winter app
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 68981, -- 10
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
				spellid = 72262, -- 10
				execute = {
					{
						"alert","quakewarn",
					},
				},
			},
			-- Summon Val'kyr
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 69037, -- 10
				execute = {
					{
						"alert","valkyrwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
