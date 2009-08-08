do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = "$Rev$",
		key = "emalon", 
		zone = L["Vault of Archavon"], 
		category = L["Northrend"],
		name = L["Emalon the Storm Watcher"], 
		triggers = {
			scan = {
				33993, -- Emalon
				33998, -- Tempest Minion
				34049, -- Tempest Minion
			}, 
		},
		onactivate = {
			tracing = {33993},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {},
		onstart = {
			{
				{alert = "overchargecd"},
			}
		},
		alerts = {
			novacd = {
				varname = format(L["%s Cooldown"],SN[64216]),
				type = "dropdown",
				time = 25,
				flashtime = 5,
				text = format(L["%s Cooldown"],SN[64216]),
				color1 = "BLUE",
				color2 = "BLUE",
				sound = "ALERT1",
				icon = ST[421],
			},
			novawarn = {
				varname = format(L["%s Cast"],SN[64216]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				text = format(L["%s Cast"],SN[64216]),
				color1 = "BROWN",
				color2 = "ORANGE",
				sound = "ALERT5",
				icon = ST[57322],
			},
			overchargecd = {
				varname = format(L["%s Cooldown"],SN[64218]),
				type = "dropdown",
				time = 45,
				flashtime = 5,
				text = format(L["Next %s"],SN[64218]),
				color1 = "RED",
				color2 = "DCYAN",
				sound = "ALERT2",
				icon = ST[64218],
			},
			overchargedblastdur = {
				varname = format(L["%s Timer"],SN[64219]),
				type = "centerpopup",
				time = 20,
				flashtime = 5,
				text = SN[64219].."!",
				color1 = "YELLOW",
				color2 = "VIOLET",
				sound = "ALERT3",
				icon = ST[37104],
			},
		},
		events = {
			-- Lightning Nova
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64216,65279},
				execute = {
					{
						{alert = "novacd"},
						{alert = "novawarn"},
					},
				},
			},
			-- Overcharge and Overcharged Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64218,
				execute = {
					{
						{alert = "overchargecd"},
						{alert = "overchargedblastdur"},
					},
				},
			},
			-- Overcharge Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 64217,
				execute = {
					{
						{quash = "overchargedblastdur"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

