do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local L_Grobbulus = L.npc_naxxramas["Grobbulus"]

	local data = {
		version = 299,
		key = "grobbulus",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas_Grobbulus,
		triggers = {
			scan = 15931, -- Grobbulus
		},
		onactivate = {
			tracing = {15931},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15931,
		},
		userdata = {},
		onstart = {
			{
				"alert","enragecd",
			}
		},
		alerts = {
			enragecd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Enrage"]),
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 360,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			injectionwarnself = {
				varname = format(L.alert["%s on self"],L.alert["Injection"]),
				type = "centerpopup",
				text = format("%s: %s! %s!",L.alert["Injection"],L.alert["YOU"],L.alert["MOVE"]),
				time = 10,
				flashtime = 10,
				sound = "ALERT1",
				color1 = "RED",
				color2 = "MAGENTA",
				flashscreen = true,
				icon = ST[28169],
			},
			injectionwarnothers = {
				varname = format(L.alert["%s on others"],L.alert["Injection"]),
				type = "centerpopup",
				text = format("%s: #5#",L.alert["Injection"]),
				time = 10,
				color1 = "ORANGE",
				icon = ST[28169],
			},
			cloudcd = {
				varname = format(L.alert["%s Cooldown"],SN[28240]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[28240]),
				time = 15,
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[28240],
			},
		},
		events = {
			-- Injection
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 28169,
				execute = {
					{
						"expect",{"#4#", "==", "&playerguid&"},
						"alert","injectionwarnself",
					},
					{
						"expect",{"#4#", "~=", "&playerguid&"},
						"alert","injectionwarnothers",
					},
				},
			},
			-- Poison cloud
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 28240,
				execute = {
					{
						"alert","cloudcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

