do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local faction = UnitFactionGroup("player")

	local defeat_msg,portal_msg,add,portal_icon,faction_npc
	if faction == "Alliance" then
		defeat_msg = L["^Don't say I didn't warn ya"]
		portal_msg = L["^Reavers, Sergeants, attack"]
		add = L["Reaver"]
		portal_icon = "Interface\\Icons\\achievement_pvp_h_04"
		faction_npc = "36939" -- Saurfang
	elseif faction == "Horde" then
		defeat_msg = L["^The Alliance falter"]
		portal_msg = L["^Marines, Sergeants, attack"]
		add = L["Marine"] 
		portal_icon = "Interface\\Icons\\achievement_pvp_a_04"
		faction_npc = "36948" -- Muradin
	end

	local data = {
		version = 7,
		key = "gunshipbattle", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = L.npc_citadel["Gunship Battle"], 
		title = L["Gunship Battle"], 
		triggers = {
			scan = {
				36939, -- Saurfang
				36948, -- Muradin
			},
			yell = {
				L["^Cowardly dogs"], -- Alliance
				L["^ALLIANCE GUNSHIP"], -- Horde
			},
		},
		onactivate = {
			combatstop = true,
			unittracing = {"boss1","boss2"},
			defeat = defeat_msg,
		},
		userdata = {
			portaltime = {11.5,60,loop = false}, -- TODO: initial time
			belowzerotime = {34,47,loop = false},
			battlefurytext = "",
		},
		onstart = {
			{
				"alert","portalcd",
				"alert","belowzerocd",
			},
		},
		alerts = {
			belowzerocd = {
				varname = format(L["%s Cooldown"],SN[69705]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[69705]),
				time = "<belowzerotime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "INDIGO",
				icon = ST[69705],
			},
			belowzerowarn = {
				varname = format(L["%s Channel"],SN[69705]),
				type = "centerpopup",
				text = format(L["%s Channel"],SN[69705]),
				time = 900,
				flashtime = 900,
				color1 = "BLUE",
				sound = "ALERT5",
				icon = ST[69705],
			},
			portalcd = {
				varname = format(L["%s Spawns"],add.."/"..L["Sergeant"]),
				type = "dropdown",
				text = format(L["%s Spawns"],add.."/"..L["Sergeant"]),
				time = "<portaltime>",
				flashtime = 10,
				color1 = "GOLD",
				sound = "ALERT1",
				icon = portal_icon,
			},
			battlefurydur = {
				varname = format(L["%s Duration"],SN[69638]),
				type = "centerpopup",
				text = "<battlefurytext>",
				time = 20,
				flashtime = 20,
				color1 = "ORANGE",
				icon = ST[69638],
			},
		},
		events = {
			-- Below Zero
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 69705,
				execute = {
					{
						"alert","belowzerowarn",
						"alert","belowzerocd",
					},
				},
			},
			-- Below Zero removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 69705,
				execute = {
					{
						"quash","belowzerowarn",
					},
				},
			},
			-- Portals
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",portal_msg},
						"alert","portalcd",
					},
				},
			},
			-- Battle Fury
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					69638, -- 10
					72306, -- 25
				},
				execute = {
					{
						"expect",{"&npcid|#4#&","==",faction_npc},
						"set",{battlefurytext = format("%s: #2#!",SN[69638])},
						"alert","battlefurydur",
					},
				},
			},
			-- Battle Fury applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					69638, -- 10
					72306, -- 25
				},
				execute = {
					{
						"expect",{"&npcid|#4#&","==",faction_npc},
						"quash","battlefurydur",
						"set",{battlefurytext = format("%s => %s!",SN[69638], format(L["%s Stacks"],"#11#"))},
						"alert","battlefurydur",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
