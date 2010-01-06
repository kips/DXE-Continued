do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 2,
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
		alerts = {
			infectionself = {
				varname = format(L["%s on self"],SN[69674]),
				type = "centerpopup",
				text = format("%s: %s!",SN[69674],L["YOU"]),
				time = 12,
				flashtime = 12,
				color1 = "GREEN",
				color2 = "MAGENTA",
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
				color1 = "INDIGO",
				icon = ST[69508],
			},
			slimespraychanwarn = {
				varname = format(L["%s Channel"],SN[69508]),
				type = "centerpopup",
				text = format(L["%s Channel"],SN[69508]),
				time = 5,
				flashtime = 5,
				color1 = "INDIGO",
				icon = ST[69508],
			},
		},
		timers = {
			fireslimespraychan = {
				{
					"alert","slimespraychanwarn",
				},
			},
		},
		events = {
			-- Mutated Infection
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69674,
					71224,
				},
				execute = {
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
			-- Slime Spray
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 69508,
				execute = {
					{
						"alert","slimespraycastwarn",
						"scheduletimer",{"fireslimespraychan",1.5},
					},
				},
			},
		},
	}


	DXE:RegisterEncounter(data)
end
