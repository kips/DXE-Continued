local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ASCENDANT COUNCIL 
---------------------------------

do
	local data = {
		version = 4,
		key = "ascendcouncil",
		zone = L.zone["The Bastion of Twilight"],
		category = L.zone["Bastion"],
		name = L.npc_bastion["The Ascendant Council"],
		triggers = {
			scan = {
				43687, -- Feludius 
				43686, -- Ignacious 
			},
		},
		onactivate = {
			tracing = {
				43687, -- Feludius 
				43686, -- Ignacious 
				43688, -- Arion
				43689, -- Terrastra
				43735, -- Elementium Monstrosity
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				43735, -- Elementium Monstrosity
			},
		},
		userdata = {
			phase = "1",
			hardenabsorbamount = 0,
			aegisabsorbamount = 0,
			glaciatetime = {30,35,loop = false, type = "series"},
		},
		onstart = {
			{
				{ 
					"expect", {"&difficulty&", "==", "1"}, --10s normal 
					"set", {hardenabsorbamount = 650000},
					"set", {aegisabsorbamount = 500000},
				}, 
				{ 
					"expect", {"&difficulty&", "==", "2"}, --25s normal 
					"set", {hardenabsorbamount = 1650000},
					"set", {aegisabsorbamount = 1500000},
				}, 
				{ 
					"expect", {"&difficulty&", "==", "3"}, --10s heroic 
					-- this number is *very* uncertain, could not find good data on wowhead. only show'd three number so I took the one that was 1 up from the bottom.
					"set", {hardenabsorbamount = 1650000},
					"set", {aegisabsorbamount = 500000},
				}, 
				{ 
					"expect", {"&difficulty&", "==", "4"}, --25s heroic }, 
					"set", {hardenabsorbamount = 2100000},
					"set", {aegisabsorbamount = 1500000},
				},			
				"set", {phase = "1"},
				"alert", "glaciatecd",
			},
		},
		windows = {
		},
		alerts = {
			-- Monstrosity
			stasisdur = {
				varname = format(L.alert["%s Duration"], SN[82285]),
				type = "dropdown",
				text = format(L.alert["%s Duration"], SN[82285]),
				time = 17,
				color1 = "PURPLE",
				throttle = 10,
				icon = ST[82285],
			},
			gravitycrushcd = {
				varname = format(L.alert["%s Cooldown"], SN[84948]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[84948]),
				color1 = "PURPLE",
				time = 10,
				icon = ST[84948],
			},
			lavaseedcast = {
				varname = format(L.alert["%s Casting"],SN[84913]),
				type = "simple",
				text = format(L.alert["%s Casting"],SN[84913]),
				flashtime = 2,
				flashscreen = true,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[84913],
			},
			
			-- Terrastra
			hardenabsorb = {
				varname = format(L.alert["%s Absorb"], SN[92541]),
				type = "absorb",
				text = format(L.alert["%s Absorb"], SN[92541]),
				total = "<hardenabsorbamount>",
				color1 = "BROWN",
				npcid = 43689,
				icon = ST[92541],
			},
			lightningrodself = {
				varname = format(L.alert["%s on self"],SN[83099]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[83099],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 15,
				flashtime = 15,
				throttle = 15,
				color1 = "BLUE",
				sound = "ALERT1",
				icon = ST[83099],
			},
			
			-- Ignacious
			aegiscd = {
				varname = format(L.alert["%s Cooldown"], SN[82631]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[82631]),
				time = 30,
				flashtime = 3,
				sound = "ALERT2",
				color1 = "MAGENTA",
				icon = ST[82631],
			},
			aegisabsorb = {
				varname = format(L.alert["%s Absorb"], SN[82631]),
				type = "absorb",
				text = format(L.alert["%s Absorb"], SN[82631]),
				total = "<aegisabsorbamount>",
				color1 = "BROWN",
				npcid = 43686,
				icon = ST[82631],
			},
			infernocd = {
				varname = format(L.alert["%s Cooldown"], SN[82857]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[82857]),
				time = 30,
				color1 = "MAGENTA",
				icon = ST[82857],
			},
			
			-- Feludius
			glaciatecd = {
				varname = format(L.alert["%s Cooldown"], SN[92506]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[92506]),
				time = "<glaciatetime>",
				flashtime = 3,
				color1 = "MAGENTA",
				icon = ST[92506],
			},
			eruptioncd = {
				varname = format(L.alert["%s Cooldown"], SN[83675]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[83675]),
				time = 35,
				color1 = "MAGENTA",
				icon = ST[83675],
			},
			
			thundershockcd = {
				varname = format(L.alert["%s Cooldown"], SN[83067]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[83067]),
				color1 = "MAGENTA",
				time = 30,
				time2 = 70,
				icon = ST[83067],
			},
			quakecd = {
				varname = format(L.alert["%s Cooldown"], SN[92544]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[92544]),
				color1 = "MAGENTA",
				time = 33,
				time2 = 65,
				icon = ST[92544],
			},
			thundershockwarn = {
				varname = format(L.alert["%s Casting"],SN[83067]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[83067]),
				time = 3,
				color1 = "BROWN",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[83067],
			},
			quakewarn = {
				varname = format(L.alert["%s Casting"],SN[92544]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[92544]),
				time = 3,
				color1 = "BROWN",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[92544],
			},
			
			hardenskincd = {
				varname = format(L.alert["%s Cooldown"], SN[92541]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[92541]),
				color1 = "MAGENTA",
				time = 27,
				icon = ST[92541],
			},
			waterloggedself = {
				varname = format(L.alert["%s on Self"],SN[82762]),
				type = "simple",
				text = format(L.alert["%s on Self"],SN[82762]),
				flashtime = 3,
				time = 3,
				flashscreen = true,
				color1 = "VIOLET",
				sound = "ALERT2",
				icon = ST[82762],
			},
			frozenbloodself = {
				varname = format(L.alert["%s on Self"],SN[92503]),
				type = "centerpopup",
				text = format(L.alert["%s on Self"],SN[92503]),
				time = 10,
				color1 = "BLUE",
				sound = "ALERT5",
				icon = ST[92503],
			},
		},
		timers = {
		},
		raidicons = {
			lightningrodmark = {
				varname = SN[83099],
				type = "FRIENDLY",
				persist = 15,
				unit = "#5#",
				icon = 1,
				reset = 10,				
			},
			--[[waterloggedmark = {
				varname = SN[82762],
				type = "MULTIFRIENDLY",
				persist = 15,
				unit = "#5#",
				icon = 2,
				total = 5,
				reset = 10,
			},]]
		},
		announces = {
			burningsay = {
				varname = format(L.alert["%s on meh!"], SN[82660]),
				type = "SAY",
				msg = format(L.alert["%s on meh!"], SN[82660]),
			},
			heartsay = {
				varname = format(L.alert["%s on meh!"], SN[82665]),
				type = "SAY",
				msg = format(L.alert["%s on meh!"], SN[82665]),
			},
			lightningrodsay = {
				varname = format(L.alert["FUCKING %s ON MEH!"], SN[83099]),
				type  "SAY",
				msg = format(L.alert["FUCKING %s ON MEH!"], SN[83099]),
			},
		},
		events = {
			-- Gravity Crush
			{
				type = "combatevent",
				eventtype = "SPELL_CHANNEL_START",
				spellname = {84948, 92486, 92487, 92488},
				execute = {
					{
						"alert", "gravitycrushcd",
					},
				},
			},
			
			-- Quake
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {83565, 92544, 92545, 92546},
				execute = {
					{
						"alert", "thundershockcd",
						"alert", "quakewarn",
					},
				},
			},
			-- Harden Skin
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {83718, 92541, 92542, 92543},
				execute = {
					{
						"alert", "hardenskincd",
						"alert", "hardenabsorb",
					},
				},
			},
			-- Gravity Well
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 83572,
				execute = {
					{
					},
				},
			},
			-- Eruption
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 83675,
				execute = {
					{
						"alert", "eruptioncd",
					},
				},
			},
			-- Elemental Stasis
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 82285,
				execute = {
					{
						"set", {phase = "3"},
						"alert", "stasisdur",
						"quash", "aegisdur",
						"quash", "glaciatecd",
						"quash", "thundershockcd",
						"quash", "hardenskincd",
						"quash", "quakecd",
					},
				},
			},
			-- Thundershock
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {83067, 92469},
				execute = {
					{
						"alert", "quakecd",
						"alert", "thundershockwarn",
					},
				},
			},
			-- Lightning Rod
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 83099,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","lightningrodself",
						"announce", "lightningrodsay",
					},
				},
			},
			-- Lightning Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {83070, 92454},
				execute = {
					{
					},
				},
			},
			-- Disperse
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 83087,
				execute = {
					{
					},
				},
			},
			-- Call Winds
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 83491,
				execute = {
					{
					},
				},
			},
			-- Rising Flames
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 82636,
				execute = {
					{
					},
				},
			},
			-- Flame Torrent
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {92516, 88558, 82777},
				execute = {
					{
					},
				},
			},
			-- Burning Blood
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {82631, 82660, 82663},
				execute = {
					{
						"announce", "burningsay",
					},
				},
			},
			-- Aegis of Flame
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {82631, 92513, 92512, 92514},
				execute = {
					{
						"alert", "aegiscd",
						"alert", "aegisabsorb",
					},
				},
			},
			-- Inferno Leap
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {82857, 82631},
				execute = {
					{
						"alert", "infernocd",
					},
				},
			},
			-- Water Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 82699,
				execute = {
					{
					},
				},
			},
			-- Waterlogged
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 82762,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","waterloggedself",
					},
				},
			},
			-- Hydro Lance
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {92509, 82752},
				execute = {
					{
					},
				},
			},
			-- Heart of Ice
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 82665,
				execute = {
					{
						"announce", "heartsay",
					},
				},
			},
			-- Glaciate
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {82746, 92507, 92506, 92508},
				execute = {
					{
						"alert", "glaciatecd",
					},
				},
			},
			-- Lava seed cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {84913, 84911},
				srcnpcid = 43735,
				execute = {
					{
						"alert","lavaseedcast",
					},
				},
			},
			--[[
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#", "find", L.chat_bastion["^FEEL THE POWER!"]},
						"alert","lavaseedcast",
					},
				},
			},]]
			-- Frozen blood
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = {82772, 92503, 92504, 92505},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","frozenbloodself",
					},
				},
			},
			
			-- P2
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#", "find", L.chat_bastion["^Enough of this foolishness!"]},
						"alert",{"thundershockcd", time = 2},
						"alert","quakecd",
						"alert","hardenskincd",
						
					},
				},
			},
		}, 
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- VALIONA & THERALION 
---------------------------------

