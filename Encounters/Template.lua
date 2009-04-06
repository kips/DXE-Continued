do
	-- Remember to add Rev keyword
	local data = {
		version = "$Rev$",
		key = "boss", 
		zone = "Zone", 
		name = "Boss", 
		title = "Boss", 
		tracing = {"Boss",},
		triggers = {
			scan = "Boss", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {},
		alerts = {

		},
	}

	DXE:RegisterEncounter(data)
end

