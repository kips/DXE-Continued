do
	local data = {
		version = "$Rev$",
		key = "auriaya", 
		zone = "Ulduar", 
		name = "Auriaya", 
		title = "Auriaya", 
		tracing = {"Auriaya","Feral Defender"},
		triggers = {
			scan = "Auriaya", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			livecount = 8,
			screechtime = 32,
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
				varname = "Terrifying Screech cooldown",
				text = "Terrifying Screech Cooldown",
				time = "<screechtime>",
				flashtime = 5,
				color1 = "PURPLE",
				color2 = "VIOLET",
				sound = "ALERT1",
			},
			sentinelwarn = {
				type = "simple",
				var = "sentinelwarn",
				varname = "Sentinel Blast warning",
				text = "Sentinel Blast Casted!",
				time = 1.5,
				color1 = "BLUE",
				sound = "ALERT2",
			},
			sonicscreechwarn = {
				var = "sonicscreechwarn",
				varname = "Sonic Screech cast",
				type = "centerpopup",
				text = "Sonic Screech Cast",
				time = 2.5,
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				sound = "ALERT3",
			},
			sonicscreechcd = {
				var = "sonicscreechcd",
				varname = "Sonic Screech cooldown",
				type = "dropdown",
				text = "Sonic Screech Cooldown",
				time = 28,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "INDIGO",
				sound = "ALERT4",
			},
			
			guardianswarmcd = {
				var = "guardianswarmcd",
				varname = "Guardian Swarm Cooldown",
				type = "dropdown",
				text = "Guardian Swarm Cooldown",
				time = 37,
				flashtime = 5,
				color1 = "GREEN",
				color2 = "GREEN",
				sound = "ALERT5",
			},
			--[[
			guardianswarmdurother = {
				var = "guardianswarmdur",
				varname = "Guardian Swarm duration",
				type = "centerpopup",
				text = "Swarm: #5#!",
				time = 37,
				color1 = "GREEN",
			},
			]]
			feraldefenderspawn = {
				var = "feraldefenderspawn",
				varname = "Feral Defender spawns",
				text = "Feral Defender Spawns",
				type = "dropdown",
				time = 60,
				flashtime = 5,
				color1 = "DCYAN",
				color2 = "DCYAN",
				sound = "ALERT8",
			},
			feraldefenderlives = {
				var = "feraldefenderlives",
				varname = "Feral Defender lives",
				type = "simple",
				text = "Defender Lives: <livecount>/9",
				time = 1.5,
				color1 = "BROWN",
				sound = "ALERT6",
			},
			feraldefenderlivesremoval = {
				var = "feraldefenderlivesremoval",
				varname = "Feral Defender lives removal",
				type = "simple",
				text = "Defender Lives: <livecount>/9",
				time = 1.5,
				color1 = "BROWN",
				sound = "ALERT6",
			},
			enragecd = {
				var = "enragecd",
				varname = "Enrage",
				type = "dropdown",
				text = "Enrage",
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
						{alert = "guardianswarmcd"}
						--{expect = {"&playerguid&","==","#4#"}},
						--{alert = "guardianswarmdurself"},
					},
					--[[
					[2] = {
						{expect = {"&playerguid&","~=","#4#"}},
						{alert = "guardianswarmdurother"},
					},
					]]
				},
			},
			-- Feral Defender - Feral Essence
			[5] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64455,
				execute = {
					[1] = {
						{alert = "feraldefenderlives"},
					},
				},
			},
			-- Feral Defender - Feral Essence Removal => Kill
			[6] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED_DOSE",
				spellid = 64455,
				execute = {
					[1] = {
						{set = {livecount = "DECR|1"}},
						{alert = "feraldefenderlivesremoval"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


