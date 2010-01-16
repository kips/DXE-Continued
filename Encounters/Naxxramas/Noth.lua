do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 299,
		key = "noththeplaguebringer", 
		zone = L.zone["Naxxramas"], 
		name = L.npc_naxxramas["Noth the Plaguebringer"], 
		triggers = {
			scan = {
				15954, -- Noth
				16983, -- Plagued Champion
				16981, -- Plagued Guardian
			}, 
		},
		onactivate = {
			tracing = {15954}, -- Noth
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15954,
		},
		userdata = { 
			roomtime = {90,110,180,loop=false},
			balconytime = {70,95,120,loop=false},
		},
		onstart = {
			{
				"alert","teleportbalccd",
				"expect",{"&difficulty&","==","2"},
				"alert","blinkcd",
			}
		},
		alerts = {
			blinkcd = {
				varname = format(L.alerts["%s Cooldown"],SN[29208]),
				type = "dropdown", 
				text = format(L.alerts["%s Cooldown"],SN[29208]),
				time = 30, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
				icon = ST[29208],
			},
			teleportbalccd = {
				varname = L.alerts["Teleport to Balcony"], 
				type = "dropdown", 
				text = L.alerts["Teleport to Balcony"], 
				time = "<roomtime>", 
				flashtime = 5, 
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[66548],
			},
			teleportroomcd = {
				varname = L.alerts["Teleport to Room"], 
				type = "dropdown", 
				text = L.alerts["Teleport to Room"], 
				time = "<balconytime>", 
				flashtime = 5, 
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[29231],
			},
			cursewarn = {
				varname = format(L.alerts["%s Warning"],L.alerts["Curse"]),
				type = "simple", 
				text = format(L.alerts["%s Casted"],L.alerts["Curse"]).."!",
				time = 1.5, 
				sound = "ALERT3", 
				icon = ST[29213],
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
						"alert","cursewarn", 
					},
				},
			},
			-- Emotes
			{
				type = "event", 
				event = "CHAT_MSG_RAID_BOSS_EMOTE", 
				execute = {
					{
						"expect",{"#1#","find",L.chat_naxxramas["blinks away"]},
						"alert","blinkcd", 
					},
					{
						"expect",{"#1#","find",L.chat_naxxramas["teleports to the balcony"]},
						"quash","blinkcd",
						"alert","teleportroomcd", 
					},
					{
						"expect",{"#1#","find",L.chat_naxxramas["teleports back into battle"]},
						"alert","teleportbalccd", 
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

