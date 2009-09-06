do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 11,
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
				"alert","enragecd",
			},
		},
		userdata = {
			burrowtime = {81,75,loop = false},
		},
		alerts = {
			enragecd = {
				type = "dropdown",
				varname = L["Enrage"],
				text = L["Enrage"],
				time = 570,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
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
				varname = format(L["%s Cooldown"],SN[26381]),
				type = "dropdown",
				text = format(L["Next %s"],SN[26381]),
				time = "<burrowtime>",
				flashtime = 10,
				color1 = "ORANGE",
				icon = ST[1784],
			},
			burrowdur = {
				varname = format(L["%s Duration"],SN[26381]),
				type = "centerpopup",
				text = format(L["%s Duration"],SN[26381]),
				time = 64,
				flashtime = 10,
				color1 = "GREEN",
				icon = ST[56504],
			},
			shadowstrikewarn = { 
				varname = format(L["%s Cast"],SN[66134]),
				type = "centerpopup", 
				text = format(L["%s Cast"],SN[66134]),
				time = 8, 
				flashtime = 8,
				color1 = "PURPLE", 
				sound = "ALERT5",
				icon = ST[66134],
				throttle = 2,
			},
			submergewarn = {
				varname = format(L["%s Cast"],SN[67322]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[67322]),
				time = 2,
				flashtime = 2,
				color1 = "GREY",
				sound = "ALERT6",
				icon = ST[67322],
			},
			leechingswarmwarn = {
				varname = format(L["%s Cast"],SN[66118]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[66118]),
				time = 1.5,
				flashtime = 1.5,
				color1 = "DCYAN",
				sound = "ALERT7",
				icon = ST[66118],
			},
		},
		arrows = {
			pursuedarrow = {
				varname = SN[62374],
				unit = "#5#",
				persist = 60,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = L["Burrow"],
			},
		},
		events = {
			-- Submerge
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 67322,
				execute = {
					{
						"alert","submergewarn",
					},
				},
			},
			-- Shadow Strike (Hard Mode) - Only tracks up to 1
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 66134, -- 10m hard
				execute = {
					{
						"alert","shadowstrikewarn",
					},
				},
			},
			-- Shadow Strike (Hard Mode) interrupt
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","34607"},
						"quash","shadowstrikewarn",
					},
				},
			},
			-- Pursued by Anub'arak
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
						"arrow","pursuedarrow",
					},
				},
			},
			-- Pursued on Anub'arak removal
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
						"removearrow","#5#",
					},
				},
			},
			-- Leeching Swarm
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					66118, -- 10 normal
					68646, -- 10 hard
					67630, -- 25 normal
					68647, -- 25 hard
				},
				execute = {
					{
						"quash","burrowcd",
						"alert","leechingswarmwarn",
					},
				},
			},
			-- Burrows/Emerges
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
