do
	local data = {
		version = "$Rev$",
		key = "algalon", 
		zone = "Ulduar", 
		name = "Algalon the Observer", 
		title = "Algalon the Observer", 
		tracing = {"Algalon the Observer",},
		triggers = {
			scan = "Algalon the Observer", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {},
	}

	DXE:RegisterEncounter(data)
end
