-- TODO: Add side switching warning
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
					{quash = "tankthrowcd"},
					{canceltimer = "tankthrow"},
					{tracing = {"Thaddius"}},
				},
			},
		},
		onstart = {
			[1] = {
				{alert = "tankthrowcd"},
				{scheduletimer = {"tankthrow", 20.6}},
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
				text = "Next Tank Throw", 
				time = 20.6, 
				flashtime = 3, 
				sound = "ALERT2", 
				color1 = "MAGENTA", 
			},
			polarityshiftwarn = {
				var = "polarityshiftwarn", 
				varname = "Polarity Shift cast", 
				type = "centerpopup", 
				text = "Polarity Shift Cast", 
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

