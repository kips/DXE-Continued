do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 297,
		key = "maexxna", 
		zone = L["Naxxramas"], 
		name = L["Maexxna"], 
		triggers = {
			scan = 15952, -- Maexxna
		},
		onactivate = {
			tracing = {15952}, -- Maexxna
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
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
				varname = format(L["%s Cooldown"],SN[29484]),
				type = "dropdown", 
				text = format(L["Next %s"],SN[29484]),
				time = 40, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "YELLOW", 
				icon = ST[29484],
			},
			spidercd = {
				varname = format(L["%s Cooldown"],L["Spider"]),
				type = "dropdown", 
				text = format(L["%s Spawns"],L["Spider"]),
				time = 30, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "ORANGE", 
				icon = ST[51069],
			},
			enragewarn = {
				varname = format(L["%s Warning"],L["Enrage"]),
				type = "simple", 
				text = format("%s!",L["Enraged"]),
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
