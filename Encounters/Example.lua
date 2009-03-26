do
	local data = {
		version = 1,
		key = "sapphiron", -- key in defaults
		zone = "Naxxramas", -- added to zone database
		name = "Sapphiron", -- name to show in the configuration menu
		title = "Sapphiron", -- initial pane title text
		tracing = {
			name = "Sapphiron", -- usage DXE:TrackUnitName(name)
			-- Could have multiple trace names
		},
		-- Start the encounter
		triggers = {
			scan = "Sapphiron", -- Add to scanner for activating encounters
			--yell = "boss yell", -- string or table {"boss yell","boss yell2"} intended use: activates and starts
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
			--entercombat = true, -- PLAYER_REGEN_DISABLED name derived from scan
			--leavecombat = true, --  PLAYER_REGEN_ENABLED name derived from scan
		},
		userdata = { -- defaults for variables changed during fights

		},
		--list of commands
		onstart = {
		},
		alerts = {
			lifedraincd = {
				var = "lifedraincd", -- required
				varname = "Life drain cooldown", -- required
				type = "dropdown", -- required
				text = "Lifedrain", -- required
				time = 23, -- required
				flashtime = 5, -- optional
				sound = "ALERT3", -- optional
				color1 = "MAGENTA", -- optional
				-- color 2 = "COLOR", -- optional
			},
			airphasedur = {
				var = "airphasedur", -- required
				varname = "Air phase duration", -- required
				type = "dropdown", -- required
				text = "Air Phase", -- required
				time = 15.5, -- required
				flashtime = 5, -- optional
				sound = "ALERT2", -- optional
				color1 = "YELLOW", -- optional
				-- color 2 = "COLOR", -- optional
			},
			deepbreathwarn = {
				var = "deepbreathwarn", -- required
				varname = "Deep breath warning", -- required
				type = "centerpopup", -- required
				text = "Deep Breath! Hide!", -- required
				time = 10, -- required
				flashtime = 6.5, -- optional
				sound = "ALERT1", -- optional
				color1 = "BLUE", -- optional
				-- color 2 = "COLOR", -- optional
			},
		},
		events = {
			-- Lifedrain
			[1] = {
				type = "combatevent", -- combatevent|event
				eventtype = "SPELL_CAST_SUCCESS", -- combatevent expects eventtype - required
				spellid = {28542,55665}, -- combatevent expected spellid - required
				execute = {
					[1] = {
						-- commands
						{alert = "lifedraincd"}, -- starts these alerts
					},
				},
			},
			-- Emotes
			[2] = {
				type = "event", -- combatevent|event
				event = "CHAT_MSG_RAID_BOSS_EMOTE", -- combatevent expects eventtype - required
				execute = {
					[1] = {
						-- commands
						{expect = {"#1#","find","lifts"}},
						{alert = "airphasedur"}, -- starts these alerts
					},
					[2] = {
						{expect = {"#1#","find","deep"}},
						{alert = "deepbreathwarn"}, -- starts these alerts
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


