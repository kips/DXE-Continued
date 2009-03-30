do
	local data = {
		version = "$Rev$",
		key = "gluth",
		zone = "Naxxramas",
		name = "Gluth",
		title = "Gluth",
		tracing = {"Gluth",},
		triggers = {
			scan = "Gluth",
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "decimatecd"},
			}
		},
		alerts = {
			decimatecd = {
				var = "decimatecd",
				varname = "Decimate cooldown",
				type = "dropdown",
				text = "Decimate cooldown", 
				time = 105, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED", 
				throttle = 5,
			},
			enragewarn = {
				var = "enragewarn", 
				varname = "Enrage warning", 
				type = "simple", 
				text = "Enraged!", 
				time = 1.5, 
				flashtime = 0, 
			},
		},
		events = {
			-- Decimate (hit)
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {28375,54426},
				execute = {
					[1] = {
						{alert = "decimatecd"},
					},
				},
			},
			-- Decimate (miss)
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_MISSED",
				spellid = {28375,54426},
				execute = {
					[1] = {
						{alert = "decimatecd"},
					},
				},
			},
			-- Emote (Enrage)
			[3] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE",
				execute = {
					[1] = {
						{expect = {"#1#","find","becomes enraged"}},
						{alert = "enragewarn"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

