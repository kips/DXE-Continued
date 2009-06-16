do
	local L,SN = DXE.L,DXE.SN

	local L_Sapphiron = L["Sapphiron"]

	local data = {
		version = "$Rev$",
		key = "sapphiron", 
		zone = L["Naxxramas"], 
		name = L_Sapphiron, 
		triggers = {
			scan = L_Sapphiron, 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
			tracing = {L_Sapphiron},
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "enragecd"},
			},
		},
		alerts = {
			enragecd = {
				var = "enragecd",
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 900,
				flashtime = 5,
				color1 = "RED",
				color2 = "RED",
			},
			lifedraincd = {
				var = "lifedraincd", 
				varname = format(L["%s Cooldown"],SN[28542]),
				type = "dropdown", 
				text = format(L["Next %s"],SN[28542]),
				time = 23, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "MAGENTA", 
			},
			airphasedur = {
				var = "airphasedur", 
				varname = format(L["%s Duration"],L["Air Phase"]),
				type = "centerpopup", 
				text = format(L["%s Duration"],L["Air Phase"]), 
				time = 15.5, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "YELLOW", 
			},
			deepbreathwarn = {
				var = "deepbreathwarn", 
				varname = format(L["%s Warning"],L["Deep Breath"]),
				type = "centerpopup", 
				text = format("%s! %s!",L["Deep Breath"],L["HIDE"]),
				time = 10, 
				flashtime = 6.5, 
				sound = "ALERT1", 
				color1 = "BLUE", 
			},
		},
		events = {
			-- Life drain
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {28542,55665}, 
				execute = {
					[1] = {
						{alert = "lifedraincd"}, 
					},
				},
			},
			-- Emotes
			[2] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"#1#","find",L["lifts"]}},
						{alert = "airphasedur"}, 
						{quash = "lifedraincd"},
					},
					[2] = {
						{expect = {"#1#","find",L["deep"]}},
						{quash = "airphasedur"},
						{alert = "deepbreathwarn"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

