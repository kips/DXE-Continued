do
	local data = {
		version = "$Rev$",
		key = "grandwidowfaerlina", 
		zone = "Naxxramas", 
		name = "Grand Widow Faerlina", 
		title = "Grand Widow Faerlina", 
		tracing = {"Grand Widow Faerlina",},
		triggers = {
			scan = "Grand Widow Faerlina", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = { 
			enraged = "false",
		},
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
				text = "Enrage Cooldown", 
				time = 60, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED", 
			},
			enragewarn = {
				var = "enragewarn", 
				varname = "Enrage warning", 
				type = "simple", 
				text = "Enraged!", 
				time = 1.5, 
				sound = "ALERT2", 
			},
			rainwarn = {
				var = "rainwarn", 
				varname = "Rain of fire warning", 
				type = "simple", 
				text = "Move Out of Rain!", 
				time = 1.5, 
				sound = "ALERT3", 
			},
			silencedur = {
				var = "silencedur", 
				varname = "Silence duration", 
				type = "dropdown", 
				text = "Silence Duration", 
				time = 30, 
				flashtime = 5, 
				sound = "ALERT4", 
			},
		},
		events = {
			-- Silence
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {28732,54097}, 
				execute = {
					[1] = {
						{expect = {"#5#","==","Grand Widow Faerlina"}},
						{expect = {"$enraged$","==","true"}},
						{set = {enraged = "false"}}, 
						{alert = "enragecd"}, 
						{quash = "silencedur"},
						{alert = "silencedur"}, 
					},
				},
			},
			-- Rain
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 54099,
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "rainwarn"},
					}
				},
			},
			-- Enrage
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 54100,
				execute = {
					[1] = {
						{expect = {"#5#","==","Grand Widow Faerlina"}},
						{quash = "enragecd"},
						{set = {enraged = "true"}}, 
						{alert = "enragewarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
