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
			leavecombat = true,
		},
		userdata = {
			tenebronarrived = 0,
			shadronarrived = 0,
			vesperonarrived = 0,
			tenebrontimer = 0,
			shadrontimer = 0,
			vesperontimer = 0,
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
				varname = "Lava Wall cooldown", 
				type = "dropdown", 
				text = "Lava Wall Cooldown", 
				time = 25, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "ORANGE", 
			},
			lavawallwarn = {
				var = "lavawallwarn", 
				varname = "Lava Wall warning", 
				type = "centerpopup", 
				text = "Incoming Lava Wall!", 
				time = 5, 
				sound = "ALERT1", 
				color1 = "RED", 
				color2 = "ORANGE",
			},
			shadowfissurewarn = {
				var = "shadowfissurewarn", 
				varname = "Shadow Fissure warning", 
				type = "simple", 
				text = "Shadow Fissure Spawned!", 
				sound = "ALERT2",
				color1 = "PURPLE",
				time = 1.5, 
			},
			flamebreathwarn = {
				var = "flamebreathwarn",
				varname = "Flame Breath cast",
				type = "centerpopup",
				text = "Flame Breath Cast",
				time = 2,
				color1 = "DCYAN",
				sound = "ALERT4",
			},
			-- No flash times. It gets too polluted during the fight if everything else is on
			shadronarrives = {
				type = "dropdown",
				var = "sharonarrives",
				varname = "Shadron arrival",
				text = "Shadron Arrives",
				time = 80,
				color1 = "DCYAN",
			},
			tenebronarrives = {
				type = "dropdown",
				var = "tenebronarrives",
				varname = "Tenebron arrival",
				text = "Tenebron Arrives",
				time = 30,
				color1 = "CYAN",
			},
			vesperonarrives = {
				type = "dropdown",
				var = "vesperonarrives",
				varname = "Vesperon arrival",
				text = "Vesperon Arrives",
				time = 120,
				color1 = "GREEN",
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
			-- Flame Breath
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {56908,58956},
				execute = {
					[1] = {
						{alert = "flamebreathwarn"},
					},
				},
			},
			-- Drake Arrivals
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {58105, 61248, 61251},
				execute = {
					[1] = {
						-- Shadron
						{expect = {"#7# <shadrontimer>","==","58105 0"}},
						{set = {shadrontimer = 1}},
						{alert = "shadronarrives"},
					},
					[2] = {
						-- Tenebron
						{expect = {"#7# <tenebrontimer>","==","61248 0"}},
						{set = {tenebrontimer = 1}},
						{alert = "tenebronarrives"},
					},
					[3] = {
						-- Vesperon
						{expect = {"#7# <vesperontimer>","==","61251 0"}},
						{set = {vesperontimer = 1}},
						{alert = "vesperonarrives"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
