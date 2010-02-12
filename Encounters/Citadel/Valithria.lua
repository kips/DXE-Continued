do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 9,
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
			defeat = L.chat_citadel["^I AM RENEWED!"],
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","portalcd",
				--"alert","blazingskeletoncd",
				--"scheduletimer",{"fireblazing",35},
			},
		},
		userdata = {
			portaltime = {33,45, loop = false, type = "series"},
			corrosiontext = "",
			blazingtime = {35,60, loop = false, type = "series"}, -- unknown
		},
		timers = {
			firelaywaste = {
				{
					"quash","laywastewarn",
					"alert","laywastedur",
				}
			},
			fireportaldur = {
				{
					"quash","portalwarn",
					"alert","portaldur",
				}
			},
			fireblazing = {
				{
					"alert","blazingskeletoncd",
					"scheduletimer",{"fireblazing",60},
				},
			},
		},
		alerts = {
			enragecd = {
				varname = L.alert["Soft Enrage"],
				type = "dropdown",
				text = L.alert["Soft Enrage"],
				time = 420,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			blazingskeletoncd = {
				varname = format(L.alert["%s Spawns"],L.npc_citadel["Blazing Skeleton"]),
				type = "dropdown",
				text = format(L.alert["%s Spawns"],L.npc_citadel["Blazing Skeleton"]),
				time = 35,
				flashtime = 10,
				color1 = "YELLOW",
				icon = ST[49264],
			},
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
				type = "centerpopup",
				text = format(L.alert["%s Soon"],L.alert["Portals"]).."!",
				time = 15,
				sound = "ALERT2",
				color1 = "GREEN",
				icon = ST[57676],
			},
			portaldur = {
				varname =  format(L.alert["%s Duration"],L.alert["Portals"]),
				type = "centerpopup",
				text =  format(L.alert["%s Duration"],L.alert["Portals"]),
				time = 10,
				sound = "ALERT7",
				color1 = "GREEN",
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
			laywastewarn = {
				varname = format(L.alert["%s Warning"],SN[69325]),
				type =  "centerpopup",
				text = format(L.alert["%s Soon"],SN[69325]),
				time = 2,
				sound = "ALERT4",
				color1 = "ORANGE",
				icon = ST[69325],
			},
			laywastedur = {
				varname = format(L.alert["%s Duration"],SN[69325]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[69325]),
				time = 12,
				flashtime = 12,
				color1 = "ORANGE",
				icon = ST[69325],
			},
			gutspraywarn = {
				varname = format(L.alert["%s Warning"],SN[70633]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[70633]),
				time = 3,
				sound = "ALERT5",
				icon = ST[70633],
			},
			corrosionself = {
				varname = format(L.alert["%s on self"],SN[70751]),
				type = "centerpopup",
				text = "<corrosiontext>",
				time = 6,
				flashtime = 6,
				sound = "ALERT6",
				color1 = "CYAN",
				icon = ST[70751],
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
						"scheduletimer",{"fireportaldur",15},
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
					72030, -- 25h
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
					72030, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","manavoidself",
					},
				},
			},
			-- Lay Waste
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69325, -- 10
					71730, -- 25, 25h
				},
				execute = {
					{
						"alert","laywastewarn",
						"scheduletimer",{"firelaywaste",2},
					},
				},
			},
			-- Lay Waste removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					69325, -- 10
					71730, -- 25, 25h
				},
				execute = {
					{
						"quash","laywastewarn",
						"canceltimer","firelaywaste",
						"quash","laywastedur",
					},
				},
			},
			-- Gut Spray
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					70633, -- 10
					71283, -- 25
					72026, -- 25h
				},
				execute = {
					{
						"alert","gutspraywarn",
					}
				},
			},
			-- Corrosion
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					70751, -- 10
					71738, -- 25
					72022, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{corrosiontext = format("%s: %s!",SN[70751],L.alert["YOU"])},
						"alert","corrosionself",
					},
				},
			},
			-- Corrosion applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					70751, -- 10
					71738, -- 25
					72022, -- 25h
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","corrosionself",
						"set",{corrosiontext = format("%s: %s! %s!",SN[70751],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","corrosionself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
