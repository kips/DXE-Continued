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
			weakenedtimer = 60,
		},
		onstart = {
			[1] = {
				{alert = "enragecd"},
			},
		},
		timers = {
			decrweakenedtimer = {
				[1] = {
					{set = {weakenedtimer = "DECR|1"}},
					{scheduletimer = {"decrweakenedtimer",1}},
				},
			},
		},
		alerts = {
			lunaticgazewarn = {
				var = "lunaticgazewarn",
				varname = "Lunatic Gaze cast",
				type = "centerpopup",
				text = "Lunatic Gaze! LOOK AWAY!",
				time = 4,
				color1 = "PURPLE",
				sound = "ALERT1",
			},
			lunaticgazecd = {
				var = "lunaticgazecd",
				varname = "Lunatic Gaze cooldown",
				type = "dropdown",
				text = "Lunatic Gaze Cooldown",
				time = 11, -- It could be lower
				flashtime = 5,
				color1 = "GREEN",
				color2 = "YELLOW",
				sound = "ALERT2",
			},
			brainlinkdur = {
				var = "brainlinkdur",
				varname = "Brain Link on self",
				type = "centerpopup",
				text = "Brain Link: YOU",
				time = 30,
				flashtime = 30,
				color1 = "BLUE",
				sound = "ALERT3",
			},
			yoggsaronarrives = {
				var = "yoggsaronarrives",
				varname = "Yogg-Saron arrival",
				type = "centerpopup",
				text = "Yogg'Saron Arrives",
				time = 14,
				flashtime = 14,
				color1 = "PEACH",
				color2 = "PEACH",
				sound = "ALERT1",
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
			weakenedwarn = {
				var = "weakenedwarn",
				varname = "Weakened warning",
				type = "centerpopup",
				text = "Weakened!",
				time = "<weakenedtimer>",
				color1 = "ORANGE",
			},
			inducewarn = {
				var = "inducewarn",
				varname = "Induce Madness cast",
				type = "dropdown",
				text = "Induce Madness Cast",
				time = 60,
				flashtime = 5,
				color1 = "BROWN",
				color2 = "MIDGREY",
				sound = "ALERT6",
			},
			squeezewarn = {
				var = "squeezewarn",
				varname = "Squeeze warning",
				type = "simple",
				text = "Squeeze: #5#",
				time = 1.5,
				color1 = "YELLOW",
				sound = "ALERT7",
			},
			maladywarn = {
				var = "maladywarn",
				varname = "Malady of the Mind warn",
				type = "simple",
				text = "Malady: #5#! MOVE AWAY!",
				time = 1.5,
				sound = "ALERT5",
				color1 = "GREEN",
			},
			empoweringshadowscd = {
				var = "empoweringshadowscd",
				varname = "empoweringshadowscd",
				type = "dropdown",
				text = "Empowering Shadows Cooldown",
				time = 45,
				flashtime = 5,
				sound = "ALERT8",
				color1 = "INDIGO",
				color2 = "RED",
			},
			-- If it's already spawning and weakened ends before it's scheduled to spawn then it spawns on time
			-- If weakened ends after it's scheduled to spawn then it spawns 1s after weakened ends
			-- Implement timeleft|alertname so we don't have to do ugly scheduling
			--[[
			crushertentaclespawn = {
			},
			]]
		},
		events = {
			-- Lunatic Gaze
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64163,64164},
				execute = {
					[1] = {
						{alert = "lunaticgazewarn"},
						{alert = "lunaticgazecd"},
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
						{tracing = {"Yogg-Saron","Brain of Yogg-Saron"}},
						{alert = "yoggsaronarrives"},
						{alert = "portalcd"},
					},
					-- Phase 3
					[2] = {
						{tracing = {"Yogg-Saron"}},
						{expect = {"#1#","find","^Look upon the true face"}},
						{canceltimer = "decrweakenedtimer"},
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
						{expect = {"#1#","find","^Portals open"}},
						{alert = "portalcd"},
					},
					-- Weakened
					[2] = {
						{expect = {"#1#","find","^The illusion shatters and a path"}},
						{quash = "inducewarn"},
						{alert = "weakenedwarn"},
					},
					-- Empowering Shadows
					[3] = {
						{expect = {"#1#","find","prepares to unleash Empowering Shadows!$"}},
						{alert = "empoweringshadowscd"},
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
						{expect = {"#4#","~=","&playerguid&"}},
						{proximitycheck = {"#5#",18}},
						{alert = "maladywarn"},
					},
				},
			},
			-- Induce Madness
			[7] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64059,
				execute = {
					[1] = {
						{alert = "inducewarn"},
						{set = {weakenedtimer = 60}},
						{scheduletimer = {"decrweakenedtimer",1}},
					},
				},
			},
			-- Brain Link removal
			[8] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {63802,63803,63804},
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "brainlinkdur"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
