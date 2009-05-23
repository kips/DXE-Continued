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
			crushertime = 14,
			allowcrusher = 1,
			phase = "1",
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
				color2 = "MAGENTA",
			},
			weakeneddur = {
				var = "weakeneddur",
				varname = "Weakened duration",
				type = "centerpopup",
				text = "Weakened!",
				time = "&timeleft|inducewarn&",
				flashtime = 5,
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
				varname = "Empowering Shadows cooldown",
				type = "dropdown",
				text = "Empowering Shadows Cooldown",
				time = 45, 
				flashtime = 5,
				sound = "ALERT8",
				color1 = "INDIGO",
				color2 = "RED",
			},
			crushertentaclespawn = {
				var = "crushertentaclespawn",
				varname = "Crusher Tentacle spawn",
				type = "dropdown",
				text = "Crusher Tentacle Spawns",
				time = "<crushertime>",
				flashtime = 7,
				color1 = "DCYAN",
				color2 = "INDIGO",
			},
		},
		-- TODO
		-- Mind Control warning
		-- Guardian Spawns
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
						{alert = "portalcd"},
						{alert = "crushertentaclespawn"},
						{set = {phase = "2"}},
					},
					-- Phase 3
					[2] = {
						{tracing = {"Yogg-Saron"}},
						{expect = {"#1#","find","^Look upon the true face"}},
						{quash = "crushertentaclespawn"},
						{quash = "inducewarn"},
						{quash = "portalcd"},
						{set = {phase = "3"}},
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
						{alert = "weakeneddur"},
						{quash = "inducewarn"},

						{expect = {"&timeleft|weakeneddur&",">","&timeleft|crushertentaclespawn&"}},
						{set = {crushertime = "&timeleft|weakeneddur|1&"}},
						{quash = "crushertentaclespawn"},
						{alert = "crushertentaclespawn"},
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
			-- Crusher Tentacle spawn
			[9] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64144,
				execute = {
					[1] = {
						-- Crusher tentacle could erupt while it's active
						{expect = {"&timeleft|crushertentaclespawn&","<","0.5"}},
						{expect = {"<phase>","==","2"}},
						{set = {crushertime = 50}},
						{quash = "crushertentaclespawn"},
						{alert = "crushertentaclespawn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
