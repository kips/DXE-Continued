do
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "thaddius", 
		zone = L["Naxxramas"], 
		name = L["Thaddius"], 
		triggers = {
			scan = {
				15928, -- Thaddius
				15929, -- Stalagg
				15930, -- Feugen
			},
			yell = {L["Stalagg crush you!"],L["Feed you to master!"]},
		},
		onactivate = {
			tracing = {
				15928, -- Thaddius
				15929, -- Stalagg
				15930, -- Feugen
			},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = { 
			dead = 0,
		},
		onacquired = {
			[15928] = { -- Thaddius
				{
					{resettimer = true},
					{alert = "enragecd"},
					{quash = "tankthrowcd"},
					{canceltimer = "tankthrow"},
					{tracing = {15928}}, -- Thaddius
				},
			},
		},
		onstart = {
			{
				{alert = "tankthrowcd"},
				{scheduletimer = {"tankthrow", 20.6}},
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown", 
				text = L["Enrage"],
				time = 360, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "RED",
			},
			tankthrowcd = {
				varname = format(L["%s Cooldown"],L["Tank Throw"]),
				type = "dropdown", 
				text = format(L["Next %s"],L["Tank Throw"]),
				time = 20.6, 
				flashtime = 3, 
				sound = "ALERT2", 
				color1 = "MAGENTA", 
			},
			polarityshiftwarn = {
				varname = format(L["%s Cast"],SN[28089]),
				type = "centerpopup", 
				text = format(L["%s Cast"],SN[28089]),
				time = 3, 
				flashtime = 3, 
				sound = "ALERT1", 
				color1 = "BLUE", 
				flashscreen = true,
			},
		},
		timers = {
			tankthrow = {
				{
					{alert = "tankthrowcd"},
					{scheduletimer = {"tankthrow", 20.6}},
				},
			},
		},
		events = {
			-- Polarity shift
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_START", 
				spellid = 28089, 
				execute = {
					{
						{alert = "polarityshiftwarn"}, 
					},
				},
			},
			-- Emotes
			{
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					{
						{expect = {"#1#","find",L["overloads"]}},
						{set = {dead = "INCR|1"}},
						{expect = {"<dead>",">=","2"}},
						{quash = "tankthrowcd"},
						{canceltimer = "tankthrow"},
						{tracing = {15928}}, -- Thaddius
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

