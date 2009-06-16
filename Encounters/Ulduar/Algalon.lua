do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "algalon", 
		zone = L["Ulduar"], 
		name = L["Algalon the Observer"], 
		triggers = {
			scan = L["Algalon the Observer"],
		},
		onactivate = {
			tracing = {L["Algalon the Observer"],},
         autostart = true,
         autostop = true,
			leavecombat = true,
		},
		userdata = {
			cosmicsmashtime = 25,
			bigbangtime = 90,
		},
		onstart = {
			{
				{alert = "cosmicsmashcd"},
				{alert = "bigbangcd"},
			},
		},
		alerts = {
			bigbangwarn = {
				var = "bigbangwarn",
				varname = format(L["%s Cast"],SN[64443]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[64443]),
				time = 8,
				flashtime = 8,
				sound = "ALERT5",
				color1 = "ORANGE",
				color2 = "BROWN",
			},
			bigbangcd = {
				var = "bigbangcd",
				varname = format(L["%s Cooldown"],SN[64443]),
				type = "dropdown",
				text = format(L["Next %s"],SN[64443]),
				time = "<bigbangtime>",
				flashtime = 5,
				sound = "ALERT2",
				color1 = "BLUE",
				color2 = "BLUE",
			},
			cosmicsmashwarn = {
				var = "cosmicsmashwarn",
				varname = format(L["%s ETA"],SN[62301]),
				type = "centerpopup",
				text = format(L["%s Hits"],SN[62301]),
				time = 4.2,
				flashtime = 4.2,
				sound = "ALERT1",
				color1 = "YELLOW",
				color2 = "RED",
			},
			cosmicsmashcd = {
				var = "cosmicsmashcd",
				varname = format(L["%s Cooldown"],SN[62301]),
				type = "dropdown",
				text = format(L["Next %s"],SN[62301]),
				time = "<cosmicsmashtime>",
				flashtime = 5,
				sound = "ALERT3",
				color1 = "GREEN",
				color2 = "GREEN",
			},
			punchcd = {
				var = "punchcd",
				varname = format(L["%s Cooldown"],SN[64412]),
				type = "dropdown",
				text = format(L["Next %s"],SN[64412]),
				time = 15,
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "PURPLE",
			},
		},
		events = {
			-- Big Bang
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64443,64584},
				execute = {
					{
						{alert = "bigbangwarn"},
						{alert = "bigbangcd"},
					},
				},
			},
			-- Cosmic Smash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {62301,64598},
				execute = {
					{
						{alert = "cosmicsmashwarn"},
						{alert = "cosmicsmashcd"},
					}
				},
			},
			-- Phase Punch
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64412,
				execute = {
					{
						{alert = "punchcd"},
					}	
				},
			},
		}
	}
	DXE:RegisterEncounter(data)
	DXE:AddFriendlyException(L["Algalon the Observer"])
end
