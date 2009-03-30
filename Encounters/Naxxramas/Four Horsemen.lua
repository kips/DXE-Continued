do
	local data = {
		version = "$Rev$",
		key = "fourhorsemen", 
		zone = "Naxxramas", 
		name = "Four Horsemen",
		title = "Four Horsemen",
		tracing = {"Thane Korth'azz","Baron Rivendare","Lady Blaumeux","Sir Zeliek"},
		triggers = {
			scan = "Thane Korth'azz", 
		},
		onactivate = {
			autostart = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			voidzonecd = {
				var = "voidzonecd",
				varname = "Void zone cooldown",
				type = "dropdown",
				text = "Void zone",
				time = 12,
				flashtime = 0,
				color1 = "MAGENTA",
			},
			meteorcd = {
				var = "meteorcd",
				varname = "Meteor cooldown",
				type = "dropdown",
				text = "Meteor",
				time = 12,
				flashtime = 0,
				color1 = "RED",
			},
			wrathcd = {
				var = "wrathcd",
				varname = "Holy wrath cooldown",
				type = "dropdown",
				text = "Holy wrath",
				time = 12,
				flashtime = 0,
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
						{expect = {"#5#","==","Sir Zeliek"},},
						{quash = "wrathcd"},
					},
					[2] = {
						{expect = {"#5#","==","Thane Korth'azz"},},
						{quash = "meteorcd"},
					},
					[3] = {
						{expect = {"#5#","==","Lady Blaumeux"},},
						{quash = "voidzonecd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
