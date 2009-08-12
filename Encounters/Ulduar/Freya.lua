do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 296,
		key = "freya", 
		zone = L["Ulduar"], 
		name = L["Freya"], 
		triggers = {
			scan = {
				32906, -- Freya
				32916, -- Snaplasher
				32919, -- Storm Lasher
				33202, -- Ancient Water Spirit
				33203, -- Ancient Conservator
				32918, -- Detonating Lasher
			}
		},
		onactivate = {
			tracing = {32906}, -- Freya
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {
			spawntime = {10,60,loop=false}
		},
		onstart = {
			{
				{alert = "spawncd"},
				{alert = "enragecd"},
			},
		},
		alerts = {
			spawncd = {
				varname = format(L["%s Timer"],SN[62678]),
				text = SN[62678],
				type = "dropdown",
				time = "<spawntime>",
				flashtime = 5,
				color1 = "MAGENTA",
				icon = ST[31687],
			},
			giftwarn = {
				varname = format(L["%s Warning"],L["Eonar's Gift"]),
				type = "simple",
				text = format(L["%s Spawned"],L["Eonar's Gift"]).."!",
				time = 3,
				sound = "ALERT2",
				color1 = "VIOLET",
				icon = ST[62584],
			},
			attunedwarn = {
				type = "simple",
				varname = format(L["%s Removal"],SN[62519]),
				text = format(L["%s Removed"],SN[62519]).."!",
				time = 1.5,
				sound = "ALERT9",
				icon = ST[62519],
			},
			naturesfuryself = {
				varname = format(L["%s on self"],SN[62589]),
				text = format("%s: %s! %s!",L["Fury"],L["YOU"],L["MOVE NOW"]),
				type = "centerpopup",
				time = 10,
				flashtime = 10,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[62589],
			},
			naturesfuryproximitywarn = {
				varname = format(L["%s Proximity Warning"],SN[62589]),
				text = format("%s: #5#! %s!",L["Fury"],L["MOVE AWAY"]),
				type = "simple",
				time = 2,
				color1 = "BLACK",
				sound = "ALERT1",
				icon = ST[62589],
			},
			gripwarn = {
				varname = format(L["%s Warning"],SN[62532]),
				type = "simple",
				text = format("%s: %s! %s!",SN[56689],L["YOU"],L["TAKE COVER"]),
				time = 1.5,
				color1 = "GREEN",
				throttle = 5,
				sound = "ALERT6",
				flashscreen = true,
				icon = ST[62532],
			},
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 600,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			groundtremorwarn = {
				varname = format(L["%s Cast"],SN[62437]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[62437]),
				time = 2,
				flashtime = 2,
				color1 = "BROWN",
				color2 = "ORANGE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[62437],
			},
			groundtremorcd = {
				varname = format(L["%s Cooldown"],SN[62437]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[62437]),
				time = 28,
				flashtime = 5,
				color1 = "TAN",
				color2 = "TAN",
				sound = "ALERT7",
				icon = ST[62437],
			},
			unstablewarnself = {
				varname = format(L["%s on self"],SN[62217]),
				type = "simple",
				text = format("%s: %s! %s!",SN[36514],L["YOU"],L["MOVE"]),
				time = 2,
				throttle = 3,
				color1 = "YELLOW",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[62217],
			},
		},
		arrows = {
			rootarrow = {
				varname = SN[62283],
				unit = "#5#",
				persist = 20,
				action = "TOWARD",
				msg = L["KILL IT"],
				spell = L["Roots"],
				sound = "ALERT4",
			},
		},
		events = {
			-- Spawn waves
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Ancient Conservator
					{
						{expect = {"#1#","find",L["^Eonar, your servant"]}},
						{tracing = {32906,33203}}, -- Freya, Ancient Conservator
						{quash = "spawncd"},
						{alert = "spawncd"},
					},
					-- Detonating Lashers
					{
						{expect = {"#1#","find",L["^The swarm of the elements"]}},
						{quash = "spawncd"},
						{alert = "spawncd"},
					},
					-- Elementals
					{
						{expect = {"#1#","find",L["^Children, assist"]}},
						{tracing = {32906,33202,32919,32916}}, -- Freya, Ancient Water Spirit, Storm Lasher, Snap Lasher
						{quash = "spawncd"},
						{alert = "spawncd"},
					},	
				},
			},
			-- Eonar's Gift
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						{expect = {"#1#","find",L["begins to grow!$"]}},
						{alert = "giftwarn"},
					},
				},
			},
			-- Nature's Fury from Ancient Conservator
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62589,63571},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "naturesfuryself"},
					},
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{proximitycheck = {"#5#",11}},
						{alert = "naturesfuryproximitywarn"},
					},
				},
			},
			-- Attuned to Nature Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 62519,
				execute = {
					{
						{quash = "spawncd"},
						{alert = "attunedwarn"},
					},
				},
			},
			-- Ancient Conservator - Conservator's Grip 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62532,
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "gripwarn"},
					},
				},
			},
			-- Ground Tremor (Hard Mode)
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62437,62859},
				execute = {
					{
						{alert = "groundtremorwarn"},
						{alert = "groundtremorcd"},
					},
				},
			},
			-- Unstable Energy
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62865,62451},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "unstablewarnself"},
					},
				},
			},
			-- Nature's Fury removed from player
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {62589,63571},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "naturesfuryself"},
					},
				},
			},
			-- Iron Roots
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {62861,62930,62283,62438},
				execute = {
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{arrow = "rootarrow"},
					},
				},
			},
			-- Iron Roots Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {62861,62930,62283,62438},
				execute = {
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{removearrow = "#5#"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
