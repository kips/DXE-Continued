do
	-- Remember to add Rev keyword
	local data = {
		version = "$Rev: 34 $",
		key = "boss", 
		zone = "Zone", 
		name = "Boss", 
		title = "Boss", 
		triggers = {
			scan = "Boss", 
		},
		onactivate = {
			tracing = {"Boss",},
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

