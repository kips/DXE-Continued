do
	local data = {
		version = "$Rev$",
		key = "emalon", 
		zone = "Vault of Archavon", 
		name = "Emalon the Storm Watcher", 
		title = "Emalon the Storm Watcher", 
		tracing = {"Emalon the Storm Watcher",},
		triggers = {
			scan = "Emalon the Storm Watcher", 
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

