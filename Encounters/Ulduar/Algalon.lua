do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 304,
		key = "algalon", 
		zone = L["Ulduar"], 
		name = L["Algalon the Observer"], 
		triggers = {
			scan = 32871, -- Algalon
		},
		onactivate = {
			tracing = {32871}, -- Algalon
         tracerstart = true,
         tracerstop = true,
			combatstop = true,
			defeat = L["^I have seen worlds bathed in the"],
		},
		userdata = {
			cosmicsmashtime = 25,
			bigbangtime = 90,
			punchtext = "",
		},
		onstart = {
			{
				"alert","cosmicsmashcd",
				"alert","bigbangcd",
				"alert","enragecd",
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 360,
				flashtime = 10,
				sound = "ALERT6",
				color1 = "GREY",
				color2 = "GREY",
				icon = ST[12317],
			},
			bigbangwarn = {
				varname = format(L["%s Cast"],SN[64443]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[64443]),
				time = 8,
				flashtime = 8,
				sound = "ALERT5",
				color1 = "ORANGE",
				color2 = "BROWN",
				flashscreen = true,
				icon = ST[64443],
			},
			bigbangcd = {
				varname = format(L["%s Cooldown"],SN[64443]),
				type = "dropdown",
				text = format(L["Next %s"],SN[64443]),
				time = "<bigbangtime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "BLUE",
				color2 = "BLUE",
				icon = ST[64443],
			},
			cosmicsmashwarn = {
				varname = format(L["%s ETA"],SN[62301]),
				type = "centerpopup",
				text = format(L["%s Hits"],SN[62301]),
				time = 5,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "YELLOW",
				color2 = "RED",
				flashscreen = true,
				icon = ST[62311],
			},
			cosmicsmashcd = {
				varname = format(L["%s Cooldown"],SN[62301]),
				type = "dropdown",
				text = format(L["Next %s"],SN[62301]),
				time = "<cosmicsmashtime>",
				flashtime = 5,
				sound = "ALERT3",
				color1 = "GREEN",
				color2 = "GREEN",
				icon = ST[62311],
			},
			punchcd = {
				varname = format(L["%s Cooldown"],SN[64412]),
				type = "dropdown",
				text = format(L["Next %s"],SN[64412]),
				time = 15,
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "PURPLE",
				icon = ST[64412],
				counter = true,
			},
			punchwarn = {
				varname = format(L["%s Warning"],SN[64412]),
				type = "simple",
				text = "<punchtext>",
				time = 3,
				icon = ST[64412],
				sound = "ALERT7",
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
						"quash","bigbangcd",
						"alert","bigbangwarn",
						"alert","bigbangcd",
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
						"quash","cosmicsmashcd",
						"alert","cosmicsmashwarn",
						"alert","cosmicsmashcd",
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
						"alert","punchcd",
					},
				},
			},
			-- Phase Punch application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64412,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{punchtext = format("%s: %s!",SN[64412],L["YOU"])},
						"alert","punchwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{punchtext = format("%s: #5#!",SN[64412])},
						"alert","punchwarn",
					},
				},
			},
			-- Phase Punch Stacks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 64412,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{punchtext = format("%s: %s! %s!",SN[64412],L["YOU"],format(L["%s Stacks"],"#11#"))},
						"alert","punchwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{punchtext = format("%s: #5#! %s!",SN[64412],format(L["%s Stacks"],"#11#")) },
						"alert","punchwarn",
					},
				},
			},
		}
	}
	DXE:RegisterEncounter(data)
end
