do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 299,
		key = "malygos", 
		zone = L.zone["The Eye of Eternity"], 
		category = L.zone["Northrend"],
		name = L.npc_northrend["Malygos"], 
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
			defeat = 28859,
		},
		userdata = { 
			phase = 1,
			vortexcd = {29,59,loop=false},
		},
		onstart = {
			{
				"alert","vortexcd",
			}
		},
		alerts = {
			vortexcd = {
				varname = format(L.alerts["%s Cooldown"],SN[56105]),
				type = "dropdown", 
				text = format(L.alerts["%s Cooldown"],SN[56105]),
				time = "<vortexcd>", 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "BLUE", 
				icon = ST[56105],
			},
			staticfieldwarn = {
				varname = format(L.alerts["%s Warning"],SN[57430]),
				type = "simple", 
				text = format("%s! %s!",format(L.alerts["%s Casted"],SN[57430]),L.alerts["MOVE"]),
				time = 1.5, 
				sound = "ALERT2", 
				color1 = "YELLOW",
				icon = ST[57430],
			},
			surgewarn = { 
				varname = format(L.alerts["%s on self"],L.alerts["Surge"]),
				type = "centerpopup", 
				text = format("%s: %s! %s!",L.alerts["Surge"],L.alerts["YOU"],L.alerts["CAREFUL"]),
				time = 3,
				flashtime = 3,
				sound = "ALERT1", 
				throttle = 5,
				color1 = "MAGENTA",
				icon = ST[56505],
			},
			presurgewarn = { 
				varname = format(L.alerts["%s Warning"],L.alerts["Surge"]), 
				type = "simple", 
				text = format("%s: %s! %s!",L.alerts["Surge"],L.alerts["YOU"],L.alerts["SOON"]),
				time = 1.5, 
				sound = "ALERT5", 
				color1 = "TURQUOISE",
				flashscreen = true,
				icon = ST[56505],
			},
			deepbreathwarn = {
				varname = format(L.alerts["%s Cooldown"],L.alerts["Deep Breath"]), 
				type = "dropdown", 
				text = format(L.alerts["Next %s"],L.alerts["Deep Breath"]),
				time = 92, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "ORANGE", 
				icon = ST[57432],
			},
			vortexdur = {
				varname = format(L.alerts["%s Duration"],SN[56105]),
				type = "centerpopup", 
				text = format(L.alerts["%s Duration"],SN[56105]),
				time = 10, 
				sound = "ALERT1", 
				color1 = "BLUE", 
				icon = ST[56105],
			},
			powersparkcd = {
				varname = format(L.alerts["%s Spawns"],L.npc_northrend["Power Spark"]),
				type = "dropdown", 
				text = format(L.alerts["Next %s"],L.npc_northrend["Power Spark"]),
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
						"alert","vortexdur", 
						"alert","vortexcd", 
						"quash","powersparkcd",
						"alert","powersparkcd",
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
						"expect",{"#4#","==","&vehicleguid&"},
						"quash","presurgewarn",
						"alert","surgewarn",
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
						"alert","staticfieldwarn",
					},
				},
			},
			-- Yells
			{
				type = "event", 
				event = "CHAT_MSG_MONSTER_YELL", 
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["I had hoped to end your lives quickly"]},
						"quash","vortexdur",
						"quash","vortexcd",
						"quash","powersparkcd",
						"set",{phase = 2},
						"alert","deepbreathwarn",
					},
					{
						"expect",{"#1#", "find", L.chat_northrend["ENOUGH!"]},
						"quash","deepbreathwarn",
						"set",{phase = 3},
					},
				},
			},
			-- Emotes
			{
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					{
						"expect",{"<phase>","==","1"},
						"quash","powersparkcd",
						"alert","powersparkcd",
					},
					{
						"expect",{"<phase>","==","2"},
						"alert","deepbreathwarn",
					},
				},
			},
			-- Whispers
			{
				type = "event",
				event = "WHISPER",
				execute = {
					{
						"expect",{"#1#","find",L.chat_northrend["fixes his eyes on you!$"]},
						"alert","presurgewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
