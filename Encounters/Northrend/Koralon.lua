do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 2,
		key = "koralon", 
		zone = L["Vault of Archavon"], 
		category = L["Northrend"],
		name = L["Koralon"], 
		triggers = {
			scan = {
				35013, -- Koralon
			}, 
		},
		onactivate = {
			tracing = {35013},
			tracerstart = true,
			combatstop = true,
		},
		userdata = {
			meteortime = {28,47,loop = false}, -- recheck
			breathtime = {8,47,loop = false}, -- recheck
		},
		onstart = {
			{
				"alert","breathcd",
				"alert","meteorcd",
			},
		},
		alerts = {
			flamingcinderself = {
				varname = format(L["%s on self"],SN[67332]),
				text = format("%s: %s! %s!",SN[67332],L["YOU"],L["MOVE AWAY"]),
				type = "simple",
				time = 3,
				throttle = 3,
				color1 = "ORANGE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[67332],
			},
			meteorcd = {
				varname = format(L["%s Cooldown"],SN[66725]),
				text = format(L["%s Cooldown"],SN[66725]),
				type = "dropdown",
				time = "<meteortime>",
				flashtime = 10,
				color1 = "MAGENTA",
				sound = "ALERT4",
				icon = ST[66725],
			},
			meteorwarn = {
				varname = format(L["%s Cast"],SN[66725]),
				text = format(L["%s Cast"],SN[66725]),
				type = "centerpopup",
				time = 1.5,
				flashtime = 1.5,
				color1 = "BROWN",
				sound = "ALERT3",
				icon = ST[66725],
			},
			meteordur = {
				varname = format(L["%s Duration"],SN[66725]),
				text = format(L["%s Duration"],SN[66725]),
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				color1 = "BROWN",
				sound = "ALERT2",
				icon = ST[66725],
			},
			breathwarn = {
				varname = format(L["%s Cast"],SN[67328]),
				text = format(L["%s Cast"],SN[67328]),
				type = "centerpopup",
				time = 1.5,
				flashtime = 1.5,
				sound = "ALERT5",
				color1 = "YELLOW",
				icon = ST[67328],
			},
			breathdur = {
				varname = format(L["%s Channel"],SN[67328]),
				text = format(L["%s Channel"],SN[67328]),
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[67328],
			},
			breathcd = {
				varname = format(L["%s Cooldown"],SN[67328]),
				text = format(L["%s Cooldown"],SN[67328]),
				type = "dropdown",
				time = "<breathtime>",
				flashtime = 5,
				color1 = "INDIGO",
				icon = ST[67328],
			},
		},
		timers = {
			startbreathchan = {
				{
					"quash","breathwarn",
					"alert","breathdur",
				},
			},
		},
		events = {
			-- Burning Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					66665,
					67328, -- 25
				},
				execute = {
					{
						"quash","breathcd",
						"alert","breathcd",
						"alert","breathwarn",
						"scheduletimer",{"startbreathchan",1.5},
					},
				},
			},
			-- Meteor Fists cast
			{
				type =  "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					68161, -- 25
					66808,
					66725,
					68160,
				},
				execute = {
					{
						"alert","meteorwarn",
					},
				},
			},
			-- Meteor Fists duration
			{
				type =  "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					68161, -- 25
					66808,
					66725,
					68160,
				},
				execute = {
					{
						"quash","meteorwarn",
						"alert","meteordur",
					},
				},
			},
			-- Flaming Cinder
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {67332,66684},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","flamingcinderself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
