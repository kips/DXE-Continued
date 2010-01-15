do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local DE = SN[67176] -- Dark Essence
	local LE = SN[67223] -- Light Essence

	local data = {
		version = 16,
		key = "twinvalkyr", 
		zone = L.zone["Trial of the Crusader"], 
		category = L.zone["Coliseum"],
		name = L["Twin Val'kyr"], 
		triggers = {
			scan = {
				34496, -- Eydis Darkbane
				34497, -- Fjola Lightbane
			}, 
		},
		onactivate = {
			tracing = {
				34496, -- Eydis Darkbane
				34497, -- Fjola Lightbane
			},
			tracerstart = true,
			combatstop = true,
			defeat = 34496,
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"},
				"set",{vortextime = 6, enragetime = 360},
			},
			{
				"alert","enragecd",
				"alert","shieldvortexcd",
			},
		},
		userdata = {
			vortextime = 8,
			enragetime = 480,
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				text = L["Enrage"],
				type = "dropdown",
				time = "<enragetime>",
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			darkvortexwarn = {
				varname = format(L["%s Cast"],SN[67182]),
				text = format(L["%s Cast"],SN[67182]),
				type = "centerpopup",
				time = "<vortextime>",
				flashtime = 6,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[67184],
			},
			darkvortexdur = {
				varname = format(L["%s Channel"],SN[67182]),
				text = format(L["%s Channel"],SN[67182]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[67184],
			},
			lightvortexwarn = {
				varname = format(L["%s Cast"],SN[67206]),
				text = format(L["%s Cast"],SN[67206]),
				type = "centerpopup",
				time = "<vortextime>",
				flashtime = 6,
				color1 = "PURPLE",
				sound = "ALERT2",
				icon = ST[67208],
			},
			lightvortexdur = {
				varname = format(L["%s Channel"],SN[67206]),
				text = format(L["%s Channel"],SN[67206]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[67208],
			},
			shieldofdarknessdur = {
				varname = format(L["%s Duration"],SN[67256]),
				text = format("%s: #5#!",SN[67256]),
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				color1 = "INDIGO",
				sound = "ALERT3",
				icon = ST[67256],
			},
			shieldoflightdur = {
				varname = format(L["%s Duration"],SN[67259]),
				text = format("%s: #5#!",SN[67259]),
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				sound = "ALERT4",
				color1 = "YELLOW",
				icon = ST[67259],
			},
			twinspactwarn = {
				varname = format(L["%s Cast"],SN[67303]),
				text = format(L["%s Cast"],SN[67303]),
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				color1 = "ORANGE",
				icon = ST[67308],
			},
			switchtodarkwarn = {
				varname = format(L["%s Warning"],format(L["Switch to %s"],DE)),
				text = format(L["Switch to %s"],DE):upper().."!",
				type = "simple",
				time = 3,
				color1 = "BLACK",
				flashscreen = true,
				sound = "ALERT5",
				icon = ST[67176],
			},
			switchtolightwarn = {
				varname = format(L["%s Warning"],format(L["Switch to %s"],LE)),
				text = format(L["Switch to %s"],LE):upper().."!",
				type = "simple",
				time = 3,
				color1 = "WHITE",
				flashscreen = true,
				sound = "ALERT6",
				icon = ST[67223],
			},
			shieldvortexcd = {
				varname = format(L["%s Cooldown"],SN[56105].."/"..L["Shield"]),
				text = format(L["Next %s"],SN[56105].."/"..L["Shield"]),
				type = "dropdown",
				time = 45,
				flashtime = 10,
				color1 = "TEAL",
				sound = "ALERT7",
				icon = ST[56105],
			},
			empoweredlightself = {
				varname = format(L["%s on self"],SN[67217]),
				text = SN[67217].."!",
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				color1 = "GOLD",
				sound = "ALERT8",
				icon = ST[67217],
			},
			empowereddarkself = {
				varname = format(L["%s on self"],SN[67214]),
				text = SN[67214].."!",
				type = "centerpopup",
				time = 20,
				flashtime = 20,
				color1 = "BLUE",
				sound = "ALERT8",
				icon = ST[67214],
			},
			touchlightself = {
				varname = format(L["%s on self"],SN[67298]),
				text = format("%s: %s!",SN[67298],L["YOU"]),
				type = "centerpopup",
				time = 20,
				flashtime = 20,
				color1 = "MAGENTA",
				icon = ST[67298],
			},
			touchdarkself = {
				varname = format(L["%s on self"],SN[67283]),
				text = format("%s: %s!",SN[67283],L["YOU"]),
				type = "centerpopup",
				time = 20,
				flashtime = 20,
				color1 = "MAGENTA",
				icon = ST[67283],
			},
		},
		events = {
			-- Twin's Pact
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67305,
					67304,
					67303,
					65875,
					65876,
					67308,
					67307,
					67306,
				},
				execute = {
					{
						"alert","twinspactwarn",
					},
				},
			},
			-- Twin's Pact interrupt
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				spellid2 = {
					67305,
					67304,
					67303,
					65875,
					65876,
					67308,
					67307,
					67306,
				},
				execute = {
					{
						"quash","twinspactwarn",
					},
				},
			},
			-- Empowered Light
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67217, -- 10 hard
					65748, -- 10 normal
					67216, -- 25 normal
					67218,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","empoweredlightself",
					},
				},
			},
			-- Empowered Darkness
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67214, -- 10 hard
					65724, -- 10 normal
					67213, -- 25 normal
					67215,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","empowereddarkself",
					},
				},
			},
			-- Dark Vortex Cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67182, -- 25 normal
					66058, -- 10 normal
					67183, -- 10 hard
					67184, -- 25 hard
				},
				execute = {
					{
						"alert","darkvortexwarn",
						"alert","shieldvortexcd",
						"expect",{"&playerdebuff|"..LE.."&","==","true"},
						"alert","switchtodarkwarn",
					},
				},
			},
			-- Dark Vortex Channel
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67182, -- 25 normal
					66058, -- 10 normal
					67183, -- 10 hard
					67184, -- 25 hard
				},
				execute = {
					{
						"quash","darkvortexwarn",
						"alert","darkvortexdur",
					},
				},
			},
			-- Light Vortex Cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67206, -- 25 normal
					66046, -- 10 normal
					67207, -- 10 hard
					67208, -- 25 hard
				},
				execute = {
					{
						"alert","lightvortexwarn",
						"alert","shieldvortexcd",
						"expect",{"&playerdebuff|"..DE.."&","==","true"},
						"alert","switchtolightwarn",
					},
				},
			},
			-- Light Vortex Channel
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67206, -- 25 normal
					66046, -- 10 normal
					67207, -- 10 hard
					67208, -- 25 hard
				},
				execute = {
					{
						"quash","lightvortexwarn",
						"alert","lightvortexdur",
					},
				},
			},
			-- Shield of Darkness 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67256, -- 25 normal
					65874,
					67257, -- 10 hard
					67258,
				},
				execute = {
					{
						"alert","shieldofdarknessdur",
						"alert","shieldvortexcd",
					},
				},
			},
			-- Shield of Darkness Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67256, -- 25 normal
					65874,
					67257, -- 10 hard
					67258,
				},
				execute = {
					{
						"quash","shieldofdarknessdur",
					},
				},
			},
			-- Shield of Lights
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67259, -- 25 normal
					65858, -- 10 normal
					67260,
					67261,
				},
				execute = {
					{
						"alert","shieldoflightdur",
						"alert","shieldvortexcd",
					},
				},
			},
			-- Shield of Lights Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67259, -- 25 normal
					65858, -- 10 normal
					67260,
					67261,
				},
				execute = {
					{
						"quash","shieldoflightdur",
					},
				},
			},
			-- Touch of Darkness
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67283, -- 25 hard
					66001,
					67281,
					67282,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","switchtodarkwarn",
						"alert","touchdarkself",
					},
				},
			},
			-- Touch of Darkness removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67283, -- 25 hard
					66001,
					67281,
					67282,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","touchdarkself",
					},
				},
			},
			-- Touch of Light
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67298, -- 25 hard
					67297,
					67296,
					65950,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","switchtolightwarn",
						"alert","touchlightself",
					},
				},
			},
			-- Touch of Light removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67298, -- 25 hard
					67297,
					67296,
					65950,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","touchlightself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
