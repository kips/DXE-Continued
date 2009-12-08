do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "sindragosa", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Sindragosa"], 
		triggers = {
			scan = {36853}, -- Sindragosa
			yell = L["^You are fools to have come to this place"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36853}, -- Sindragosa
			defeat = 36853, -- Sindragosa
		},
		userdata = {
			chilledtext = "",
			airtime = {63.5,110,loop = false},
		},
		onstart = {
			{
				"alert","aircd",
			},
		},
		alerts = {
			icetombwarn = {
				varname = format(L["%s Cast"],SN[69712]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[69712]),
				time = 1,
				flashtime = 1,
				color1 = "INDIGO",
				sound = "ALERT1",
				icon = ST[69712],
			},
			frostbeacondur = {
				varname = format(L["%s Duration"],SN[70126]),
				type = "centerpopup",
				text = format(L["%s Duration"],SN[70126]),
				time = 7,
				flashtime = 7,
				color1 = "GOLD",
				throttle = 2,
				icon = ST[70126],
			},
			frostbeaconself = {
				varname = format(L["%s on self"],SN[70126]),
				type = "simple",
				text = format("%s: %s!",SN[70126],L["YOU"]).."!",
				time = 3,
				icon = ST[70126],
				flashscreen = true,
			},
			--[[
			icygripcd = {
				varname = format(L["%s Cooldown"],SN[70117]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[70117]),
				--time = ,
				flashtime = 10,
				--color1 = ,
				icon = ST[70117],
			},
			]]
			blisteringcoldwarn = {
				varname = format(L["%s Cast"],SN[71047]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71047]),
				time = 5,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT2",
				icon = ST[71047],
			},
			unchainedself = {
				varname = format(L["%s on self"],SN[69762]),
				type = "centerpopup",
				text = format("%s: %s! %s!",SN[69762],L["YOU"],L["CAREFUL"]),
				time = 30,
				flashtime = 30,
				color1 = "PURPLE",
				flashscreen = true,
				sound = "ALERT3",
				icon = ST[69762],
			},
			chilledself = {
				varname = format(L["%s on self"],SN[70106]),
				type = "centerpopup",
				text = "<chilledtext>",
				time = 8,
				flashtime = 8,
				color1 = "CYAN",
				icon = ST[70106],
			},
			aircd = {
				varname = format(L["%s Cooldown"],L["Air Phase"]),
				type = "dropdown",
				text = format("Next %s",L["Air Phase"]),
				time = "<airtime>",
				flashtime = 10,
				color1 = "YELLOW",
				icon = "Interface\\Icons\\INV_Misc_Toy_09",
			},
			airdur = {
				varname = format(L["%s Duration"],L["Air Phase"]),
				type = "dropdown",
				text = L["Air Phase"],
				time = 47,
				flashtime = 10,
				color1 = "MAGENTA",
				icon = "Interface\\Icons\\INV_Misc_Toy_09",
			},
			frostbombwarn = {
				varname = format(L["%s ETA"],SN[71053]),
				type = "centerpopup",
				text = format(L["%s Hits"],SN[71053]),
				time = 5.85, -- average: ranges from 5.3 to 6.5
				flashtime = 5.85,
				color1 = "BLUE",
				sound = "ALERT5",
				icon = ST[71053],
			},
			frostbreathwarn = {
				varname = format(L["%s Cast"],SN[71056]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71056]),
				time = 1.5,
				flashtime = 1.5,
				color1 = "BROWN",
				sound = "ALERT4",
				icon = ST[71056],
			},
		},
		raidicons = {
			frostbeaconmark = {
				varname = SN[70126],
				type = "MULTIFRIENDLY",
				persist = 7,
				reset = 2,
				unit = "#5#",
				icon = 1,
				total = 5,
			},
		},
		events = {
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Air phase
					{
						"expect",{"#1#","find",L["^Your incursion ends here"]},
						"quash","aircd",
						"alert","aircd",
						"alert","airdur",
					},
					-- Last Phase
					{
						"expect",{"#1#","find",L["^Now, feel my master's limitless power"]},
						"quash","aircd",
					},
				},
			},
			-- Ice Tomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					69712, -- 25
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
					70126, -- 25
				},
				execute = {
					{
						"raidicon","frostbeaconmark",
						"alert","frostbeacondur",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","frostbeaconself",
					},
				},
			},
			-- Frost Beacon removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					70126, -- 25
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			--[[
			-- Icy Grip
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					70117, -- 25
				},
				execute = {
					{
						"alert","icygripcd",
					},
				},
			},
			]]
			-- Blistering Cold
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					71047, -- 25
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
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69762, -- 25
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","unchainedself",
					},
				},
			},
			-- Chilled to the Bone
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70106, -- 25
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{chilledtext = format("%s: %s!",SN[70106],L["YOU"])},
						"alert","chilledself",
					},
				},
			},
			-- Chilled to the Bone applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					70106, -- 25
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","chilledself",
						"set",{chilledtext = format("%s: %s! %s!",SN[70106],L["YOU"],format(L["%s Stacks"],"#11#"))},
						"alert","chilledself",
					},
				},
			},
			-- Frost Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {
					71053, -- 25
				},
				execute = {
					{
						"alert","frostbombwarn",
					},
				},
			},
			-- Frost Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					71056, -- 25
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

--[[
	Block positions
	0.35448017716408, 0.23266260325909 West
	0.3654870390892, 0.2162726521492 North
	0.37621337175369, 0.23285666108131 East
	0.36525920033455, 0.24926269054413 South
	0.36546084284782, 0.27346137166023 South South
]]