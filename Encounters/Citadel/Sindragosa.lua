do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 27,
		key = "sindragosa", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Sindragosa"], 
		triggers = {
			scan = {36853}, -- Sindragosa
			yell = L.chat_citadel["^You are fools to have come to this place"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36853}, -- Sindragosa
			defeat = 36853, -- Sindragosa
		},
		userdata = {
			chilledtext = "",
			airtime = {63.5,110,loop = false, type = "series"},
			phase = "1",
			instabilitytext = "",
			unchainedtime = 30,
			frostbeacontext = "",
			icygriptime = {33.8,67.2, loop = false, type = "series"},
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","aircd",
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 600,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			icetombwarn = {
				varname = format(L.alert["%s Casting"],SN[69712]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[69712]),
				time = 1,
				flashtime = 1,
				color1 = "INDIGO",
				sound = "ALERT1",
				icon = ST[69712],
			},
			frostbeacondur = {
				varname = format(L.alert["%s Duration"],SN[70126]),
				type = "centerpopup",
				text = "<frostbeacontext>",
				time = 7,
				flashtime = 7,
				color1 = "GOLD",
				throttle = 2,
				icon = ST[70126],
			},
			frostbeaconself = {
				varname = format(L.alert["%s on self"],SN[70126]),
				type = "simple",
				text = format("%s: %s!",SN[70126],L.alert["YOU"]).."!",
				time = 3,
				icon = ST[70126],
				sound = "ALERT7",
				flashscreen = true,
			},
			icygripcd = {
				varname = format(L.alert["%s Cooldown"],SN[70117]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[70117]),
				time = "<icygriptime>",
				flashtime = 10,
				color1 = "GREY",
				icon = ST[70117],
			},
			blisteringcoldwarn = {
				varname = format(L.alert["%s Casting"],SN[71047]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71047]),
				time = 5,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT2",
				icon = ST[71047],
			},
			unchainedself = {
				varname = format(L.alert["%s on self"],SN[69762]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[69762],L.alert["YOU"],L.alert["CAREFUL"]),
				time = 30,
				flashtime = 30,
				color1 = "TURQUOISE",
				flashscreen = true,
				sound = "ALERT3",
				icon = ST[69762],
			},
			unchainedcd = {
				varname = format(L.alert["%s Cooldown"],SN[69762]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[69762]),
				time = "<unchainedtime>",
				flashtime = 10,
				color1 = "WHITE",
				sound = "ALERT5",
				icon = ST[69762],
			},
			instabilityself = {
				varname = format(L.alert["%s on self"],SN[69766]),
				type = "centerpopup",
				text = "<instabilitytext>",
				time = 8,
				flashtime = 8,
				color1 = "VIOLET",
				icon = ST[69766],
			},
			chilledself = {
				varname = format(L.alert["%s on self"],SN[70106]),
				type = "centerpopup",
				text = "<chilledtext>",
				time = 8,
				flashtime = 8,
				color1 = "CYAN",
				icon = ST[70106],
			},
			aircd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Air Phase"]),
				type = "dropdown",
				text = format("Next %s",L.alert["Air Phase"]),
				time = "<airtime>",
				flashtime = 10,
				color1 = "YELLOW",
				icon = "Interface\\Icons\\INV_Misc_Toy_09",
			},
			airdur = {
				varname = format(L.alert["%s Duration"],L.alert["Air Phase"]),
				type = "dropdown",
				text = L.alert["Air Phase"],
				time = 47,
				flashtime = 10,
				color1 = "MAGENTA",
				icon = "Interface\\Icons\\INV_Misc_Toy_09",
			},
			--[[
			frostbombwarn = {
				varname = format(L.alert["%s ETA"],SN[71053]),
				type = "centerpopup",
				text = format(L.alert["%s Hits"],SN[71053]),
				time = 5.85, -- average: ranges from 5.3 to 6.5
				flashtime = 5.85,
				color1 = "BLUE",
				sound = "ALERT5",
				icon = ST[71053],
			},
			]]
			frostbreathwarn = {
				varname = format(L.alert["%s Casting"],SN[71056]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71056]),
				time = 1.5,
				flashtime = 1.5,
				color1 = "BROWN",
				sound = "ALERT4",
				icon = ST[71056],
			},
			mysticbuffetcd = {
				varname = format(L.alert["%s Timer"],SN[72528]),
				type = "centerpopup",
				text = format(L.alert["Next %s"],SN[72528]),
				time = 6,
				color1 = "PINK",
				icon = ST[72528],
				throttle = 4,
			},
		},
		windows = {
			proxwindow = true,
		},
		raidicons = {
			frostbeaconmark = {
				varname = SN[70126],
				type = "MULTIFRIENDLY",
				persist = 7,
				reset = 2,
				unit = "#5#",
				icon = 1,
				total = 6,
			},
		},
		arrows = {
			westarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["West"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["West"],
				fixed = true,
				xpos = 0.35448017716408,
				ypos = 0.23266260325909,
			},
			northarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["North"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["North"],
				fixed = true,
				xpos = 0.3654870390892,
				ypos = 0.2162726521492,
			},
			eastarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["East"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["East"],
				fixed = true,
				xpos = 0.37621337175369,
				ypos = 0.23285666108131,
			},
			southarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["South"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["South"],
				fixed = true,
				xpos = 0.36525920033455,
				ypos = 0.250081539154054,
			},
			southsoutharrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["South"].." "..L.alert["South"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["South"].." "..L.alert["South"],
				fixed = true,
				xpos = 0.36546084284782,
				ypos = 0.27346137166023,
			},
			easteastarrow = {
				varname = format(L.alert["%s Beacon Position"],L.alert["East"].." "..L.alert["East"]),
				unit = "player",
				persist = 7,
				action = "TOWARD",
				msg = L.alert["MOVE THERE"],
				spell = L.alert["East"].." "..L.alert["East"],
				fixed = true,
				xpos = 0.39097648859024,
				ypos = 0.23303273320198,
			},
		},
		timers = {
			checkbeacon = {
				{
					-- This is dependent on multi raid icons being set and consistent across all users
					-- Icon positioning is the following:
					--     1
					--
					-- 3       4    6
					--
					--     2
					--
					--     5
					"expect",{"&playerdebuff|"..SN[70126].."&","==","true"},
					"invoke",{
						{
							"expect",{"&hasicon|player|1&","==","true"}, -- Skull
							"arrow","northarrow",
						},
						{
							"expect",{"&hasicon|player|2&","==","true"}, -- Cross
							"arrow","southarrow",
						},
						{
							"expect",{"&hasicon|player|3&","==","true"}, -- Square
							"arrow","westarrow",
						},
						{
							"expect",{"&hasicon|player|4&","==","true"}, -- Moon
							"arrow","eastarrow",
						},
						{
							"expect",{"&hasicon|player|5&","==","true"}, -- Triangle
							"arrow","southsoutharrow",
						},
						{
							"expect",{"&hasicon|player|6&","==","true"}, -- Diamond
							"arrow","easteastarrow",
						},
					},
				},
			},
		},
		events = {
			-- Mystic Buffet
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72529,
					70127,
					72528, -- 25
					72530, -- 25h
				},
				execute = {
					{
						"expect",{"&timeleft|mysticbuffetcd&","<","3"},
						"quash","mysticbuffetcd",
					},
					{
						"alert","mysticbuffetcd",
					},
				},
			},
			-- Mystic Buffet
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					72529,
					70127,
					72528, -- 25
					72530, -- 25h
				},
				execute = {
					{
						"expect",{"&timeleft|mysticbuffetcd&","<","3"},
						"quash","mysticbuffetcd",
					},
					{
						"alert","mysticbuffetcd",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Air phase
					{
						"expect",{"#1#","find",L.chat_citadel["^Your incursion ends here"]},
						"quash","aircd",
						"quash","unchainedcd",
						"set",{unchainedtime = 55},
						"alert","unchainedcd",
						"set",{unchainedtime = 30},
						"alert","aircd",
						"alert","airdur",
					},
					-- Last Phase
					{
						"expect",{"#1#","find",L.chat_citadel["^Now, feel my master's limitless power"]},
						"set",{phase = "2", unchainedtime = 80},
						"quash","aircd",
						"alert","icygripcd",
						"tracing",{36853,36980}, -- Sindragosa, Ice Tomb
					},
				},
			},
			-- Ice Tomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					69712, -- 10,25,25h
				},
				execute = {
					{
						"alert","icetombwarn",
					},
				},
			},
			-- Frost Beacon
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70126, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"<phase>","==","1"},
						"set",{frostbeacontext = format(L.alert["%s Duration"],SN[70126])},
					},
					{
						"expect",{"<phase>","==","2"},
						"set",{frostbeacontext = format("%s: #5#!",SN[70126])},
					},
					{
						"raidicon","frostbeaconmark",
						"alert","frostbeacondur",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","frostbeaconself",
						"expect",{"<phase>","==","1"},
						"invoke",{
							{
								"expect",{"&difficulty&","==","4"}, -- 25h
								"scheduletimer",{"checkbeacon",0.2}, -- allow time for raid icon to set
							},
							{
								"expect",{"&difficulty&","==","2"}, -- 25
								"scheduletimer",{"checkbeacon",0.2}, -- allow time for raid icon to set
							},
						},
					},
				},
			},
			-- Frost Beacon removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					70126, -- 10,25,25h
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Icy Grip
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					70117, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"<phase>","==","2"},
						"alert","icygripcd",
					},
				},
			},
			-- Blistering Cold
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					70123, -- 10
					71048, -- 10h
					71047, -- 25
					71049, -- 25h
				},
				execute = {
					{
						"alert","blisteringcoldwarn",
					},
				},
			},
			-- Unchained Magic
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					69762, -- 10,25,25h
				},
				execute = {
					{
						"alert","unchainedcd",
					},
				},
			},
			-- Unchained Magic application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69762, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","unchainedself",
					},
				},
			},
			-- Instability
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69766, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{instabilitytext = format("%s: %s!",SN[69766],L.alert["YOU"])},
						"alert","instabilityself",
					},
				},
			},
			-- Instability applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					69766, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","instabilityself",
						"set",{instabilitytext = format("%s: %s! %s!",SN[69766],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","instabilityself",
					},
				},
			},
			-- Instability removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					69766, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","instabilityself",
					},
				},
			},
			-- Chilled to the Bone
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70106, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{chilledtext = format("%s: %s!",SN[70106],L.alert["YOU"])},
						"alert","chilledself",
					},
				},
			},
			-- Chilled to the Bone applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					70106, -- 10,25,25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","chilledself",
						"set",{chilledtext = format("%s: %s! %s!",SN[70106],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","chilledself",
					},
				},
			},
			--[[
			-- Frost Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {
					69845, -- 10
					71053, -- 25
				},
				execute = {
					{
						"alert","frostbombwarn",
					},
				},
			},
			]]
			-- Frost Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					69649, -- 10
					71056, -- 25
					71057, -- 10h
					71058, -- 25h
				},
				execute = {
					{
						"alert","frostbreathwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
