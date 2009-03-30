do
	local data = {
		version = "$Rev$",
		key = "grobbulus",
		zone = "Naxxramas",
		name = "Grobbulus",
		title = "Grobbulus",
		tracing = {"Grobbulus",},
		triggers = {
			scan = "Grobbulus",
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "enragecd"},
			}
		},
		alerts = {
			enragecd = {
				var = "enragecd",
				varname = "Enrage cooldown",
				type = "dropdown",
				text = "Enrage",
				time = 360,
				flashtime = 5,
				sound = "ALERT1",
			},
			injectionwarnself = {
				var = "injectionwarn",
				varname = "Injection warning",
				type = "centerpopup",
				text = "Move! You're injected!",
				time = 10,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "ORANGE",
			},
			injectionwarnother = {
				var = "injectionwarn",
				varname = "Injection warning",
				type = "centerpopup",
				
				text = "#5# is injected!",
				time = 10,
				flashtime = 0,
				sound = "ALERT1",
				color1 = "ORANGE",
			},
			cloudcd = {
				var = "cloudcd",
				varname = "Poison cloud cooldown",
				type = "dropdown",
				text = "Poison cloud cooldown",
				time = 15,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "GREEN",
			},
		},
		events = {
			-- Injection
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 28169,
				execute = {
					[1] = {
						{expect = {"#4#", "==", "&playerguid&"}},
						{alert = "injectionwarnself"},
					},
					[2] = {
						{expect = {"#4#", "not_==", "&playerguid&"}},
						{alert = "injectionwarnother"},
					},
				},
			},
			-- Poison cloud
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 28240,
				execute = {
					[1] = {
						{alert = "cloudcd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

