do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = "$Rev$",
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
			acidmawdead = 0,
			dreadscaledead = 0,
			jormunactivated = 0,
		},
		onstart = {
			{
				{alert = "enragecd"},
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown", 
				text = L["Enrage"],
				time = 900, 
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
				type = "dropdown",
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
				type = "dropdown",
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
			-- Icehowl
			breathwarn = {
				varname = format(L["%s Cast"],SN[66689]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[66689]),
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
				color1 = "RED",
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
				text = format(L["%s Cooldown"],SN[66683]),
				time = 56,
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
		},
		arrows = {
			tramplearrow = {
				varname = SN[66734],
				unit = "#5#",
				persist = 4,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = SN[66734],
				fixed = true,
			},
		},
		raidicons = {
			tramplemark = {
				varname = SN[66734],
				type = "FRIENDLY",
				persist = 4,
				unit = "#5#",
				icon = 7,
			},
		},
		events = { 
			-- Fire Bomb on self - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {67472,66320},
				execute = {
					{
						{alert = "firebombwarnself"},
					}
				},
			},
			-- Impale - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {67477,66331},
				execute = {
					{
						{alert = "impalecd"},
					},
				},
			},
			-- Staggering Stomp - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {67647,66330},
				execute = {
					{
						{alert = "stompwarn"},
						{alert = "stompcd"},
					},
				},
			},
			-- Paralytic Toxin - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {67618,66823},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "toxinonself"},
					},
				},
			},
			-- Paralytic Toxin Removal - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {67618,66823},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "toxinonself"},
					},
				},
			},
			-- Burning Bile - Jormungars - Dreadmaw 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66869,
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "bileonself"},
					},
				},
			},
			-- Burning Bile Removal - Jormungars - Dreadmaw 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 66869,
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "bileonself"},
					},
				},
			},
			-- Slime Pool - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {66881,67638},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "slimepoolself"},
					},
				},
			},
			-- Arctic Breath - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {67650,66689},
				execute = {
					{
						{alert = "breathwarn"},
					},
				},
			},
			-- Frothing Rage - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 67657,
				execute = {
					{
						{alert = "ragewarn"},
					},
				},
			},
			-- Frothing Removal - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 67657,
				execute = {
					{
						{quash = "ragewarn"},
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
						{alert = "dazedur"},
					},
				},
			},
			-- Massive Crash - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {67660,66683},
				execute = {
					{
						{alert = "crashcast"},
						{alert = "crashcd"},
					},
				},
			},
			-- Trample - Icehowl
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						{expect = {"#1#","find",L["lets out a bellowing roar!$"]}},
						{expect = {"#5#","~=","&playername&"}},
						{proximitycheck = {"#5#",18}},
						{alert = "tramplewarnothers"},
						{arrow = "tramplearrow"},
					},
					{
						{expect = {"#1#","find",L["lets out a bellowing roar!$"]}},
						{expect = {"#5#","==","&playername&"}},
						{alert = "tramplewarnself"},
					},
					{
						{expect = {"#1#","find",L["lets out a bellowing roar!$"]}},
						{raidicon = "tramplemark"},
					},
				},
			},
			-- Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						{expect = {"&npcid|#4#&","==","34796"}}, -- Gormok
						{tracing = {35144,34799}},
						{quash = "impalecd"},
						{quash = "stompcd"},
						{resettimer = true},
					},
					{
						{expect = {"&npcid|#4#&","==","35144"}}, -- Acidmaw
						{set = {acidmawdead = 1}}
					},
					{
						{expect = {"&npcid|#4#&","==","34799"}}, -- Dreadscale
						{set = {dreadscaledead = 1}}
					},
					{
						{expect = {"<acidmawdead> <dreadscaledead> <jormunactivated>","==","1 1 0"}},
						{set = {jormunactivated = 1}},
						{tracing = {34797}}, -- Icehowl
						{resettimer = true},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
