do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 299,
		key = "kelthuzad", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas["Kel'Thuzad"], 
		triggers = {
			yell = "^Minions, servants, soldiers of the cold dark",
			scan = {
				15990, -- Kel'Thuzad
				16441, -- Guardian of Icecrown
				16427, -- Soldier of the Frozen Wastes
				23561, -- Soldier of the Frozen Wastes
				16428, -- Unstoppable Abomination
				23562, -- Unstoppable Abomination
				23563, -- Soul Weaver
				16429, -- Soul Weaver
			},
		},
		onactivate = {
			tracing = {15990}, -- Kel'Thuzad
			combatstop = true,
			defeat = 15990,
		},
		userdata = {},
		onstart = {
			{
				"alert","ktarrivescd",
			}
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			fissurewarn = {
				varname = format(L.alert["%s Warning"],SN[27810]),
				type = "simple", 
				text = format(L.alert["%s Spawned"],SN[27810]),
				time = 1.5, 
				sound = "ALERT1",
				color1 = "BLACK",
				icon = ST[27810],
			},
			frostblastwarn = {
				varname = format(L.alert["%s Warning"],SN[27808]),
				type = "simple", 
				text = format(L.alert["%s Casted"],SN[27808]),
				time = 1.5, 
				sound = "ALERT2", 
				throttle = 5,
				color1 = "BLUE",
				icon = ST[27808],
			},
			detonatewarn = {
				varname = format(L.alert["%s Warning"],SN[29870]),
				type = "centerpopup", 
				text = format("%s: %s!",SN[29870],L.alert["YOU"]),
				time = 5, 
				sound = "ALERT3", 
				color1 = "WHITE",
				flashscreen = true,
				icon = ST[29870],
			},
			ktarrivescd = {
				varname = format(L.alert["%s Arrival"],L.npc_naxxramas["Kel'Thuzad"]),
				type = "dropdown", 
				text = format(L.alert["%s Arrives"],L.npc_naxxramas["Kel'Thuzad"]),
				time = 225,
				color1 = "RED",
				flashtime = 5, 
				icon = ST[586],
			},
			guardianswarn = {
				varname = format(L.alert["%s Spawns"],SN[4070]),
				type = "centerpopup", 
				text = format(L.alert["%s Spawns"],SN[4070]),
				time = 10, 
				flashtime = 3, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
				icon = ST[4070],
			},
		},
		announces = {
			detonatesay = {
				varname = format(L.alert["Say %s on self"],SN[29870]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[29870]).."!",
			},
		},
		events = {
			-- Fissure
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 27810, 
				execute = {
					{
						"alert","fissurewarn", 
					},
				},
			},
			-- Frost blast
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 27808, 
				execute = {
					{
						"alert","frostblastwarn", 
					},
				},
			},
			-- Mana detonate
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 27819, 
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","detonatewarn",
						"announce","detonatesay",
					},
				},
			},
			-- Guardians
			{
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["^Very well. Warriors of the frozen wastes, rise up!"]},
						"alert","guardianswarn", 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end
