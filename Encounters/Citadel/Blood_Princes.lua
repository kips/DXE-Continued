do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 4,
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
			tracing = {
				37970, -- Valanar
				37972, -- Keleseth
				37973, -- Taldaram
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
			empoweredshockwarn = {
				varname = format(L.alert["%s Casting"],SN[73037]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[73037]),
				time = 4.5,
				flashtime = 4.5,
				color1 = "GREY",
				sound = "ALERT1",
				icon = ST[73037],
				flashscreen = true,
			},
			infernoself = {
				varname = format(L.alert["%s on self"],L.alert["Inferno Flame"]),
				type = "simple",
				text = format("%s: %s! %s!",L.alert["Inferno Flame"],L.alert["YOU"],L.alert["RUN"]),
				time = 3,
				color1 = "ORANGE",
				icon = ST[62910],
				flashscreen = true,
			},
			infernowarn = {
				varname = format(L.alert["%s on others"],L.alert["Inferno Flame"]),
				type = "simple",
				text = format("%s: #5#! %s!",L.alert["Inferno Flame"],L.alert["MOVE AWAY"]),
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
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = L.alert["Inferno Flame"],
			},
		},
		windows = {
			proxwindow = true,
		},
		events = {
			-- Inferno Flames
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^Inferno Flames speed"]},
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
						"alert","invocationwarn",
					},
				}	
			},
			-- Empowered Shock
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 73037,
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
--[[
shock vortex explodes
]]
