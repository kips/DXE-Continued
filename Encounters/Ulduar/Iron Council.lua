--[[
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
			autoupdate = true,
			autostart = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "enragecd"},
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
				varname = "Rune of summoning warning",
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
				varname = "Rune of power warning",
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
			[3] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {62269, 63490},
				execute = {
					[1] = {
						{alert = "runeofdeathwarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
]]
