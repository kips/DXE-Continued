do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local faction = UnitFactionGroup("player")

	local defeat_msg,portal_msg,add,portal_icon
	if faction == "Alliance" then
		defeat_msg = L["^Don't say I didn't warn ya"]
		portalmsg = L["^Reavers, Sergeants, attack"]
		add = L["Reaver"]
		portal_icon = "Interface\\Icons\\achievement_pvp_h_04"
	elseif faction == "Horde" then
		defeat_msg = L["^The Alliance falter"]
		portal_msg = L["^Marines, Sergeants, attack"]
		add = L["Marine"] 
		portal_icon = "Interface\\Icons\\achievement_pvp_a_04"
	end

	local data = {
		version = 3,
		key = "gunshipbattle", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Gunship Battle"], 
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
			portaltime = {12,60,loop = false}, -- TODO: initial time
		},
		onstart = {
			{
				"alert","portalcd",
			},
		},
		alerts = {
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
						"expect",{"#1#","==",portal_msg},
						"alert","portalcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
