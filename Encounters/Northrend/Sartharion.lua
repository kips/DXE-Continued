do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local L_Sartharion = L["Sartharion"]
	local L_Vesperon = L["Vesperon"]
	local L_Shadron = L["Shadron"]
	local L_Tenebron = L["Tenebron"]

	local data = {
		version = 297,
		key = "sartharion", 
		zone = L["The Obsidian Sanctum"], 
		category = L["Northrend"],
		name = L_Sartharion, 
		triggers = {
			scan = {
				28860, -- Sartharion
				30452, -- Tenebron
				30451, -- Shadron
				30449, -- Vesperon
			},
		},
		onactivate = {
			tracing = {28860}, -- Sartharion
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {
			tenebronarrived = 0,
			shadronarrived = 0,
			vesperonarrived = 0,
			tenebrontimer = 0,
			shadrontimer = 0,
			vesperontimer = 0,
		},
		onstart = {
			{
				"alert","lavawallcd",
			}
		},
		timers = {
			updatetracers = {
				-- Tenebron, Shadron, Vesperon
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 0 1"},
					"tracing",{28860,30449}, -- Sartharion, Vesperon
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 1 0"},
					"tracing",{28860,30451}, -- Sartharion, Shadron
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 1 1"},
					"tracing",{28860,30451,30449}, -- Sartharion, Shadron, Vesperon
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 0 0"},
					"tracing",{28860,30452}, -- Sartharion, Tenebron
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 0 1"},
					"tracing",{28860,30452,30449}, -- Sartharion, Tenebron, Vesperon
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 1 0"},
					"tracing",{28860,30452,30451}, -- Sartharion, Tenebron, Shadron
				},
				{
					"expect",{"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 1 1"},
					"tracing",{28860,30452,30451,30449}, -- Sartharion, Tenebron, Shadron, Vesperon
				},
			},
		},
		alerts = {
			lavawallcd = {
				varname = format(L["%s Cooldown"],L["Lava Wall"]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],L["Lava Wall"]),
				time = 25, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "ORANGE", 
				icon = ST[43114],
			},
			lavawallwarn = {
				varname = format(L["%s Cast"],L["Lava Wall"]),
				type = "centerpopup", 
				text = format(L["Incoming %s"],L["Lava Wall"]).."!",
				time = 5, 
				sound = "ALERT1", 
				color1 = "RED", 
				color2 = "ORANGE",
				flashscreen = true,
				icon = ST[43114],
			},
			shadowfissurewarn = {
				varname = format(L["%s Warning"],SN[59127]),
				type = "simple", 
				text = format(L["%s Spawned"],SN[59127]).."!",
				sound = "ALERT2",
				color1 = "PURPLE",
				time = 1.5, 
				icon = ST[59127],
			},
			flamebreathwarn = {
				varname = format(L["%s Cast"],SN[56908]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[56908]),
				time = 2,
				color1 = "DCYAN",
				sound = "ALERT4",
				icon = ST[56908],
			},
			shadronarrives = {
				type = "dropdown",
				varname = format(L["%s Arrival"],L_Shadron),
				text = format(L["%s Arrives"],L_Shadron),
				time = 80,
				color1 = "DCYAN",
				icon = ST[58105],
			},
			tenebronarrives = {
				type = "dropdown",
				varname = format(L["%s Arrival"],L_Tenebron),
				text = format(L["%s Arrives"],L_Tenebron),
				time = 30,
				color1 = "CYAN",
				icon = ST[61248],
			},
			vesperonarrives = {
				type = "dropdown",
				varname = format(L["%s Arrival"],L_Vesperon),
				text = format(L["%s Arrives"],L_Vesperon),
				time = 120,
				color1 = "GREEN",
				icon = ST[61251],
			},
		},
		events = {
			-- Shadow fissure
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {59127,57579}, 
				execute = {
					{
						"alert","shadowfissurewarn", 
					},
				},
			},
			-- Lava wall
			{
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					{
						"expect",{"#1#","find",L["lava surrounding"]},
						"alert","lavawallwarn",
						"alert","lavawallcd", 
					},
				},
			},
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Tenebron
					{
						"expect",{"#1#","find",L["It is amusing to watch you struggle. Very well, witness how it is done."]},
						"set",{tenebronarrived = 1},
						"scheduletimer",{"updatetracers",0},
					},
					-- Shadron
					{
						"expect",{"#1#","find",L["I will take pity on you, Sartharion, just this once"]},
						"set",{shadronarrived = 1},
						"scheduletimer",{"updatetracers",0},
					},
					-- Vesperon
					{
						"expect",{"#1#","find",L["Father was right about you, Sartharion, you ARE a weakling."]},
						"set",{vesperonarrived = 1},
						"scheduletimer",{"updatetracers",0},
					},
				},
			},
			-- Flame Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {56908,58956},
				execute = {
					{
						"alert","flamebreathwarn",
					},
				},
			},
			-- Drake Arrivals
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {58105, 61248, 61251},
				execute = {
					{
						-- Shadron
						"expect",{"#7# <shadrontimer>","==","58105 0"},
						"set",{shadrontimer = 1},
						"alert","shadronarrives",
					},
					{
						-- Tenebron
						"expect",{"#7# <tenebrontimer>","==","61248 0"},
						"set",{tenebrontimer = 1},
						"alert","tenebronarrives",
					},
					{
						-- Vesperon
						"expect",{"#7# <vesperontimer>","==","61251 0"},
						"set",{vesperontimer = 1},
						"alert","vesperonarrives",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
