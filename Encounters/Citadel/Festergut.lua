do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 5,
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
			inhaletime = {29, 33.5, loop = false}, -- placeholder
			sporetime = {21,40,40,51, loop=false}, -- placeholder
			pungenttime = {133, 138, loop = false},
			gastrictext = "",
		},
		onstart = {
			{
				"alert","gassporecd",
				"alert","inhaleblightcd",
				"alert","pungentblightcd",
				"alert","enragecd",
				"set",{sporetime = {40,40,40,51,loop = true}},
				"set",{inhaletime = {33.5,33.5,33.5,68, loop = true}},
			},
		},
		alerts = {
			enragecd = {
				varname = L.alerts["Enrage"],
				type = "dropdown",
				text = L.alerts["Enrage"],
				time = 300,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			inhaleblightcd = {
				varname = format(L.alerts["%s Cooldown"],SN[69165]),
				type = "dropdown",
				text = format(L.alerts["%s Cooldown"],SN[69165]),
				time = "<inhaletime>",
				color1 = "GREY",
				flashtime = 10,
				icon = ST[69165],
			},
			inhaleblightwarn = {
				varname = format(L.alerts["%s Cast"],SN[69165]),
				type = "centerpopup",
				text = format(L.alerts["%s Cast"],SN[69165]),
				time = 3.5,
				flashtime = 3.5,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[69165],
			},
			gassporecd = {
				varname = format(L.alerts["%s Cooldown"],SN[71221]),
				type = "dropdown",
				text = format(L.alerts["%s Cooldown"],SN[71221]),
				time = "<sporetime>",
				color1 = "YELLOW",
				flashtime = 5,
				icon = ST[71221],
			},
			gassporedur = {
				varname = format(L.alerts["%s Duration"],SN[71221]),
				type = "centerpopup",
				text = format(L.alerts["%s Duration"],SN[71221]),
				time = 12,
				flashtime = 12,
				color1 = "MAGENTA",
				sound = "ALERT2",
				flashscreen = true,
				icon = ST[71221],
			},
			gassporeself = {
				varname = format(L.alerts["%s on self"],SN[71221]),
				type = "simple",
				text = format("%s: %s!",SN[71221],L.alerts["YOU"]).."!",
				time = 3,
				icon = ST[71221],
			},
			vilegascd = {
				varname = format(L.alerts["%s Cooldown"],SN[71218]),
				type = "dropdown",
				text = format(L.alerts["%s Cooldown"],SN[71218]),
				time = 20,
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[71288],
			},
			vilegaswarn = {
				varname = format(L.alerts["%s Warning"],SN[71218]),
				type = "simple",
				text = format(L.alerts["%s Casted"],SN[71218]).."!",
				time = 3,
				color1 = "GREEN",
				sound = "ALERT3",
				icon = ST[71288],
				throttle = 2,
			},
			pungentblightwarn ={
				varname = format(L.alerts["%s Cast"],SN[71219]),
				type = "centerpopup",
				text = format(L.alerts["%s Cast"],SN[71219]),
				time = 3,
				flashtime = 3,
				color1 = "PURPLE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[71219],
			},
			pungentblightcd = {
				varname = format(L.alerts["%s Cooldown"],SN[71219]),
				type = "dropdown",
				text = format(L.alerts["%s Cooldown"],SN[71219]),
				time = "<pungenttime>",
				color1 = "DCYAN",
				flashtime = 10,
				icon = ST[71219],
			},
			gastricbloatwarn = {
				varname = format(L.alerts["%s Warning"],SN[72551]),
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
			-- Gas Spore on self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71221, -- 25
					69279, -- 10
				},
				execute = {
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
						"set",{gastrictext = format("%s: %s!",SN[72551],L.alerts["YOU"])},
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
						"set",{gastrictext = format("%s: %s! %s!",SN[72551],L.alerts["YOU"],format(L.alerts["%s Stacks"],"#11#"))},
						"alert","gastricbloatwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{gastrictext = format("%s: #5#! %s!",SN[72551],format(L.alerts["%s Stacks"],"#11#")) },
						"alert","gastricbloatwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
