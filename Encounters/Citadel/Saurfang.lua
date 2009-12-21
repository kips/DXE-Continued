do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 4,
		key = "saurfang", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Saurfang"], 
		triggers = {
			scan = {
				37813, -- Deathbringer Saurfang
			},
		},
		userdata = {
			bloodtext = "",
			markfallentext = "",
		},
		onactivate = {
			tracerstart = true,
			combatstop = true,
			tracing = {37813}, -- Deathbringer Saurfang
			defeat = 37813,
		},
		alerts = {
			bloodbeastwarn = {
				varname = format(L["%s Warning"],SN[72172]),
				text = format(L["%s Casted"],SN[72172]).."!",
				type = "simple",
				time = 3,
				sound = "ALERT5",
				icon = ST[72172],
			},
			bloodbeastcd = {
				varname = format(L["%s Cooldown"],SN[72172]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[72172]),
				time = 40,
				flashtime = 10,
				color1 = "PURPLE",
				icon = ST[72173],
			},
			runeofbloodwarn = {
				varname = format(L["%s Warning"],SN[72410]),
				type = "simple",
				text = "<bloodtext>",
				time = 3,
				color1 = "BROWN",
				sound = "ALERT3",
				icon = ST[72410],
			},
			markfallenwarn = {
				varname = format(L["%s Cast"],SN[28836]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[72293]),
				time = 1.5,
				flashtime = 1.5,
				color1 = "ORANGE",
				sound = "ALERT1",
				icon = ST[72293],
			},
			markfallen2warn = {
				varname = format(L["%s Warning"],SN[28836]),
				type = "simple",
				text = "<markfallentext>",
				time = 3,
				color1 = "PEACH",
				sound = "ALERT4",
				icon = ST[72293],
			},
			frenzywarn = {
				varname = format(L["%s Warning"],SN[72737]),
				type = "simple",
				text = format(L["%s Warning"],SN[72737]),
				time = 3,
				sound = "ALERT6",
				color1 = "ORANGE",
				icon = ST[72737],
			},
		},
		windows = {
			proxwindow = true,
		},
		events = {
			-- Call Blood Beast
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				-- There are five different spellids for this
				-- 72172, 72173, 72356, 72357, 72358
				spellid = {
					72172, -- 25
				},
				execute = {
					{
						"alert","bloodbeastwarn",
						"alert","bloodbeastcd",
					},
				},
			},
			-- Rune of Blood
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					72410, -- 25 and 25 hard
				},
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{bloodtext = format("%s: #5#!",SN[72410])},
						"alert","runeofbloodwarn",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{bloodtext = format("%s: %s!",SN[72410],L["YOU"])},
						"alert","runeofbloodwarn",
					},
				},
			},
			-- Mark of the Fallen
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 72293, -- 25 and 25 hard
				execute = {
					{
						"alert","markfallenwarn",
					},
				},
			},
			-- Mark of the Fallen applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 72293,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{markfallentext = format("%s: %s!",SN[72293],L["YOU"])},
						"alert","markfallen2warn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{markfallentext = format("%s: #5#!",SN[72293])},
						"alert","markfallen2warn",
					},
				},
			},
			-- Frenzy
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 72737,
				execute = {
					{
						"alert","frenzywarn",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end
