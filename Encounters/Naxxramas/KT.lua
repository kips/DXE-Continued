do
	local L,SN = DXE.L,DXE.SN

	local L_KelThuzad = L["Kel'Thuzad"]

	local data = {
		version = "$Rev$",
		key = "kelthuzad", 
		zone = L["Naxxramas"], 
		name = L_KelThuzad, 
		triggers = {
			yell = "^Minions, servants, soldiers of the cold dark",
			scan = {
				L["Kel'Thuzad"],
				L["Guardian of Icecrown"],
				L["Soldier of the Frozen Wastes"], 
				L["Unstoppable Abomination"], 
				L["Soul Weaver"],
			},
		},
		onactivate = {
			tracing = {L["Kel'Thuzad"]},
			leavecombat = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "ktarrives"},
			}
		},
		alerts = {
			fissurewarn = {
				var = "fissurewarn", 
				varname = format(L["%s Warning"],SN[27810]),
				type = "simple", 
				text = format(L["%s Spawned"],SN[27810]),
				time = 1.5, 
				sound = "ALERT1",
				color1 = "BLACK",
			},
			frostblastwarn = {
				var = "frostblastwarn", 
				varname = format(L["%s Warning"],SN[27808]),
				type = "simple", 
				text = format(L["%s Casted"],SN[27808]),
				time = 1.5, 
				sound = "ALERT2", 
				throttle = 5,
				color1 = "BLUE",
			},
			detonatewarn = {
				var = "detonatewarn", 
				varname = format(L["%s Warning"],SN[29870]),
				type = "centerpopup", 
				text = format("%s: %s!",SN[29870],L["YOU!"]),
				time = 5, 
				sound = "ALERT3", 
				color1 = "WHITE", 
			},
			ktarrives = {
				var = "ktarrives", 
				varname = format(L["%s Arrival"],L_KelThuzad),
				type = "dropdown", 
				text = format(L["%s Arrives"],L_KelThuzad),
				time = 225, 
				flashtime = 5, 
			},
			guardianswarn = {
				var = "guardianswarn", 
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
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 27810, 
				execute = {
					[1] = {
						{alert = "fissurewarn"}, 
					},
				},
			},
			-- Frost blast
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 27808, 
				execute = {
					[1] = {
						{alert = "frostblastwarn"}, 
					},
				},
			},
			-- Mana detonate
			[3] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 27819, 
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "detonatewarn"}, 
					},
				},
			},
			-- Guardians
			[4] = {
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					[1] = {
						{expect = {"#1#","find",L["^Very well. Warriors of the frozen wastes, rise up!"]}},
						{alert = "guardianswarn"}, 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end
