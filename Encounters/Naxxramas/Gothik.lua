do
	local data = {
		version = "$Rev$",
		key = "gothiktheharvester",
		zone = "Naxxramas",
		name = "Gothik the Harvester",
		title = "Gothik the Harvester",
		tracing = {"Gothik the Harvester",},
		triggers = {
			scan = "Gothik the Harvester", 
			yell = "Foolishly you have sought your own demise",
		},
		onactivate = {
			autoupdate = true,
			autostart = true,
			autostop = true,
		},
		userdata = {},
		onstart = {
			[1] = {
				{alert = "gothikcomesdown"},
			}
		},
		alerts = {
			gothikcomesdown = {
				var = "gothikcomesdown", 
				varname = "Gothik comes down",
				type = "dropdown",
				text = "Gothik comes down", 
				time = 270,
				flashtime = 5, 
				sound = "ALERT1", 
			},
		},
	}
	DXE:RegisterEncounter(data)
end
