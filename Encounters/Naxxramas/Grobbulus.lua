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
			leavecombat = true,
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
			},
			injectionwarnself = {
				var = "injectionwarnself",
				varname = "Injections on self",
				type = "centerpopup",
				text = "Injection: YOU! Move!",
				time = 10,
				flashtime = 10,
				sound = "ALERT1",
				color1 = "RED",
				color2 = "MAGENTA",
			},
			injectionwarnother = {
				var = "injectionwarnother",
				varname = "Injections on others",
				type = "centerpopup",
				text = "Injection: #5#",
				time = 10,
				color1 = "ORANGE",
			},
			cloudcd = {
				var = "cloudcd",
				varname = "Poison cloud cooldown",
				type = "dropdown",
				text = "Next Poison Cloud",
				time = 15,
				flashtime = 5,
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
						{expect = {"#4#", "~=", "&playerguid&"}},
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

