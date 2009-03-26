do
	local data = {
		version = "$Rev: 22 $",
		key = "sartharion", 
		zone = "The Obsidian Sanctum", 
		name = "Sartharion", 
		title = "Sartharion", 
		tracing = {
			name = "Sartharion", 
		},
		triggers = {
			scan = "Sartharion", 
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "lavawallcd"},
			}
		},
		alerts = {
			lavawallcd = {
				var = "lavawallcd", 
				varname = "Lava wall cooldown", 
				type = "dropdown", 
				text = "Lava wall cooldown", 
				time = 25, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "ORANGE", 
			},
			lavawallwarn = {
				var = "lavawallwarn", 
				varname = "Lava wall warning", 
				type = "centerpopup", 
				text = "Incoming Lava Wall", 
				time = 5, 
				flashtime = 0, 
				sound = "ALERT1", 
				color1 = "ORANGE", 
			},
			shadowfissurewarn = {
				var = "shadowfissurewarn", 
				varname = "Shadow fissure warning", 
				type = "simple", 
				text = "Shadow Fissure Spawned", 
				time = 1.5, 
				flashtime = 0, 
			},
		},
		events = {
			-- Shadow fissure
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {59127,57579}, 
				execute = {
					[1] = {
						{alert = "shadowfissurewarn"}, 
					},
				},
			},
			-- Laval wall
			[2] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"#1#","find","lava surrounding"}},
						{alert = "lavawallwarn"},
						{alert = "lavawallcd"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

