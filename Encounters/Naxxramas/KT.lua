do
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "kelthuzad", 
		zone = L["Naxxramas"], 
		name = L["Kel'Thuzad"], 
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
		},
		userdata = {},
		onstart = {
			{
				{alert = "ktarrives"},
			}
		},
		alerts = {
			fissurewarn = {
				varname = format(L["%s Warning"],SN[27810]),
				type = "simple", 
				text = format(L["%s Spawned"],SN[27810]),
				time = 1.5, 
				sound = "ALERT1",
				color1 = "BLACK",
			},
			frostblastwarn = {
				varname = format(L["%s Warning"],SN[27808]),
				type = "simple", 
				text = format(L["%s Casted"],SN[27808]),
				time = 1.5, 
				sound = "ALERT2", 
				throttle = 5,
				color1 = "BLUE",
			},
			detonatewarn = {
				varname = format(L["%s Warning"],SN[29870]),
				type = "centerpopup", 
				text = format("%s: %s!",SN[29870],L["YOU"]),
				time = 5, 
				sound = "ALERT3", 
				color1 = "WHITE",
				flashscreen = true,
			},
			ktarrives = {
				varname = format(L["%s Arrival"],L["Kel'Thuzad"]),
				type = "dropdown", 
				text = format(L["%s Arrives"],L["Kel'Thuzad"]),
				time = 225, 
				color1 = "RED",
				flashtime = 5, 
			},
			guardianswarn = {
				varname = format(L["%s Spawns"],SN[4070]),
				type = "centerpopup", 
				text = format(L["%s Spawns"],SN[4070]),
				time = 10, 
				flashtime = 3, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
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
						{alert = "fissurewarn"}, 
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
						{alert = "frostblastwarn"}, 
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
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "detonatewarn"}, 
					},
				},
			},
			-- Guardians
			{
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					{
						{expect = {"#1#","find",L["^Very well. Warriors of the frozen wastes, rise up!"]}},
						{alert = "guardianswarn"}, 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end
