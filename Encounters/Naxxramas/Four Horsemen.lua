do
	local data = {
		version = "$Rev: 22 $",
		key = "fourhorsemen", 
		zone = "Naxxramas", 
		name = "Four Horsemen",
		title = "Four Horsemen",
		tracing = {
			name = "Thane Korth'azz", 
		},
		triggers = {
			scan = "Thane Korth'azz", 
		},
		onactivate = {
			autoupdate = true,
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
		},
	}

	DXE:RegisterEncounter(data)
end

-- Need to quash alerts on death somehow
