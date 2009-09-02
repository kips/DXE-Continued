do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 6,
		key = "anubcoliseum", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Anub'arak"], 
		triggers = {
			scan = {
				34564, -- Anub
			}, 
		},
		onactivate = {
			tracing = {34564},
			tracerstart = true,
			combatstop = true,
		},
		onstart = {
			{
				"alert","burrowcd",
			},
		},
		userdata = {
			burrowtime = {81,75,loop = false},
		},
		alerts = {
			pursueself = {
				varname = format(L["%s on self"],SN[62374]),
				type = "centerpopup",
				time = 60,
				flashtime = 60,
				text = format("%s: %s! %s!",SN[62374],L["YOU"],L["RUN"]),
				sound = "ALERT1",
				color1 = "BROWN",
				color2 = "GREY",
				icon = ST[67574],
			},
			pursueother = {
				varname = format(L["%s on others"],SN[62374]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[62374]),
				time = 60,
				flashtime = 60,
				color1 = "BROWN",
				icon = ST[67574],
			},
			burrowcd = {
				varname = format(L["%s Cooldown"],L["Burrow"]),
				type = "dropdown",
				text = "Next Burrow",
				time = "<burrowtime>",
				flashtime = 10,
				color1 = "GREY",
				icon = ST[26381],
			},
			burrowdur = {
				varname = "Burrow Duration",
				type = "dropdown",
				text = "Burrow Duration",
				time = 64,
				flashtime = 10,
				color1 = "GREEN",
				icon = ST[56504],
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
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L["burrows into the ground!$"]},
						"alert","burrowdur",
					},
					{
						"expect",{"#1#","find",L["emerges from the ground!$"]},
						"alert","burrowcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
