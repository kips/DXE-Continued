do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev: 185 $",
		key = "emalon", 
		zone = L["Vault of Archavon"], 
		category = L["Northrend"],
		name = L["Emalon the Storm Watcher"], 
		triggers = {
			scan = {L["Emalon the Storm Watcher"],L["Tempest Minion"]}, 
		},
		onactivate = {
			tracing = {L["Emalon the Storm Watcher"],},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "overchargecd"},
			}
		},
		alerts = {
			novacd = {
				var = "novacd",
				varname = format(L["%s Cooldown"],SN[64216]),
				type = "dropdown",
				time = 25,
				flashtime = 5,
				text = format(L["%s Cooldown"],SN[64216]),
				color1 = "BLUE",
				color2 = "BLUE",
				sound = "ALERT1",
			},
			novawarn = {
				var = "novawarn",
				varname = format(L["%s Cast"],SN[64216]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				text = format(L["%s Cast"],SN[64216]),
				color1 = "BROWN",
				color2 = "ORANGE",
				sound = "ALERT5",
			},
			overchargecd = {
				var = "overchargecd",
				varname = format(L["%s Cooldown"],SN[64218]),
				type = "dropdown",
				time = 45,
				flashtime = 5,
				text = format(L["Next %s"],SN[64218]),
				color1 = "RED",
				color2 = "DCYAN",
				sound = "ALERT2",
			},
			overchargedblastdur = {
				var = "overchargedblastdur",
				varname = format(L["%s Timer"],SN[64219]),
				type = "centerpopup",
				time = 20,
				flashtime = 5,
				text = SN[64219].."!",
				color1 = "YELLOW",
				color2 = "VIOLET",
				sound = "ALERT3",
			},
		},
		events = {
			-- Lightning Nova
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64216,65279},
				execute = {
					[1] = {
						{alert = "novacd"},
						{alert = "novawarn"},
					},
				},
			},
			-- Overcharge and Overcharged Blast
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64218,
				execute = {
					[1] = {
						{alert = "overchargecd"},
						{alert = "overchargedblastdur"},
					},
				},
			},
			-- Overcharge Removal
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 64217,
				execute = {
					[1] = {
						{quash = "overchargedblastdur"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

