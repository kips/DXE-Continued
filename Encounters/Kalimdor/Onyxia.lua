do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 2,
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
			deepbreathwarn = {
				varname = format(L["%s Cast"],L["Deep Breath"]),
				text = format(L["%s Cast"],L["Deep Breath"]).." "..L["MOVE"].."!",
				type = "centerpopup",
				time = 8,
				flashtime = 8,
				sound = "ALERT5",
				color1 = "MAGENTA",
				color2 = "YELLOW",
				icon = ST[67328],
				flashscreen = true,
			},
		},
		events = {
			-- Bellowing Roar
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 18431, -- 25
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
				spellid = 68970, -- 25
				execute = {
					{
						"alert","breathwarn",
					},
				},
			},
			-- Deep Breath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 18596, -- 25
				execute = {
					{
						"alert","deepbreathwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


