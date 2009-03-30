do
	local data = {
		version = "$Rev$",
		key = "sartharion", 
		zone = "The Obsidian Sanctum", 
		name = "Sartharion", 
		title = "Sartharion", 
		tracing = {"Sartharion",},
		triggers = {
			scan = "Sartharion", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {
			tenebronarrived = 0,
			shadronarrived = 0,
			vesperonarrived = 0,
		},
		onstart = {
			[1] = {
				{alert = "lavawallcd"},
			}
		},
		timers = {
			updatetracers = {
				-- Tenebron, Shadron, Vesperon
				[1] = {
					{expect = {"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 0 1"}},
					{tracing = {"Sartharion","Vesperon"}},
				},
				[2] = {
					{expect = {"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 1 0"}},
					{tracing = {"Sartharion","Shadron"}},
				},
				[3] = {
					{expect = {"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","0 1 1"}},
					{tracing = {"Sartharion","Shadron","Vesperon"}},
				},
				[4] = {
					{expect = {"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 0 0"}},
					{tracing = {"Sartharion","Tenebron"}},
				},
				[5] = {
					{expect = {"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 0 1"}},
					{tracing = {"Sartharion","Tenebron","Vesperon"}},
				},
				[6] = {
					{expect = {"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 1 0"}},
					{tracing = {"Sartharion","Tenebron","Shadron"}},
				},
				[7] = {
					{expect = {"<tenebronarrived> <shadronarrived> <vesperonarrived>","==","1 1 1"}},
					{tracing = {"Sartharion","Tenebron","Shadron","Vesperon"}},
				},
			},
		},
		alerts = {
			lavawallcd = {
				var = "lavawallcd", 
				varname = "Lava wall cooldown", 
				type = "dropdown", 
				text = "Lava wall cooldown", 
				time = 25, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "ORANGE", 
			},
			lavawallwarn = {
				var = "lavawallwarn", 
				varname = "Lava wall warning", 
				type = "centerpopup", 
				text = "Incoming Lava Wall", 
				time = 5, 
				flashtime = 0, 
				sound = "ALERT1", 
				color1 = "ORANGE", 
			},
			shadowfissurewarn = {
				var = "shadowfissurewarn", 
				varname = "Shadow fissure warning", 
				type = "simple", 
				text = "Shadow Fissure Spawned", 
				time = 1.5, 
				flashtime = 0, 
			},
		},
		events = {
			-- Shadow fissure
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {59127,57579}, 
				execute = {
					[1] = {
						{alert = "shadowfissurewarn"}, 
					},
				},
			},
			-- Lava wall
			[2] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"#1#","find","lava surrounding"}},
						{alert = "lavawallwarn"},
						{alert = "lavawallcd"}, 
					},
				},
			},
 			-- Tenebron: It is amusing to watch you struggle. Very well, witness how it is done. 
 			-- Shadron:  I will take pity on you, Sartharion, just this once. 
 			-- Vesperon: Father was right about you, Sartharion, you ARE a weakling. 
			[3] = {
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Tenebron
					[1] = {
						{expect = {"#1#","find","^It is amusing"}},
						{set = {tenebronarrived = 1}},
						{scheduletimer = {"updatetracers",0}},
					},
					-- Shadron
					[2] = {
						{expect = {"#1#","find","^I will take pity on you"}},
						{set = {shadronarrived = 1}},
						{scheduletimer = {"updatetracers",0}},
					},
					-- Vesperon
					[3] = {
						{expect = {"#1#","find","^Father was right about you"}},
						{set = {vesperonarrived = 1}},
						{scheduletimer = {"updatetracers",0}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
