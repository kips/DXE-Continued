do
	local data = {
		version = "$Rev$",
		key = "yoggsaron", 
		zone = "Ulduar", 
		name = "Yogg-Saron", 
		title = "Yogg-Saron", 
		tracing = {"Yogg-Saron",},
		triggers = {
			yell = "^The time to strike at the head of the beast",
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			lunaticgazewarn = {
				var = "lunaticgazewarn",
				varname = "Lunatic Gaze cast",
				type = "centerpopup",
				text = "Gaze: LOOK AWAY!",
				time = 4,
				color1 = "ORANGE",
				sound = "ALERT1",
			},
			brainlinkdur = {
				var = "brainlinkdur",
				varname = "Brain Link on self",
				type = "dropdown",
				text = "Brain Link: YOU",
				time = 30,
				flashtime = 0,
				color1 = "BLUE",
				sound = "ALERT3",
			},
			yoggsaronarrives = {
				var = "yoggsaronarrives",
				varname = "Yogg'Saron arrival",
				type = "dropdown",
				text = "Yogg'Saron Arrives",
				time = 20,
				flashtime = 5,
				color1 = "GREEN",
			},
		},
		events = {
			-- Lunatic Gaze
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64163,
				execute = {
					[1] = {
						{alert = "lunaticgazewarn"},
					},
				},
			},
			-- Brain Link
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63802,
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "brainlinkdur"},
					},
				},
			},
			-- Phase 2 beginning
			[3] = {
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					[1] = {
						{expect = {"#1#","find","^I am the lucid dream"}},
						{alert = "yoggsaronarrives"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
