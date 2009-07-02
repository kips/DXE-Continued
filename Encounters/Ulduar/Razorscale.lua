do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "razorscale", 
		zone = "Ulduar", 
		name = "Razorscale", 
		triggers = {
			scan = {
				L["Razorscale"],
				L["Dark Rune Guardian"],
				L["Dark Rune Sentinel"],
				L["Dark Rune Watcher"],
			}, 
			yell = L["^Be on the lookout! Mole machines"],
		},
		onactivate = {
			tracing = {L["Razorscale"],},
			leavecombat = true,
		},
		onstart = {
			{
				{alert = "enragecd"},
			},
		},
		userdata = {},
		alerts = {
			enragecd = {
				var = "enragecd",
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 900,
				flashtime = 5,
				color1 = "RED",
				color2 = "RED",
				sound = "ALERT6",
			},
			devourwarnself = {
				var = "devourwarnself",
				varname = format(L["%s on self"],SN[63014]),
				type = "simple",
				text = format(L["Move Out of %s"],SN[63014]).."!",
				time = 1.5,
				color1 = "RED",
				sound = "ALERT1",
			},
			breathwarn = {
				var = "breathwarn",
				varname = format(L["%s Cast"],SN[63317]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[63317]),
				time = 2.5,
				flashtime = 2.5,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT2",
			},
			chaindur = {
				var = "chaindur",
				varname = format(L["%s Duration"],L["Chain"]),
				type = "centerpopup",
				text = format(L["%s Duration"],L["Chain"]),
				time = 38,
				color1 = "BROWN",
				sound = "ALERT3",
			},
			permlandwarn = {
				var = "permlandwarn",
				varname = format(L["%s Warning"],L["Permanent Landing"]),
				type = "simple",
				text = format(L["%s Permanently Landed"],SN["Razorscale"]).."!",
				time = 1.5,
				sound = "ALERT4",
			},
		},
		events = {
			-- Devouring Flame
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63014,63816},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "devourwarnself"},
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Razorscale gets chained
					{
						{expect = {"#1#","find",L["^Move quickly"]}},
						{alert = "chaindur"},
					},
					-- Razorscale lifts off
					{
						{expect = {"#1#","find",L["^Give us a moment to"]}},
						{quash = "chaindur"},
					},
				},
			},
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						{expect = {"#1#","find",L["deep breath...$"]}},
						{alert = "breathwarn"},
					},
					{
						{expect = {"#1#","find",L["lands permanently!$"]}},
						{quash = "chaindur"},
						{alert = "permlandwarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
