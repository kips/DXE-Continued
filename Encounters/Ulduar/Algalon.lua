do
	local data = {
		version = "$Rev$",
		key = "algalon", 
		zone = "Ulduar", 
		name = "Algalon the Observer", 
		title = "Algalon the Observer", 
		tracing = {"Algalon the Observer",},
		triggers = {
			scan = "Algalon the Observer",
			yell = "^Your actions are illogical. All possible results",
		},
		onactivate = {
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			bigbangwarn = {
				var = "bigbangwarn",
				varname = "Big Bang cast",
				type = "centerpopup",
				text = "Big Bang Cast",
				time = 8,
				flashtime = 8,
				sound = "ALERT5",
				color1 = "ORANGE",
				color2 = "BROWN",
			},
			cosmicsmashwarn = {
				var = "cosmicsmashwarn",
				varname = "Cosmic Smash eta",
				type = "centerpopup",
				text = "Cosmic Smash Hits",
				time = 4.2,
				flashtime = 4.2,
				sound = "ALERT1",
				color1 = "MAGENTA",
				color2 = "MAGENTA",
			},
		},
		events = {
			[1] = {
				type = "event",
				event = "EMOTE",
				execute = {
					-- Collapsing Stars
					[1] = {
						{expect = {"#1#","find","begins to Summon Collapsing Stars!"}},
					},
					-- Cosmic Smash
						-- Takes 4 seconds to hit
					[2] = {
						{expect = {"#1#","find","begins to cast Cosmic Smash!"}},
						{alert = "cosmicsmashwarn"},
					},
					-- Big Bang
					[3] = {
						{expect = {"#1#","find","begins to cast Big Bang!"}},
						{alert = "bigbangwarn"},
					},
				},
			},
		}
	}
	-- Big Bang
		-- 8 second cast that wdoes 100k damage
		-- Have to be in black hole to avoid it
	-- Phase Punch
	-- Black Hole Explosion
		-- Happens when collapsing stars are killed
	-- Cosmic Smash
		-- Red void zones on the ground
	DXE:RegisterEncounter(data)
end
