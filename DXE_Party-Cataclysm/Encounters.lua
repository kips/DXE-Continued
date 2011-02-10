local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- Ascendant Lord Obsidius
---------------------------------

do
	local data = {
		version = 1,
		key = "ascendantlordobsidius",
		zone = L.zone["BlackrockCaverns"],
		category = L.zone["Heroics"],
		name = L.npc_heroics["Ascendant Lord Obsidius"],
		triggers = {
			scan = {
				39705, -- Ascendant Lord Obsidius
			},
		},
		onactivate = {
			tracing = {
				39705, -- Ascendant Lord Obsidius 
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				39705, -- Ascendant Lord Obsidius 
			},
		},
		alerts = {
			vielwarn = {
				varname = format(L.alert["%s Warning"],SN[76189]),
				type = "simple",
				text = "<vieltext>",
				time = 4,
				color1 = "RED",
				icon = ST[76189],
			},
			
			transformwarn = {
				varname = format(L.alert["%s Duration"],SN[76200]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[76200]),
				time = 3,
				flashtime = 3,
				sound = "ALERT4",
				color1 = "MAGENTA",
				icon = ST[76200],
			},
			
			corruptwarn = {
				varname = format(L.alert["%s Duration"],SN[76188]),
				type = "centerpopup",
				text = "<corrupttext>",
				time = 12,
				sound = "ALERT4",
				color1 = "MAGENTA",
				icon = ST[76188],
			},
		},
		windows = {
			proxwindow = false,
		},
		events = {
			-- Twilight Corruption
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 76188,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{corrupttext = format("%s: %s!",SN[76188],L.alert["YOU"])},
						"alert","coprrutpwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{coprruttext = format("%s: #5#!",SN[76188])},
						"alert","coprruptwarn",
					},
				},
			},
			
			-- Crepuscular Veil
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 76189,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{vieltext = format("%s: %s!",SN[76189],L.alert["YOU"])},
						"alert","vielwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{vieltext = format("%s: #5#!",SN[76189])},
						"alert","vielwarn",
					},
				},
			},
			
			-- Crepuscular Veil Dose
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 76189,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{vieltext = format("%s: %s! %s!",SN[76189],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","vielwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{vieltext = format("%s: #5#! %s!",SN[76189],format(L.alert["%s Stacks"],"#11#")) },
						"alert","vielwarn",
					},
				},
			},
			
			-- Transformation
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 76200,
				execute = {
					{
						"alert","transformwarn",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

---------------------------------
-- Beauty
---------------------------------

do
	local data = {
		version = 1,
		key = "beauty",
		zone = L.zone["BlackrockCaverns"],
		category = L.zone["Heroics"],
		name = L.npc_heroics["Beauty"],
		triggers = {
			scan = {
				39700, -- Beauty
			},
		},
		onactivate = {
			tracing = {
				39700, -- Beauty
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				39700, -- Beauty
			},
		},
		userdata = {
			roartime = {27, 30, loop = false, type = "series"},
		},
		onstart = {
			{
				"alert","roarcd",
				"set",{roartime = {27, 30, loop = false, type = "series"},},
			},
		},
		alerts = {
			roarwarn = {
				varname = format(L.alert["%s Duration"],SN[76028]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[76028]),
				time = 4,
				flashtime = 4,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[76028],
			},
			
			roarcd = {
				varname = format(L.alert["%s Cooldown"],SN[76028]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[76028]),
				time = "<roartime>",
				color1 = "GREY",
				flashtime = 10,
				icon = ST[76028],
			},
			
			spitwarn = {
				varname = format(L.alert["%s Warning"],SN[76031]),
				type = "centerpopup",
				text = format(L.alert["%s Warning"],SN[76031]),
				time = 3,
				sound = "ALERT4",
				color1 = "MAGENTA",
				icon = ST[76031],
			},
			
			spitduration = {
				varname = format(L.alert["%s Duration"],SN[76031]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[76031]),
				time = 9,
				sound = "ALERT4",
				color1 = "MAGENTA",
				icon = ST[76031],
			},
		},
		windows = {
			proxwindow = false,
		},
		events = {
			-- Terrifying Roar
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 76028,
				execute = {
					{
						"alert","roarcd",
						"alert","roarwarn",
					},
				},
			},
			
			-- Magma Spit
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 76031,
				execute = {
					{
						"alert","spitwarn",
						"alert","spitduration",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end

---------------------------------
-- Corla
---------------------------------

do
	local data = {
		version = 1,
		key = "corla",
		zone = L.zone["BlackrockCaverns"],
		category = L.zone["Heroics"],
		name = L.npc_heroics["Corla, Herald of Twilight"],
		triggers = {
			scan = {
				39679, -- Corla
			},
		},
		onactivate = {
			tracing = {
				39679, -- Corla
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				39679, -- Corla
			},
		},
		userdata = {
			commandtime = {22, 25, loop = false, type = "series"},
		},
		onstart = {
			{
				"alert","commandcd",
				"set",{commandtime = {22, 25, loop = false, type = "series"},},
			},
		},
		alerts = {
			commandwarn = {
				varname = format(L.alert["%s Duration"],SN[75823]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[75823]),
				time = 4,
				flashtime = 4,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[75823],
			},
			
			commandcd = {
				varname = format(L.alert["%s Cooldown"],SN[75823]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[75823]),
				time = "<commandtime>",
				color1 = "GREY",
				flashtime = 10,
				icon = ST[75823],
			},
			
			evolutionalert = {
				varname = format(L.alert["%s on self"],SN[75697]),
				type = "centerpopup",
				text = "<evolutiontext>",
				time = 15,
				flashtime = 1,
				color1 = "VIOLET",
				icon = ST[75697],
			},
		},
		windows = {
			proxwindow = false,
		},
		events = {
			-- Dark Command
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 75823,
				execute = {
					{
						"alert","commandcd",
						"alert","commandwarn",
					},
				},
			},
			
			-- Evolution Normal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 75697,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","evolutionalert",
					},
				},
			},
			
			-- Evolution Heroic
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 87378,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","evolutionalert",
					},
				},
			},
			
			
			-- Evolution Normal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 75697,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","evolutionalert",
						"set",{evolutiontext = format("%s: %s! %s!",SN[75697],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","evolutionalert",
					},
				},
			},
			
			-- Evolution Heroic
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 87378,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","evolutionalert",
						"set",{evolutiontext = format("%s: %s! %s!",SN[75697],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","evolutionalert",
					},
				},
			},
			
			
			
			
		},
	}
	DXE:RegisterEncounter(data)
