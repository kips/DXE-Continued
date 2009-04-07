do
	local data = {
		version = "$Rev$",
		key = "sapphiron", 
		zone = "Naxxramas", 
		name = "Sapphiron", 
		title = "Sapphiron", 
		tracing = {"Sapphiron"},
		triggers = {
			scan = "Sapphiron", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			lifedraincd = {
				var = "lifedraincd", 
				varname = "Life Drain cooldown", 
				type = "dropdown", 
				text = "Next Life Drain", 
				time = 23, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "MAGENTA", 
			},
			airphasedur = {
				var = "airphasedur", 
				varname = "Air phase duration", 
				type = "centerpopup", 
				text = "Air Phase Duration", 
				time = 15.5, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "YELLOW", 
			},
			deepbreathwarn = {
				var = "deepbreathwarn", 
				varname = "Deep breath warning", 
				type = "centerpopup", 
				text = "Deep Breath! Hide!", 
				time = 10, 
				flashtime = 6.5, 
				sound = "ALERT1", 
				color1 = "BLUE", 
			},
		},
		events = {
			-- Life drain
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {28542,55665}, 
				execute = {
					[1] = {
						{alert = "lifedraincd"}, 
					},
				},
			},
			-- Emotes
			[2] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"#1#","find","lifts"}},
						{alert = "airphasedur"}, 
						{quash = "lifedraincd"},
					},
					[2] = {
						{expect = {"#1#","find","deep"}},
						{quash = "airphasedur"},
						{alert = "deepbreathwarn"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

