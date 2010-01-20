-- Proximity Mine cooldown. 30.5 seconds
do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 313,
		key = "mimiron", 
		zone = L.zone["Ulduar"], 
		name = L.npc_ulduar["Mimiron"], 
		triggers = {
			yell = {L.chat_ulduar["^We haven't much time, friends"],L.chat_ulduar["^Self%-destruct sequence initiated"]},
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
			defeat = L.chat_ulduar["^It would appear that I've made a slight miscalculation"],
		},
		userdata = {
			plasmablasttime = {14,30,loop = false, type = "series"},
			laserbarragetime = {30,44,loop = false, type = "series"},
			flametime = 6.5,
			phase = "1",
		},
		onstart = {
			-- Phase 1
			{
				"alert","plasmablastcd",
			},
			-- Hard mode activation
			{
				"expect",{"#1#","find",L.chat_ulduar["^Self%-destruct sequence initiated"]},
				"alert","hardmodecd",
				"alert","flamesuppressantcd",
				"alert","flamecd",
				"set",{flametime = 27.5},
				"scheduletimer",{"flames",6.5},
			},
		},
		windows = {
			proxwindow = true,
		},
		timers = {
			flames = {
				{
					"expect",{"<phase>","~=","4"},
					"alert","flamecd",
					"scheduletimer",{"flames",27.5},
				},
				{
					"expect",{"<phase>","==","4"},
					"alert","flamecd",
					"scheduletimer",{"flames",18},
				},
			},
			startbarragedur = {
				{
					"alert","laserbarragedur",
					"quash","spinupwarn",
				},
			},
			startbarragecd = {
				{
					"alert","laserbarragecd",
				},
			},
			startblastcd = {
				{
					"alert","shockblastcd",
				},
			},
			startfrostbombexplodes = {
				{
					"alert","frostbombexplodeswarn",
				},
			},
			startplasmablastdur = {
				{
					"alert","plasmablastdur",
				},
			},
		},
		alerts = {
			flamesuppressantwarn = {
				type = "centerpopup",
				varname = format(L.alert["%s Casting"],SN[64570]),
				text = format(L.alert["%s Casting"],SN[64570]),
				time = 2,
				sound = "ALERT5",
				color1 = "TEAL",
				icon = ST[64570],
			},
			flamesuppressantcd = {
				type = "dropdown",
				varname = format(L.alert["%s Cooldown"],SN[64570]),
				text = format(L.alert["%s Cooldown"],SN[64570]),
				time = 60,
				flashtime = 5,
				color1 = "INDIGO",
				icon = ST[64570],
			},
			frostbombwarn = {
				type = "centerpopup",
				varname = format(L.alert["%s Casting"],SN[64623]),
				text = format(L.alert["%s Casting"],SN[64623]),
				time = 2,
				sound = "ALERT5",
				color1 = "BLUE",
				icon = ST[64623],
			},
			frostbombexplodeswarn = {
				type = "centerpopup",
				varname = format(L.alert["%s Timer"],SN[64623]),
				text = format(L.alert["%s Explodes"],SN[64623]).."!",
				time = 12,
				flashtime = 5,
				sound = "ALERT9",
				color1 = "BLUE",
				color2 = "WHITE",
				flashscreen = true,
				icon = ST[64623],
			},
			flamecd = {
				type = "dropdown",
				varname = format(L.alert["%s Timer"],SN[15643]),
				text = format(L.alert["Next %s Spawn"],SN[15643]),
				time = "<flametime>",
				flashtime = 5,
				sound = "ALERT1",
				color1 = "GREEN",
				color2 = "GREEN",
				icon = ST[22436],
			},
			-- Leviathan MKII
			plasmablastwarn = { 
				type = "centerpopup",
				varname = format(L.alert["%s Casting"],SN[62997]),
				text = format(L.alert["%s Casting"],SN[62997]),
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT5",
				icon = ST[62997],
			},
			plasmablastdur = { 
				type = "centerpopup",
				varname = format(L.alert["%s Duration"],SN[62997]),
				text = format(L.alert["%s Duration"],SN[62997]),
				time = 6,
				color1 = "ORANGE",
				icon = ST[62997],
			},
			plasmablastcd = {
				type = "dropdown",
				varname = format(L.alert["%s Cooldown"],SN[62997]),
				text = format(L.alert["%s Cooldown"],SN[62997]),
				time = "<plasmablasttime>",
				flashtime = 5,
				color1 = "ORANGE",
				color2 = "RED",
				sound = "ALERT2",
				icon = ST[62997],
			},
			shockblastwarn = {
				varname = format(L.alert["%s Casting"],SN[63631]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[63631]),
				time = 4,
				color1 = "MAGENTA",
				sound = "ALERT5",
				icon = ST[63631],
			},
			--- VX-001
			laserbarragedur = {
				type = "centerpopup",
				varname = format(L.alert["%s Duration"],L.alert["Laser Barrage"]),
				text = format(L.alert["%s Duration"],L.alert["Laser Barrage"]),
				time = 10,
				color1 = "PURPLE",
				sound = "ALERT6",
				icon = ST[63293],
			},
			laserbarragecd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Laser Barrage"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Laser Barrage"]),
				time = "<laserbarragetime>",
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "YELLOW",
				sound = "ALERT3",
				icon = ST[63293],
			},
			shockblastcd = {
				varname = format(L.alert["%s Cooldown"],SN[63631]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[63631]),
				time = 30,
				flashtime = 5,
				color1 = "MAGENTA",
				color2 = "ORANGE",
				sound = "ALERT3",
				icon = ST[63631],
			},
			spinupwarn = {
				varname = format(L.alert["%s Casting"],SN[63414]),
				type = "centerpopup",
				text = SN[63414].."!",
				time = 4,
				color1 = "WHITE",
				color2 = "RED",
				sound = "ALERT4",
				flashscreen = true,
				icon = ST[64385],
			},
			weakeneddur = {
				varname = format(L.alert["%s Duration"],L.alert["Weakened"]),
				type = "centerpopup",
				text = L.alert["Weakened"],
				time = 15,
				flashtime = 15,
				color1 = "GREY",
				color2 = "GREY",
				sound = "ALERT7",
				icon = ST[64436],
			},
			--- Phase Changes
			onetotwocd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Two"]),
				type = "dropdown",
				text = format(L.alert["%s Begins"],L.alert["Phase Two"]),
				time = 40,
				flashtime = 10,
				color1 = "RED",
				icon = ST[3648],
			},
			twotothreecd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Three"]),
				type = "dropdown",
				text = format(L.alert["%s Begins"],L.alert["Phase Three"]),
				time = 25,
				flashtime = 10,
				color1 = "RED",
				icon = ST[3648],
			},
			threetofourcd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Four"]),
				type = "dropdown",
				text = format(L.alert["%s Begins"],L.alert["Phase Four"]),
				time = 25,
				flashtime = 10,
				color1 = "RED",
				icon = ST[3648],
			},
			-- Hard Mode
			hardmodecd = {
				varname = format(L.alert["%s Timer"],L.alert["Hard Mode"]),
				type = "dropdown",
				text = L.alert["Raid Wipe"],
				time = 620,
				flashtime = 10,
				color1 = "BROWN",
				icon = ST[20573],
			},
			-- Bomb bot
			bombbotwarn = {
				varname = format(L.alert["%s Spawns"],L.npc_ulduar["Bomb Bot"]),
				type = "simple",
				text = format(L.alert["%s Spawned"],L.npc_ulduar["Bomb Bot"]).."!",
				time = 5,
				sound = "ALERT8",
				icon = ST[15048],
			},
		},
		events = {
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Transition from Phase 1 to Phase 2
					{
						"expect",{"#1#","find",L.chat_ulduar["^WONDERFUL! Positively"]},
						"set",{phase = "2"},
						"quash","plasmablastcd",
						"quash","flamesuppressantcd",
						"quash","shockblastcd",
						"canceltimer","startblastcd",
						"canceltimer","startplasmablastdur",
						"scheduletimer",{"startbarragecd",40},
						"tracing",{33651}, -- VX-001
						"alert","onetotwocd",
					},
					-- Transition from Phase 2 to Phase 3
					{
						"expect",{"#1#","find",L.chat_ulduar["^Thank you, friends!"]},
						"set",{phase = "3"},
						"tracing",{33670}, -- Aerial Command Unit
						"quash","laserbarragecd",
						"quash","laserbarragedur",
						"quash","spinupwarn",
						"canceltimer","startbarragedur",
						"canceltimer","startbarragecd",
						"canceltimer","startfrostbombexplodes",
						"alert","twotothreecd",
					},
					-- Transition from Phase 3 to Phase 4
					{
						"expect",{"#1#","find",L.chat_ulduar["^Preliminary testing phase complete"]},
						"quash","weakeneddur",
						"set",{phase = "4"},
						"set",{flametime = 18},
						"tracing",{33432,33651,33670}, -- Leviathan Mk II, VX-001, Aerial Command Unit
						"scheduletimer",{"startbarragecd",14},
						"scheduletimer",{"startblastcd",25},
						"alert","threetofourcd",
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
						"alert","plasmablastwarn",
						"alert","plasmablastcd",
						"scheduletimer",{"startplasmablastdur",3},
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
						"quash","shockblastcd",
						"alert","shockblastwarn",
						"scheduletimer",{"startblastcd",4},
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
						"alert","spinupwarn",
						"scheduletimer",{"startbarragedur",4},
						"scheduletimer",{"startbarragecd",14},
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
						"alert","flamesuppressantwarn",
						"alert","flamesuppressantcd",
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
						"alert","frostbombwarn",
						"scheduletimer",{"startfrostbombexplodes",2},
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
						"alert","bombbotwarn",
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
						"alert","weakeneddur",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

