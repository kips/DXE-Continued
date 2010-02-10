do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 14,
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
		},
		onstart = {
			{
				"alert","cultcd",
				"alert","enragecd",
				"scheduletimer",{"firecult",7},
			},
		},
		timers = {
			firecult = {
				{
					"alert","cultcd",
					"scheduletimer",{"firecult",60},
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
				color1 = "PURPLE",
				icon = ST[71001],
				flashscreen = true,
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
				text = format("%s: #5#!",SN[71289]),
				type = "simple",
				time = 3,
				color1 = "GREY",
				sound = "ALERT6",
				icon = ST[71289],
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
		events = {
			-- Death and Decay self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71001,
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
						"expect",{"#4#","~=","&playerguid&"},
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
					72007, -- 25
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
					72007, -- 25
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
