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
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = { 
			roomtime = {90,110,180,loop=false},
			balconytime = {70,95,120,loop=false},
		},
		onstart = {
			{
				{alert = "teleportbalc"},
				{expect = {"&difficulty&","==","2"}},
				{alert = "blinkcd"},
			}
		},
		alerts = {
			blinkcd = {
				varname = format(L["%s Cooldown"],SN[29208]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],SN[29208]),
				time = 30, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
			},
			teleportbalc = {
				varname = L["Teleport to Balcony"], 
				type = "dropdown", 
				text = L["Teleport to Balcony"], 
				time = "<roomtime>", 
				flashtime = 5, 
				color1 = "RED",
				sound = "ALERT2", 
			},
			teleportroom = {
				varname = L["Teleport to Room"], 
				type = "dropdown", 
				text = L["Teleport to Room"], 
				time = "<balconytime>", 
				flashtime = 5, 
				color1 = "RED",
				sound = "ALERT2", 
			},
			cursewarn = {
				varname = format(L["%s Warning"],L["Curse"]),
				type = "simple", 
				text = format(L["%s Casted"],L["Curse"]).."!",
				time = 1.5, 
				sound = "ALERT3", 
			},
		},
		events = {
			-- Curses
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {29213,54835}, 
				execute = {
					{
						{alert = "cursewarn"}, 
					},
				},
			},
			-- Emotes
			{
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					{
						{expect = {"#1#","find",L["blinks away"]}},
						{alert = "blinkcd"}, 
					},
					{
						{expect = {"#1#","find",L["teleports to the balcony"]}},
						{quash = "blinkcd"},
						{alert = "teleportroom"}, 
					},
					{
						{expect = {"#1#","find",L["teleports back into battle"]}},
						{alert = "teleportbalc"}, 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

