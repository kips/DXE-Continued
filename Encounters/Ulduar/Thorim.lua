do
	local data = {
		version = "$Rev$",
		key = "thorim", 
		zone = "Ulduar", 
		name = "Thorim", 
		title = "Thorim", 
		tracing = {"Thorim",},
		triggers = {
			scan = "Thorim", 
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

