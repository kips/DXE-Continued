local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ASCENDANT COUNCIL 
---------------------------------

do
	local data = {
		version = 1,
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
--				43735, -- Elementium Monstrosity, disabled for now can't trace 5 mobs
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				43735, -- Elementium Monstrosity
			},
		},
		--[[userdata = {},
		onstart = {
			{
			}
		},
		windows = {
		},
		alerts = {
		},
		timers = {
		},
		events = {
		}, ]]
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- VALIONA & THERALION 
---------------------------------

do
	local data = {
		version = 4,
		key = "valther",
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
				varname = format(L.alert["%s on self"],SN[95639]),
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
			blackoutself = {
				varname = format(L.alert["%s on self"],SN[92876]),
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
				reset = 2, -- Looks like 2 on 25 man, TODO: Check for 10 man count 
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
					}
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
					}
				},
			},
			-- Engulfing Magic
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 95639,
				execute = {
					{
						"raidicon","engulfmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","engulfself",
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
				spellname = 92876,
				execute = {
					{
						"raidicon","blackoutmark",
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
				spellname = 92876,
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
		version = 2, 
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
			tracing = {44600},
			tracerstart = true,
			combatstop = true,
			defeat = 44600,
		},
		onstart = {
			{
				"alert","enragecd",
			}
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
			}
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
				text = SN[91303].."!",
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
				text = SN[81628].."!",
				time = 3,
				flashtime = 3,
				color1 = "BLUE",
				sound = "ALERT2",
				icon = ST[81628],
			},
			furycd = {
				varname = format(L.alert["%s Cooldown"],SN[82524]),
				type = "dropdown",
				text = SN[82524].."!",
				time = "<furytime>",
				flashtime = 5,
				color1 = "CYAN",
				icon = ST[82524],
			},
			furywarn = {
				varname = format(L.alert["%s Warning"],SN[82524]),
				type = "simple",
				text = SN[82524].."!",
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
				text = SN[82299].."!",
				color1 = "MAGENTA",
				sound = "ALERT4",
				time = 3,
				flashtime = 3,
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
				text = SN[82414].."!",
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
				}
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
				spellname = 91317,
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
				spellname = 81538,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","blazewarnself",
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
				spellname = 82414,
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

