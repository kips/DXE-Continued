do
	local data = {
		version = "$Rev$",
		key = "freya", 
		zone = "Ulduar", 
		name = "Freya", 
		title = "Freya", 
		tracing = {"Freya"},
		triggers = {
			scan = "Freya", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			spawnmessage = "Minions",
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
				varname = "Minion spawn cooldown",
				text = "Spawn: <spawnmessage>",
				type = "dropdown",
				time = "<spawntime>",
				flashtime = 5,
				color1 = "MAGENTA",
			},
			giftwarn = {
				var = "giftwarn",
				varname = "Eonar's Gift spawn warning",
				type = "simple",
				text = "Eonar's Gift Spawned!",
				time = 1.5,
				sound = "ALERT2",
				color1 = "PEACH",
			},
			attunedwarn = {
				var = "attunedwarn",
				type = "simple",
				varname = "Attuned to Nature removal warning",
				text = "Attuned to Nature Removed!",
				time = 1.5,
				sound = "ALERT3",
			},
			sunbeamwarnself = {
				var = "sunbeamwarn",
				varname = "Sunbeam warning",
				type = "simple",
				text = "Sunbeam: YOU! Move!",
				time = 1.5,
				color1 = "GOLD",
				sound = "ALERT4",
			},
			sunbeamwarnother = {
				var = "sunbeamwarn",
				varname = "Sunbeam warning",
				text = "Sunbeam: &tft_unitname&",
				type = "simple",
				time = 1.5,
				color1 = "GOLD",
				sound = "ALERT4",
			},
			naturesfuryself = {
				var = "naturesfuryself",
				varname = "Nature's Fury on self",
				text = "Nature's Fury: YOU!",
				type = "centerpopup",
				time = 10,
				flashtime = 10,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT1",
			},
			naturesfuryothers = {
				var = "naturesfuryothers",
				varname = "Nature's Fury on others",
				text = "Nature's Fury: #5#",
				type = "centerpopup",
				time = 10,
				color1 = "BLUE",
			},
			gripwarn = {
				var = "gripwarn",
				varname = "Conservators Grip warning",
				type = "simple",
				text = "Get Under a Mushrooom!",
				time = 1.5,
				color1 = "GREEN",
				throttle = 5,
				sound = "ALERT6",
			},
			enragecd = {
				var = "enragecd",
				varname = "Enrage cooldown",
				type = "dropdown",
				text = "Enrage",
				time = 600,
				flashtime = 5,
				color1 = "RED",
			},
			groundtremorwarn = {
				var = "groundtremorwarn",
				varname = "Ground Tremor warning",
				type = "centerpopup",
				text = "Ground Tremor Cast",
				time = 2,
				flashtime = 2,
				color1 = "BROWN",
				color2 = "ORANGE",
				sound = "ALERT5",
			},
			groundtremorcd = {
				var = "groundtremorcd",
				varname = "Ground Tremor cooldown",
				type = "dropdown",
				text = "Ground Tremor Cooldown",
				time = 28,
				flashtime = 5,
				color1 = "TAN",
				color2 = "TAN",
				sound = "ALERT7",
			},
			-- It's off and pretty useless imo
			--[[
			sunbeamcd = {
				var = "sunbeamcd",
				varname = "Sun Beam cooldown",
				type = "dropdown",
				text = "Sun Beam Cooldown",
				time = 28,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "YELLOW",
				sound = "ALERT8",
			},
			]]
		},
		timers = {
			sunbeam = {
				[1] = {
					{expect = {"&tft_unitexists& &tft_isplayer&","==","1 1"}},
					{alert = "sunbeamwarnself"},
				},
				[2] = {
					{expect = {"&tft_unitexists& &tft_isplayer&","==","1 nil"}},
					{alert = "sunbeamwarnother"},
				},
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
						{expect = {"#1#","find","^Eonar, your servant"}},
						{set = {spawnmessage = "Ancient Conservator"}},
						{alert = "spawncd"},
					},
					-- Detonating Lashers
					[2] = {
						{expect = {"#1#","find","^The swarm of the elements"}},
						{set = {spawnmessage = "Detonating Lashers"}},
						{alert = "spawncd"},
					},
					-- Elementals
					[3] = {
						{expect = {"#1#","find","^Children, assist"}},
						{set = {spawnmessage = "Elementals"}},
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
						{expect = {"#1#","find","^A Lifebinder's Gift"}},
						{alert = "giftwarn"},
					},
				},
			},
			-- Sunbeam
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62872},
				execute = {
					[1] = {
						{scheduletimer = {"sunbeam",0.1}},
						--{alert = "sunbeamcd"},
					},
				},
			},
			-- Nature's Fury from Ancient Conservator. Add Fury quashing on SPELL_AURA_REMOVED?
			[4] = {
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
						{alert = "naturesfuryothers"},
					},
				},
			},
			-- Attuned to Nature
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 62519,
				execute = {
					[1] = {
						{alert = "attunedwarn"},
					},
				},
			},
			-- Ancient Conservator - Conservator's Grip 
			[6] = {
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
			[7] = {
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
		},
	}

	DXE:RegisterEncounter(data)
end
