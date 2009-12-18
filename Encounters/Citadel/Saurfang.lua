do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 2,
		key = "saurfang", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Saurfang"], 
		triggers = {
			scan = {
				37813, -- Deathbringer Saurfang
			},
			--yell = ,
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"},
				"set",{bloodbeasttime = 40}, -- TODO: verify normal mode time
			},
		},
		userdata = {
			bloodbeasttime = 30,
			bloodtext = "",
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
				time = "<bloodbeasttime>",
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
				icon = ST[72410],
			},
			markfallenwarn = {
				varname = format(L["%s Cast"],SN[72293]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[72293]),
				time = 1.5,
				flashtime = 1.5,
				color1 = "ORANGE",
				icon = ST[72293],
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
		},
	}
	-- mark of the fallen champion warning cooldown
	DXE:RegisterEncounter(data)
end
