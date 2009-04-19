do
	local data = {
		version = "$Rev$",
		key = "ironcouncil", 
		zone = "Ulduar", 
		name = "Iron Council", 
		title = "Iron Council", 
		tracing = {"Steelbreaker", "Runemaster Molgeim", "Stormcaller Brundir",},
		triggers = {
			scan = {"Steelbreaker", "Runemaster Molgeim", "Stormcaller Brundir",},
		},
		onactivate = {
			autostart = true,
			leavecombat = true,
		},
		userdata = {
			--overwhelmtime = 25,
			previoustarget = "",
		},
		onstart = {
			[1] = {
				{alert = "enragecd"},
				--{expect = {"&difficulty&","==","1"}},
				--{set = {overwhelmtime = 60}},
			},
		},
		-- TODO: Add Fusion Punch Cast, Runic Barrier Duration, Lightning Whirl Cooldown, Static Disruption Cooldown, Rune of Summoning Cooldown, 
		--       Lightning Tendrils Cooldown, Overwhelm Cooldown, Overload Cooldown
		alerts = {
			enragecd = {
				var = "enragecd",
				varname = "Enrage cooldown",
				type = "dropdown",
				text = "Enrage",
				time = 600,
				flashtime = 5,
			},
			fusionpunchcast = {
				var = "fushionpunchcast",
				varname = "Fushion Punch cast",
				type = "centerpopup",
				text = "Fusion Punch Cast",
				time = 3,
				color1 = "BROWN",
				sound = "ALERT5",
			},
			fusionpunchcd = {
				var = "fushionpunchcd",
				varname = "Fushion Punch cooldown",
				type = "dropdown",
				text = "Fusion Punch cooldown",
				time = 12,
				flashtime = 5,
				color1 = "TEAL",
				color2 = "BLUE",
			},
			runeofsummoningwarn = {
				var = "runeofsummoningwarn",
				varname = "Rune of Summoning warning",
				type = "simple",
				text = "Rune of Summoning Casted!",
				sound = "ALERT1",
				color2 = "MAGENTA",
				time = 1.5,
			},
			runeofdeathwarn = {
				var = "runeofdeathwarn",
				varname = "Rune of Death warning on self",
				type = "simple",
				text = "Rune of Death: YOU!",
				time = 1.5,
				sound = "ALERT3",
			},
			runeofpowerwarn = {
				var = "runeofpowerwarn",
				varname = "Rune of Power cast",
				type = "centerpopup",
				text = "Rune of Power Cast",
				sound = "ALERT4",
				color1 = "GREEN",
				time = 1.5,
			},
			overloadwarn = {
				var = "overloadwarn",
				varname = "Overload cast",
				type = "centerpopup",
				text = "Overload! Move Away!",
				time = 6, 
				flashtime = 6,
				sound = "ALERT2",
				color1 = "MAGENTA",
			},
			tendrilsdur = {
				var = "tendrilscd", 
				varname = "Lightning Tendrils duration", 
				type = "centerpopup", 
				text = "Lightning Tendrils Duration", 
				time = 35, 
				color1 = "BLUE", 
			},
			tendrilswarnself = {
				var = "tendrilswarn",
				varname = "Lightning Tendrils targeting warning",
				type = "simple",
				text = "Lightning Tendrils: YOU! Run!",
				time = 1.5,
				color1 = "DCYAN",
				sound = "ALERT5",
			},
			tendrilswarnother = {
				var = "tendrilswarn",
				varname = "Lightning Tendrils targeting warning",
				type = "simple",
				text = "Lightning Tendrils: <previoustarget>",
				color1 = "YELLOW",
				time = 1.5,
			},
			overwhelmdurself = {
				var = "overwhelmdurself",
				varname = "Overwhelm duration on self",
				type = "centerpopup",
				text = "Overwhelm: YOU!",
				time = 25,--"<overwhelmtime>",
				color1 = "DCYAN",
				sound = "ALERT6",
			},
			overwhelmdurother = {
				var = "overwhelmdurother",
				varname = "Overwhelm duration on others",
				type = "centerpopup",
				text = "Overwhelm: #4#",
				time = 25,--"<overwhelmtime>",
				color1 = "YELLOW",
				color2 = "DCYAN",
				sound = "ALERT7",
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
					{expect = {"&tft3_unitexists& &tft3_isplayer&","==","true true"}},
					{expect = {"&tft3_unitname&","~=","<previoustarget>"}},
					{set = {previoustarget = "&tft3_unitname&"}},
					{alert = "tendrilswarnself"},
				},
				[2] = {
					{expect = {"&tft3_unitexists& &tft3_isplayer&","==","true false"}},
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
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {61869, 63481},
				execute = {
					[1] = {
						{alert = "overloadwarn"},
					},
				},
			},
			-- Stormcaller Brundir - Lightning Tendrils +2
			[2] = {
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
			[3] = {
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
			[4] = {
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
			[5] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_START", 
				spellid = 62273,
				execute = {
					[1] = {
						{alert = "runeofsummoningwarn"},
					},
				},
			},
			--[[
			[6] = {
				type = "combatevent",
				spellid = 
				eventtype = "SPELL_CAST_SUCCESS",
				execute = {
					[1] = {
					},
				},
			},]]
			-- Steelbreaker - Overwhelm - +2
			[6] = {
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
			-- Fusion Punch
			[7] = {
				type = "combatevent",
				spellid = 63493,
				eventtype = "SPELL_CAST_START",
				execute = {
					[1] = {
						{alert = "fusionpunchcd"},
						{alert = "fusionpunchcast",},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
