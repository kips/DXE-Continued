do
	local data = {
		version = "$Rev$",
		key = "Razorscale", 
		zone = "Ulduar", 
		name = "Razorscale", 
		title = "Razorscale", 
		tracing = {"Razorscale",},
		triggers = {
			scan = {"Razorscale","Dark Rune Guardian","Dark Rune Sentinel"}, 
			yell = "^Be on the lookout! Mole machines",
		},
		onactivate = {
			leavecombat = true,
		},
		onstart = {
			[1] = {
				{alert = "enragecd"},
			},
		},
		userdata = {},
		alerts = {
			enragecd = {
				var = "enragecd",
				varname = "Enrage",
				type = "dropdown",
				text = "Enrage",
				time = 900,
				flashtime = 5,
				color1 = "RED",
				color2 = "RED",
				sound = "ALERT6",
			},
			devourwarnself = {
				var = "devourwarnself",
				varname = "Devouring Flame warning on self",
				type = "simple",
				text = "Move out of Devouring Flame!",
				time = 1.5,
				color1 = "RED",
				sound = "ALERT1",
			},
			breathwarn = {
				var = "breathwarn",
				varname = "Flame Breath cast",
				type = "centerpopup",
				text = "Flame Breath Cast",
				time = 2.5,
				flashtime = 2.5,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT2",
			},
			chaindur = {
				var = "chaindur",
				varname = "Chain duration",
				type = "centerpopup",
				text = "Chain Duration",
				time = 38,
				color1 = "BROWN",
				sound = "ALERT3",
			},
			chainwarn = {
				var = "chainwarn",
				varname = "Chain warning",
				type = "simple",
				text = "Razorscale is now chained!",
				time = 1.5,
				sound = "ALERT5",
				color1 = "GOLD",
			},
			permlandwarn = {
				var = "permlandwarn",
				varname = "Permanent landing warning",
				type = "simple",
				text = "Razorscale permanently landed!",
				time = 1.5,
				sound = "ALERT4",
			},
		},
		events = {
			-- Devouring Flame
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63014,63816},
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "devourwarnself"},
					},
				},
			},
			[2] = {
				type = "event",
				event = "YELL",
				execute = {
					-- Chain
					[1] = {
						{expect = {"#1#","find","^Move quickly"}},
						{alert = "chaindur"},
						{alert = "chainwarn"},
					},
					[2] = {
						{expect = {"#1#","find","^Give us a moment to"}},
						{quash = "chaindur"},
					},
				},
			},
			[3] = {
				type = "event",
				event = "EMOTE",
				execute = {
					[1] = {
						{expect = {"#1#","find","deep breath...$"}},
						{alert = "breathwarn"},
					},
					[2] = {
						{expect = {"#1#","find","lands permanently!$"}},
						{alert = "permlandwarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
