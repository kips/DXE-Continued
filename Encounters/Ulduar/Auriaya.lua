do
	-- TODO: Add Terrifying Screech Cast, Sentinel Blast channel time
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "auriaya", 
		zone = L["Ulduar"], 
		name = L["Auriaya"], 
		triggers = {
			scan = {
				L["Auriaya"],
				L["Feral Defender"],
				L["Sanctum Sentry"]
			}, 
		},
		onactivate = {
			tracing = {L["Auriaya"],L["Feral Defender"]},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {
			livecount = 8,
			screechtime = 32,
			guardianswarmtext = "",
		},
		onstart = {
			{
				{alert = "enragecd"},
				{alert = "feraldefenderspawn"},
				{alert = "screechcd"},
				{set = {screechtime = 35}},
			},
		},
		alerts = {
			screechcd = {
				varname = format(L["%s Cooldown"],SN[64386]),
				text = format(L["%s Cooldown"],SN[64386]),
				type = "dropdown",
				time = "<screechtime>",
				flashtime = 5,
				color1 = "PURPLE",
			},
			screechwarn = {
				varname = format(L["%s Cast"],SN[64386]),
				text = format(L["%s Cast"],SN[64386]),
				type = "centerpopup",
				time = 2,
				color1 = "BROWN",
				sound = "ALERT1",
			},
			sentinelwarn = {
				varname = format(L["%s Warning"],SN[64389]),
				type = "simple",
				text = format(L["%s Casted"],SN[64389]).."!",
				time = 1.5,
				color1 = "BLUE",
				sound = "ALERT2",
			},
			sonicscreechwarn = {
				varname = format(L["%s Cast"],SN[64422]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[64422]),
				time = 2.5,
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				sound = "ALERT3",
			},
			sonicscreechcd = {
				varname = format(L["%s Cooldown"],SN[64422]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[64422]),
				time = 28,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "INDIGO",
				sound = "ALERT4",
			},
			guardianswarmcd = {
				varname = format(L["%s Cooldown"],SN[64396]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[64396]),
				time = 37,
				flashtime = 5,
				color1 = "GREEN",
				color2 = "GREEN",
				sound = "ALERT5",
			},
			guardianswarmwarn = {
				varname = format(L["%s Warning"],SN[64396]),
				type = "simple",
				text = format("%s: <guardianswarmtext>",SN[64396]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT8",
			},
			feraldefenderspawn = {
				varname = format(L["%s Spawn"],L["Feral Defender"]),
				text = format(L["%s Spawn"],L["Feral Defender"]),
				type = "dropdown",
				time = 60,
				flashtime = 5,
				color1 = "DCYAN",
				color2 = "DCYAN",
				sound = "ALERT8",
			},
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 600,
				flashtime = 5,
				color1 = "RED",
				sound = "ALERT7",
			},
		},
		events = {
			-- Terrifying Screech - Fear
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64386,
				execute = {
					{
						{alert = "screechcd"},
						{alert = "screechwarn"},
					}	
				},
			},
			-- Sentinel Blast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64389,64678},
				execute = {
					{
						{alert = "sentinelwarn"},
					},
				},
			},
			-- Sonic Screech
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64422,64688},
				execute = {
					{
						{alert = "sonicscreechwarn"},
						{quash = "sonicscreechcd"},
						{alert = "sonicscreechcd"},
					},
				},
			},
			-- Guardian Swarm
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64396,
				execute = {
					{
						{expect = {"&playerguid&","==","#4#"}},
						{set = {guardianswarmtext = L["YOU"].."!"}},
					},
					{
						{expect = {"&playerguid&","~=","#4#"}},
						{set = {guardianswarmtext = "#5#"}},
					},
					{
						{alert = "guardianswarmcd"},
						{alert = "guardianswarmwarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
