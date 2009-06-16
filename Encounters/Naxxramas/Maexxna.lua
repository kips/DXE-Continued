do
	local L,SN = DXE.L,DXE.SN

	local L_Maexxna = L["Maexxna"]

	local data = {
		version = "$Rev$",
		key = "maexxna", 
		zone = L["Naxxramas"], 
		name = L_Maexxna, 
		triggers = {
			scan = L_Maexxna, 
		},
		onactivate = {
			tracing = {L_Maexxna,},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "spraycd"},
				{alert = "spidercd"},
			}
		},
		alerts = {
			spraycd = {
				var = "spraycd", 
				varname = format(L["%s Cooldown"],SN[29484]),
				type = "dropdown", 
				text = format(L["Next %s"],SN[29484]),
				time = 40, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "YELLOW", 
			},
			spidercd = {
				var = "spidercd", 
				varname = format(L["%s Cooldown"],L["Spider"]),
				type = "dropdown", 
				text = format(L["%s Spawns"],L["Spider"]),
				time = 30, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "ORANGE", 
			},
			enragewarn = {
				var = "enragewarn", 
				varname = format(L["%s Warning"],L["Enrage"]),
				type = "simple", 
				text = format("%s!",L["Enraged"]),
				time = 1.5, 
				sound = "ALERT3", 
			},
		},
		events = {
			-- Spray
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {29484,54125}, 
				execute = {
					[1] = {
						
						{alert = "spraycd"}, 
						{alert = "spidercd"},
					},
				},
			},
			-- Enrage
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {54123,54124},
				execute = {
					[1] = {
						{alert = "enragewarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
