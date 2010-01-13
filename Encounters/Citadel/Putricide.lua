do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 7,
		key = "putricide", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Putricide"], 
		triggers = {
			scan = {
				36678, -- Putricide
			},
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {36678},
			defeat = 36678,
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","unstableexperimentcd",
				"set",{experimenttime = 37.5},
			},
		},
		userdata = {
			oozeaggrotext = {format(L["%s Aggros"],L["Volatile Ooze"]),format(L["%s Aggros"],L["Gas Cloud"]),loop = true},
			bloattext = "",
			experimenttime = 25,
			malleabletime = 6,
			gasbombtime = 16,
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 600,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			unstableexperimentwarn = {
				varname = format(L["%s Cast"],SN[71966]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71966]),
				sound = "ALERT1",
				color1 = "MAGENTA",
				time = 2.5,
				flashtime = 2.5,
				icon = ST[71966],
			},
			unstableexperimentcd = {
				varname = format(L["%s Cooldown"],SN[71966]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[71966]),
				time = "<experimenttime>",
				flashtime = 10,
				color1 = "PINK",
				icon = ST[71966],
			},
			mutatedslimeself = {
				varname = format(L["%s on self"],SN[72456]),
				type = "simple",
				text = format("%s: %s!",SN[72456],L["YOU"]),
				color1 = "GREEN",
				time = 3,
				sound = "ALERT2",
				icon = ST[72456],
				flashscreen = true,
				throttle = 4,
			},
			oozeaggrocd = {
				varname = format(L["%s Timer"],format(L["%s Aggros"],L["Volatile Ooze"].."/"..L["Gas Cloud"])),
				type = "centerpopup",
				text = "<oozeaggrotext>",
				color1 = "ORANGE",
				time = 8.5, -- 11 from Unstable Experiment Cast
				flashtime = 8.5,
				icon = ST[72218],
			},
			oozeadhesivecastwarn = {
				varname = format(L["%s Cast"],SN[72836]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[72836]),
				time = 3,
				color1 = "DCYAN",
				icon = ST[72836],
			},
			oozeadhesiveappwarn = {
				varname = format(L["%s on others"],SN[72836]),
				type = "simple",
				text = format("%s: #5#!",SN[72836]),
				color1 = "CYAN",
				sound = "ALERT3",
				time = 3,
				icon = ST[72836],
				flashscreen = true,
			},
			bloatcastwarn = {
				varname = format(L["%s Cast"],SN[72455]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[72455]),
				time = 3,
				color1 = "BROWN",
				icon = ST[72455],
			},
			bloatappwarn = {
				varname = format(L["%s Warning"],SN[72455]),
				type = "simple",
				text = "<bloattext>",
				time = 3,
				sound = "ALERT4",
				color1 = "BROWN",
				icon = ST[72455],
				flashscreen = true,
			},
			gasbombwarn = {
				varname = format(L["%s Explodes"],SN[71255]),
				type = "centerpopup",
				text = format(L["%s Explodes"],SN[71255]),
				time = 10,
				sound = "ALERT5",
				color1 = "YELLOW",
				icon = ST[71255],
			},
			gasbombcd = {
				varname = format(L["%s Cooldown"],SN[71255]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[71255]),
				time = "<gasbombtime>",
				color1 = "GOLD",
				icon = ST[71255],
			},
			malleablegoowarn = {
				varname = format(L["%s Warning"],SN[72615]),
				type = "simple",
				text = format(L["%s Casted"],SN[72615]),
				time = 3,
				sound = "ALERT6",
				color1 = "BLACK",
				icon = ST[72615],
			},
			malleablegoocd = {
				varname = format(L["%s Cooldown"],SN[72615]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[72615]),
				time = "<malleabletime>",
				color1 = "GREY",
				icon = ST[72615],
			},
			teargaswarn = {
				varname = format(L["%s Cast"],SN[71617]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71617]),
				time = 2.5,
				sound = "ALERT7",
				color1 = "INDIGO",
				icon = ST[71617],
			},
			teargasdur = {
				varname = format(L["%s Duration"],SN[71617]),
				type = "centerpopup",
				text = format(L["%s Ends Soon"],SN[71617]),
				time = 16,
				color1 = "INDIGO",
				icon = ST[71617],
			},
		},
		raidicons = {
			oozeadhesivemark = {
				varname = SN[72836],
				type = "FRIENDLY",
				persist = 30,
				unit = "#5#",
				icon = 1,
			},
			gaseousbloatmark = {
				varname = SN[72455],
				type = "FRIENDLY",
				persist = 30,
				unit = "#5#",
				icon = 2,
			},
		},
		timers = {
			fireoozeaggro = {
				{
					"alert","oozeaggrocd",
				},
			},
		},
		events = {
			-- Malleable Goo
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					72615, -- 25
					72295, -- 10
				},
				execute = {
					{
						"quash","malleablegoocd",
						"alert","malleablegoowarn",
						"alert","malleablegoocd",
					},
				},
			},
			-- Choking Gas Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 71255,
				execute = {
					{
						"quash","gasbombcd",
						"alert","gasbombwarn",
						"alert","gasbombcd",
					},
				},
			},
			-- Tear Gas
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71617, -- 10/25
				execute = {
					{
						"quash","oozeaggrocd", -- don't cancel timer
						"quash","malleablegoocd",
						"quash","unstableexperimentcd",
						"alert","teargaswarn",
					},
				},
			},
			-- Tear Gas duration
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71615,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","teargasdur",
					},
				},
			},
			-- Tear Gas removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 71615,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{malleabletime = 6, experimenttime = 20, gasbombtime = 16},
						"alert","malleablegoocd",
						"alert","unstableexperimentcd",
						"alert","gasbombcd",
						"set",{malleabletime = 25.5, experimenttime = 37.5, gasbombtime = 35.5},
					},
				},
			},
			-- Gaseous Bloat
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72455, -- 25
					70672, -- 10
				},
				execute = {
					{
						"quash","oozeaggrocd",
						"alert","bloatcastwarn",
					},
				},
			},
			-- Gaseous Bloat application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72455, -- 25
					70672, -- 10
				},
				execute = {
					{
						"raidicon","gaseousbloatmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{bloattext = format("%s: %s! %s!",SN[72455],L["YOU"],L["MOVE AWAY"])},
						"alert","bloatappwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{bloattext = format("%s: #5#!",SN[72455])},
						"alert","bloatappwarn",
					},
				},
			},
			-- Gaseous Bloat removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					72455, -- 25
					70672, -- 10
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Volatile Ooze Adhesive
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					72836, -- 25
					70447, -- 10
				},
				execute = {
					{
						"quash","oozeaggrocd",
						"alert","oozeadhesivecastwarn",
					},
				},
			},
			-- Volatile Ooze Adhesive application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72836, -- 25
					70447, -- 10
				},
				execute = {
					{
						"raidicon","oozeadhesivemark",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","oozeadhesivecastwarn",
						"alert","oozeadhesiveappwarn",
					},
				},
			},
			-- Volatile Ooze Adhesive removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					72836, -- 25
					70447, -- 10
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Unstable Experiment
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					71966,
					70351,
					71966,
				},
				execute = {
					{
						"quash","unstableexperimentcd",
						"alert","unstableexperimentwarn",
						"alert","unstableexperimentcd",
						"scheduletimer",{"fireoozeaggro",2.5},
					},
				},
			},
			-- Mutated Slime self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					72456, -- 25
					70346, -- 10 Slime Puddle
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","mutatedslimeself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
