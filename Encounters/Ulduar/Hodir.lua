do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 296,
		key = "hodir", 
		zone = L["Ulduar"], 
		name = L["Hodir"], 
		triggers = {
			scan = 32845, -- Hodir
		},
		onactivate = {
			tracing = {32845}, -- Hodir
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {},
		onstart = {
			{
				{alert = "enragecd"},
				{alert = "flashfreezecd"},
				{alert = "hardmodeends"},
			},
		},
		alerts = {
			flashfreezewarn = {
				varname = format(L["%s Cast"],SN[61968]),
				type = "centerpopup", 
				text = format("%s! %s!",SN[61968],L["MOVE"]),
				time = 9,
				flashtime = 9,
				sound = "ALERT1", 
				color1 = "BLUE",
				color2 = "GREEN",
				flashscreen = true,
				icon = ST[61968],
			},
			flashfreezecd = {
				varname = format(L["%s Cooldown"],SN[61968]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],SN[61968]),
				time = 50, 
				flashtime = 5,
				sound = "ALERT2", 
				color1 = "TURQUOISE",
				color2 = "TURQUOISE",
				icon = ST[61968],
			},
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 480,
				flashtime = 5,
				color1 = "RED",
				icon = ST[12317],
			},
			frozenblowdur = {
				varname = format(L["%s Duration"],SN[63512]),
				type = "centerpopup", 
				text = format(L["%s Duration"],SN[63512]),
				time = 20,
				flashtime = 20, 
				sound = "ALERT3", 
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				icon = ST[63512],
			},
			hardmodeends = {
				varname = format(L["%s Timer"],L["Hard Mode"]),
				type = "dropdown",
				text = format(L["%s Ends"],L["Hard Mode"]),
				time = 180,
				flashtime = 10,
				sound = "ALERT4",
				color1 = "YELLOW",
				color2 = "YELLOW",
				icon = ST[20573],
			},
			stormcloudwarnself = {
				varname = format(L["%s on self"],SN[65133]),
				type = "simple",
				text = format("%s: %s! %s!",SN[65133],L["YOU"],L["SPREAD IT"]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT4",
				flashscreen = true,
				icon = ST[65133],
			},
			stormcloudwarnother = {
				varname = format(L["%s on others"],SN[65133]),
				type = "simple",
				text = format("%s: #5#",SN[65133]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT4",
				icon = ST[65133],
			},
		},
		announces = {
			stormcloudsay = {
				varname = format(L["Say %s on self"],SN[65133]),
				type = "SAY",
				msg = format(L["%s on Me"],SN[65133]).."!",
			},
		},
		events = {
			-- Flash Freeze cast
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_START",
				spellid = 61968, 
				execute = {
					{
						{alert = "flashfreezewarn"},
						{alert = "flashfreezecd"},
					},
				},
			},
			-- Frozen Blow
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {62478,63512},
				execute = {
					{
						{alert = "frozenblowdur"},
					},
				},
			},
			-- Storm Cloud
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {65133,65123},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "stormcloudwarnself"},
						{announce = "stormcloudsay"},
					},
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "stormcloudwarnother"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
