do
	local data = {
		version = "$Rev$",
		key = "xt002", 
		zone = "Ulduar", 
		name = "XT-002 Deconstructor", 
		title = "XT-002 Deconstructor", 
		tracing = {"XT-002 Deconstructor",},
		triggers = {
			scan = "XT-002 Deconstructor", 
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


