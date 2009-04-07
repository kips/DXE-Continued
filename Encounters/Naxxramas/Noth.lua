do
	local data = {
		version = "$Rev$",
		key = "noththeplaguebringer", 
		zone = "Naxxramas", 
		name = "Noth the Plaguebringer", 
		title = "Noth the Plaguebringer", 
		tracing = {"Noth the Plaguebringer",},
		triggers = {
			scan = "Noth the Plaguebringer", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = { 
			roomtime = {90,110,180,loop=false},
			balconytime = {70,95,120,loop=false},
		},
		onstart = {
			[1] = {
				{alert = "blinkcd"},
				{alert = "teleportbalc"},
			}
		},
		alerts = {
			blinkcd = {
				var = "blinkcd", 
				varname = "Blink cooldown", 
				type = "dropdown", 
				text = "Blink Cooldown", 
				time = 30, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
			},
			teleportbalc = {
				var = "teleportbalc", 
				varname = "Teleport to balcony", 
				type = "dropdown", 
				text = "Noth Teleports", 
				time = "<roomtime>", 
				flashtime = 5, 
				sound = "ALERT2", 
			},
			teleportroom = {
				var = "teleportroom", 
				varname = "Teleport to room", 
				type = "dropdown", 
				text = "Noth Returns", 
				time = "<balconytime>", 
				flashtime = 5, 
				sound = "ALERT2", 
			},
			cursewarn = {
				var = "cursewarn", 
				varname = "Curse warning", 
				type = "simple", 
				text = "Curse Casted. Decurse!", 
				time = 1.5, 
				sound = "ALERT3", 
			},
		},
		events = {
			-- Curses
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {29213,54835}, 
				execute = {
					[1] = {
						
						{alert = "cursewarn"}, 
					},
				},
			},
			-- Emotes
			[2] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"#1#","find","blinks away"}},
						{alert = "blinkcd"}, 
					},
					[2] = {
						{expect = {"#1#","find","teleports to the balcony"}},
						{quash = "blinkcd"},
						{alert = "teleportroom"}, 
					},
					[3] = {
						{expect = {"#1#","find","teleports back into battle"}},
						{alert = "teleportbalc"}, 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

