do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
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
				color1 = "BLUE",
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
				varname = SN[67308].."!",
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
		},
		events = {
			-- Dark Vortex
			{
				eventtype = "combatevent",
				combatevent = "SPELL_CAST_START",
				spellid = {
					67182, 
					66058,
					67183,
					67184,
				},
				execute = {
					{
						{alert = "darkvortexwarn"},
					},
				},
			},
			-- Light Vortex
			{
				eventtype = "combatevent",
				combatevent = "SPELL_CAST_START",
				spellid = {
					67206,
					66046,
					67207,
					67208,
				},
				execute = {
					{
						{alert = "lightvortexwarn"},
					},
				},
			},
			-- Twin's Pact - Eydis - Dark
			{
				eventtype = "combatevent",
				combatevent = "SPELL_CAST_START",
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
				eventtype = "combatevent",
				combatevent = "SPELL_AURA_REMOVED",
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
				eventtype = "combatevent",
				combatevent = "SPELL_CAST_START",
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
				eventtype = "combatevent",
				combatevent = "SPELL_AURA_REMOVED",
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
