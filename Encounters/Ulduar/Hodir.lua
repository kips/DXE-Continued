do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "hodir", 
		zone = L["Ulduar"], 
		name = L["Hodir"], 
		triggers = {
			scan = L["Hodir"], 
		},
		onactivate = {
			tracing = {L["Hodir"],},
			autostart = true,
			autostop = true,
			leavecombat = true,
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
				var = "flashfreezewarn", 
				varname = format(L["%s Cast"],SN[61968]),
				type = "centerpopup", 
				text = format("%s! %s!",SN[61968],L["MOVE"]),
				time = 9,
				flashtime = 9,
				sound = "ALERT1", 
				color1 = "BLUE",
				color2 = "GREEN",
			},
			flashfreezecd = {
				var = "flashfreezecd", 
				varname = format(L["%s Cooldown"],SN[61968]),
				type = "dropdown", 
				text = format(L["%s Cooldown"],SN[61968]),
				time = 50, 
				flashtime = 5,
				sound = "ALERT2", 
				color1 = "TURQUOISE",
				color2 = "TURQUOISE",
			},
			enragecd = {
				var = "enragecd",
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 480,
				flashtime = 5,
				color1 = "RED",
			},
			frozenblowdur = {
				var = "frozenblowdur", 
				varname = format(L["%s Duration"],SN[63512]),
				type = "centerpopup", 
				text = format(L["%s Duration"],SN[63512]),
				time = 20,
				flashtime = 20, 
				sound = "ALERT3", 
				color1 = "MAGENTA",
				color2 = "MAGENTA",
			},
			hardmodeends = {
				var = "hardmodeends",
				varname = format(L["%s Timer"],L["Hard Mode"]),
				type = "dropdown",
				text = format(L["%s Ends"],L["Hard Mode"]),
				time = 180,
				flashtime = 10,
				sound = "ALERT4",
				color1 = "YELLOW",
				color2 = "YELLOW",
			},
			stormcloudwarnself = {
				var = "stormcloudwarn",
				varname = format(L["%s Warning"],SN[65133]),
				type = "simple",
				text = format("%s: %s! %s!",SN[65133],L["YOU"],L["SPREAD IT"]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT4",
			},
			stormcloudwarnother = {
				var = "stormcloudwarn",
				varname = format(L["%s Warning"],SN[65133]),
				type = "simple",
				text = format("%s: #5#",SN[65133]),
				time = 1.5,
				color1 = "ORANGE",
				sound = "ALERT4",
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
