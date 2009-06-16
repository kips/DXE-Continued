do
	local L,SN = DXE.L,DXE.SN

	local data = {
		version = "$Rev$",
		key = "auriaya", 
		zone = L["Ulduar"], 
		name = L["Auriaya"], 
		triggers = {
			scan = {L["Auriaya"],L["Feral Defender"],L["Sanctum Sentry"]}, 
		},
		onactivate = {
			tracing = {L["Auriaya"],L["Feral Defender"]},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			livecount = 8,
			screechtime = 32,
			guardianswarmtext = "",
		},
		onstart = {
			[1] = {
				{alert = "enragecd"},
				{alert = "feraldefenderspawn"},
				{alert = "screechcd"},
				{set = {screechtime = 35}},
			},
		},
		alerts = {
			screechcd = {
				type = "dropdown",
				var = "screechcd",
				varname = format(L["%s Cooldown"],SN[64386]),
				text = format(L["%s Cooldown"],SN[64386]),
				time = "<screechtime>",
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "VIOLET",
				sound = "ALERT1",
			},
			sentinelwarn = {
				type = "simple",
				var = "sentinelwarn",
				varname = format(L["%s Warning"],SN[64389]),
				text = format(L["%s Casted"],SN[64389]).."!",
				time = 1.5,
				color1 = "BLUE",
				sound = "ALERT2",
			},
			sonicscreechwarn = {
				var = "sonicscreechwarn",
				varname = format(L["%s Cast"],SN[64422]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[64422]),
				time = 2.5,
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				sound = "ALERT3",
			},
			sonicscreechcd = {
				var = "sonicscreechcd",
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
				var = "guardianswarmcd",
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
				var = "guardianswarmwarn",
				varname = format(L["%s Warning"],SN[64396]),
				type = "simple",
				text = format("%s: <guardianswarmtext>",SN[64396]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT8",
			},
			feraldefenderspawn = {
				var = "feraldefenderspawn",
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
				var = "enragecd",
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
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64386,
				execute = {
					[1] = {
						{alert = "screechcd"},
					}	
				},
			},
			-- Sentinel Blast
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64389,64678},
				execute = {
					[1] = {
						{alert = "sentinelwarn"},
					},
				},
			},
			-- Sonic Screech
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64422,64688},
				execute = {
					[1] = {
						{alert = "sonicscreechwarn"},
						{alert = "sonicscreechcd"},
					},
				},
			},
			-- Guardian Swarm
			[4] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64396,
				execute = {
					[1] = {
						{expect = {"&playerguid&","==","#4#"}},
						{set = {guardianswarmtext = L["YOU"].."!"}},
					},
					[2] = {
						{expect = {"&playerguid&","~=","#4#"}},
						{set = {guardianswarmtext = "#5#"}},
					},
					[3] = {
						{alert = "guardianswarmcd"},
						{alert = "guardianswarmwarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end




