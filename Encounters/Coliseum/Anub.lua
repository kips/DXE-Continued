do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 32,
		key = "anubcoliseum", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Anub'arak"], 
		triggers = {
			scan = {
				34564, -- Anub
			}, 
			yell = L["^This place will serve as"], 
		},
		onactivate = {
			tracing = {34564},
			combatstop = true,
		},
		onstart = {
			{
				"alert","burrowcd",
				"alert","enragecd",
				"alert","nerubiancd",
				"scheduletimer",{"firenerubian",10},
				"set",{nerubiantime = 5.5},
				"expect",{"&difficulty&",">=","3"},
				"alert","shadowstrikecd",
				"scheduletimer",{"fireshadowstrike",30},
			},
		},
		userdata = {
			burrowtime = {80,75,loop = false},
			nerubiantime = 10.5,
			leeching = 0,
			burrowed = 0,
		},
		timers = {
			firenerubian = {
				{
					"set",{nerubiantime = 46.5},
					"alert","nerubiancd",
					"expect",{"&difficulty&",">=","3"},
					"scheduletimer",{"firenerubian2",46},
				},
			},
			firenerubian2 = {
				{
					"alert","nerubiancd",
					"scheduletimer",{"firenerubian2",46},
				},
			},
			fireshadowstrike = {
				{
					"alert","shadowstrikecd",
					"scheduletimer",{"fireshadowstrike",30},
				},
			},
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
			shadowstrikecd = {
				varname = format(L["%s Cooldown"],SN[66134]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],SN[66134]),
				time = 30,
				flashtime = 10,
				color1 = "VIOLET",
				icon = ST[66135],
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
			nerubiancd = {
				varname = format(L["%s Timer"],SN[66333]),
				type = "dropdown",
				text = format(L["%s Spawns"],SN[66333]),
				time = "<nerubiantime>",
				flashtime = 10,
				color1 = "INDIGO",
				icon = ST[66333],
			},
			slashother = {
				varname = format(L["%s on others"],SN[66012]),
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				text = format("%s: #5#!",SN[66012]),
				color1 = "BLUE",
				icon = ST[66012],
				sound = "ALERT8",
			},
			slashcd = {
				varname = format(L["%s Cooldown"],SN[66012]),
				type = "dropdown",
				time = 20,
				flashtime = 5,
				text = format(L["%s Cooldown"],SN[66012]),
				color1 = "YELLOW",
				icon = ST[66012],
			},
			coldcd = {
				varname = format(L["%s Cooldown"],SN[68509]),
				type = "dropdown",
				time = 16,
				flashtime = 5,
				text = format(L["%s Cooldown"],SN[68509]),
				color1 = "TURQUOISE",
				icon = ST[68509],
			},
			coldselfwarn = {
				varname = format(L["%s on self"],SN[68509]),
				type = "simple",
				time = 3,
				text = format("%s: %s!",SN[68509],L["YOU"]),
				flashscreen = true,
				sound = "ALERT9",
				icon = ST[68509],
			},
			colddur = {
				varname = format(L["%s Duration"],SN[68509]),
				type = "centerpopup",
				time = 18,
				flashtime = 18,
				text = format(L["%s Duration"],SN[68509]),
				color1 = "MAGENTA",
				sound = "ALERT2",
				icon = ST[68509],
			},
		},
		raidicons = {
			coldmark = {
				varname = SN[68509],
				type = "MULTIFRIENDLY",
				persist = 15,
				reset = 3,
				unit = "#5#",
				icon = 2,
				total = 5,
			},
			pursuemark = {
				varname = SN[62374],
				type = "FRIENDLY",
				persist = 60,
				unit = "#5#",
				icon = 1,
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
			-- Shadow Strike (Hard Mode) - Only tracks up to 1
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 66134,
				execute = {
					{
						"alert","shadowstrikewarn",
						"quash","shadowstrikecd",
						"alert","shadowstrikecd",
						"scheduletimer",{"fireshadowstrike",30},
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
						"raidicon","pursuemark",
					},
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
						"removeraidicon","#5#",
					},
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
						"set",{leeching = 1},
						"expect",{"&difficulty&","<=","2"},
						"quash","nerubiancd",
						"canceltimer","firenerubian",
					},
				},
			},
			-- Burrows/Emerges
			{
				type = "event",
				event = "EMOTE",
				execute = {
					-- Burrows
					{
						"expect",{"#1#","find",L["burrows into the ground!$"]},
						"set",{burrowed = 1},
						"alert","burrowdur",
						"quash","slashcd",
						"quash","nerubiancd",
						"canceltimer","firenerubian2",
						"canceltimer","fireshadowstrike",
						"quash","shadowstrikecd",
					},
					-- Emerges
					{
						"expect",{"#1#","find",L["emerges from the ground!$"]},
						"set",{burrowed = 0},
						"alert","burrowcd",
						"set",{nerubiantime = 5.5},
						"alert","nerubiancd",
						"scheduletimer",{"firenerubian",5},
						"scheduletimer",{"fireshadowstrike",5},
					},
				},
			},
			-- Freezing Slash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 66012,
				execute = {
					{
						"quash","slashcd",
						"alert","slashcd",
					},
				},
			},
			-- Freezing Slash application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66012,
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","slashother",
					},
				},
			},
			-- Penetrating Cold
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					68509, -- 10 normal
					66013, -- 10 hard
					67700, -- 25 normal
					68510, -- 25 hard
				},
				execute = {
					{
						"expect",{"<leeching>","==","1"},
						"alert","coldcd",
						"alert","colddur",
					},
				},
			},
			-- Penetrating Cold self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					68509, -- 10 normal
					66013, -- 10 hard
					67700, -- 25 normal
					68510, -- 25 hard
				},
				execute = {
					{
						"raidicon","coldmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","coldselfwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
