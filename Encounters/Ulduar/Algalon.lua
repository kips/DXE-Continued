-- Collapsing Star cd?
-- Living Constellation cd?
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
		userdata = {
			startime = 24,
			cosmicsmashtime = {33,25,loop = false},
			bigbangtime = {98,90,loop = false},
			constellationtime = 65,
		},
		onstart = {
			{
				{alert = "starcd"},
				{alert = "cosmicsmashcd"},
				{alert = "bigbangcd"},
				{alert = "constellationcd"},
				{alert = "algalonengage"},
			},
		},
		alerts = {
			algalonengage = {
				var = "algalonengage",
				varname = "Algalon engage",
				type = "centerpopup",
				text = "Algalon Engages",
				time = 8,
			},
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
			bigbangcd = {
				var = "bigbangcd",
				varname = "Big Bang cooldown",
				type = "dropdown",
				text = "Big Bang Cooldown",
				time = "<bigbangtime>",
				flashtime = 5,
				sound = "ALERT2",
				color1 = "BLUE",
				color2 = "BLUE",
			},
			cosmicsmashwarn = {
				var = "cosmicsmashwarn",
				varname = "Cosmic Smash eta",
				type = "centerpopup",
				text = "Cosmic Smash Hits",
				time = 4.2,
				flashtime = 4.2,
				sound = "ALERT1",
				color1 = "YELLOW",
				color2 = "DCYAN",
			},
			cosmicsmashcd = {
				var = "cosmicsmashcd",
				varname = "Cosmic Smash cooldown",
				type = "dropdown",
				text = "Cosmic Smash Cooldown",
				time = "<cosmicsmashtime>",
				flashtime = 5,
				sound = "ALERT3",
				color1 = "GREEN",
				color2 = "GREEN",
			},
			starcd = {
				var = "starcd",
				varname = "Collapsing Star spawns",
				type = "dropdown",
				text = "Stars Spawn",
				time = "<startime>",
				flashtime = 5,
				sound = "ALERT6",
				color1 = "TAN",
				color2 = "TAN",
			},
			constellationcd = {
				var = "constellationcd",
				varname = "Living Constellation spawns",
				type = "dropdown",
				text = "Constellations Spawn",
				time = "<constellationtime>",
				flashtime = 5,
				sound = "ALERT7",
				color1 = "TEAL",
				color2 = "TEAL",
			},
			punchcd = {
				var = "punchcd",
				varname = "Phase Punch cooldown",
				type = "dropdown",
				text = "Phase Punch Cooldown",
				time = 15,
				flashtime = 5,
				color1 = "INDIGO",
				color2 = "INDIGO",
			},
		},
		events = {
			{
				type = "event",
				event = "EMOTE",
				execute = {
					-- Collapsing Stars
					{
						{expect = {"#1#","find","begins to Summon Collapsing Stars!"}},
						{alert = "starcd"},
					},
				},
			},
			-- Big Bang
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64443,64584},
				execute = {
					{
						{alert = "bigbangwarn"},
						{alert = "bigbangcd"},
					},
				},
			},
			-- Cosmic Smash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {62301,64598},
				execute = {
					{
						{alert = "cosmicsmashwarn"},
						{alert = "cosmicsmashcd"},
					}
				},
			},
			-- Phase Punch
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64412,
				execute = {
					{
						{alert = "punchcd"},
					}	
				},
			},
		}
	}
	DXE:RegisterEncounter(data)
end
