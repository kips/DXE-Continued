do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 299,
		key = "maexxna", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas["Maexxna"], 
		triggers = {
			scan = 15952, -- Maexxna
		},
		onactivate = {
			tracing = {15952}, -- Maexxna
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15952,
		},
		userdata = {},
		onstart = {
			{
				"alert","spraycd",
				"alert","spidercd",
			}
		},
		alerts = {
			spraycd = {
				varname = format(L.alert["%s Cooldown"],SN[29484]),
				type = "dropdown", 
				text = format(L.alert["Next %s"],SN[29484]),
				time = 40, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "YELLOW", 
				icon = ST[29484],
			},
			spidercd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Spider"]),
				type = "dropdown", 
				text = format(L.alert["%s Spawns"],L.alert["Spider"]),
				time = 30, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "ORANGE", 
				icon = ST[51069],
			},
			enragewarn = {
				varname = format(L.alert["%s Warning"],L.alert["Enrage"]),
				type = "simple", 
				text = format("%s!",L.alert["Enraged"]),
				time = 1.5, 
				sound = "ALERT3",
				icon = ST[12317],
			},
		},
		events = {
			-- Spray
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {29484,54125}, 
				execute = {
					{
						"alert","spraycd", 
						"alert","spidercd",
					},
				},
			},
			-- Enrage
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {54123,54124},
				execute = {
					{
						"alert","enragewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
