do
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "fourhorsemen", 
		zone = L["Naxxramas"], 
		name = L["The Four Horsemen"],
		triggers = {
			scan = {
				16064, -- Thane Korth'azz
				30549, -- Baron Rivendare
				16065, -- Lady Blaumeux
				16063, -- Sir Zeliek
			},
		},
		onactivate = {
			tracing = {
				16064, -- Thane Korth'azz
				30549, -- Baron Rivendare
				16065, -- Lady Blaumeux
				16063, -- Sir Zeliek
			},
			tracerstart = true,
			combatstop = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			voidzonecd = {
				varname = format(L["%s Cooldown"],SN[28863]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[28863]),
				time = 12,
				color1 = "MAGENTA",
			},
			meteorcd = {
				varname = format(L["%s Cooldown"],SN[28884]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[28884]),
				time = 12,
				color1 = "RED",
			},
			wrathcd = {
				varname = format(L["%s Cooldown"],SN[28883]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[28883]),
				time = 12,
				color1 = "YELLOW",
			},
		},
		events = {
			-- Void Zone
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28863,57463},
				execute = {
					{
						{alert = "voidzonecd"},
					},
				},
			},
			-- Meteor
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {28884,57467},
				execute = {
					{
						{alert = "meteorcd"},
					},
				},
			},
			-- Wrath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28883,57466},
				execute = {
					{
						{alert = "wrathcd"},
					},
				},
			},
			-- Boss quashes
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						{expect = {"&npcid|#4#&","==","16063"}},
						{quash = "wrathcd"},
					},
					{
						{expect = {"&npcid|#4#&","==","16064"}},
						{quash = "meteorcd"},
					},
					{
						{expect = {"&npcid|#4#&","==","16065"}},
						{quash = "voidzonecd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