end

---------------------------------
-- Romogg
---------------------------------

do
	local data = {
		version = 1,
		key = "romogg",
		zone = L.zone["BlackrockCaverns"],
		category = L.zone["Heroics"],
		name = L.npc_heroics["Romogg Bonecrusher"],
		triggers = {
			scan = {
				39665, -- Corla
			},
		},
		onactivate = {
			tracing = {
				39665, -- Corla
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				39665, -- Corla
			},
		},
		userdata = {
			quaketime = {19, 19, loop = false, type = "series"},
		},
		onstart = {
			{
				"alert","quakecd",
				"set",{quaketime = {19, 19, loop = false, type = "series"},},
			},
		},
		alerts = {
			quakewarn = {
				varname = format(L.alert["%s !"],SN[75272]),
				type = "centerpopup",
				text = format(L.alert["%s !"],SN[75272]),
				time = 3,
				flashtime = 3,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[75272],
			},
			
			quakecd = {
				varname = format(L.alert["%s Cooldown"],SN[75272]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[75272]),
				time = "<commandtime>",
				color1 = "GREY",
				flashtime = 10,
				icon = ST[75272],
			},
			
			chainswarn = {
				varname = format(L.alert["%s"],SN[75539]),
				type = "centerpopup",
				text = format(L.alert["%s !"],SN[75539]),
				time = 12,
				flashtime = 12,
				color1 = "VIOLET",
				icon = ST[75539],
			},
		},
		windows = {
			proxwindow = false,
		},
		events = {
			-- Dark Command
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 75272,
				execute = {
					{
						"alert","quakecd",
						"alert","quakewarn",
					},
				},
			},
			
			-- Chains of Woe
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 75539,
				execute = {
					{
						"alert","chainswarn",
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end