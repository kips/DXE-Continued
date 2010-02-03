do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 3,
		key = "valithria", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Valithria"], 
		triggers = {
			scan = 36789,
			yell = L.chat_citadel["^Heroes, lend me your aid"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36789},
		},
		onstart = {
			{
				"alert","portalcd",
			},
		},
		userdata = {
			portaltime = {33,45, loop = false, type = "series"},
		},
		alerts = {
			portalcd = {
				varname = format(L.alert["%s Cooldown"],L.alert["Portals"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.alert["Portals"]),
				time = "<portaltime>",
				flashtime = 10,
				sound = "ALERT1",
				color1 = "GREEN",
				icon = ST[57676],
			},
			portalwarn = {
				varname = format(L.alert["%s Warning"],L.alert["Portals"]),
				type = "simple",
				text = format(L.alert["%s Spawned"],L.alert["Portals"]).."!",
				time = 3,
				sound = "ALERT2",
				icon = ST[57676],
			},
			manavoidself = {
				varname = format(L.alert["%s on self"],SN[71743]),
				type = "simple",
				text = format("%s: %s! %s!",SN[71743],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				sound = "ALERT3",
				color1 = "PURPLE",
				flashscreen = true,
				throttle = 2,
				icon = ST[71743],
			},
		},
		events = {
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",L.chat_citadel["^I have opened a portal into the Dream"]},
						"alert","portalwarn",
						"alert","portalcd",
					},
				},
			},
			-- Mana Void (hit)
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					71086, -- 10
					71743, -- 25
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","manavoidself",
					},
				},
			},
			-- Mana Void (miss)
			{
				type = "combatevent",
				eventtype = "SPELL_MISSED",
				spellid = {
					71086, -- 10
					71743, -- 25
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","manavoidself",
					},
				},
			},
			-- Dreamwalker's Rage
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71189,
				execute = {
					{
						"defeat",true
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
