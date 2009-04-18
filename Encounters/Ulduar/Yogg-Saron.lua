do
	local data = {
		version = "$Rev$",
		key = "yoggsaron", 
		zone = "Ulduar", 
		name = "Yogg-Saron", 
		title = "Yogg-Saron", 
		tracing = {"Sara"},
		triggers = {
			yell = "^The time to strike at the head of the beast",
		},
		onactivate = {
			leavecombat = true,
		},
		userdata = {
			portaltime = {78,90,loop = false},
		},
		onstart = {
			[1] = {
				{alert = "enragecd"},
			},
		},
		alerts = {
			lunaticgazewarn = {
				var = "lunaticgazewarn",
				varname = "Lunatic Gaze cast",
				type = "centerpopup",
				text = "Gaze: LOOK AWAY!",
				time = 4,
				color1 = "PURPLE",
				sound = "ALERT1",
			},
			brainlinkdur = {
				var = "brainlinkdur",
				varname = "Brain Link on self",
				type = "centerpopup",
				text = "Brain Link: YOU",
				time = 30,
				color1 = "BLUE",
				color2 = "INDIGO",
				sound = "ALERT3",
			},
			yoggsaronarrives = {
				var = "yoggsaronarrives",
				varname = "Yogg'Saron arrival",
				type = "centerpopup",
				text = "Yogg'Saron Arrives",
				time = 20,
				color1 = "GREY",
			},
			enragecd = {
				var = "enragecd",
				varname = "Enrage",
				type = "dropdown",
				text = "Enrage",
				time = 900,
				flashtime = 10,
				color1 = "RED",
			},
			portalcd = {
				var = "portalcd",
				varname = "Portal cooldown",
				type = "dropdown",
				text = "Next Portal",
				time = "<portaltime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "MAGENTA",
				color2 = "DCYAN",
			},
			weakeneddur = {
				var = "weakeneddur",
				varname = "Weakened duration",
				type = "centerpopup",
				text = "Weakened!",
				time = 45,
				flashtime = 10,
				color1 = "ORANGE",
				color2 = "YELLOW",
			},
			inducewarn = {
				var = "inducewarn",
				varname = "Induce Madness cast",
				type = "dropdown",
				text = "Induce Madness cast",
				time = 60,
				flashtime = 5,
				color1 = "BROWN",
				color2 = "MIDGREY",
			},
			squeezewarn = {
				var = "squeezewarn",
				varname = "Squeeze warning",
				type = "simple",
				text = "Squeeze: #5#",
				time = 1.5,
				color1 = "AQUA",
			},
			maladywarnself = {
				var = "maladywarn",
				varname = "Malady of the Mind warn",
				type = "simple",
				text = "Malady of the Mind: YOU!",
				time = 1.5,
				sound = "ALERT5",
				color1 = "GREEN",
			},
			maladywarnother = {
				var = "maladywarn",
				varname = "Malady of the Mind warn",
				type = "simple",
				text = "Malady of the Mind: #5#",
				time = 1.5,
				sound = "ALERT5",
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
			[3] = {
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Phase 2
					[1] = {
						{expect = {"#1#","find","^I am the lucid dream"}},
						{tracing = {"Yogg-Saron","Sara"}},
						{alert = "yoggsaronarrives"},
						{alert = "portalcd"},
					},
					-- Phase 3
					[2] = {
						{expect = {"#1#","find","^Look upon the true face"}},
						{quash = "inducewarn"},
						{quash = "portalcd"},
					},
				},
			},
			[4] = {
				type = "event",
				event = "EMOTE",
				execute = {
					-- Portal
					[1] = {
						{expect = {"#1#","find","^Portals open into Yogg-Saron"}},
						{alert = "inducewarn"},
						{alert = "portalcd"},
					},
					[2] = {
						{expect = {"#1#","find","^The Illusion shatters and a path"}},
						{quash = "inducewarn"},
						{alert = "weakeneddur"},
					},
				},
			},
			-- Squeeze
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64126,
				execute = {
					[1] = {
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "squeezewarn"},
					},
				},
			},
			-- Malady of the Mind
			[6] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63830,
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "maladywarnself"},
					},
					[2] = {
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "maladywarnother"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
