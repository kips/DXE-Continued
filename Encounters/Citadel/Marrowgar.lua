do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "marrowgar", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Marrowgar"], 
		triggers = {
			scan = {36612}, -- Lord Marrowgar
			yell = L["^The Scourge will wash over this world"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36612}, -- Lord Marrowgar
		},
		userdata = {
			bonetime = {45,90,loop = false},
			graveyardtime = {18,60,loop = true},
		},
		onstart = {
			{
				"alert","graveyardcd",
				"alert","bonestormcd",
			},
		},
		alerts = {
			bonestormwarn = {
				varname = format(L["%s Cast"],SN[69076]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[69076]),
				time = 3,
				flashtime = 3,
				color1 = "GREEN",
				sound = "ALERT5",
				icon = ST[69076],
			},
			-- duration is underministic 36.1, 37.3, 42.6, 34.4
			bonestormdur = {
				varname = format(L["%s Duration"],SN[69076]),
				type = "centerpopup",
				text = format(L["%s Ends Soon"],SN[69076]),
				time = 34,
				flashtime = 34,
				color1 = "BROWN",
				icon = ST[69075],
			},
			bonestormcd = {
				varname = format(L["%s Cooldown"],SN[69076]),
				type = "dropdown",
				text = format(L["Next %s"],SN[69076]),
				time = "<bonetime>",
				flashtime = 10,
				color1 = "BLUE",
				sound = "ALERT1",
				icon = ST[69076],
			},
			coldflameself = {
				varname = format(L["%s on self"],SN[70823]),
				type = "simple",
				text = format("%s: %s! %s!",SN[70823],L["YOU"],L["MOVE AWAY"]),
				time = 3,
				color1 = "INDIGO",
				sound = "ALERT2",
				icon = ST[70823],
				flashscreen = true,
			},
			graveyardwarn = {
				varname = format(L["%s Cast"],SN[70826]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[70826]),
				time = 3,
				flashtime = 3,
				color1 = "GREY",
				sound = "ALERT3",
				icon = ST[70826],
			},
			graveyardcd = {
				varname = format(L["%s Cooldown"],SN[70826]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[70826]),
				time = "<graveyardtime>",
				flashtime = 7,
				color1 = "PURPLE",
				icon = ST[70826],
			},
		},
		arrows = {
			impalearrow = {
				varname = SN[69062],
				unit = "#2#",
				persist = 15,
				action = "TOWARD",
				msg = L["KILL IT"],
				spell = SN[69062],
			},
		},
		raidicons = {
			impalemark = {
				varname = SN[69062],
				type = "MULTIFRIENDLY",
				persist = 15,
				reset = 3,
				unit = "#2#",
				icon = 1,
				total = 3,
			},
		},
		events = {
			-- Bone Storm cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					69076, -- 25 hard
				},
				execute = {
					{
						"alert","bonestormwarn",
					},
				},
			},
			-- Bone Storm duration and cooldown
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69076,
				},
				execute = {
					{
						"quash","bonestormcd",
						"alert","bonestormdur",
						"alert","bonestormcd",
					},
				},
			},
			-- Bone Storm removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					69076,
				},
				execute = {
					{
						"quash","bonestormdur",
					},
				},
			},
			-- Coldflame self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70823, -- 25
					70825, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","coldflameself",
					},
				},
			},
			-- Bone Spike Graveyard
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					70826, -- 25
					72089, -- 25 hard
				},
				execute = {
					{
						"alert","graveyardwarn",
						"alert","graveyardcd",
					},
				},
			},
			-- Impale
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = 69062,
				execute = {
					{
						"expect",{"#2#","~=","&playerguid&"},
						"raidicon","impalemark",
						"arrow","impalearrow",
					},
				},
			},
			-- Impale removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 69065, -- different spellid from SPELL_SUMMON
				execute = {
					{
						"expect",{"#2#","~=","&playerguid&"},
						"removeraidicon","#2#",
						"removearrow","#2#",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end