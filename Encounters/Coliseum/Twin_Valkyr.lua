do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local DE = SN[67176]
	local LE = SN[67223]

	local data = {
		version = 3,
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
				{alert = "enragecd"},
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				text = L["Enrage"],
				type = "dropdown",
				time = 360,
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
			darkpactwarn = {
				varname = L["Eydis"].." "..format(L["%s Cast"],SN[67308]),
				text = SN[67308].."!",
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				color1 = "INDIGO",
				sound = "ALERT3",
				icon = ST[65875],
			},
			lightpactwarn = {
				varname = L["Fjola"].." "..format(L["%s Cast"],SN[67308]),
				text = SN[67308].."!",
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				sound = "ALERT4",
				color1 = "YELLOW",
				icon = ST[65876],
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
		},
		events = {
			-- Dark Vortex
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67182, 
					66058,
					67183,
					67184,
				},
				execute = {
					{
						{alert = "darkvortexwarn"},
						{expect = {"&playerdebuff|"..LE.."&","==","true"}},
						{alert = "switchtodarkwarn"},
					},
				},
			},
			-- Light Vortex
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67206,
					66046,
					67207,
					67208,
				},
				execute = {
					{
						{alert = "lightvortexwarn"},
						{expect = {"&playerdebuff|"..DE.."&","==","true"}},
						{alert = "switchtolightwarn"},
					},
				},
			},
			-- Twin's Pact - Eydis - Dark
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67303,
					65875,
					67304,
					67305,
				},
				execute = {
					{
						{alert = "darkpactwarn"},
					},
				},
			},
			-- Twin's Pact - Eydis - Dark Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67303,
					65875,
					67304,
					67305,
				},
				execute = {
					{
						{quash = "darkpactwarn"},
					},
				},
			},
			-- Twin's Pact - Fjola - Light
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					65876,
					67306,
					67307,
					67308,
				},
				execute = {
					{
						{alert = "lightpactwarn"},
					},
				},
			},
			-- Twin's Pact - Fjola - Light Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					65876,
					67306,
					67307,
					67308,
				},
				execute = {
					{
						{quash = "lightpactwarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

