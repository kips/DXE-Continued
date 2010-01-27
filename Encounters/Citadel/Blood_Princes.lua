do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 8,
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
			unittracing = {
				"boss1", -- Valanar
				"boss2", -- Keleseth
				"boss3", -- Taldaram
			},
		},
		userdata = {
			invocationtime = {33,46.5,loop = false, type = "series"},
			shocktext = "",
		},
		onstart = {
			{
				"alert","invocationcd",
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
			shockwarn = {
				varname = format(L.alert["%s Cast"],SN[72037]),
				type = "simple",
				text = format("%s: &tft_unitname&",SN[72037]),
				time = 3,
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
				persist = 5,
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
		timers = {
			fireshock = {
				{
					"expect",{"&tft_unitexists& &tft_isplayer&","==","1 1"},
					"set",{shocktext = format("%s: %s!",SN[72037],L.alert["YOU"])},
					"raidicon","shockmark",
					"alert","shockwarn",
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
			-- Shock Vortex
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72037, -- 25
					71944, -- 10
				},
				execute = {
					{
						"scheduletimer",{"fireshock",0.5},
					},
				},
			},
			-- Inferno Flames
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^Inferno Flames speed"]},
						"raidicon","infernomark",
						"expect",{"#5#","==","&playername&"},
						"alert","infernoself",
					},
					{
						"expect",{"#1#","find",L.chat_citadel["^Inferno Flames speed"]},
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
					70983,
					70982, -- Taldaram gains
					70981, -- Keleseth gains
					71582,
					70934,
					71596,
					70952,
				},
				execute = {
					{
						"alert","invocationcd",
						"alert","invocationwarn",
					},
				}	
			},
			-- Empowered Shock
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					73037, -- 25
					72039,
				},
				execute = {
					{
						"alert","empoweredshockwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
