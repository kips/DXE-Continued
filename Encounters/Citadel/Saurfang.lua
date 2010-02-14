do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 12,
		key = "saurfang", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Saurfang"], 
		triggers = {
			scan = {
				37813, -- Deathbringer Saurfang
			},
		},
		userdata = {
			bloodtext = "",
			markfallentext = "",
			runebloodtime = {22,20,loop = false, type = "series"},
			enragetime = 480,
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {37813,powers={true}}, -- Deathbringer Saurfang
			defeat = 37813,
		},
		onstart = {
			{
				"alert","bloodbeastcd",
				"alert","enragecd",
				"alert","runeofbloodcd",
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 480,
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
