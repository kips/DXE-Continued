do
	local data = {
		version = "$Rev: 22 $",
		key = "loatheb", 
		zone = "Naxxramas", 
		name = "Loatheb", 
		title = "Loatheb", 
		tracing = {"Loatheb",},
		triggers = {
			scan = "Loatheb", 
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = { 
			sporecount = 1,
			sporetimer = 15,
		},
		onstart = {
			[1] = {
				{alert = "sporespawn"},
				{expect = {"&difficulty&","==","1"}},
				{set = {sporetimer = 30}}
			}
		},
		alerts = {
			necroaura = {
				var = "necroaura", 
				varname = "Necrotic aura", 
				type = "dropdown", 
				text = "Necrotic aura fades", 
				time = 17, 
				flashtime = 7, 
				sound = "ALERT2", 
				color1 = "MAGENTA", 
			},
			openheals = {
				var = "necroaura", 
				varname = "Necrotic aura", 
				type = "centerpopup", 
				text = "Open healing", 
				time = 3, 
				flashtime = 0, 
				sound = "ALERT3", 
				color1 = "GREEN", 
				
			},
			sporespawn = {
				var = "sporespawn", 
				varname = "Spore spawns", 
				type = "dropdown", 
				text = "Spore <sporecount>", 
				time = "<sporetimer>", 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "ORANGE", 
			},
		},
		timers = {
			healtime = {
				[1] = {
					{quash = "necroaura"},
					{alert = "openheals"},
				},
			},
		},
		events = {
			-- Necrotic aura
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 55593, 
				execute = {
					[1] = {
						{alert = "necroaura"}, 
						{scheduletimer = {"healtime", 17}},
					},
				},
			},
			-- Spore
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 29234, 
				execute = {
					[1] = {
						{set = {sporecount = "INCR|1"}},
						{alert = "sporespawn"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


