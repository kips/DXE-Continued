do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 320,
		key = "northrendbeasts", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Northrend Beasts"], 
		triggers = {
			scan = {
				34796, -- Gormok
				35144, -- Acidmaw
				34799, -- Dreadscale
				34797, -- Icehowl
			}, 
			yell = L["^Hailing from the deepest, darkest caverns of the Storm Peaks"]
		},
		onactivate = {
			tracing = {34796}, -- Gormok
			combatstop = true,
		},
		userdata = {
			enragetime = 900,
			acidmawdead = 0,
			dreadscaledead = 0,
			jormunactivated = 0,
			moltenspewtime = {10,21,loop = false},
			acidicspewtime = {27,21,loop = true},
			firemoltencd = 1,
			fireacidiccd = 1,
			impaletext = "",
			lasttoxin = "NONE",
			lastbile = "NONE",
			hastoxin = 0,
			hasbile = 0,
			tmp = "",
			crashtext = {format(L["Next %s"],SN[66683]),format(L["%s Cooldown"],SN[66683]),loop = false},
			crashtime = {36,55,loop = false},
		},
		onstart = {
			{
				"expect",{"&difficulty&","==","3"},
				"set",{enragetime = 486}, -- 10m hard, need more data to verify this
			},
			{
				"alert","enragecd",
				"alert","zerotoone",
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown", 
				text = L["Enrage"],
				time = "<enragetime>",
				flashtime = 10, 
				color1 = "RED", 
				icon = ST[12317],
			},
			-- Gormok
			firebombwarnself = {
				varname = format(L["%s on self"],SN[66313]),
				type = "simple",
				text = format("%s: %s! %s!",SN[66313],L["YOU"],L["MOVE"]),
				time = 2,
				throttle = 3,
				color1 = "ORANGE",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[66313],
			},
			impalecd = {
				varname = format(L["%s Cooldown"],SN[66331]),
				type = "dropdown",
				text = format(L["Next %s"],SN[66331]),
				time = 10,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[66331],
				counter = true,
			},
			impalewarn = {
				varname = format(L["%s Warning"],SN[66331]).." "..format(L["%s Stacks"],">= 3"),
				type = "simple",
				text = "<impaletext>",
				time = 3,
				icon = ST[66331],
				sound = "ALERT1",
			},
			stompwarn = {
				varname = format(L["%s Cast"],SN[66330]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[48131]),
				time = 0.5,
				color1 = "BROWN",
				sound = "ALERT5",
				icon = ST[66330],
			},
			stompcd = {
				varname = format(L["%s Cooldown"],SN[66330]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[48131]),
				time = 20.8,
				flashtime = 5,
				color1 = "TAN",
				color2 = "TAN",
				sound = "ALERT7",
				icon = ST[66330],
			},
			-- Jormungars
			bileonself = {
				varname = format(L["%s on self"],SN[66870]),
				type = "centerpopup",
				text = format("%s: %s",SN[66870],L["YOU"]).."!",
				time = 24,
				flashtime = 24,
				sound = "ALERT3",
				color1 = "CYAN",
				color2 = "ORANGE",
				flashscreen = true,
				icon = ST[66870],
			},
			toxinonself = {
				varname = format(L["%s on self"],SN[66823]),
				type = "centerpopup",
				text = format("%s: %s",SN[66823],L["YOU"]).."!",
				time = 60,
				flashtime = 60,
				sound = "ALERT2",
				color1 = "GREEN",
				color2 = "PINK",
				flashscreen = true,
				icon = ST[66823],
			},
			slimepoolself = {
				varname = format(L["%s on self"],SN[67638]),
				type = "simple",
				text = format("%s: %s!",SN[67638],L["YOU"]),
				time = 3,
				sound = "ALERT1",
				color1 = "TURQUOISE",
				icon = ST[67638],
				throttle = 3,
				flashscreen = true,
			},
			enragewarn = {
				varname = format(L["%s Warning"],SN[5229]),
				type = "simple",
				text = format("%s: #5#!",SN[5229]),
				time = 3,
				sound = "ALERT5",
				icon = ST[68335],
			},
			moltenspewcd = {
				varname = format(L["%s Cooldown"],SN[66821]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[66821]),
				time = "<moltenspewtime>",
				color1 = "MAGENTA",
				flashtime = 5,
				icon = ST[66821],
			},
			moltenspewwarn = {
				varname = format(L["%s Cast"],SN[66821]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[66821]),
				time = 3.5,
				flashtime = 3.5,
				color1 = "MAGENTA",
				color2 = "GREY",
				sound = "ALERT7",
				icon = ST[66821],
			},
			acidicspewcd = {
				varname = format(L["%s Cooldown"],SN[66818]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[66818]),
				time = "<acidicspewtime>",
				flashtime = 5,
				color1 = "TEAL",
				icon = ST[66818],
			},
			acidicspewwarn = {
				varname = format(L["%s Cast"],SN[66818]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[66818]),
				time = 3.5,
				flashtime = 3.5,
				color1 = "TEAL",
				color2 = "GREY",
				sound = "ALERT7",
				icon = ST[66818],
			},
			-- Icehowl
			breathwarn = {
				varname = format(L["%s Cast"],SN[66689]),
				type = "centerpopup",
				text = SN[66689].."!",
				time = 5,
				color1 = "BLUE",
				sound = "ALERT6",
				throttle = 6,
				icon = ST[66689],
			},
			ragewarn = {
				varname = format(L["%s Warning"],SN[67657]),
				type = "centerpopup",
				text = format("%s! %s!",SN[67657],L["DISPEL"]),
				time = 15,
				throttle = 15,
				color1 = "DCYAN",
				sound = "ALERT4",
				icon = ST[67657],
			},
			dazedur = {
				varname = format(L["%s Duration"],SN[66758]),
				type = "centerpopup",
				text = SN[66758].."!",
				time = 15,
				color1 = "GREY",
				icon = ST[66758],
			},
			crashcast = {
				varname = format(L["%s Cast"],SN[66683]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[66683]),
				time = 1,
				color1 = "INDIGO",
				sound = "ALERT8",
				icon = ST[66683],
			},
			crashcd = {
				varname = format(L["%s Cooldown"],SN[66683]),
				type = "dropdown",
				text = "<crashtext>",
				time = "<crashtime>",
				flashtime = 10,
				color1 = "YELLOW",
				icon = ST[66683],
			},
			tramplewarnself = {
				type = "centerpopup",
				varname = format(L["%s on self"],SN[66734]),
				text = format("%s: %s! %s",SN[66734],L["YOU"],L["MOVE"]),
				time = 3,
				flashtime = 3,
				color1 = "ORANGE",
				color2 = "GREEN",
				sound = "ALERT9",
				icon = ST[66734],
				flashscreen = true,
			},
			tramplewarnothers = {
				type = "centerpopup",
				varname = format(L["%s on others"],SN[66734]),
				time = 3,
				text = format("%s: #5#! %s!",SN[66734],L["MOVE AWAY"]),
				color1 = "ORANGE",
				sound = "ALERT9",
				icon = ST[66734],
				flashscreen = true,
			},
			--- Phase Changes
			zerotoone = {
				varname = format(L["%s Timer"],L["Phase One"]),
				type = "centerpopup",
				text = format(L["%s Begins"],L["Phase One"]),
				time = 22,
				flashtime = 22,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
			onetotwo = {
				varname = format(L["%s Timer"],L["Phase Two"]),
				type = "centerpopup",
				text = format(L["%s Begins"],L["Phase Two"]),
				time = 15,
				flashtime = 15,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
			twotothree = {
				varname = format(L["%s Timer"],L["Phase Three"]),
				type = "centerpopup",
				text = format(L["%s Begins"],L["Phase Three"]),
				time = 10,
				flashtime = 10,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
		},
		arrows = {
			tramplearrow = {
				varname = SN[66734],
				unit = "#5#",
				persist = 8,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = SN[66734],
				fixed = true,
			},
			toxinarrow = {
				varname = SN[66823],
				unit = "<lasttoxin>",
				persist = 10,
				action = "TOWARD",
				msg = L["MOVE TOWARD"],
				spell = L["Toxin"],
				sound = "ALERT3",
			},
			bilearrow = {
				varname = SN[66870],
				unit = "<lastbile>",
				persist = 10,
				action = "TOWARD",
				msg = L["MOVE TOWARD"],
				spell = L["Bile"],
				sound = "ALERT5",
			},
		},
		raidicons = {
			tramplemark = {
				varname = SN[66734],
				type = "FRIENDLY",
				persist = 8,
				unit = "#5#",
				icon = 7,
			},
		},
		timers = {
			reset = {
				{"resettimer",true},
			},
			firemolten = {
				{
					"alert","moltenspewcd",
					"set",{moltenspewtime = {27,21,loop = true}},
				},
			},
			firecrash = {
				{
					"alert","crashcd",
				},
			},
		},
		events = { 
			---------------
			-- Gormok
			---------------

			-- Fire Bomb on self - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					67472,
					66320,
					67473, -- 10m hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","firebombwarnself",
					}
				},
			},
			-- Impale - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					67477,
					66331,
					67478, -- 10 hard
					67479, -- 25 hard
				},
				execute = {
					{
						"alert","impalecd",
					},
				},
			},
			-- Impale Stacks - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					67477,
					66331,
					67478, -- 10 hard
					67479, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"expect",{"#11#",">=","3"},
						"set",{impaletext = format("%s: %s! %s!",SN[66331],L["YOU"],format(L["%s Stacks"],"#11#"))},
						"alert","impalewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"expect",{"#11#",">=","3"},
						"set",{impaletext = format("%s: #5#! %s!",SN[66331],format(L["%s Stacks"],"#11#")) },
						"alert","impalewarn",
					},
				},
			},
			-- Staggering Stomp - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67647,
					66330,
					67648, -- 10m hard
					67649, -- 10m hard
				},
				execute = {
					{
						"alert","stompwarn",
						"alert","stompcd",
					},
				},
			},

			---------------
			-- Jormungars
			---------------

			-- Paralytic Toxin - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67618,
					66823,
					67619, -- 10m hard
					67620,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","toxinonself",
						"set",{hastoxin = 1},
						"expect",{"<lastbile>","~=","NONE"},
						"arrow","bilearrow",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{lasttoxin = "#5#"},
						"expect",{"<hasbile>","==","1"},
						-- Fires toxinarrow using #5#
						"set",{tmp = "<lasttoxin>"},
						"set",{lasttoxin = "#5#"},
						"arrow","toxinarrow",
						"set",{lasttoxin = "<tmp>"},
					},
				},
			},
			-- Paralytic Toxin Removal - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67618,
					66823,
					67619, -- 10m hard
					67620,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","toxinonself",
						"set",{hastoxin = 0},
						"removeallarrows",true,
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"removearrow","#5#",
						"expect",{"#5#","==","<lasttoxin>"},
						"set",{lasttoxin = "NONE"},
					},
				},
			},
			-- Burning Bile - Jormungars - Dreadmaw 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {66869,66870},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","bileonself",
						"set",{hasbile = 1},
						"expect",{"<lasttoxin>","~=","NONE"},
						"arrow","toxinarrow",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{lastbile = "#5#"},
						"expect",{"<hastoxin>","==","1"},
						-- Fires bilearrow using #5#
						"set",{tmp = "<lastbile>"},
						"set",{lastbile = "#5#"},
						"arrow","bilearrow",
						"set",{lastbile = "<tmp>"},
					},
				},
			},
			-- Burning Bile Removal - Jormungars - Dreadmaw 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {66869,66870},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","bileonself",
						"removeallarrows",true,
						"set",{hasbile = 0},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"removearrow","#5#",
						"expect",{"#5#","==","<lastbile>"},
						"set",{lastbile = "NONE"},
					},
				},
			},
			-- Slime Pool - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					66881,
					67638,
					67639, -- 10 hard
					67640,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","slimepoolself",
					},
				},
			},
			-- Enrage - Jormungars
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 68335,
				execute = {
					{
						"alert","enragewarn",
					},
				},
			},
			-- Acidic Spew - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 66818,
				execute = {
					{
						"quash","acidicspewcd",
						"alert","acidicspewwarn",
					},
					{
						"expect",{"<fireacidiccd> <dreadscaledead>","==","0 0"},
						"alert","moltenspewcd",
						"set",{firemoltencd = 1},
					},
					{
						"expect",{"<fireacidiccd> <dreadscaledead>","==","1 0"},
						"alert","acidicspewcd",
						"set",{fireacidiccd = 0},
					},
					{
						"expect",{"<dreadscaledead>","==","1"},
						"set",{acidicspewtime = 21},
						"alert","acidicspewcd",
					},
				},
			},
			-- Molten Spew - Dreadscale
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 66821,
				execute = {
					{
						"quash","moltenspewcd",
						"alert","moltenspewwarn",
					},
					{
						"expect",{"<firemoltencd> <acidmawdead>","==","0 0"},
						"alert","acidicspewcd",
						"set",{fireacidiccd = 1},
					},
					{
						"expect",{"<firemoltencd> <acidmawdead>","==","1 0"},
						"alert","moltenspewcd",
						"set",{firemoltencd = 0},
					},
					{
						"expect",{"<acidmawdead>","==","1"},
						"set",{moltenspewtime = 21},
						"alert","moltenspewcd",
					},
				},
			},

			---------------
			-- Icehowl
			---------------

			-- Arctic Breath - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67650,
					66689,
					67651, -- 10m hard
				},
				execute = {
					{
						"alert","breathwarn",
					},
				},
			},
			-- Frothing Rage - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67657,
					67658, -- 10m hard
					66759,
				},
				execute = {
					{
						"alert","ragewarn",
					},
				},
			},
			-- Frothing Removal - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67657,
					67658,
					66759,
				},
				execute = {
					{
						"quash","ragewarn",
					},
				},
			},
			-- Staggered Daze - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66758,
				execute = {
					{
						"alert","dazedur",
					},
				},
			},
			-- Massive Crash - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67660,
					66683,
					67661, -- 10m hard
					67662,
				},
				execute = {
					{
						"alert","crashcast",
						"alert","crashcd",
					},
				},
			},
			-- Trample - Icehowl
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L["lets out a bellowing roar!$"]},
						"expect",{"#5#","~=","&playername&"},
						"proximitycheck",{"#5#",18},
						"alert","tramplewarnothers",
						"arrow","tramplearrow",
					},
					{
						"expect",{"#1#","find",L["lets out a bellowing roar!$"]},
						"expect",{"#5#","==","&playername&"},
						"alert","tramplewarnself",
					},
					{
						"expect",{"#1#","find",L["lets out a bellowing roar!$"]},
						"raidicon","tramplemark",
					},
				},
			},
			-- Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","34796"}, -- Gormok
						"tracing",{35144,34799},
						"quash","impalecd",
						"quash","stompcd",
						"alert","onetotwo",
						"scheduletimer",{"reset",15},
						"scheduletimer",{"firemolten",15},
					},
					{
						"expect",{"&npcid|#4#&","==","35144"}, -- Acidmaw
						"quash","moltenspewcd",
						"quash","acidicspewcd",
						"set",{acidmawdead = 1},
					},
					{
						"expect",{"&npcid|#4#&","==","34799"}, -- Dreadscale
						"quash","moltenspewcd",
						"quash","acidicspewcd",
						"set",{dreadscaledead = 1},
					},
					{
						"expect",{"<acidmawdead> <dreadscaledead> <jormunactivated>","==","1 1 0"},
						"set",{jormunactivated = 1},
						"tracing",{34797}, -- Icehowl
						"alert","twotothree",
						"scheduletimer",{"reset",10},
						"scheduletimer",{"firecrash",10},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
