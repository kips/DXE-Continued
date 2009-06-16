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
			autostart = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			voidzonecd = {
				var = "voidzonecd",
				varname = format(L["%s Cooldown"],SN[28863]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[28863]),
				time = 12,
				color1 = "MAGENTA",
			},
			meteorcd = {
				var = "meteorcd",
				varname = format(L["%s Cooldown"],SN[28884]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[28884]),
				time = 12,
				color1 = "RED",
			},
			wrathcd = {
				var = "wrathcd",
				varname = format(L["%s Cooldown"],SN[28883]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[28883]),
				time = 12,
				color1 = "YELLOW",
			},
		},
		events = {
			-- Void Zone
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28863,57463},
				execute = {
					[1] = {
						{alert = "voidzonecd"},
					},
				},
			},
			-- Meteor
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {28884,57467},
				execute = {
					[1] = {
						{alert = "meteorcd"},
					},
				},
			},
			-- Wrath
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28883,57466},
				execute = {
					[1] = {
						{alert = "wrathcd"},
					},
				},
			},
			-- Boss quashes
			[4] = {
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					[1] = {
						{expect = {"#5#","==",L["Sir Zeliek"]},},
						{quash = "wrathcd"},
					},
					[2] = {
						{expect = {"#5#","==",L["Thane Korth'azz"]},},
						{quash = "meteorcd"},
					},
					[3] = {
						{expect = {"#5#","==",L["Lady Blaumeux"]},},
						{quash = "voidzonecd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
