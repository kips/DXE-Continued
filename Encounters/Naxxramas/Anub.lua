do
	local data = {
		version = "$Rev$",
		key = "anubrekhan", 
		zone = "Naxxramas", 
		name = "Anub'Rekhan", 
		title = "Anub'Rekhan", 
		tracing = {"Anub'Rekhan",},
		triggers = {
			scan = "Anub'Rekhan", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = { 
			swarmcd = {90, 85, loop=false},
		},
		onstart = {
			[1] = {
				{alert = "locustswarmcd"},
			}
		},
		alerts = {
			locustswarmcd = {
				var = "locustswarmcd", 
				varname = "Locust swarm cooldown", 
				type = "dropdown", 
				text = "Locust swarm cooldown", 
				time = 90, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "GREEN", 
			},
			locustswarmcast = {
				var = "locustswarmcast", 
				varname = "Locust swarm cast", 
				type = "centerpopup", 
				text = "Locust swarm casting", 
				time = 3, 
				flashtime = 0, 
				sound = "ALERT3", 
				color1 = "GREY", 
			},
			locustswarmgain = {
				var = "locustswarmgain", 
				varname = "Locus swarm gain", 
				type = "centerpopup", 
				text = "Locust swarm casting", 
				time = 20, 
				flashtime = 0, 
				sound = "ALERT2", 
				color1 = "YELLOW", 
			},
		},
		events = {
			-- Locust swarm gain
			[1] = {
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = {28785,54021}, 
				execute = {
					[1] = {
						{expect = {"#5#","==","Anub'Rekhan"}},
						{alert = "locustswarmgain"},
						{quash = "locustswarmcd"},
						{alert = "locustswarmcd"}, 
					},
				},
			},
			-- Locust swarm cast
			[2] = {
				type = "combatevent", 
				eventtype = "SPELL_CAST_START", 
				spellid = {28785,54021}, 
				execute = {
					[1] = {
						{alert = "locustswarmcast"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
