-- Proximity Mine cooldown. 30.5 seconds
do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "mimiron", 
		zone = L["Ulduar"], 
		name = L["Mimiron"], 
		triggers = {
			yell = {L["^We haven't much time, friends"],L["^Self%-destruct sequence initiated"]},
			scan = {
				L["Leviathan Mk II"],
				L["Mimiron"],
				L["VX-001"],
				L["Aerial Command Unit"],
				L["Bomb Bot"],
				L["Assault Bot"],
				L["Emergency Fire Bot"],
			},
		},
		onactivate = {
			tracing = {L["Leviathan Mk II"]},
			leavecombat = true,
		},
		userdata = {
			plasmablasttime = {14,30,loop = false},
			laserbarragetime = {30,44,loop = false},
			flametime = 6.5,
			phase = "1",
		},
		onstart = {
			-- Phase 1
			[1] = {
				{alert = "plasmablastcd"},
			},
			-- Hard mode activation
			[2] = {
				{expect = {"#1#","find",L["^Self%-destruct sequence initiated"]}},
				{alert = "hardmodetimer"},
				{alert = "flamesuppressantcd"},
				{alert = "flamecd"},
				{set = {flametime = 27.5}},
				{scheduletimer = {"flames",6.5}},
			},
		},
		timers = {
			flames = {
				[1] = {
					{expect = {"<phase>","~=","4"}},
					{alert = "flamecd"},
					{scheduletimer = {"flames",27.5}},
				},
				[2] = {
					{expect = {"<phase>","==","4"}},
					{alert = "flamecd"},
					{scheduletimer = {"flames",18}},
				},
			},
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
			startfrostbombexplodes = {
				[1] = {
					{alert = "frostbombexplodes"},
				},
			},
			startplasmablastdur = {
				[1] = {
					{alert = "plasmablastdur"},
				},
			},
		},
		alerts = {
			flamesuppressantwarn = {
				type = "centerpopup",
				var = "flamesuppressantwarn",
				varname = format(L["%s Cast"],SN[64570]),
				text = format(L["%s Cast"],SN[64570]),
				time = 2,
				sound = "ALERT5",
				color1 = "TEAL",
			},
			flamesuppressantcd = {
				type = "dropdown",
				var = "flamesuppressantcd",
				varname = format(L["%s Cooldown"],SN[64570]),
				text = format(L["%s Cooldown"],SN[64570]),
				time = 60,
				flashtime = 5,
				color1 = "INDIGO",
			},
			frostbombwarn = {
				type = "centerpopup",
				var = "frostbombwarn",
				varname = format(L["%s Cast"],SN[64623]),
				text = format(L["%s Cast"],SN[64623]),
				time = 2,
				sound = "ALERT5",
				color1 = "BLUE",
			},
			frostbombexplodes = {
				type = "centerpopup",
				var = "frostbombexplodes",
				varname = format(L["%s Timer"],SN[64623]),
				text = format(L["%s Explodes"],SN[64623]).."!",
				time = 12,
				flashtime = 5,
				sound = "ALERT9",
				color1 = "BLUE",
				color2 = "WHITE",
			},
			flamecd = {
				type = "dropdown",
				var = "flamecd",
				varname = format(L["%s Timer"],SN[15643]),
				text = format(L["Next %s Spawn"],SN[15643]),
				time = "<flametime>",
				flashtime = 5,
				sound = "ALERT1",
				color1 = "GREEN",
				color2 = "GREEN",
			},
			-- Leviathan MKII
			plasmablastwarn = { 
				type = "centerpopup",
				var = "plasmablastwarn",
				varname = format(L["%s Cast"],SN[62997]),
				text = format(L["%s Cast"],SN[62997]),
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT5",
			},
			plasmablastdur = { 
				type = "centerpopup",
				var = "plasmablastdur",
				varname = format(L["%s Duration"],SN[62997]),
				text = format(L["%s Duration"],SN[62997]),
				time = 6,
				color1 = "ORANGE",
			},
			plasmablastcd = {
				type = "dropdown",
				var = "plasmablastcd",
				varname = format(L["%s Cooldown"],SN[62997]),
				text = format(L["%s Cooldown"],SN[62997]),
				time = "<plasmablasttime>",
				flashtime = 5,
				color1 = "ORANGE",
				color2 = "RED",
				sound = "ALERT2",
			},
			shockblastwarn = {
				type = "centerpopup",
				var = "shockblastwarn",
				varname = format(L["%s Cast"],SN[63631]),
				text = format(L["%s Cast"],SN[63631]),
				time = 4,
				color1 = "MAGENTA",
				sound = "ALERT5",
			},
			--- VX-001
			laserbarragedur = {
				type = "centerpopup",
				var = "laserbarragedur",
				varname = format(L["%s Duration"],L["Laser Barrage"]),
				text = format(L["%s Duration"],L["Laser Barrage"]),
				time = 10,
				color1 = "PURPLE",
				sound = "ALERT6",
			},
			laserbarragecd = {
				var = "laserbarragecd",
				varname = format(L["%s Cooldown"],L["Laser Barrage"]),
				type = "dropdown",
				text = format(L["%s Cooldown"],L["Laser Barrage"]),
				time = "<laserbarragetime>",
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "YELLOW",
				sound = "ALERT3",
			},
			shockblastcd = {
				var = "shockblastcd",
				varname = format(L["%s Cooldown"],SN[63631]),
				type = "dropdown",
				text = format(L["Next %s"],SN[63631]),
				time = 30,
				flashtime = 5,
				color1 = "MAGENTA",
				color2 = "ORANGE",
				sound = "ALERT3",
			},
			spinupwarn = {
				var = "spinupwarn",
				varname = format(L["%s Cast"],L["Spinning Up"]),
				type = "centerpopup",
				text = L["Spinning Up"].."!",
				time = 4,
				color1 = "WHITE",
				color2 = "RED",
				sound = "ALERT4",
			},
			weakeneddur = {
				var = "weakeneddur",
				varname = format(L["%s Duration"],L["Weakened"]),
				type = "centerpopup",
				text = L["Weakened"],
				time = 15,
				flashtime = 15,
				color1 = "GREY",
				color2 = "GREY",
				sound = "ALERT7",
			},
			--- Phase Changes
			onetotwo = {
				var = "onetotwo",
				varname = format(L["%s Timer"],L["Phase Two"]),
				type = "dropdown",
				text = format(L["%s Begins"],L["Phase Two"]),
				time = 40,
				flashtime = 10,
			},
			twotothree = {
				var = "twotothree",
				varname = format(L["%s Timer"],L["Phase Three"]),
				type = "dropdown",
				text = format(L["%s Begins"],L["Phase Three"]),
				time = 25,
				flashtime = 10,
			},
			threetofour = {
				var = "threetofour",
				varname = format(L["%s Timer"],L["Phase Four"]),
				type = "dropdown",
				text = format(L["%s Begins"],L["Phase Four"]),
				time = 25,
				flashtime = 10,
			},
			-- Hard Mode
			hardmodetimer = {
				var = "hardmodetimer",
				varname = format(L["%s Timer"],L["Hard Mode"]),
				type = "dropdown",
				text = L["Raid Wipe"],
				time = 620,
				flashtime = 10,
				color1 = "BROWN",
			},
			-- Bomb bot
			bombbotwarn = {
				var = "bombbotwarn",
				varname = format(L["%s Spawns"],L["Bomb Bot"]),
				type = "simple",
				text = format(L["%s Spawned"],L["Bomb Bot"]).."!",
				time = 5,
				sound = "ALERT8",
			},
		},
		events = {
			[1] = {
				type = "event",
				event = "YELL",
				execute = {
					-- Transition from Phase 1 to Phase 2
					[1] = {
						{expect = {"#1#","find",L["^WONDERFUL! Positively"]}},
						{set = {phase = "2"}},
						{quash = "plasmablastcd"},
						{quash = "flamesuppressantcd"},
						{quash = "shockblastcd"},
						{canceltimer = "startblastcd"},
						{canceltimer = "startplasmablastdur"},
						{scheduletimer = {"startbarragecd",40}},
						{tracing = {L["VX-001"]}},
						{alert = "onetotwo"},
					},
					-- Transition from Phase 2 to Phase 3
					[2] = {
						{expect = {"#1#","find",L["^Thank you, friends!"]}},
						{set = {phase = "3"}},
						{tracing = {L["Aerial Command Unit"]}},
						{quash = "laserbarragecd"},
						{quash = "laserbarragedur"},
						{quash = "spinupwarn"},
						{canceltimer = "startbarragedur"},
						{canceltimer = "startbarragecd"},
						{canceltimer = "startfrostbombexplodes"},
						{alert = "twotothree"},
					},
					-- Transition from Phase 3 to Phase 4
					[3] = {
						{expect = {"#1#","find",L["^Preliminary testing phase complete"]}},
						{quash = "weakeneddur"},
						{set = {phase = "4"}},
						{set = {flametime = 18}},
						{tracing = {L["Leviathan Mk II"],L["VX-001"],L["Aerial Command Unit"]}},
						{scheduletimer = {"startbarragecd",14}},
						{scheduletimer = {"startblastcd",25}},
						{alert = "threetofour"},
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
						{scheduletimer = {"startplasmablastdur",3}},
					},	
				},
			},
			-- Shock Blast
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 63631,
				execute = {
					[1] = {
						{quash = "shockblastcd"},
						{alert = "shockblastwarn"},
						{scheduletimer = {"startblastcd",4}},
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
						{scheduletimer = {"startbarragecd",14}},
					},
				},
			},
			-- Flame Suppressant
			[5] = {
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
			[6] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64623,
				execute = {
					[1] = {
						{alert = "frostbombwarn"},
						{scheduletimer = {"startfrostbombexplodes",2}},
					},
				},
			},
			-- Bomb Bot
			[7] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 63811,
				execute = {
					[1] = {
						{alert = "bombbotwarn"},
					},	
				},
			},
			-- Weakened
			[8] = {
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = 64444,
				execute = {
					[1] = {
						{alert = "weakeneddur"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