do
	local data = {
		version = 2,
		key = "val+ther",
		zone = L.zone["The Bastion of Twilight"],
		category = L.zone["Bastion"],
		name = L.npc_bastion["Valiona & Theralion"],
		triggers = {
			scan = {
				45992, -- Valiona
				45993, -- Theralion
			},
		},
		onactivate = {
			tracing = {
				45992, -- Valiona
				45993, -- Theralion
			},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = {
				45992, -- Valiona
				45993, -- Theralion
			},
		},
		alerts = {
			flamewarn = {
				varname = format(L.alert["%s Casting"],SN[86840]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[86840]),
				time = 2.5,
				flashtime = 2.5,
				color1 = "ORANGE",
				sound = "ALERT12",
				icon = ST[86840],
			},
			dazzlewarn = {
				varname = format(L.alert["%s Casting"],SN[86408]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[86408]),
				time = 4,
				flashtime = 4,
				color1 = "GREEN",
				sound = "ALERT2",
				icon = ST[86408],
			},
			engulfself = {
				varname = format(L.alert["%s on Self"],SN[95639]),
				type = "centerpopup",
				text = format("%s: %s!",SN[95639],L.alert["YOU"]),
				time = 20,
				color1 = "CYAN",
				icon = ST[95639],
				flashscreen = true,
			},
			engulfdur = {
				varname = format(L.alert["%s Duration"],SN[95639]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[95639]),
				time = 20,
				color1 = "CYAN",
				icon = ST[95639],
			},
			engulfcd = {
				varname = format(L.alert["%s Cooldown"],SN[95639]),
				type = "centerpopup",
				text = format(L.alert["%s Cooldown"],SN[95639]),
				time = 37,
				color1 = "YELLOW",
				icon = ST[95639],
			},
			blackoutself = {
				varname = format(L.alert["%s on Self"],SN[92876]),
				type = "centerpopup",
				text = format("%s: %s!",SN[92876],L.alert["YOU"]),
				time = 15,
				color1 = "BLACK",
				sound = "ALERT1",
				icon = ST[92876],
				flashscreen = true,
			},
			blackoutwarn = {
				varname = format(L.alert["%s Warning"],SN[92876]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[92876]),
				time = 15,
				color1 = "BLACK",
				icon = ST[92876],
			},
			meteoriteself = {
				varname = format(L.alert["%s on self"],SN[92863]),
				type = "centerpopup",
				text = format(L.alert["%s Warning"],SN[92863]),
				time = 6,
				color1 = "PURPLE",
				icon = ST[92863],
				sound = "ALERT2",
			},
			meteoritewarn = {
				varname = format(L.alert["%s Warning"],SN[92863]),
				type = "centerpopup",
				text = format(L.alert["%s Warning"],SN[92863]),
				time = 6,
				color1 = "PURPLE",
				icon = ST[92863],
			},
			blastself = {
				varname = format(L.alert["%s on self"],SN[92904]),
				type = "centerpopup",
				text = format(L.alert["%s Warning"],SN[92904]),
				time = 2,
				color1 = "BLUE",
				icon = ST[92904],
				sound = "ALERT3",
			},
			blastwarn = {
				varname = format(L.alert["%s Casting"],SN[92904]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[92904]),
				time = 2,
				color1 = "BLUE",
				icon = ST[92904],
			},
		},
		announces = {
			engulfsay = {
				varname = format(L.alert["%s on meh!"], SN[95639]),
				type = "SAY",
				msg = format(L.alert["%s on meh!"], SN[95639]),
			},
		},
		arrows = {
			blackoutarrow = {
				varname = SN[92876],
				unit = "#5#",
				persist = 15,
				action = "TOWARD",
				msg = L.alert["MOVE TOWARD"],
				spell = SN[92876],
				-- TODO: Discover range on this ability tooltip says 0 yds.
			},
			engulfarrow = {
				varname = SN[95639],
				unit = "#5#",
				persist = 20,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[95639],
				-- TODO: Discover range on this ability tooltip says 0 yds.
			},
			-- The lack of arrows for Twilight Blast and Twilight Meteorite are not
			-- an oversight.  They don't fire SPELL_AURA events so it's a pain to provide this.
		},
		raidicons = {
			blackoutmark = {
				varname = SN[92876],
				type = "FRIENDLY",
				persist = 15,
				unit = "#5#",
				icon = 1,
			},
			engulfmark = {
				varname = SN[95639],
				type = "MULTIFRIENDLY",
				persist = 20,
				unit = "#5#",
				icon = 2,
				reset = 2, -- Guess as to how many there are for now.
				total = 2,
			},
		},
		timers = {
			fireblast = {
				{
					"expect",{"&playerdebuff|"..SN[92898].."&","==","true"},
					"alert","blastself",
				},
				{
					"expect",{"&playerdebuff|"..SN[92898].."&","~=","false"},
					"alert","blastwarn",
				},
			},
			firemeteorite = {
				{
					"expect",{"&playerdebuff|"..SN[92863].."&","==","true"},
					"alert","blastself",
				},
				{
					"expect",{"&playerdebuff|"..SN[92863].."&","~=","false"},
					"alert","blastwarn",
				},
			},
		},
		events = {
			-- Devouring Flames
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 86840,
				execute = {
					{
						"alert","flamewarn",
					},
				},
			},
			-- Dazzling Destruction
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 86408,
				execute = {
					{
						"alert","dazzlewarn",
						"alert","engulfcd",
					},
				},
			},
			-- Engulfing Magic
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = {95639, 95640, 95641, 86622, 86631},
				dstisplayerunit = true,
				execute = {
					{
						"raidicon","engulfmark",
						"alert","engulfcd",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","engulfself",
						"announce","engulfsay",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","engulfdur",
						"arrow","engulfarrow",
					},
				},
			},
			-- Blackout
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = {86788, 92877, 92876, 92878},
				execute = {
					{
						"raidicon","blackoutmark",
						"quash","engulfcd",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","blackoutself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","blackoutwarn",
						"arrow","blackoutarrow",
					},
				},
			},
			-- Blackout removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = {86788, 92877, 92876, 92878},
				execute = {
					{
						"batchquash",{"blackoutwarn","blackoutself"},
						"removeraidicon","#5#",
						"removearrow","#5#",
					},
				},
			},
			-- Twilight Meteorite
			-- Does not fire SPELL_AURA events so use a timer to wait and look with playerdebuff. 
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 92863,
				execute = {
					{
						"scheduletimer",{"firemeteorite",0.2},	
					},
				},
			},
			-- Twilight Blast
			-- Does not fire SPELL_AURA events so use a timer to wait and look with playerdebuff. 
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 92898,
				execute = {
					{
						"scheduletimer",{"fireblast",0.2},	
					},
				},
			},
		}, 
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- HALFUS WYRMBREAKER 
---------------------------------

