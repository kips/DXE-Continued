do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 5,
		key = "deathwhisper", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Deathwhisper"], 
		triggers = {
			scan = {
				36855, -- Lady Deathwhisper
			},
			yell = L["^What is this disturbance"],
		},
		userdata = {
			culttime = {7,60,loop = false},
			insignificancetext = "",
		},
		onstart = {
			{
				"alert","cultcd",
				"scheduletimer",{"firecult",7},
			},
		},
		timers = {
			firecult = {
				{
					"alert","cultcd",
					"scheduletimer",{"firecult",60},
				},
			},
		},
		onactivate = {
			combatstop = true,
			tracing = {36855}, -- Lady Deathwhisper
			defeat = 36855, -- Lady Deathwhisper
		},
		alerts = {
			dndself = {
				varname = format(L["%s on self"],SN[71001]),
				text = format("%s: %s!",SN[71001],L["YOU"]),
				type = "simple",
				time = 3,
				sound = "ALERT1",
				color1 = "PURPLE",
				icon = ST[71001],
				flashscreen = true,
			},
			cultcd = {
				varname = format(L["%s Spawns"],L["Cult"]),
				text = format(L["%s Spawns"],L["Cult"]),
				type = "dropdown",
				time = "<culttime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "BROWN",
				icon = ST[61131],
			},
			manabarrierwarn = {
				varname = format(L["%s Removal"],SN[70842]),
				text = format(L["%s Removed"],SN[70842]).."!",
				type = "simple",
				time = 3,
				sound = "ALERT3",
				color1 = "TEAL",
				icon = ST[70842],
			},
			insignificancewarn = {
				varname = format(L["%s Warning"],SN[71204]),
				text = "<insignificancetext>",
				type = "simple",
				time = 3,
				sound = "ALERT4",
				color1 = "TAN",
				icon = ST[71204],
			},
		},
		events = {
			-- Death and Decay self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					71001,
					72108, -- 25
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","dndself",
					},
				},
			},
			-- Mana Barrier
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 70842,
				execute = {
					{
						"alert","manabarrierwarn",
						"quash","cultcd",
						"canceltimer","firecult",
					},
				},
			},
			-- Touch of Insignificance
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71204,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{insignificancetext = format("%s: %s!",SN[71204],L["YOU"])},
						"alert","insignificancewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{insignificancetext = format("%s: #5#!",SN[71204])},
						"alert","insignificancewarn",
					},
				},
			},
			-- Touch of Insignificance stacks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 71204,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{insignificancetext = format("%s: %s! %s!",SN[71204],L["YOU"],format(L["%s Stacks"],"#11#"))},
						"alert","insignificancewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{insignificancetext = format("%s: #5#! %s!",SN[71204],format(L["%s Stacks"],"#11#"))},
						"alert","insignificancewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
