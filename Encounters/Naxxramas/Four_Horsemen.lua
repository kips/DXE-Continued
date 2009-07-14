do
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "fourhorsemen", 
		zone = L["Naxxramas"], 
		name = L["The Four Horsemen"],
		triggers = {
			scan = {L["Thane Korth'azz"],L["Baron Rivendare"],L["Lady Blaumeux"],L["Sir Zeliek"]},
		},
		onactivate = {
			tracing = {L["Thane Korth'azz"],L["Baron Rivendare"],L["Lady Blaumeux"],L["Sir Zeliek"]},
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
						{expect = {"#5#","==",L["Sir Zeliek"]},},
						{quash = "wrathcd"},
					},
					{
						{expect = {"#5#","==",L["Thane Korth'azz"]},},
						{quash = "meteorcd"},
					},
					{
						{expect = {"#5#","==",L["Lady Blaumeux"]},},
						{quash = "voidzonecd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
