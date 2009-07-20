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
				33432, -- Leviathan MK II
				33350, -- Mimiron
				33651, -- VX-001
				33670, -- Aerial Command Unit
				33836, -- Bomb Bot
				34057, -- Assault Bot
				34147, -- Emergency Fire Bot
			},
		},
		onactivate = {
			tracing = {33432}, -- Leviathan Mk II
			combatstop = true,
		},
		userdata = {
			plasmablasttime = {14,30,loop = false},
			laserbarragetime = {30,44,loop = false},
			flametime = 6.5,
			phase = "1",
		},
		onstart = {
			-- Phase 1
			{
				{alert = "plasmablastcd"},
			},
			-- Hard mode activation
			{
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
				{
					{expect = {"<phase>","~=","4"}},
					{alert = "flamecd"},
					{scheduletimer = {"flames",27.5}},
				},
				{
					{expect = {"<phase>","==","4"}},
					{alert = "flamecd"},
					{scheduletimer = {"flames",18}},
				},
			},
			startbarragedur = {
				{
					{alert = "laserbarragedur"},
					{quash = "spinupwarn"},
				},
			},
			startbarragecd = {
				{
					{alert = "laserbarragecd"},
				},
			},
			startblastcd = {
				{
					{alert = "shockblastcd"},
				},
			},
			startfrostbombexplodes = {
				{
					{alert = "frostbombexplodes"},
				},
			},
			startplasmablastdur = {
				{
					{alert = "plasmablastdur"},
				},
			},
		},
		alerts = {
			flamesuppressantwarn = {
				type = "centerpopup",
				varname = format(L["%s Cast"],SN[64570]),
				text = format(L["%s Cast"],SN[64570]),
				time = 2,
				sound = "ALERT5",
				color1 = "TEAL",
			},
			flamesuppressantcd = {
				type = "dropdown",
				varname = format(L["%s Cooldown"],SN[64570]),
				text = format(L["%s Cooldown"],SN[64570]),
				time = 60,
				flashtime = 5,
				color1 = "INDIGO",
			},
			frostbombwarn = {
				type = "centerpopup",
				varname = format(L["%s Cast"],SN[64623]),
				text = format(L["%s Cast"],SN[64623]),
				time = 2,
				sound = "ALERT5",
				color1 = "BLUE",
			},
			frostbombexplodes = {
				type = "centerpopup",
				varname = format(L["%s Timer"],SN[64623]),
				text = format(L["%s Explodes"],SN[64623]).."!",
				time = 12,
				flashtime = 5,
				sound = "ALERT9",
				color1 = "BLUE",
				color2 = "WHITE",
				flashscreen = true,
			},
			flamecd = {
				type = "dropdown",
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
				varname = format(L["%s Cast"],SN[62997]),
				text = format(L["%s Cast"],SN[62997]),
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT5",
			},
			plasmablastdur = { 
				type = "centerpopup",
				varname = format(L["%s Duration"],SN[62997]),
				text = format(L["%s Duration"],SN[62997]),
				time = 6,
				color1 = "ORANGE",
			},
			plasmablastcd = {
				type = "dropdown",
				varname = format(L["%s Cooldown"],SN[62997]),
				text = format(L["%s Cooldown"],SN[62997]),
				time = "<plasmablasttime>",
				flashtime = 5,
				color1 = "ORANGE",
				color2 = "RED",
				sound = "ALERT2",
			},
			shockblastwarn = {
				varname = format(L["%s Cast"],SN[63631]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[63631]),
				time = 4,
				color1 = "MAGENTA",
				sound = "ALERT5",
			},
			--- VX-001
			laserbarragedur = {
				type = "centerpopup",
				varname = format(L["%s Duration"],L["Laser Barrage"]),
				text = format(L["%s Duration"],L["Laser Barrage"]),
				time = 10,
				color1 = "PURPLE",
				sound = "ALERT6",
			},
			laserbarragecd = {
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
				varname = format(L["%s Cast"],L["Spinning Up"]),
				type = "centerpopup",
				text = L["Spinning Up"].."!",
				time = 4,
				color1 = "WHITE",
				color2 = "RED",
				sound = "ALERT4",
				flashscreen = true,
			},
			weakeneddur = {
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
				varname = format(L["%s Timer"],L["Phase Two"]),
				type = "dropdown",
				text = format(L["%s Begins"],L["Phase Two"]),
				time = 40,
				flashtime = 10,
				color1 = "RED",
			},
			twotothree = {
				varname = format(L["%s Timer"],L["Phase Three"]),
				type = "dropdown",
				text = format(L["%s Begins"],L["Phase Three"]),
				time = 25,
				flashtime = 10,
				color1 = "RED",
			},
			threetofour = {
				varname = format(L["%s Timer"],L["Phase Four"]),
				type = "dropdown",
				text = format(L["%s Begins"],L["Phase Four"]),
				time = 25,
				flashtime = 10,
				color1 = "RED",
			},
			-- Hard Mode
			hardmodetimer = {
				varname = format(L["%s Timer"],L["Hard Mode"]),
				type = "dropdown",
				text = L["Raid Wipe"],
				time = 620,
				flashtime = 10,
				color1 = "BROWN",
			},
			-- Bomb bot
			bombbotwarn = {
				varname = format(L["%s Spawns"],L["Bomb Bot"]),
				type = "simple",
				text = format(L["%s Spawned"],L["Bomb Bot"]).."!",
				time = 5,
				sound = "ALERT8",
			},
		},
		events = {
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Transition from Phase 1 to Phase 2
					{
						{expect = {"#1#","find",L["^WONDERFUL! Positively"]}},
						{set = {phase = "2"}},
						{quash = "plasmablastcd"},
						{quash = "flamesuppressantcd"},
						{quash = "shockblastcd"},
						{canceltimer = "startblastcd"},
						{canceltimer = "startplasmablastdur"},
						{scheduletimer = {"startbarragecd",40}},
						{tracing = {33651}}, -- VX-001
						{alert = "onetotwo"},
					},
					-- Transition from Phase 2 to Phase 3
					{
						{expect = {"#1#","find",L["^Thank you, friends!"]}},
						{set = {phase = "3"}},
						{tracing = {33670}}, -- Aerial Command Unit
						{quash = "laserbarragecd"},
						{quash = "laserbarragedur"},
						{quash = "spinupwarn"},
						{canceltimer = "startbarragedur"},
						{canceltimer = "startbarragecd"},
						{canceltimer = "startfrostbombexplodes"},
						{alert = "twotothree"},
					},
					-- Transition from Phase 3 to Phase 4
					{
						{expect = {"#1#","find",L["^Preliminary testing phase complete"]}},
						{quash = "weakeneddur"},
						{set = {phase = "4"}},
						{set = {flametime = 18}},
						{tracing = {33432,33651,33670}}, -- Leviathan Mk II, VX-001, Aerial Command Unit
						{scheduletimer = {"startbarragecd",14}},
						{scheduletimer = {"startblastcd",25}},
						{alert = "threetofour"},
					},
				},
			},
			--- Phase 1 - Leviathan MKII
			-- Plasma Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62997,64529},
				execute = {
					{
						{alert = "plasmablastwarn"},
						{alert = "plasmablastcd"},
						{scheduletimer = {"startplasmablastdur",3}},
					},	
				},
			},
			-- Shock Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 63631,
				execute = {
					{
						{quash = "shockblastcd"},
						{alert = "shockblastwarn"},
						{scheduletimer = {"startblastcd",4}},
					},	
				},
			},
			--- Phase 2 - VX-001
			-- Spinning Up ->  Laser Barrage
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 63414,
				execute = {
					{
						{alert = "spinupwarn"},
						{scheduletimer = {"startbarragedur",4}},
						{scheduletimer = {"startbarragecd",14}},
					},
				},
			},
			-- Flame Suppressant
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64570,
				execute = {
					{
						{alert = "flamesuppressantwarn"},
						{alert = "flamesuppressantcd"},
					},
				},
			},
			-- Frost Bomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64623,
				execute = {
					{
						{alert = "frostbombwarn"},
						{scheduletimer = {"startfrostbombexplodes",2}},
					},
				},
			},
			-- Bomb Bot
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 63811,
				execute = {
					{
						{alert = "bombbotwarn"},
					},	
				},
			},
			-- Weakened
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = 64444,
				execute = {
					{
						{alert = "weakeneddur"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

