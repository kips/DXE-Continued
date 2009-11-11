do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "valithria", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Valithria"], 
		triggers = {
			--scan = ,
			yell = L["^Heroes, lend me your aid"],
		},
		onactivate = {
			combatstop = true,
			--tracing = ,
		},
		events = {
			{
				type = "event",
				event = "YELL",
				execute = {
					{
						"expect",{"#1#","find",L["^I have opened a portal into the Dream"]},
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
