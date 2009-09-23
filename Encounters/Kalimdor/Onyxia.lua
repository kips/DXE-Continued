do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "onyxia", 
		zone = L["Onyxia's Lair"], 
		category = L["Kalimdor"],
		name = L["Onyxia"], 
		triggers = {
			yell = L["^How fortuitous. Usually, I must leave my"],
			scan = {
				10184, -- Onyxia
			}, 
		},
		onactivate = {
			tracing = {10184}, -- Onyxia
			combatstop = true,
		},
		alerts = {
			bellowwarn = {
				varname = format(L["%s Cast"],SN[18431]),
				text = format(L["%s Cast"],SN[18431]),
				type = "centerpopup",
				time = 2.5,
				flashtime = 2.5,
				sound = "ALERT1",
				color1 = "BROWN",
				flashscreen = true,
				icon = ST[39427],
			},
			breathwarn = {
				varname = format(L["%s Cast"],SN[68970]),
				text = format(L["%s Cast"],SN[68970]),
				type = "centerpopup",
				time = 2,
				flashtime = 2,
				sound = "ALERT2",
				color1 = "ORANGE",
				icon = ST[68970],
			},
		},
		events = {
			-- Bellowing Roar
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 18431,
				execute = {
					{
						"alert","bellowwarn",
					},
				},
			},
			-- Flame Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 68970,
				execute = {
					{
						"alert","breathwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


