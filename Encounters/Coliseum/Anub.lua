do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "anubcoliseum", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Anub'arak"], 
		triggers = {
			scan = {
				34660, -- Anub
			}, 
		},
		onactivate = {
			tracing = {34660},
			tracerstart = true,
			combatstop = true,
		},
		alerts = {
			pursueself = {
				varname = format(L["%s on self"],SN[62374]),
				type = "centerpopup",
				time = 60,
				flashtime = 60,
				text = format("%s: #5#! %s!",SN[62374],L["RUN"]),
				sound = "ALERT1",
				color1 = "BROWN",
				color2 = "GREY",
				icon = ST[67574],
			},
			pursueother = {
				varname = format(L["%s on others"],SN[62374]),
				type = "dropdown",
				text = format("%s: #5#!",SN[62374]),
				time = 60,
				flashtime = 15,
				color1 = "BROWN",
				icon = ST[67574],
			},
		},
		events = {
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 67574,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","pursueself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","pursueother",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 67574,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","pursueself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","pursueother",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
