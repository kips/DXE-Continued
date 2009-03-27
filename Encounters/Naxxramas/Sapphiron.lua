do
	local data = {
		version = "$Rev: 22 $",
		key = "sapphiron", 
		zone = "Naxxramas", 
		name = "Sapphiron", 
		title = "Sapphiron", 
		tracing = {"Sapphiron"},
		triggers = {
			scan = "Sapphiron", 
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			lifedraincd = {
				var = "lifedraincd", 
				varname = "Life drain cooldown", 
				type = "dropdown", 
				text = "Lifedrain", 
				time = 23, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "MAGENTA", 
			},
			airphasedur = {
				var = "airphasedur", 
				varname = "Air phase duration", 
				type = "dropdown", 
				text = "Air Phase", 
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
					},
					[2] = {
						{expect = {"#1#","find","deep"}},
						{alert = "deepbreathwarn"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

