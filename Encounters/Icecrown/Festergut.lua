do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "festergut", 
		zone = L["Icecrown Citadel"], 
		category = L["Icecrown"], 
		name = L["Festergut"], 
		triggers = {
			scan = {36626}, -- Festergut
			yell = L["^Just an ordinary gas cloud, but watch"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36626}, -- Festergut
		},
		userdata = {
			inhaletime = {28.9, 33.8, loop = false},
			sporetime = {13.6, 35, loop = false},
			pungenttime = {116, 105, loop = false},
		},
		alerts = {
			inhaleblightcd = {
				varname = format(L["%s Cooldown"],SN[69165]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[69165]),
				time = "<inhaletime>",
				color1 = "GREY",
				flashtime = 10,
				icon = ST[69165],
			},
			inhaleblightwarn = {
				varname = format(L["%s Cast"],SN[69165]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[69165]),
				time = 3.5,
				flashtime = 3.5,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[69165],
			},
			gassporecd = {
				varname = format(L["%s Cooldown"],SN[71221]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[71221]),
				time = "<sporetime>",
				color1 = "YELLOW",
				flashtime = 5,
				icon = ST[71221],
			},
			gassporedur = {
				varname = format(L["%s Duration"],SN[71221]),
				type = "centerpopup",
				text = format(L["%s Duration"],SN[71221]),
				time = 12,
				flashtime = 12,
				color1 = "BLUE",
				sound = "ALERT2",
				flashscreen = true,
				icon = ST[71221],
			},
			gassporeself = {
				varname = format(L["%s on self"],SN[71221]),
				type = "simple",
				text = format("%s: %s!",SN[71221],L["YOU"]).."!",
				time = 3,
				flashscreen = true,
				icon = ST[71221],
			},
			vilegascd = {
				varname = format(L["%s Cooldown"],SN[71218]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[71218]),
				time = 20,
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[71288],
			},
			vilegaswarn = {
				varname = format(L["%s Warning"],SN[71218]),
				type = "simple",
				text = format(L["%s Casted"],SN[71218]).."!",
				time = 3,
				color1 = "GREEN",
				sound = "ALERT3",
				icon = ST[71288],
			},
			pungentblightwarn ={
				varname = format(L["%s Cast"],SN[71219]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71219]),
				time = 3,
				flashtime = 3,
				color1 = "PURPLE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[71219],
			},
			pungentblightcd = {
				varname = format(L["%s Cooldown"],SN[71219]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[71219]),
				time = "<pungenttime>",
				color1 = "DCYAN",
				flashtime = 10,
				icon = ST[71219],
			},
		},
		raidicons = {
			vilegasmark = {
				varname = SN[71307],
				type = "MULTIFRIENDLY",
				persist = 6,
				reset = 3,
				unit = "#5#",
				icon = 1,
				total = 3,
			},
		},
		events = {
			-- Inhale Blight
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 69165,
				execute = {
					{
						"alert","inhaleblightcd",
						"alert","inhaleblightwarn",
					},
				},
			},
			-- Gas Spore
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 71221,
				execute = {
					{
						"quash","gassporecd",
						"alert","gassporedur",
						"alert","gassporecd",
					},
				},
			},
			-- Gas Spore on self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71221,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","gassporeself",
					},
				},
			},
			-- Vile Gas
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 71218, -- Note: Don't use 71307
				execute = {
					{
						"quash","vilegascd",
						"alert","vilegascd",
						"alert","vilegaswarn",
					},
				},
			},
			-- Vile Gas applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71218,
				execute = {
					{
						"raidicon","vilegasmark",
					},
				},
			},
			-- Pungent Blight
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71219,
				execute = {
					{
						"alert","pungentblightcd",
						"alert","pungentblightwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
