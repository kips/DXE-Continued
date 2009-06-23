do
	local L,SN = DXE.L,DXE.SN 

	local data = {
		version = "$Rev$",
		key = "grandwidowfaerlina", 
		zone = L["Naxxramas"], 
		name = L["Grand Widow Faerlina"],
		triggers = {
			scan = L["Grand Widow Faerlina"],
		},
		onactivate = {
			tracing = {L["Grand Widow Faerlina"]},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = { 
			enraged = "false",
		},
		onstart = {
			{
				{alert = "enragecd"},
			}
		},
		alerts = {
			enragecd = {
				var = "enragecd", 
				varname = L["Enrage"],
				type = "dropdown", 
				text = L["Enrage"],
				time = 60, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED", 
			},
			enragewarn = {
				var = "enragewarn", 
				varname = format(L["%s Warning"],L["Enrage"]),
				type = "simple", 
				text = format("%s!",L["Enraged"]), 
				time = 1.5, 
				sound = "ALERT2", 
			},
			rainwarn = {
				var = "rainwarn", 
				varname = format(L["%s Warning"],SN[39024]),
				type = "simple", 
				text = format("%s! %s!",SN[39024],L["MOVE"]),
				time = 1.5, 
				sound = "ALERT3", 
			},
			silencedur = {
				var = "silencedur", 
				varname = format(L["%s Duration"],SN[15487]),
				type = "dropdown", 
				text = format(L["%s Duration"],SN[15487]),
				time = 30, 
				flashtime = 5, 
				sound = "ALERT4", 
			},
		},
		events = {
			-- Silence
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {28732,54097}, 
				execute = {
					{
						{expect = {"#5#","==",L["Grand Widow Faerlina"]}},
						{expect = {"$enraged$","==","true"}},
						{set = {enraged = "false"}}, 
						{alert = "enragecd"}, 
						{quash = "silencedur"},
						{alert = "silencedur"}, 
					},
				},
			},
			-- Rain
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 54099,
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "rainwarn"},
					}
				},
			},
			-- Enrage
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 54100,
				execute = {
					{
						{expect = {"#5#","==",L["Grand Widow Faerlina"]}},
						{quash = "enragecd"},
						{set = {enraged = "true"}}, 
						{alert = "enragewarn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
