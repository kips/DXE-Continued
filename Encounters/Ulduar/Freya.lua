do
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "freya", 
		zone = L["Ulduar"], 
		name = L["Freya"], 
		triggers = {
			scan = {
				L["Freya"], 
				L["Snaplasher"],
				L["Storm Lasher"],
				L["Ancient Water Spirit"],
				L["Ancient Conservator"],
				L["Detonating Lasher"],
			}
		},
		onactivate = {
			tracing = {L["Freya"]},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			spawntime = {10,60,loop=false}
		},
		onstart = {
			[1] = {
				{alert = "spawncd"},
				{alert = "enragecd"},
			},
		},
		alerts = {
			spawncd = {
				var = "spawncd",
				varname = format(L["%s Timer"],SN[62678]),
				text = SN[62678],
				type = "dropdown",
				time = "<spawntime>",
				flashtime = 5,
				color1 = "MAGENTA",
			},
			giftwarn = {
				var = "giftwarn",
				varname = format(L["%s Warning"],L["Eonar's Gift"]),
				type = "simple",
				text = format(L["%s Spawned"],L["Eonar's Gift"]).."!",
				time = 3,
				sound = "ALERT2",
				color1 = "VIOLET",
			},
			attunedwarn = {
				var = "attunedwarn",
				type = "simple",
				varname = format(L["%s Removal"],SN[62519]),
				text = format(L["%s Removed"],SN[62519]).."!",
				time = 1.5,
				sound = "ALERT9",
			},
			naturesfuryself = {
				var = "naturesfuryself",
				varname = format(L["%s on self"],SN[62589]),
				text = format("%s: %s! %s!",L["Fury"],L["YOU"],L["MOVE NOW"]),
				type = "centerpopup",
				time = 10,
				flashtime = 10,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT1",
			},
			naturesfuryproximitywarn = {
				var = "naturesfuryproximitywarn",
				varname = format(L["%s Proximity Warning"],SN[62589]),
				text = format("%s: #5#! %s!",L["Fury"],L["MOVE AWAY"]),
				type = "simple",
				time = 2,
				color1 = "YELLOW",
				sound = "ALERT1",
			},
			gripwarn = {
				var = "gripwarn",
				varname = format(L["%s Warning"],SN[62532]),
				type = "simple",
				text = format("%s: %s! %s!",SN[56689],L["YOU"],L["TAKE COVER"]),
				time = 1.5,
				color1 = "GREEN",
				throttle = 5,
				sound = "ALERT6",
			},
			enragecd = {
				var = "enragecd",
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 600,
				flashtime = 5,
				color1 = "RED",
			},
			groundtremorwarn = {
				var = "groundtremorwarn",
				varname = format(L["%s Cast"],SN[62437]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[62437]),
				time = 2,
				flashtime = 2,
				color1 = "BROWN",
				color2 = "ORANGE",
				sound = "ALERT5",
			},
			groundtremorcd = {
				var = "groundtremorcd",
				varname = format(L["%s Cooldown"],SN[62437]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[62437]),
				time = 28,
				flashtime = 5,
				color1 = "TAN",
				color2 = "TAN",
				sound = "ALERT7",
			},
			unstablewarnself = {
				var = "unstablewarnself",
				varname = format(L["%s on self"],SN[62217]),
				type = "simple",
				text = format("%s: %s! %s!",SN[36514],L["YOU"],L["MOVE"]),
				time = 2,
				throttle = 3,
				color1 = "BLACK",
				sound = "ALERT3",
			},
		},
		events = {
			-- Spawn waves
			[1] = {
				type = "event",
				event = "YELL",
				execute = {
					-- Ancient Conservator
					[1] = {
						{expect = {"#1#","find",L["^Eonar, your servant"]}},
						{tracing = {L["Freya"],L["Ancient Conservator"]}},
						{quash = "spawncd"},
						{alert = "spawncd"},
					},
					-- Detonating Lashers
					[2] = {
						{expect = {"#1#","find",L["^The swarm of the elements"]}},
						{quash = "spawncd"},
						{alert = "spawncd"},
					},
					-- Elementals
					[3] = {
						{expect = {"#1#","find",L["^Children, assist"]}},
						{tracing = {L["Freya"],L["Ancient Water Spirit"], L["Storm Lasher"], L["Snaplasher"]}},
						{quash = "spawncd"},
						{alert = "spawncd"},
					},	
				},
			},
			-- Eonar's Gift
			[2] = {
				type = "event",
				event = "EMOTE",
				execute = {
					[1] = {
						{expect = {"#1#","find",L["begins to grow!$"]}},
						{alert = "giftwarn"},
					},
				},
			},
			-- Nature's Fury from Ancient Conservator
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62589,63571},
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "naturesfuryself"},
					},
					[2] = {
						{expect = {"#4#","~=","&playerguid&"}},
						{proximitycheck = {"#5#",11}},
						{alert = "naturesfuryproximitywarn"},
					},
				},
			},
			-- Attuned to Nature Removal
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 62519,
				execute = {
					[1] = {
						{quash = "spawncd"},
						{alert = "attunedwarn"},
					},
				},
			},
			-- Ancient Conservator - Conservator's Grip 
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62532,
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "gripwarn"},
					},
				},
			},
			-- Ground Tremor (Hard Mode)
			[6] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62437,62859},
				execute = {
					[1] = {
						{alert = "groundtremorwarn"},
						{alert = "groundtremorcd"},
					},
				},
			},
			-- Unstable Energy
			[7] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62865,62451},
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "unstablewarnself"},
					},
				},
			},
			-- Nature's Fury removed from player
			[8] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {62589,63571},
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "naturesfuryself"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
