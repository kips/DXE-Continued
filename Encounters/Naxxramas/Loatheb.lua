do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 297,
		key = "loatheb", 
		zone = L["Naxxramas"], 
		name = L["Loatheb"], 
		triggers = {
			scan = 16011, -- Loatheb
		},
		onactivate = {
			tracing = {16011}, -- Loatheb
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = { 
			sporecount = 1,
			sporetimer = 15,
		},
		onstart = {
			{
				"alert","sporespawn",
				"expect",{"&difficulty&","==","1"},
				"set",{sporetimer = 30},
			}
		},
		alerts = {
			necroaura = {
				varname = format(L["%s Duration"],SN[55593]),
				type = "dropdown", 
				text = format(L["%s Fades"],SN[55593]),
				time = 17, 
				flashtime = 7, 
				sound = "ALERT2", 
				color1 = "MAGENTA", 
				icon = ST[55593],
			},
			openheals = {
				varname = format(L["%s Duration"],SN[37455]),
				type = "centerpopup", 
				text = L["Open Healing"], 
				time = 3, 
				sound = "ALERT3", 
				color1 = "GREEN", 
				icon = ST[53765],
			},
			sporespawn = {
				varname = format(L["%s Timer"],SN[29234]),
				type = "dropdown", 
				text = format("%s: <sporecount>",SN[29234]),
				time = "<sporetimer>", 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "ORANGE", 
				icon = ST[35336],
			},
		},
		timers = {
			healtime = {
				{
					"quash","necroaura",
					"alert","openheals",
				},
			},
		},
		events = {
			-- Necrotic aura
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 55593, 
				execute = {
					{
						"alert","necroaura", 
						"scheduletimer",{"healtime", 17},
					},
				},
			},
			-- Spore
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 29234, 
				execute = {
					{
						"set",{sporecount = "INCR|1"},
						"alert","sporespawn", 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


