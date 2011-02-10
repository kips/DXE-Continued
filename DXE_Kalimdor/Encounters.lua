local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ONYXIA
---------------------------------

do
	local data = {
		version = 5,
		key = "onyxia",
		zone = L.zone["Onyxia's Lair"],
		category = L.zone["Kalimdor"],
		name = L.npc_kalimdor["Onyxia"],
		triggers = {
			yell = L.chat_kalimdor["^How fortuitous. Usually, I must leave my"],
			scan = {
				10184, -- Onyxia
			},
		},
		onactivate = {
			tracing = {10184}, -- Onyxia
			combatstop = true,
			defeat = 10184,
		},
		alerts = {
			bellowwarn = {
				varname = format(L.alert["%s Casting"],SN[18431]),
				text = format(L.alert["%s Casting"],SN[18431]),
				type = "centerpopup",
				time = 2.5,
				flashtime = 2.5,
				sound = "ALERT1",
				color1 = "BROWN",
				flashscreen = true,
				icon = ST[39427],
			},
			breathwarn = {
				varname = format(L.alert["%s Casting"],SN[68970]),
				text = format(L.alert["%s Casting"],SN[68970]),
				type = "centerpopup",
				time = 2,
				flashtime = 2,
				sound = "ALERT2",
				color1 = "ORANGE",
				icon = ST[68970],
			},
			deepbreathwarn = {
				varname = format(L.alert["%s Casting"],L.alert["Deep Breath"]),
				text = format(L.alert["%s Casting"],L.alert["Deep Breath"]).." "..L.alert["MOVE"].."!",
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
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_kalimdor["deep breath"]},
						"alert","deepbreathwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
