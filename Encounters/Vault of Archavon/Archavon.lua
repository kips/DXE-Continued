do
	local data = {
		version = "$Rev: 22 $",
		key = "archavon", 
		zone = "Vault of Archavon",
		name = "Archavon the Stone Watcher",
		title = "Archavon the Stone Watcher",
		tracing = {
			name = "Archavon the Stone Watcher", 
		},
		triggers = {
			scan = "Archavon the Stone Watcher",
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "enragecd"},
				{alert = "stompcd"},
			}
		},
		alerts = {
			enragecd = {
				var = "enragecd",
				varname = "Enrage cooldown",
				type = "dropdown",
				text = "Enrage",
				time = 300,
				flashtime = 5,
			},
			chargewarn = {
				var = "chargewarn",
				varname = "Charge warning",
				type = "simple",
				text = "#5# charged",
				time = 1.5,
				sound = "ALERT2",
			},
			cloudwarn = {
				var = "cloudwarn",
				varname = "Cloud warning",
				type = "simple",
				text = "Move out of cloud!",
				time = 1.5,
				sound = "ALERT2",
			},
			shardswarnself = {
				var = "shardswarn",
				varname = "Shards warning",
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				text = "Rock shards on YOU! Move!",
				sound = "ALERT3",
			},
			shardswarnother = {
				var = "shardswarn",
				varname = "Shards warning",
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				color2 = "YELLOW",
				sound = "ALERT3",
				text = "Rock shards on &tft_unitname&",
			},
			stompcd = {
				var = "stompcd",
				varname = "Stomp cooldown",
				type = "dropdown",
				text = "Stomp Cooldown",
				time = 47,
				flashtime = 5,
				sound = "ALERT1",
				color1 = "BROWN",

			},
		},
		timers = {
			shards = {
				[1] = {
					{expect = {"&tft_unitexists& &tft_isplayer&","==","true true"}},
					{alert = "shardswarnself"},
				},
				[2] = {
					{expect = {"&tft_unitexists& &tft_isplayer&","==","true false"}},
					{alert = "shardswarnother"},
				},
			},
		},
		events = {
			-- Stomp
			[1] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {58663, 60880}, 
				execute = {
					[1] = {
						{alert = "stompcd"}, 
					},
				},
			},
			-- Shards
			[2] = {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 58678,
				execute = {
					[1] = {
						{scheduletimer = {"shards",0.2}},
					}
				},
			},
			-- Cloud
			[3] = {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {58965, 61672},
				execute = {
					[1] = {
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "cloudwarn"},
					},
				},
			},
			[4] = {
				type = "event",
				event = "CHAT_MSG_MONSTER_EMOTE",
				execute = {
					[1] = {
						{alert = "chargewarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
