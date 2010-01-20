do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 322,
		key = "jaraxxus", 
		zone = L.zone["Trial of the Crusader"], 
		category = L.zone["Coliseum"],
		name = L.npc_coliseum["Lord Jaraxxus"], 
		triggers = {
			scan = {
				34780, -- Jaraxxus
				34826, -- Mistress of Pain
			}, 
		},
		onactivate = {
			tracing = {34780,34826},
			tracerstart = true,
			combatstop = true,
			defeat = 34780,
		},
		userdata = {
			eruptiontime = {80,120, loop = false, type = "series"},
			portaltime = {20,120, loop = false, type = "series"},
			fleshtime = {14, 21, loop = false, type = "series"},
			flametime = {9, 30, loop = false, type = "series"},
			mistresstime = 8,
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"},
				"tracing",{
					34780, -- Jaraxxus
					34826, -- Mistress
					34825, -- Nether Portal
					34813, -- Infernal Volcano
				},
				"set",{mistresstime = 6},
			},
			{
				"alert","enragecd",
				"alert","portalcd",
				"alert","legionflamecd",
				"alert","eruptioncd",
				"alert","fleshcd",
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				text = L.alert["Enrage"],
				type = "dropdown",
				time = 600,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			legionflameself = {
				varname = format(L.alert["%s on self"],SN[68123]),
				text = format("%s: %s!",SN[68123],L.alert["YOU"]),
				type = "centerpopup",
				time = 8, -- +2 seconds because it falls off and then reapplies
				flashtime = 8,
				color1 = "GREEN",
				color2 = "MAGENTA",
				flashscreen = true,
				sound = "ALERT1",
				icon = ST[68123],
			},
			legionflamecd = {
				varname = format(L.alert["%s Cooldown"],SN[68123]),
				text = format(L.alert["%s Cooldown"],SN[68123]),
				type = "dropdown",
				time = "<flametime>",
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[68123],
			},
			legionflameproximitywarn = {
				varname = format(L.alert["%s Proximity Warning"],SN[68123]),
				text = format("%s: #5#! %s!",SN[68123],L.alert["MOVE AWAY"]),
				type = "simple",
				time = 2,
				color1 = "GOLD",
				sound = "ALERT3",
				icon = ST[68123],
				flashscreen = true,
			},
			fleshself = {
				varname = format(L.alert["%s on self"],SN[67051]),
				text = format("%s: %s!",SN[67051],L.alert["YOU"]),
				type = "centerpopup",
				time = 12,
				flashtime = 12,
				color1 = "ORANGE",
				color2 = "BLACK",
				flashscreen = true,
				sound = "ALERT2",
				icon = ST[67051],
			},
			fleshwarn = {
				varname = format(L.alert["%s on others"],SN[67051]),
				text = format("%s: #5#!",SN[67051]),
				type = "centerpopup",
				time = 12,
				flashtime = 12,
				color1 = "ORANGE",
				icon = ST[67051],
			},
			fleshcd = {
				varname = format(L.alert["%s Cooldown"],SN[67051]),
				text = format(L.alert["%s Cooldown"],SN[67051]),
				type = "dropdown",
				time = "<fleshtime>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[67051],
			},
			eruptioncd = {
				varname = format(L.alert["%s Cooldown"],SN[67901]),
				text = format(L.alert["Next %s"],SN[67901]),
				type = "dropdown",
				time = "<eruptiontime>",
				flashtime = 10,
				color1 = "BROWN",
				icon = ST[67901],
			},
			portalcd = {
				varname = format(L.alert["%s Cooldown"],SN[67898]),
				text = format(L.alert["Next %s"],SN[67898]),
				type = "dropdown",
				time = "<portaltime>",
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[67898],
			},
			netherpowerwarn = {
				varname = format(L.alert["%s Warning"],SN[66228]),
				text = format("%s! %s!",SN[66228],L.alert["DISPEL"]),
				type = "simple",
				time = 3,
				color1 = "WHITE",
				sound = "ALERT4",
				icon = ST[66228],
			},
			mistresswarn = {
				varname = format(L.alert["%s Timer"],L.npc_coliseum["Mistress of Pain"]),
				text = format(L.alert["%s Spawns"],L.npc_coliseum["Mistress of Pain"]).."!",
				type = "centerpopup",
				time = "<mistresstime>",
				color1 = "TAN",
				icon = ST[67905],
			},
			kissselfdur = {
				type = "centerpopup",
				varname = format(L.alert["%s on self"],SN[67907]),
				text = format("%s: %s! %s!",SN[67907],L.alert["YOU"],L.alert["CAREFUL"]),
				time = 15,
				flashtime = 15,
				color1 = "CYAN",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[67907],
			},
			felinfernowarn = {
				type = "simple",
				varname = format(L.alert["%s on self"],SN[68718]),
				text = format("%s: %s! %s!",SN[68718],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				sound = "ALERT7",
				flashscreen = true,
				icon = ST[68718],
				throttle = 3,
			},
		},
		arrows = {
			flamearrow = {
				varname = SN[68123],
				unit = "#5#",
				persist = 3,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[68123],
				sound = "ALERT8",
			},
		},
		raidicons = {
			legionflamemark = {
				varname = SN[68123],
				type = "FRIENDLY",
				persist = 6,
				unit = "#5#",
				icon = 2,
			},
			fleshmark = {
				varname = SN[67051],
				type = "FRIENDLY",
				persist = 12,
				unit = "#5#",
				icon = 1,
			},
		},
		announces = {
			flamesay = {
				varname = format(L.alert["Say %s on self"],SN[68123]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[68123]).."!",
			},
		},
		events = {
			-- Legion Flame Note: Use spellid with buff description 'Flame begins to spread from your body!'
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					68125,
					68124, -- 10 hard
					66197, -- 10 normal
					68123, -- 25 normal
				},
				execute = {
					{
						"alert","legionflamecd",
						"raidicon","legionflamemark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","legionflameself",
						"announce","flamesay",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"proximitycheck",{"#5#",11},
						"alert","legionflameproximitywarn",
						"arrow","flamearrow",
					},
				},
			},
			-- Incinerate Flesh
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67050, -- 10 hard
					67051,
					66237, -- 10 normal
					67049, -- 25 normal
				},
				execute = {
					{
						"alert","fleshcd",
						"raidicon","fleshmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","fleshself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","fleshwarn",
					},
				},
			},
			-- Incinerate Flesh - Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67050, -- 10 hard
					67051,
					66237, -- 10 normal
					67049, -- 25 normal
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","fleshself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","fleshwarn",
					},
				},
			},
			-- Infernal Eruption
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					67902, -- 10 hard
					67903,
					66258, -- 10 normal
					67901, -- 25 normal
				},
				execute = {
					{
						"alert","eruptioncd",
					},
				},
			},
			-- Nether Portal
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					67900,
					66269, -- 10 normal
					67898, -- 25 normal
					67899, -- 10m hard
				},
				execute = {
					{
						"alert","portalcd",
						"alert","mistresswarn",
					},
				},
			},
			-- Nether Power
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 67009, -- 10/25 normal
				execute = {
					{
						"alert","netherpowerwarn",
					},
				},
			},
			-- Mistress' Kiss (hard)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67906, -- 10 hard
					67907, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","kissselfdur",
					},
				},
			},
			-- Mistress' Kiss removal (hard)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67906, -- 10 hard
					67907, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","kissselfdur",
					},
				},
			},
			-- Fel Inferno
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					68718, -- 25 hard
					68716, -- 25 normal
					68717, -- 10 hard
					66496, -- 10 normal
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","felinfernowarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
