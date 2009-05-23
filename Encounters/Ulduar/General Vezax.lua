do
	local data = {
		version = "$Rev$",
		key = "generalvezax", 
		zone = "Ulduar", 
		name = "General Vezax", 
		title = "General Vezax", 
		tracing = {"General Vezax",},
		triggers = {
			scan = {"General Vezax","Saronite Animus"}, 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			shadowcrashmessage = "",
			saronitecount = 1,
		},
		onstart = {
			[1] = {
				{alert = "vaporcd"},
				{set = {saronitecount = "INCR|1"}},
			},
		},
		alerts = {
			searingflamewarn = {
				var = "searingflamewarn",
				varname = "Searing Flame cast",
				type = "centerpopup",
				text = "Searing Flame Cast",
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT1",
			},
			darknesswarn = {
				var = "darknesswarn",
				varname = "Surge of Darkness cast",
				type = "centerpopup",
				text = "Surge of Darkness Cast",
				time = 3,
				color1 = "VIOLET",
				sound = "ALERT1",
			},
			darknessdur = {
				var = "darknessdur",
				varname = "Surge of Darkness duration",
				type = "centerpopup",
				text = "Surge of Darkness Ends",
				time = 10,
				flashtime = 10,
				color1 = "VIOLET",
				color2 = "AQUA",
				sound = "ALERT2",
			},
			animuswarn = {
				var = "animuswarn",
				varname = "Saronite Animus spawn warning",
				type = "simple",
				text = "Saronite Animus Spawned!",
				time = 1.5,
				sound = "ALERT3",
			},
			vaporcd = {
				var = "vaporcd",
				varname = "Saronite Vapor cooldown",
				type = "dropdown",
				text = "Next Saronite Vapor <saronitecount>",
				time = 30,
				flashtime = 5,
				color1 = "GREEN",
			},
			shadowcrashwarn = {
				var = "shadowcrashwarn",
				varname = "Shadow Crash warning",
				type = "simple",
				text = "<shadowcrashmessage>",
				time = 1.5,
				color1 = "BLACK",
				sound = "ALERT4",
			},
			facelessdurself = {
				var = "facelessdurself",
				varname = "Mark of the Faceless on self",
				type = "centerpopup",
				time = 10,
				flashtime = 10,
				text = "Mark of the Faceless: YOU!",
				sound = "ALERT5",
				color1 = "RED",
			},
			facelessdurothers = {
				var = "facelessdurothers",
				varname = "Mark of the Faceless on others",
				type = "centerpopup",
				text = "Mark of the Faceless: #5#",
				time = 10,
				color1 = "RED",
			},
			facelessproxwarn = {
				var = "facelessproxwarn",
				varname = "Mark of the Faceless proximity warn",
				type = "simple",
				text = "#5# is Marked! YOU ARE CLOSE!",
				time = 1.5,
				color1 = "MAGENTA",
				sound = "ALERT5",
			},
		},
		timers = {
			shadowcrash = {
				[1] = {
					{expect = {"&tft_unitexists& &tft_isplayer&","==","1 1"}},
					{set = {shadowcrashmessage = "Shadow Crash: YOU! Move!"}},
					{alert = "shadowcrashwarn"},
				},
				
				[2] = {
					{expect = {"&tft_unitexists& &tft_isplayer&","==","1 nil"}},
					{proximitycheck = {"&tft_unitname&",18}},
					{set = {shadowcrashmessage = "Shadow Crash: &tft_unitname&! MOVE!"}},
					{alert = "shadowcrashwarn"},
				},
			},
		},
		events = {
			-- Searing Flames
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 62661,
				execute = {
					[1] = {
						{alert = "searingflamewarn"},
					},
				},
			},
			-- Surge of Darkness cast
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 62662,
				execute = {
					[1] = {
						{alert = "darknesswarn"},
					},
				},
			},
			-- Surge of Darkness gain
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62662,
				execute = {
					[1] = {
						{quash = "darknesswarn"},
						{alert = "darknessdur"},
					},
				},
			},
			-- Shadow Crash
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {60835,62660},
				execute = {
					[1] = {
						{scheduletimer = {"shadowcrash",0.1}},
					},
				},
			},
			-- Mark of the Faceless
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 63276,
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "facelessdurself"},
					},
					[2] = {
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "facelessdurothers"},
						{proximitycheck = {"#5#",18}},
						{alert = "facelessproxwarn"},
					},
				},
			},
			-- Saronite Vapors
			[6] = {
				type = "event",
				event = "EMOTE",
				execute = {
					[1] = {
						{expect = {"#1#","find","^A cloud of saronite vapors"}},
						{alert = "vaporcd"},
						{set = {saronitecount = "INCR|1"}},
					},
				},
			},
			-- Saronite Animus spawns
			[7] = {
				type = "event",
				event = "EMOTE",
				execute = {
					[1] = {
						{expect = {"#1#","==","^A saronite barrier appears around"}},
						{alert = "animuswarn"},
						{tracing = {"General Vezax","Saronite Animus"}},
					},
				},
			},
			-- Saronite Animus dies
			[8] = {
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					[1] = {
						{expect = {"#5#","==","Saronite Animus"}},
						{tracing = {"General Vezax"}},
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end
