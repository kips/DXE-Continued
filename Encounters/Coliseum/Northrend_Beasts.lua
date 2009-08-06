do
	local L,SN = DXE.L,DXE.SN
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
		},
		alerts = {
			firebombwarnself = {
				varname = format(L["%s on self"],SN[66313]),
				type = "simple",
				text = format("%s: %s! %s!",SN[66313],L["YOU"],L["MOVE"]),
				time = 2,
				throttle = 3,
				color1 = "ORANGE",
				sound = "ALERT3",
				flashscreen = true,
			},
			impalecd = {
				varname = format(L["%s Cooldown"],SN[66331]),
				type = "dropdown",
				text = format(L["Next %s"],SN[66331]),
				time = 10,
				flashtime = 5,
				color1 = "PURPLE",
			},
			stompwarn = {
				varname = format(L["%s Cast"],SN[66330]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[48131]),
				time = 0.5,
				color1 = "BROWN",
				sound = "ALERT5",
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
			},
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
			},
			breathwarn = {
				varname = format(L["%s Cast"],SN[66689]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[66689]),
				time = 5,
				color1 = "BLUE",
				sound = "ALERT6",
				throttle = 6,
			},
			ragewarn = {
				varname = format(L["%s Warning"],SN[67657]),
				type = "centerpopup",
				text = format("%s! %s!",SN[67657],L["DISPEL"]),
				time = 15,
				throttle = 15,
				color1 = "RED",
				sound = "ALERT4",
			},
			dazedur = {
				varname = format(L["%s Duration"],SN[66758]),
				type = "centerpopup",
				text = SN[66758].."!",
				time = 15,
				color1 = "GREY",
			},
			crashcast = {
				varname = format(L["%s Cast"],SN[66683]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[66683]),
				time = 1,
				color1 = "INDIGO",
				sound = "ALERT8",
			},
			crashcd = {
				varname = format(L["%s Cooldown"],SN[66683]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[66683]),
				time = 56,
				flashtime = 10,
				color1 = "YELLOW",
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
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
