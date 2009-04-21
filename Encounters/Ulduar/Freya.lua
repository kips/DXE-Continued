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
			spawntime = {8,60,loop=false}
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
				color1 = "INDIGO",
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
		},
		-- TODO
		-- Ground Tremor for hard mode
		timers = {
			sunbeam = {
				[1] = {
					{expect = {"&tft_unitexists& &tft_isplayer&","==","true true"}},
					{alert = "sunbeamwarnself"},
				},
				[2] = {
					{expect = {"&tft_unitexists& &tft_isplayer&","==","true false"}},
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
				spellid = {62623,62873},
				execute = {
					[1] = {
						{scheduletimer = {"sunbeam",0.1}},
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
		},
	}

	DXE:RegisterEncounter(data)
end
