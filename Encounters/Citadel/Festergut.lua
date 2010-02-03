do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 7,
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
				throttle = 2,
			},
			vilegascd = {
				varname = format(L.alert["%s Cooldown"],SN[71218]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71218]),
				time = 20,
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[71288],
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
					73032,
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
		},
	}

	DXE:RegisterEncounter(data)
end
