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
			tracerstart = true,
			combatstop = true,
		},
		userdata = {
			overwhelmtime = 30,
			previoustarget = "",
		},
		onstart = {
			{
				{alert = "enragecd"},
				{expect = {"&difficulty&","==","1"}},
				{set = {overwhelmtime = 60}},
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 600,
				flashtime = 5,
				color1 = "RED",
			},
			fusionpunchcast = {
				varname = format(L["%s Cast"],SN[61903]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[61903]),
				time = 3,
				color1 = "BROWN",
				sound = "ALERT5",
			},
			fusionpunchcd = {
				varname = format(L["%s Cooldown"],SN[61903]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[61903]),
				time = 12,
				flashtime = 5,
				color1 = "BLUE",
				color2 = "GREY",
			},
			runeofsummoningwarn = {
				varname = format(L["%s Warning"],SN[62273]),
				type = "simple",
				text = format(L["%s Casted"],SN[62273]).."!",
				sound = "ALERT1",
				color2 = "MAGENTA",
				time = 1.5,
			},
			runeofdeathwarn = {
				varname = format(L["%s on self"],SN[62269]),
				type = "simple",
				text = format("%s: %s!",SN[62269],L["YOU"]),
				time = 1.5,
				sound = "ALERT3",
			},
			runeofpowerwarn = {
				varname = format(L["%s Cast"],SN[61973]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[61973]),
				sound = "ALERT4",
				color1 = "GREEN",
				time = 1.5,
			},
			overloadwarn = {
				varname = format(L["%s Cast"],SN[61869]),
				type = "centerpopup",
				text = format("%s! %s!",SN[61869],L["MOVE AWAY"]),
				time = 6, 
				flashtime = 6,
				sound = "ALERT2",
				color1 = "PURPLE",
			},
			overloadcd = {
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
				varname = format(L["%s Duration"],SN[61887]),
				type = "centerpopup", 
				text = format(L["%s Duration"],SN[61887]),
				time = 35, 
				color1 = "BLUE", 
			},
			tendrilswarnself = {
				varname = format(L["%s Target"],SN[61887]),
				type = "simple",
				text = format("%s: <previoustarget>",SN[61887]),
				color1 = "YELLOW",
				time = 1.5,
			},
			tendrilswarnother = {
				varname = format(L["%s Target"],SN[61887]),
				type = "simple",
				text = format("%s: <previoustarget>",SN[61887]),
				color1 = "YELLOW",
				time = 1.5,
			},
			whirlwarn = {
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
				varname = format(L["%s on others"],L["Overwhelm"]),
				type = "centerpopup",
				text = format("%s: #5#",L["Overwhelm"]),
				time = "<overwhelmtime>",
				color1 = "DCYAN",
			},
		},
		timers = {
			canceltendril = {
				{
					{canceltimer = "tendriltargets"},
					{set = {previoustarget = ""}},
				},
			},
			-- tft3 = Stormcaller Brundir's Target
			tendriltargets = {
				{
					{expect = {"&tft3_unitexists& &tft3_isplayer&","==","1 1"}},
					{expect = {"&tft3_unitname&","~=","<previoustarget>"}},
					{set = {previoustarget = "&tft3_unitname&"}},
					{alert = "tendrilswarnself"},
				},
				{
					{expect = {"&tft3_unitexists& &tft3_isplayer&","==","1 nil"}},
					{expect = {"&tft3_unitname&","~=","<previoustarget>"}},
					{set = {previoustarget = "&tft3_unitname&"}},
					{alert = "tendrilswarnother"},
				},
				{
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
					{
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
					{
						{alert = "whirlwarn"},
					},
				},
			},
			-- Stormcaller Brundir - Lightning Whirl Interruption +1
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					{
						{expect = {"#10#","==","63483"}},
						{quash = "whirlwarn"},
					},
					{
						{expect = {"#10#","==","61915"}},
						{quash = "whirlwarn"},
					},
				},
			},
			-- Stormcaller Brundir - Lightning Tendrils +2
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {61887, 63486}, 
				execute = {
					{
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
					{
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
					{
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
					{
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
					{
						{expect = {"&playerguid&","==","#4#"}},
						{alert = "overwhelmdurself"},
					},
					{
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
					{
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
					{
						{expect = {"#5#","==",L["Steelbreaker"]}},
						{quash = "fusionpunchcd"},
						{quash = "fusionpunchcast"},
					},
					{
						{expect = {"#5#","==",L["Stormcaller Brundir"]}},
						{quash = "overloadcd"},
						{quash = "overloadwarn"},
					},
					--[[
					{
						{expect = {"#5#","==",L["Runemaster Molgeim"]}},
					},
					]]
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
