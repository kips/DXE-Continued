do
	local data = {
		version = "$Rev$",
		key = "algalon", 
		zone = "Ulduar", 
		name = "Algalon", 
		title = "Algalon", 
		tracing = {"Algalon",},
		triggers = {
			scan = "Algalon", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {},
		alerts = {},
	}

	DXE:RegisterEncounter(data)
end

