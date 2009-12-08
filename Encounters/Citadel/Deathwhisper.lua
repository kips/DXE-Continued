do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "deathwhisper", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Deathwhisper"], 
		triggers = {
			scan = {
				36855, -- Lady Deathwhisper
			},
			yell = L["^What is this disturbance"],
		},
		onactivate = {
			combatstop = true,
			tracing = {36855}, -- Lady Deathwhisper
		},
		alerts = {
			dndself = {
				varname = format(L["%s on self"],SN[71001]),
				text = format("%s: %s!",SN[71001],L["YOU"]),
				type = "simple",
				time = 3,
				sound = "ALERT1",
				color1 = "PURPLE",
				icon = ST[71001],
				flashscreen = true,
			},
		},
		events = {
			-- Death and Decay self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71001,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","dndself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
