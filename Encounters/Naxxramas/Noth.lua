do
	local L,SN = DXE.L,DXE.SN

	local L_NothThePlaguebringer = L["Noth the Plaguebringer"]

	local data = {
		version = "$Rev$",
		key = "noththeplaguebringer", 
		zone = L["Naxxramas"], 
		name = L_NothThePlaguebringer, 
		triggers = {
			scan = {L_NothThePlaguebringer,L["Plagued Champion"],L["Plagued Guardian"]}, 
		},
		onactivate = {
			tracing = {L_NothThePlaguebringer,},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = { 
			roomtime = {90,110,180,loop=false},
			balconytime = {70,95,120,loop=false},
		},
		onstart = {
			[1] = {
				{alert = "teleportbalc"},
				{expect = {"&difficulty&","==","2"}},
				{alert = "blinkcd"},
			}
		},
		alerts = {
			blinkcd = {
				var = "blinkcd", 
				varname = format(L["%s Cooldown"],SN[29208]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],SN[29208]),
				time = 30, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
			},
			teleportbalc = {
				var = "teleportbalc", 
				varname = L["Teleport to Balcony"], 
				type = "dropdown", 
				text = L["Teleport to Balcony"], 
				time = "<roomtime>", 
				flashtime = 5, 
				sound = "ALERT2", 
			},
			teleportroom = {
				var = "teleportroom", 
				varname = L["Teleport To Room"], 
				type = "dropdown", 
				text = L["Teleport To Room"], 
				time = "<balconytime>", 
				flashtime = 5, 
				sound = "ALERT2", 
			},
			cursewarn = {
				var = "cursewarn", 
				varname = format(L["%s Warning"],L["Curse"]),
				type = "simple", 
				text = format(L["%s Casted"],L["Curse"]).."!",
				time = 1.5, 
				sound = "ALERT3", 
			},
		},
		events = {
			-- Curses
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {29213,54835}, 
				execute = {
					[1] = {
						{alert = "cursewarn"}, 
					},
				},
			},
			-- Emotes
			[2] = {
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					[1] = {
						{expect = {"#1#","find",L["blinks away"]}},
						{alert = "blinkcd"}, 
					},
					[2] = {
						{expect = {"#1#","find",L["teleports to the balcony"]}},
						{quash = "blinkcd"},
						{alert = "teleportroom"}, 
					},
					[3] = {
						{expect = {"#1#","find",L["teleports back into battle"]}},
						{alert = "teleportbalc"}, 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

