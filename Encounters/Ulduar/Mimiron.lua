do
	local data = {
		version = "$Rev$",
		key = "mimiron", 
		zone = "Ulduar", 
		name = "Mimiron", 
		title = "Mimiron", 
		tracing = {"Leviathan Mk II"},
		triggers = {
			yell = {"^We haven't much time, friends","^Self%-destruct sequence"},
			scan = {"Leviathan Mk II","Mimiron"},
		},
		onactivate = {
			leavecombat = true,
		},
		userdata = {
			plasmablasttime = {14,30,loop = false},
		},
		onstart = {
			-- Phase 1
			[1] = {
				{alert = "plasmablastcd"},
				{alert = "flamesuppressantcd"},
			},
		},
		alerts = {
			flamesuppressantwarn = {
				type = "centerpopup",
				var = "flamesuppressantwarn",
				varname = "Flame Suppressant cast",
				text = "Flame Suppressant cast",
				time = 2,
				sound = "ALERT5",
				color1 = "TEAL",
			},
			flamesuppressantcd = {
				type = "dropdown",
				var = "flamesuppressantcd",
				varname = "Flame Suppressant cooldown",
				text = "Flame Suppressant Cooldown",
				time = 61,
				flashtime = 5,
				color1 = "INDIGO",
			},
			frostbombwarn = {
				type = "centerpopup",
				var = "frostbombwarn",
				varname = "Frost Bomb cast",
				text = "Frost Bomb cast",
				time = 2,
				sound = "ALERT5",
				color1 = "BLUE",
			},
			--[[
			frostbombcd = {
				type = "dropdown",
				var = "frostbombcd",
				varname = "Frost Bomb cooldown",
				text = "Frost Bomb cooldown",
				time = 2,
				sound = "ALERT1",
				color1 = "BLUE",
				color2 = "WHITE",
			},
			]]
			-- Leviathan MKII
			plasmablastwarn = { 
				type = "centerpopup",
				var = "plasmablastwarn",
				varname = "Plasma Blast warning",
				text = "Plasma Blast Cast",
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT5",
			},
			plasmablastcd = {
				type = "dropdown",
				var = "plasmablastcd",
				varname = "Plasma Blast cooldown",
				text = "Plasma Blast Cooldown",
				time = "<plasmablasttime>",
				flashtime = 5,
				color1 = "ORANGE",
				color2 = "RED",
				sound = "ALERT2",
			},
			shockblastwarn = {
				type = "centerpopup",
				var = "shockblastwarn",
				varname = "Shock Blast cast",
				text = "Shock Blast Cast",
				time = 4,
				color1 = "MAGENTA",
				sound = "ALERT5",
			},
			--- VX-001
			laserbarragedur = {
				type = "centerpopup",
				var = "laserbarragedur",
				varname = "Laser Barrage duration",
				text = "Laser Barrage Duration",
				time = 10,
				color1 = "PURPLE",
				sound = "ALERT6",
			},
			laserbarragecd = {
				var = "laserbarragecd",
				varname = "Laser Barrage cooldown",
				type = "dropdown",
				text = "Next Laser Barrage",
				time = 41,
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "YELLOW",
				sound = "ALERT3",
			},
			shockblastcd = {
				var = "shockblastcd",
				varname = "Shock Blast cooldown",
				type = "dropdown",
				text = "Next Shock Blast",
				time = 25,
				flashtime = 5,
				color1 = "MAGENTA",
				color2 = "ORANGE",
				sound = "ALERT3",
			},
			spinupwarn = {
				var = "spinupwarn",
				varname = "Spin Up warning",
				type = "centerpopup",
				text = "Spinning Up!",
				time = 4,
				color1 = "WHITE",
				color2 = "RED",
				sound = "ALERT4",
			},
			--- Leviathan MK II and VX-001
			rocketstrikewarn = {
				var = "rocketstrikewarn",
				varname = "Rocket Strike warning",
				type = "simple",
				text = "Target Circle spawned. Avoid it!",
				time = 1.5,
				sound = "ALERT7",
			},
			--- Phase Changes
			onetotwo = {
				var = "onetotwo",
				varname = "Phase 1 to Phase 2 timer",
				type = "dropdown",
				text = "Phase Two Begins",
				time = 40,
				flashtime = 10,
			},
			twotothree = {
				var = "twotothree",
				varname = "Phase 2 to Phase 3 timer",
				type = "dropdown",
				text = "Phase Three Begins",
				time = 25,
				flashtime = 10,
			},
			threetofour = {
				var = "threetofour",
				varname = "Phase 3 to Phase 4 timer",
				type = "dropdown",
				text = "Phase Four Begins",
				time = 25,
				flashtime = 10,
			},
			-- Hard Mode
			hardmodetimer = {
				var = "hardmodetimer",
				varname = "Hard mode timer",
				type = "dropdown",
				text = "Raid Wipe",
				time = 600,
				flashtime = 10,
				color1 = "BROWN",
			},
			-- Bomb bot
			bombbotwarn = {
				var = "bombbotwarn",
				varname = "Bomb bot warning",
				type = "simple",
				text = "Bomb bot spawned",
				time = 5,
			},
		},
		timers = {
			startbarragedur = {
				[1] = {
					{alert = "laserbarragedur"},
					{quash = "spinupwarn"},
				},
			},
			startbarragecd = {
				[1] = {
					{alert = "laserbarragecd"},
				},
			},
			startblastcd = {
				[1] = {
					{alert = "shockblastcd"},
				},
			},
		},
		events = {
			[1] = {
				type = "event",
				event = "YELL",
				execute = {
					-- Transition from Phase 1 to Phase 2
					[1] = {
						{expect = {"#1#","find","^WONDERFUL! Positively"}},
						{quash = "plasmablastcd"},
						{quash = "flamesuppressantcd"},
						{tracing = {"VX-001"}},
						{alert = "onetotwo"},
					},
					-- Transition from Phase 2 to Phase 3
					[2] = {
						{expect = {"#1#","find","^Thank you, friends!"}},
						{tracing = {"Aerial Command Unit"}},
						{quash = "laserbarragecd"},
						{quash = "laserbarragedur"},
						{quash = "spinupwarn"},
						{canceltimer = "startbarragedur"},
						{canceltimer = "startbarragecd"},
						{alert = "twotothree"},
					},
					-- Transition from Phase 3 to Phase 4
					[3] = {
						{expect = {"#1#","find","^Preliminary testing phase complete"}},
						{tracing = {"Leviathan Mk II","VX-001","Aerial Command Unit"}},
						{scheduletimer = {"startbarragecd",9}},
						{scheduletimer = {"startblastcd",25}},
						{alert = "threetofour"},
					},
					-- Hard mode activated
					[4] = {
						{expect = {"#1#","find","^Self%-destruct sequence initiated"}},
						{alert = "hardmodetimer"},
					},
				},
			},
			--- Phase 1 - Leviathan MKII
			-- Plasma Blast
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62997,64529},
				execute = {
					[1] = {
						{alert = "plasmablastwarn"},
						{alert = "plasmablastcd"},
					},	
				},
			},
			-- Shock Blast
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 63631, -- TODO: Add heroic spellid
				execute = {
					[1] = {
						{alert = "shockblastwarn"},
						{scheduletimer = {"startblastcd",10}},
					},	
				},
			},
			--- Phase 2 - VX-001
			-- Spinning Up ->  Laser Barrage
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 63414,
				execute = {
					[1] = {
						{alert = "spinupwarn"},
						{scheduletimer = {"startbarragedur",4}},
						{scheduletimer = {"startbarragecd",19}},
					},
				},
			},
			-- Rocket Strike
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {65034,64402,63681,63036,63041}, -- TODO: Remove unnecessary spellids
				execute = {
					[1] = {
						{alert = "rocketstrikewarn"},
					},
				},
			},
			--- Phase 3 - Aerial Command Unit
			-- Possible additions:
				-- Spawn messages
				-- Plasma Ball
			--- Unknown - Are these even in the fight?
			-- Possibly hard mode additional abilities
			-- Flame Suppressant
			[6] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64570,
				execute = {
					[1] = {
						{alert = "flamesuppressantwarn"},
						{alert = "flamesuppressantcd"},
					},
				},
			},
			-- Frost Bomb
			[7] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64623,
				execute = {
					[1] = {
						{alert = "frostbombwarn"},
						--{alert = "frostbombcd"},
					},
				},
			},
			-- Bomb Bot
			[8] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 63811,
				execute = {
					[1] = {
						{alert = "bombbotwarn"},
					},	
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

