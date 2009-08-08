do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = "$Rev$",
		key = "malygos", 
		zone = L["The Eye of Eternity"], 
		category = L["Northrend"],
		name = L["Malygos"], 
		triggers = {
			scan = {
				28859, -- Malygos
				30245, -- Nexus Lord
				30249, -- Scion of Eternity
				30084, -- Power Spark
			}, 
		},
		onactivate = {
			tracing = {28859}, -- Malygos
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = { 
			phase = 1,
			vortexcd = {29,59,loop=false},
		},
		onstart = {
			{
				{alert = "vortexcd"},
			}
		},
		alerts = {
			vortexcd = {
				varname = format(L["%s Cooldown"],SN[56105]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],SN[56105]),
				time = "<vortexcd>", 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "BLUE", 
				icon = ST[56105],
			},
			staticfieldwarn = {
				varname = format(L["%s Warning"],SN[57430]),
				type = "simple", 
				text = format("%s! %s!",format(L["%s Casted"],SN[57430]),L["MOVE"]),
				time = 1.5, 
				sound = "ALERT2", 
				color1 = "YELLOW",
				icon = ST[57430],
			},
			surgewarn = { 
				varname = format(L["%s on self"],L["Surge"]),
				type = "centerpopup", 
				text = format("%s: %s! %s!",L["Surge"],L["YOU"],L["CAREFUL"]),
				time = 3,
				flashtime = 3,
				sound = "ALERT1", 
				throttle = 5,
				color1 = "MAGENTA",
				icon = ST[56505],
			},
			presurgewarn = { 
				varname = format(L["%s Warning"],L["Surge"]), 
				type = "simple", 
				text = format("%s: %s! %s!",L["Surge"],L["YOU"],L["SOON"]),
				time = 1.5, 
				sound = "ALERT5", 
				color1 = "TURQUOISE",
				flashscreen = true,
				icon = ST[56505],
			},
			deepbreath = {
				varname = format(L["%s Cooldown"],L["Deep Breath"]), 
				type = "dropdown", 
				text = format(L["Next %s"],L["Deep Breath"]),
				time = 92, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "ORANGE", 
				icon = ST[57432],
			},
			vortexdur = {
				varname = format(L["%s Duration"],SN[56105]),
				type = "centerpopup", 
				text = format(L["%s Duration"],SN[56105]),
				time = 10, 
				sound = "ALERT1", 
				color1 = "BLUE", 
				icon = ST[56105],
			},
			powerspark = {
				varname = format(L["%s Spawns"],L["Power Spark"]),
				type = "dropdown", 
				text = format(L["Next %s"],L["Power Spark"]),
				time = 17, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "WHITE", 
				icon = ST[56152],
			},
		},
		events = {
			-- Vortex/Power spark
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 56105, 
				execute = {
					{
						{alert = "vortexdur"}, 
						{alert = "vortexcd"}, 
						{quash = "powerspark"},
						{alert = "powerspark"},
					},
				},
			},
			-- Surge
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {57407, 60936}, 
				execute = {
					{
						{expect = {"#4#","==","&vehicleguid&"}},
						{quash = "presurgewarn"},
						{alert = "surgewarn"},
					},
				},
			},
			-- Static field
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 57430, 
				execute = {
					{
						{alert = "staticfieldwarn"},
					},
				},
			},
			-- Yells
			{
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					{
						{expect = {"#1#","find",L["I had hoped to end your lives quickly"]}},
						{quash = "vortexdur"},
						{quash = "vortexcd"},
						{quash = "powerspark"},
						{set = {phase = 2}},
						{alert = "deepbreath"},
					},
					{
						{expect = {"#1#", "find", L["ENOUGH!"]}},
						{quash = "deepbreath"},
						{set = {phase = 3}},
					},
				},
			},
			-- Emotes
			{
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					{
						{expect = {"<phase>","==","1"}},
						{quash = "powerspark"},
						{alert = "powerspark"},
					},
					{
						{expect = {"<phase>","==","2"}},
						{alert = "deepbreath"},
					},
				},
			},
			-- Whispers
			{
				type = "event",
				event = "WHISPER",
				execute = {
					{
						{expect = {"#1#","find",L["fixes his eyes on you!$"]}},
						{alert = "presurgewarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
