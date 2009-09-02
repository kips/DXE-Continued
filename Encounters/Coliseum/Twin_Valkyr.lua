do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local DE = SN[67176] -- Dark Essence
	local LE = SN[67223] -- Light Essence

	local data = {
		version = 9,
		key = "twinvalkyr", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
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
		},
		onstart = {
			{
				"alert","enragecd",
				"alert","shieldvortexcd",
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				text = L["Enrage"],
				type = "dropdown",
				time = 480,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			darkvortexwarn = {
				varname = format(L["%s Cast"],SN[67182]),
				text = format(L["%s Cast"],SN[67182]),
				type = "centerpopup",
				time = 8,
				flashtime = 8,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[67184],
			},
			lightvortexwarn = {
				varname = format(L["%s Cast"],SN[67206]),
				text = format(L["%s Cast"],SN[67206]),
				type = "centerpopup",
				time = 8,
				flashtime = 8,
				color1 = "PURPLE",
				sound = "ALERT2",
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
		},
		events = {
			-- Dark Vortex
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67182, -- 25 normal
					66058, -- 10 normal
					67183,
					67184,
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
			-- Light Vortex
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67206, -- 25 normal
					66046, -- 10 normal
					67207,
					67208,
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
			-- Shield of Darkness 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67256, -- 25 normal
					65874,
					67257,
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
					67257,
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
		},
	}

	DXE:RegisterEncounter(data)
end

