do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 4,
		key = "rotface", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Rotface"], 
		triggers = {
			scan = {
				36627, -- Rotface
			},
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36627},
			defeat = 36627,
		},
		userdata = {
			slimetime = {16,20,loop = false},
		},
		onstart = {
			{
				"alert","slimespraycd",
			},
		},
		alerts = {
			infectionself = {
				varname = format(L["%s on self"],SN[69674]),
				type = "centerpopup",
				text = format("%s: %s!",SN[69674],L["YOU"]),
				time = 12,
				flashtime = 12,
				color1 = "GREEN",
				color2 = "PEACH",
				sound = "ALERT1",
				icon = ST[69674],
				flashscreen = true,
			},
			infectiondur = {
				varname = format(L["%s on others"],SN[69674]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[69674]),
				time = 12,
				flashtime = 12,
				color1 = "TEAL",
				icon = ST[69674],
			},
			slimespraycastwarn = {
				varname = format(L["%s Cast"],SN[69508]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[69508]),
				time = 1.5,
				flashtime = 1.5,
				sound = "ALERT2",
				color1 = "CYAN",
				icon = ST[69508],
			},
			slimespraychanwarn = {
				varname = format(L["%s Channel"],SN[69508]),
				type = "centerpopup",
				text = format(L["%s Channel"],SN[69508]),
				time = 5,
				flashtime = 5,
				color1 = "CYAN",
				icon = ST[69508],
			},
			slimesprayself = {
				varname = format(L["%s on self"],SN[71213]),
				type = "simple",
				text = format("%s: %s! %s!",SN[71213],L["YOU"],L["MOVE AWAY"]),
				time = 3,
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[71213],
				throttle = 4,
			},
			slimespraycd = {
				varname = format(L["%s Cooldown"],SN[71213]),
				type = "dropdown",
				text = format(L["Next %s"],SN[71213]),
				time = "<slimetime>",
				color1 = "BROWN",
				flashtime = 5,
				icon = ST[71213],
			},
			oozefloodself = {
				varname = format(L["%s on self"],SN[71215]),
				type = "simple",
				text = format("%s: %s! %s!",SN[71215],L["YOU"],L["MOVE AWAY"]),
				time = 3,
				color1 = "BLACK",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[71215],
				throttle = 3,
			},
			unstableoozewarn = {
				varname = format(L["%s Cast"],SN[69839]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[69839]).."! "..L["MOVE"].."!",
				time = 4,
				flashtime = 4,
				color1 = "MAGENTA",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[69839],
			},
			unstableoozestackwarn = {
				varname = format(L["%s Stacks"],SN[69558]).." >= 3",
				type = "simple",
				text = format("%s => %s!",SN[69558],format(L["%s Stacks"],"#11#")),
				time = 3,
				color1 = "YELLOW",
				icon = ST[69558],
			},
		},
		timers = {
			fireslimespraychan = {
				{
					"quash","slimespraycastwarn",
					"alert","slimespraychanwarn",
				},
			},
		},
		raidicons = {
			infectionmark = {
				varname = SN[69674],
				type = "MULTIFRIENDLY",
				persist = 12,
				reset = 7,
				unit = "#5#",
				icon = 1,
				total = 4, -- safety
			},
		},
		events = {
			-- Mutated Infection
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69674, -- 10
					71224, -- 25
				},
				execute = {
					{
						"raidicon","infectionmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","infectionself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","infectiondur",
					},
				},
			},
			-- Mutated Infection removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					69674, -- 10
					71224, -- 25
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Slime Spray
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 69508,
				execute = {
					{
						"alert","slimespraycd",
						"alert","slimespraycastwarn",
						"scheduletimer",{"fireslimespraychan",1.5},
					},
				},
			},
			-- Slime Spray self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					71213, -- 25
					69507, -- 10
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","slimesprayself",
					},
				},
			},
			-- Ooze Flood self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					71215, -- 25
					69789, -- 10
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","oozefloodself",
					},
				},
			},
			-- Unstable Ooze Explosion
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 69839, -- 25
				execute = {
					{
						"alert","unstableoozewarn",
					},
				},
			},
			-- Unstable Ooze stacks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 69558, -- 10/25
				execute = {
					{
						"expect",{"#11#",">=","3"},
						"alert","unstableoozestackwarn",
					},
				},
			},
		},
	}


	DXE:RegisterEncounter(data)
end
