do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "valithria", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Valithria"], 
		triggers = {
			scan = 36789,
			yell = L["^Heroes, lend me your aid"],
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
		alerts = {
			portalcd = {
				varname = format(L["%s Cooldown"],L["Portals"]),
				type = "dropdown",
				text = format(L["%s Cooldown"],L["Portals"]),
				time = 45,
				flashtime = 10,
				sound = "ALERT1",
				color1 = "GREEN",
				icon = ST[57676],
			},
			portalwarn = {
				varname = format(L["%s Warning"],L["Portals"]),
				type = "simple",
				text = format(L["%s Spawned"],L["Portals"]).."!",
				time = 3,
				sound = "ALERT2",
				icon = ST[57676],
			},
			manavoidself = {
				varname = format(L["%s on self"],SN[71743]),
				type = "simple",
				text = format("%s: %s! %s!",SN[71743],L["YOU"],L["MOVE AWAY"]),
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
						"expect",{"#1#","find",L["^I have opened a portal into the Dream"]},
						"alert","portalwarn",
						"alert","portalcd",
					},
				},
			},
			-- Mana Void
			{
				type = "combatevent",
				eventtype = "SPELL_MISSED",
				spellid = 71743,
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
