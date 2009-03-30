do
	local data = {
		version = "$Rev$",
		key = "thaddius", 
		zone = "Naxxramas", 
		name = "Thaddius", 
		title = "Thaddius", 
		tracing = {"Feugen","Stalagg","Thaddius"},
		triggers = {
			scan = {"Feugen","Stalagg","Thaddius"}, 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = { 
			dead = 0,
		},
		onacquired = {
			["Thaddius"] = {
				[1] = {
					{resettimer = true},
					{alert = "enragecd"},
				},
			},
		},
		onstart = {
			[1] = {
				{alert = "tankthrowcd"},
				{scheduletimer = {"tankthrow", 20.6}},
			},
			[2] = {
				{expect = {"&scan&","==","Thaddius"}},
				{quash = "tankthrowcd"},
				{canceltimer = "tankthrow"},
				{tracing = {"Thaddius"}},
			},
		},
		alerts = {
			enragecd = {
				var = "enragecd", 
				varname = "Enrage cooldown", 
				type = "dropdown", 
				text = "Enrage", 
				time = 360, 
				flashtime = 5, 
				sound = "ALERT2", 
			},
			tankthrowcd = {
				var = "tankthrowcd", 
				varname = "Tank throw cooldown", 
				type = "dropdown", 
				text = "Tank throw", 
				time = 20.6, 
				flashtime = 3, 
				sound = "ALERT2", 
				color1 = "MAGENTA", 
			},
			polarityshiftwarn = {
				var = "polarityshiftwarn", 
				varname = "Polarity shift warning", 
				type = "centerpopup", 
				text = "Polarity Shift", 
				time = 3, 
				flashtime = 3, 
				sound = "ALERT1", 
				color1 = "BLUE", 
			},
		},
		timers = {
			tankthrow = {
				[1] = {
					{alert = "tankthrowcd"},
					{scheduletimer = {"tankthrow", 20.6}},
				},
			},
		},
		events = {
			-- Polarity shift
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_START", 
				spellid = 28089, 
				execute = {
					[1] = {
						{alert = "polarityshiftwarn"}, 
					},
				},
			},
			-- Emotes
			[2] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"#1#","find","overloads!"}},
						{set = {dead = "INCR|1"}},
						{expect = {"<dead>",">=","2"}},
						{quash = "tankthrowcd"},
						{canceltimer = "tankthrow"},
						{tracing = {"Thaddius"}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