do
	local data = {
		version = 5, 
		key = "halfus",
		zone = L.zone["The Bastion of Twilight"],
		category = L.zone["Bastion"],
		name = L.npc_bastion["Halfus Wyrmbreaker"],
		triggers = {
			scan = {
				44600, -- Halfus Wyrmbreaker 
			},
		},
		onactivate = {
			tracing = {
				44600, -- Halfus Wyrmbreaker
				44650, -- Storm Rider
				44645, -- Nether Scion
				44797, -- Time Warden
				44652, -- Slate Dragon
			},
			tracerstart = true,
			combatstop = true,
			defeat = 44600,
		},
		userdata = {
			phase = "1",
			scorchingbreathtime = {30,25,loop = false, type = "series"},
			--froartime = {2,2,30,loop = true, type = "series"},
			malevolenttext = "",
		},
		onstart = {
			{
				"set", {phase = "1"},
				"alert", "enragecd",
				"alert", "scorchingbreathcd",
				"alert", "shadownovacd",
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 360,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			fireballwarn = {
				varname = format(L.alert["%s Warning"], SN[83706]),
				type = "dropdown",
				text = format(L.alert["%s Casting"], SN[83706]),
				time = 6,
				flashtime = 6,
				color1 = "BLUE",
				icon = ST[83707],
				throttle = 7,
			},
			furiousroarcd = {
				varname = format(L.alert["%s Cooldown"], SN[86169]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[86169]),
				time = 30,
				flashtime = 10,
				color1 = "RED",
				icon = ST[86169],
				throttle = 7,
			},
			scorchingbreathcd = {
				varname = format(L.alert["%s Cooldown"], SN[83707]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[83707]),
				time = "<scorchingbreathtime>",
				flashtime = 15,
				color1 = "RED",
				icon = ST[83707],
				throttle = 7,
			},
			scorchingbreathdur = {
				varname = format(L.alert["%s Duration"], SN[83707]),
				type = "dropdown",
				text = format(L.alert["%s Duration"], SN[83707]),
				time = 6,
				flashtime  = 6,
				color1 = "ORANGE",
				icon = ST[83707],
				throttle = 6,			
			},
			shadownovacd = {
				varname = format(L.alert["%s Cooldown"], SN[86166]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"], SN[86166]),
				time = 7,
				flashtime = 7,
				color1 = "PURPLE",
				icon = ST[86166],
			},
			malevolentwarn = {
				varname = format(L.alert["%s Warning"],SN[86158]),
				type = "simple",
				text = "<malevolenttext>",
				time = 3,
				icon = ST[86158],
				sound = "ALERT7",
			},
			scorchingbreathwarn = {
				varname = format(L.alert["%s Warning"], SN[86153]),
				type = "simple",
				text = format(L.alert["%s Casting"], SN[86153]),
				time = 5,
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[86153],
				throttle = 5,
			},
		},
		events = {
			-- Fireball Barrage
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 83706,
				execute = {
					{
						"alert", "fireballwarn",
					},
				},
			},
			-- Scorching Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {83707, 83855, 86163, 86164, 86165},
				execute = {
					{
						"quash", "scorchingbreathcd",
						"alert", "scorchingbreathcd",
						"alert", "scorchingbreathdur",
					},
				},
			},
			-- Shadow Nova
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {86166, 83703},
				execute = {
					{
						"quash", "shadownovacd",
						"alert", "shadownovacd",
					},
				},
			},
			-- Furious Roar
			{
				type = "combatevent",
				eventtype = "SPELL_AURA APPLIED",
				spellid = {83710, 86169, 86171},
				execute = {
					{
						"set", {phase = "2"},
						"quash", "furiousroarcd",
						"alert", "furiousroarcd",
					},
				},
			},
			-- Malevolent Strikes 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {83908, 86157, 86159, 86158},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{malevolenttext = format("%s: %s! %s!",SN[86158],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","malevolentwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{malevolenttext = format("%s: #5#! %s!",SN[86158],format(L.alert["%s Stacks"],"#11#")) },
						"alert","malevolentwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- CHO'GALL 
---------------------------------

do
	local data = {
		version = 2, 
		key = "chogall",
		zone = L.zone["The Bastion of Twilight"],
		category = L.zone["Bastion"],
		name = L.npc_bastion["Cho'gall"],
		triggers = {
			scan = {
				43324, -- Cho'gall 
			},
		},
		onactivate = {
			tracing = {43324},
			tracerstart = true,
			combatstop = true,
			defeat = 43324,
		},
		onstart = {
			{
				"alert","furycd",
				"alert","conversioncd",
				"set",{conversiontime = 24},
				"alert","adherentcd",
			},
		},
		userdata = {
			conversiontime = 11,
			adherenttime = {57,92,loop = false, type = "series"},
			furytime = {50,47,loop = false, type = "series"},
			creationstime = {30,40,loop = false, type = "series"},
		},
		alerts = {
			-- Phase 1
			conversioncd = {
				varname = format(L.alert["%s Cooldown"],SN[91303]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[91303]),
				time = "<conversiontime>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[91303],
			},
			conversionwarn = {
				varname = format(L.alert["%s Warning"],SN[91303]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[91303]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				sound = "ALERT1",
				icon = ST[91303],
			},
			adherentcd = {
				varname = format(L.alert["%s Cooldown"],SN[81628]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[81628]),
				time = "<adherenttime>",
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[81628],
			},
			adherentwarn = {
				varname = format(L.alert["%s Warning"],SN[81628]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[81628]),
				time = 3,
				flashtime = 3,
				color1 = "BLUE",
				sound = "ALERT2",
				icon = ST[81628],
			},
			furycd = {
				varname = format(L.alert["%s Cooldown"],SN[82524]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[82524]),
				time = "<furytime>",
				flashtime = 5,
				color1 = "CYAN",
				icon = ST[82524],
			},
			furywarn = {
				varname = format(L.alert["%s Warning"],SN[82524]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[82524]),
				time = 3,
				flashtime = 3,
				color1 = "CYAN",
				sound = "ALERT3",
				icon = ST[82524],
			},
			festerbloodcd = {
				varname = format(L.alert["%s Cooldown"],SN[82299]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[82299]),
				time = 38,
				flashtime = 5,
				color1 = "MAGENTA",
				icon = ST[82299],
			},
			festerbloodwarn = {
				varname = format(L.alert["%s Warning"],SN[82299]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[82299]),
				color1 = "MAGENTA",
				sound = "ALERT4",
				time = 3,
				flashtime = 3,
				icon = ST[82299],
			},
			blazewarnself = {
				varname = format(L.alert["%s on self"],SN[81538]),
				type = "simple",
				text = format("%s: %s! %s!",SN[81538],L.alert["YOU"],L.alert["MOVE AWAY"]), 
				time = 3,
				flashtime = 3,
				throttle = 3,
				flashscreen = true,
				color1 = "ORANGE",
				sound = "ALERT12",
				icon = ST[81538],
			},
			-- Crash
			crashwarnself = {
				varname = format(L.alert["%s on self"],SN[93180]),
				type = "simple",
				text = format("%s: %s! %s!",SN[93180],L.alert["YOU"],L.alert["MOVE AWAY"]), 
				time = 3,
				flashtime = 3,
				throttle = 3,
				flashscreen = true,
				color1 = "PURPLE",
				sound = "ALERT10",
				icon = ST[93180],
			},
			crashwarn = {
				varname = format(L.alert["%s Warning"],SN[93180]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[93180]),
				time = 3,
				color1 = "CYAN",
				sound = "ALERT5",
				icon = ST[93180],
			},
			
			-- Phase 2
			onetotwocd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Two"]),
				type = "centerpopup",
				text = format(L.alert["%s Begins"],L.alert["Phase Two"]),
				time = 5,
				flashtime = 5,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
			creationscd = {
				varname = format(L.alert["%s Cooldown"],SN[82414]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[82414]),
				time = "<creationstime>",
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[82414],
			},
			creationswarn = {
				varname = format(L.alert["%s Warning"],SN[82414]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[82414]),
				time = 3,
				flashtime = 3,
				color1 = "PURPLE",
				sound = "ALERT5",
				icon = ST[82414],
			},
		},
		raidicons = {
			worshipmark = {
				varname = SN[91317],
				type = "MULTIFRIENDLY",
				persist = 5,
				reset = 5,
				unit = "#5#",
				icon = 1,
				total = 2,
			},
			creationsmark = {
				varname = SN[82414],
				type = "MULTIENEMY",
				persist = 30,
				reset = 30,
				unit = "#1#",
				icon = 1,
				total = 4,
				remove = false,
			},
		},
		announces = {
			crashsay = {
				varname = format(L.alert["%s Warning"], SN[93180]),
				type = "SAY",
				msg = format(L.alert["Crash inc !"]),
			},
			crashselfsay = {
				varname = format(L.alert["%s on meh!"], SN[93180]),
				type = "SAY",
				msg = format(L.alert["Crash on ME !"]),
			},
		},
		events = {
			-- Summon Corrupting Adherent
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 81628,
				execute = {
					{
						"quash","adherentcd",
						"alert","adherentcd",
						"alert","adherentwarn",
						"alert","festerbloodcd",
						"set",{conversiontime = 37},
					},
				},
			},
			-- Fury of Cho'gall
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 82524,
				execute = {
					{
						"alert","furycd",    
						"alert","furywarn",
					},
				},
			},
			-- Festerblood
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 82299,
				execute = {
					{
						"quash","festerbloodcd",
						"alert","festerbloodwarn",
					},
				},
			},
			-- Conversion
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 91303,
				execute = {
					{
						"alert","conversioncd",
						"alert","conversionwarn",
					},
				},
			},
			-- Worshipping
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = {91317, 93365, 93366, 93367},
				execute = {
					{
						"raidicon","worshipmark",
					},
				},
			},
			-- Blaze on self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = {81538, 93212, 93213, 93214},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","blazewarnself",
					},
				},
			},
			-- Crash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 93180,
				execute = {
					{
						"expect",{"&tft_unitexists& &tft_isplayer&","==","true true"},
						"alert","crashwarnself",
						"announce","crashselfsay",
					},
					{
						"expect",{"&tft_unitexists& &tft_isplayer&","==","true false"},
						"alert","crashwarn",
						"announce","crashsay",
					},
				},
			},
			-- Consume Blood of the Old God
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 82630,
				execute = {
					{
						"quashall",true,
						"alert","onetotwocd",
						"alert","creationscd",
					},
				},
			},
			-- Darkened Creations
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = {82414, 93160, 93162},
				execute = {
					{
						"alert","creationscd",
						"alert","creationswarn",
					},
				},
			},
			-- Darkened Creations marks
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 82411,
				execute = {
					{
						"raidicon","creationsmark",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

