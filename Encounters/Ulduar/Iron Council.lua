do
	local data = {
		version = "$Rev$",
		key = "ironcouncil", 
		zone = "Ulduar", 
		name = "Iron Council", 
		title = "Iron Council", 
		tracing = {"Steelbreaker, Runemaster Molgeim, Stormcaller Brundir",},
		triggers = {
			scan = {"Steelbreaker, Runemaster Molgeim, Stormcaller Brundir",},
		},
		onactivate = {
			autostart = true,
			leavecombat = true,
		},
		userdata = {
			overwhelmtime = 25,
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
				varname = "Enrage cooldown",
				type = "dropdown",
				text = "Enrage",
				time = 600,
				flashtime = 5,
			},
			runeofsummoningwarn = {
				var = "runeofsummoningwarn",
				varname = "Rune of Summoning warning",
				type = "simple",
				text = "Rune of Summoning casted. Careful!",
				sound = "ALERT1",
				time = 1.5,
			},
			runeofdeathwarn = {
				var = "runeofdeathwarn",
				varname = "Rune of Death warning on self",
				type = "simple",
				text = "Rune of Death on YOU!",
				time = 1.5,
				sound = "ALERT3",
			},
			runeofpowerwarn = {
				var = "runeofpowerwarn",
				varname = "Rune of Power warning",
				type = "simple",
				text = "Rune of Power!",
				sound = "ALERT4",
				time = 1.5,
			},
			overloadwarn = {
				var = "overloadwarn",
				varname = "Overload cast",
				type = "centerpopup",
				text = "Overload is casting!",
				time = 10,
				flashtime = 5,
				sound = "ALERT2",
				color1 = "MAGENTA",
			},
			tendrilsdur = {
				var = "tendrilscd", 
				varname = "Lightning Tendrils duration", 
				type = "centerpopup", 
				text = "Lightning Tendrils duration", 
				time = 35, 
				color1 = "BLUE", 
			},
			tendrilswarnself = {
				var = "tendrilswarn",
				varname = "Lightning Tendrils targeting warning",
				type = "simple",
				text = "Lightning Tendrils are now chasing YOU!",
				time = 1.5,
				color1 = "RED",
				sound = "ALERT5",
			},
			tendrilswarnother = {
				var = "tendrilswarn",
				varname = "Lightning Tendrils targeting warning",
				type = "simple",
				text = "Lightning tendrils are now chasing <previoustarget>",
				time = 1.5,
			},
			overwhelmdurself = {
				var = "overwhelmdurself",
				varname = "Overwhelm duration on self",
				type = "centerpopup",
				text = "You are OVERWHELMED!",
				time = "<overwhelmtime>",
				color1 = "DCYAN",
			},
			overwhelmdurother = {
				var = "overwhelmdurother",
				varname = "Overwhelm duration on others",
				type = "centerpopup",
				text = "#4# is overwhelmed for...",
				time = "<overwhelmtime>",
				color1 = "CYAN",
			},
		},
		timers = {
			canceltendril = {
				[1] = {
					{canceltimer = "tendriltargets"},
					{set = {previoustarget = ""}},
				},
			},
			-- tft3 = Stormcaller Brundir
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
				eventtype = "SPELL_CAST_START",
				spellid = 63481,
				execute = {
					[1] = {
						{alert = "overloadwarn"},
					},
				},
			},
			-- Stormcaller Brundir - Lightning Tendrils
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 63485, 
				execute = {
					[1] = {
						{alert = "tendrilsdur"},
						{scheduletimer = {"tendriltargets",0}},
						{scheduletimer = {"canceltendril",35}},
					},
				},
			},
			-- Runemaster Molgeim - Rune of Summoning - Elementals spawn - 2 dead
			[3] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 62273,
				execute = {
					[1] = {
						{alert = "runeofsummoningwarn"},
					},
				},
			},
			-- Steelbreaker - Rune of Power
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 61974,
				execute = {
					[1] = {
						{alert = "runeofpowerwarn"},
					},
				},
			},
			-- Runemaster Molgeim - Rune of Death
			[5] = {
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
			-- Steelbreaker - Overwhelm - 2 dead
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
		},
	}

	DXE:RegisterEncounter(data)
end
