do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "ironcouncil", 
		zone = "Ulduar", 
		name = L["The Iron Council"], 
		triggers = {
			scan = {L["Steelbreaker"], L["Runemaster Molgeim"], L["Stormcaller Brundir"],},
		},
		onactivate = {
			tracing = {L["Steelbreaker"], L["Runemaster Molgeim"], L["Stormcaller Brundir"],},
			autostart = true,
			leavecombat = true,
		},
		userdata = {
			overwhelmtime = 30,
			previoustarget = "",
		},
		onstart = {
			[1] = {
				{alert = "enragecd"},
				{expect = {"&difficulty&","==","1"}},
				{set = {overwhelmtime = 60}},
			},
		},
		alerts = {
			enragecd = {
				var = "enragecd",
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 600,
				flashtime = 5,
			},
			fusionpunchcast = {
				var = "fushionpunchcast",
				varname = format(L["%s Cast"],SN[61903]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[61903]),
				time = 3,
				color1 = "BROWN",
				sound = "ALERT5",
			},
			fusionpunchcd = {
				var = "fushionpunchcd",
				varname = format(L["%s Cooldown"],SN[61903]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[61903]),
				time = 12,
				flashtime = 5,
				color1 = "BLUE",
				color2 = "GREY",
			},
			runeofsummoningwarn = {
				var = "runeofsummoningwarn",
				varname = format(L["%s Warning"],SN[62273]),
				type = "simple",
				text = format(L["%s Casted"],SN[62273]).."!",
				sound = "ALERT1",
				color2 = "MAGENTA",
				time = 1.5,
			},
			runeofdeathwarn = {
				var = "runeofdeathwarn",
				varname = format(L["%s on self"],SN[62269]),
				type = "simple",
				text = format("%s: %s!",SN[62269],L["YOU"]),
				time = 1.5,
				sound = "ALERT3",
			},
			runeofpowerwarn = {
				var = "runeofpowerwarn",
				varname = format(L["%s Cast"],SN[61973]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[61973]),
				sound = "ALERT4",
				color1 = "GREEN",
				time = 1.5,
			},
			overloadwarn = {
				var = "overloadwarn",
				varname = format(L["%s Cast"],SN[61869]),
				type = "centerpopup",
				text = format("%s! %s!",SN[61869],L["MOVE AWAY"]),
				time = 6, 
				flashtime = 6,
				sound = "ALERT2",
				color1 = "PURPLE",
			},
			overloadcd = {
				var = "overloadcd",
				varname = format(L["%s Cooldown"],SN[61869]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[61869]),
				time = 60, 
				flashtime = 5,
				sound = "ALERT9",
				color1 = "PURPLE",
				color2 = "PURPLE",
			},
			tendrilsdur = {
				var = "tendrilscd", 
				varname = format(L["%s Duration"],SN[61887]),
				type = "centerpopup", 
				text = format(L["%s Duration"],SN[61887]),
				time = 35, 
				color1 = "BLUE", 
			},
			tendrilswarnself = {
				var = "tendrilswarn",
				varname = format(L["%s Target"],SN[61887]),
				type = "simple",
				text = format("%s: %s! %s!",SN[61887],L["YOU"],L["RUN"]),
				time = 1.5,
				color1 = "DCYAN",
				sound = "ALERT5",
			},
			tendrilswarnother = {
				var = "tendrilswarn",
				varname = format(L["%s Target"],SN[61887]),
				type = "simple",
				text = format("%s: <previoustarget>",SN[61887]),
				color1 = "YELLOW",
				time = 1.5,
			},
			whirlwarn = {
				var = "whirlwarn",
				varname = format(L["%s Cast"],SN[61915]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				text = SN[61915].."!",
				color1 = "ORANGE",
				color2 = "ORANGE",
				sound = "ALERT7",
			},
			overwhelmdurself = {
				var = "overwhelmdurself",
				varname = format(L["%s on self"],L["Overwhelm"]),
				type = "centerpopup",
				text = format("%s: %s!",L["Overwhelm"],L["YOU"]),
				time = "<overwhelmtime>",
				flashtime = 25,
				color1 = "DCYAN",
				color2 = "YELLOW",
				sound = "ALERT6",
			},
			overwhelmdurother = {
				var = "overwhelmdurother",
				varname = format(L["%s on others"],L["Overwhelm"]),
				type = "centerpopup",
				text = format("%s: #5#",L["Overwhelm"]),
				time = "<overwhelmtime>",
				color1 = "DCYAN",
			},
		},
		timers = {
			canceltendril = {
				[1] = {
					{canceltimer = "tendriltargets"},
					{set = {previoustarget = ""}},
				},
			},
			-- tft3 = Stormcaller Brundir's Target
			tendriltargets = {
				[1] = {
					{expect = {"&tft3_unitexists& &tft3_isplayer&","==","1 1"}},
					{expect = {"&tft3_unitname&","~=","<previoustarget>"}},
					{set = {previoustarget = "&tft3_unitname&"}},
					{alert = "tendrilswarnself"},
				},
				[2] = {
					{expect = {"&tft3_unitexists& &tft3_isplayer&","==","1 nil"}},
					{expect = {"&tft3_unitname&","~=","<previoustarget>"}},
					{set = {previoustarget = "&tft3_unitname&"}},
					{alert = "tendrilswarnother"},
				},
				[3] = {
					{scheduletimer = {"tendriltargets",0.2}},
				},
			},
		},
		events = {
			-- Stormcaller Brundir - Overload cast
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {61869, 63481},
				execute = {
					[1] = {
						{alert = "overloadwarn"},
						{alert = "overloadcd"},
					},
				},
			},
			-- Stormcaller Brundir - Lightning Whirl +1
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {63483,61915},
				execute = {
					[1] =  {
						{alert = "whirlwarn"},
					},
				},
			},
			-- Stormcaller Brundir - Lightning Whirl Interruption +1
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					[1] = {
						{expect = {"#10#","==","63483"}},
						{quash = "whirlwarn"},
					},
					[2] = {
						{expect = {"#10#","==","61915"}},
						{quash = "whirlwarn"},
					},
				},
			},
			-- Stormcaller Brundir - Lightning Tendrils +2
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {61886, 63485}, 
				execute = {
					[1] = {
						{alert = "tendrilsdur"},
						{scheduletimer = {"tendriltargets",0}},
						{scheduletimer = {"canceltendril",35}},
					},
				},
			},
			-- Runemaster Molgeim - Rune of Power
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {61974,61973},
				execute = {
					[1] = {
						{alert = "runeofpowerwarn"},
					},
				},
			},
			-- Runemaster Molgeim - Rune of Death +1
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {62269, 63490},
				execute = {
					[1] = {
						{expect = {"&playerguid&","==","#4#"}},
						{alert = "runeofdeathwarn"},
					},
				},
			},
			-- Runemaster Molgeim - Rune of Summoning +2
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_START", 
				spellid = 62273,
				execute = {
					[1] = {
						{alert = "runeofsummoningwarn"},
					},
				},
			},
			-- Steelbreaker - Overwhelm - +2
			{
				type = "combatevent",
				spellid = {64637, 61888},
				eventtype = "SPELL_AURA_APPLIED",
				execute = {
					[1] = {
						{expect = {"&playerguid&","==","#4#"}},
						{alert = "overwhelmdurself"},
					},
					[2] = {
						{expect = {"&playerguid&","~=","#4#"}},
						{alert = "overwhelmdurother"},
					},
				},
			},
			-- Steelbreaker Fusion Punch
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {63493,61903},
				execute = {
					[1] = {
						{alert = "fusionpunchcd"},
						{alert = "fusionpunchcast",},
					},
				},
			},
			-- Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					[1] = {
						{expect = {"#5#","==",L["Steelbreaker"]}},
						{quash = "fusionpunchcd"},
						{quash = "fusionpunchcast"},
					},
					[2] = {
						{expect = {"#5#","==",L["Stormcaller Brundir"]}},
						{quash = "overloadcd"},
						{quash = "overloadwarn"},
					},
					--[[
					[3] = {
						{expect = {"#5#","==",L["Runemaster Molgeim"]}},
					},
					]]
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
