do
	local L,SN = DXE.L,DXE.SN

	local L_Loatheb = L["Loatheb"]

	local data = {
		version = "$Rev$",
		key = "loatheb", 
		zone = L["Naxxramas"], 
		name = L_Loatheb, 
		triggers = {
			scan = L_Loatheb, 
		},
		onactivate = {
			tracing = {L_Loatheb,},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = { 
			sporecount = 1,
			sporetimer = 15,
		},
		onstart = {
			{
				{alert = "sporespawn"},
				{expect = {"&difficulty&","==","1"}},
				{set = {sporetimer = 30}}
			}
		},
		alerts = {
			necroaura = {
				var = "necroaura", 
				varname = format(L["%s Duration"],SN[55593]),
				type = "dropdown", 
				text = format(L["%s Fades"],SN[55593]),
				time = 17, 
				flashtime = 7, 
				sound = "ALERT2", 
				color1 = "MAGENTA", 
			},
			openheals = {
				var = "openheals", 
				varname = format(L["%s Duration"],SN[37455]),
				type = "centerpopup", 
				text = L["Open Healing"], 
				time = 3, 
				sound = "ALERT3", 
				color1 = "GREEN", 
				
			},
			sporespawn = {
				var = "sporespawn", 
				varname = format(L["%s Timer"],SN[29234]),
				type = "dropdown", 
				text = format("%s: <sporecount>",SN[29234]),
				time = "<sporetimer>", 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "ORANGE", 
			},
		},
		timers = {
			healtime = {
				{
					{quash = "necroaura"},
					{alert = "openheals"},
				},
			},
		},
		events = {
			-- Necrotic aura
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 55593, 
				execute = {
					{
						{alert = "necroaura"}, 
						{scheduletimer = {"healtime", 17}},
					},
				},
			},
			-- Spore
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 29234, 
				execute = {
					{
						{set = {sporecount = "INCR|1"}},
						{alert = "sporespawn"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


