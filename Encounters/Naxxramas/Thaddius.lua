do
	local L,SN = DXE.L,DXE.SN

	local L_Thaddius = L["Thaddius"]

	local data = {
		version = "$Rev$",
		key = "thaddius", 
		zone = L["Naxxramas"], 
		name = L_Thaddius, 
		title = L_Thaddius, 
		triggers = {
			scan = {L_Thaddius,L["Stalagg"],L["Feugen"]},
			yell = {L["Stalagg crush you!"],L["Feed you to master!"]},
		},
		onactivate = {
			tracing = {L_Thaddius,L["Stalagg"],L["Feugen"]},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = { 
			dead = 0,
		},
		onacquired = {
			[L_Thaddius] = {
				[1] = {
					{resettimer = true},
					{alert = "enragecd"},
					{quash = "tankthrowcd"},
					{canceltimer = "tankthrow"},
					{tracing = {L_Thaddius}},
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
				varname = L["Enrage"],
				type = "dropdown", 
				text = L["Enrage"],
				time = 360, 
				flashtime = 5, 
				sound = "ALERT2", 
			},
			tankthrowcd = {
				var = "tankthrowcd", 
				varname = format(L["%s Cooldown"],L["Tank Throw"]),
				type = "dropdown", 
				text = format(L["Next %s"],L["Tank Throw"]),
				time = 20.6, 
				flashtime = 3, 
				sound = "ALERT2", 
				color1 = "MAGENTA", 
			},
			polarityshiftwarn = {
				var = "polarityshiftwarn", 
				varname = format(L["%s Cast"],SN[28089]),
				type = "centerpopup", 
				text = format(L["%s Cast"],SN[28089]),
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
						{expect = {"#1#","find",L["overloads!"]}},
						{set = {dead = "INCR|1"}},
						{expect = {"<dead>",">=","2"}},
						{quash = "tankthrowcd"},
						{canceltimer = "tankthrow"},
						{tracing = {L_Thaddius}},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

