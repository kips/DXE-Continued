do
	local data = {
		version = "$Rev$",
		key = "yoggsaron", 
		zone = "Ulduar", 
		name = "Yogg-Saron", 
		title = "Yogg-Saron", 
		tracing = {"Yogg-Saron",},
		triggers = {
			scan = "Yogg-Saron", 
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

