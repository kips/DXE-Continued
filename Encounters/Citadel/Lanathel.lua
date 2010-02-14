do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 22,
		key = "lanathel", 
		zone = L.zone["Icecrown Citadel"],
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Lana'thel"], 
		triggers = {
			scan = 37955, -- Lana'thel
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {37955}, -- Lana'thel
			defeat = 37955,
		},
		onstart = {
			{
				"expect",{"&difficulty&","==","1"},
				"set",{
					essencetime = 75,
					bloodtime = {127,120, loop = false, type = "series"},
					incitetime = {122,115, loop = false, type = "series"},
				},
			},
			{
				"alert","enragecd",
				"alert","bloodboltcd",
				"alert","inciteterrorcd",
				"alert","pactcd",
				"alert","swarmingshadowcd",
			},
		},
		userdata = {
			bloodtime = {133,100, loop = false, type = "series"},
			incitetime = {128,95, loop = false, type = "series"},
			firedblood = "0",
			essencetime = 60,
			pacttime = {15,30,loop = false, type = "series"},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 320,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			essenceself = {
				varname = format(L.alert["%s on self"],L.alert["Essence"]),
				type = "centerpopup",
				text = format("%s: %s!",L.alert["Essence"],L.alert["YOU"]),
				time = "<essencetime>",
				flashtime = 10,
				color1 = "PURPLE",
				color2 = "MAGENTA",
				icon = ST[71473]
			},
			pactself = {
				varname = format(L.alert["%s on self"],L.alert["Pact"]),
				type = "simple",
				text = format("%s: %s! %s!",L.alert["Pact"],L.alert["YOU"],L.alert["MOVE"]),
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[71340],
			},
			pactremovalself = {
				varname = format(L.alert["%s on self"],format(L.alert["%s Removal"],L.alert["Pact"])),
				type = "simple",
				text = format(L.alert["%s Removed"],L.alert["Pact"]).."! "..L.alert["YOU"].."!",
				time = 3,
				color1 = "GOLD",
				sound = "ALERT4",
				flashscreen = true,
				icon = ST[71340],
			},
			bloodboltcd = {
				varname = format(L.alert["%s Cooldown"],SN[71772]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71772]),
				time = "<bloodtime>",
				color1 = "BROWN",
				sound = "ALERT2",
				flashtime = 10,
				icon = ST[71772],
			},
			bloodboltdur = {
				varname = format(L.alert["%s Duration"],SN[71772]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[71772]),
				time = 6,
				flashtime = 6,
				color1 = "YELLOW",
				sound = "ALERT3",
				icon = ST[71772],
			},
			swarmingshadowself = {
				varname = format(L.alert["%s on self"],SN[71265]),
				type = "centerpopup",
				text = format("%s: %s!",SN[71265],L.alert["YOU"]),
				time = 8.5,
				flashtime = 8.5,
				color1 = "BLACK",
				color2 = "GREEN",
				flashscreen = true,
				icon = ST[71265],
			},
			swarmingshadowothers = {
				varname = format(L.alert["%s on others"],SN[71265]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[71265]),
				time = 8.5,
				flashtime = 8.5,
				color1 = "BLACK",
				icon = ST[71265],
			},
			pactcd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Pact"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Pact"]),
				time = "<pacttime>",
				flashtime = 5,
				color1 = "BLACK",
				sound = "ALERT5",
				icon = ST[71340],
			},
			swarmingshadowcd = {
				varname = format(L.alert["%s Cooldown"],SN[71265]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[71265]),
				time = 30,
				flashtime = 5,
				color1 = "INDIGO",
				icon = ST[71265],
			},
			inciteterrorcd = {
				varname = format(L.alert["%s Cooldown"],SN[73070]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[73070]),
				time = "<incitetime>",
				sound = "ALERT6",
				flashtime = 10,
				color1 = "GREY",
				icon = ST[73070],
			},
		},
		windows = {
			proxwindow = true,
		},
		events = {
			-- Swarming Shadows early
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^Shadows amass and swarm"]},
						"quash","swarmingshadowcd",
						"alert","swarmingshadowcd",
						-- Swarming Shadows self
						"expect",{"#5#","==","&playername&"},
						"alert","swarmingshadowself",
					},
					{
						-- Swarming Shadows others
						"expect",{"#1#","find",L.chat_citadel["^Shadows amass and swarm"]},
						"expect",{"#5#","~=","&playername&"},
						"alert","swarmingshadowothers",
					},
				},
			},
			-- Swarming Shadows others removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 71265,
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","swarmingshadowothers",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","swarmingshadowself",
					},
				},
			},
			-- Pact of the Darkfallen
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 71336, -- 10/25
				execute = {
					{
						"alert","pactcd",
					},
				},
			},
			-- Pact of the Darkfallen applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71340, -- 10/10h/25/25h
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","pactself",
					},
				},
			},
			-- Pact of the Darkfallen removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 71340,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","pactremovalself",
					},
				},
			},
			-- Essence of the Blood Queen
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71473,
					71525,
					70867, -- 10
					71533, -- 25h
					71532, -- 10h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","essenceself",
					},
				},
			},
			-- Bloodbolt Whirl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71772,
				execute = {
					{
						"quash","bloodboltcd",
						"alert","bloodboltdur",
						"expect",{"<firedblood>","==","0"},
						"alert","bloodboltcd",
						"alert","inciteterrorcd",
						"set",{firedblood = 1},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
