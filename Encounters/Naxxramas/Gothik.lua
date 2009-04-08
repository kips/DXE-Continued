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
			yell = {"^Foolishly you have sought","^Teamanare shi rikk"},
		},
		onactivate = {
			leavecombat = true,
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
				varname = "Gothik arrival",
				type = "dropdown",
				text = "Gothik Arrives", 
				time = 270,
				flashtime = 5, 
				sound = "ALERT1", 
			},
		},
	}
	DXE:RegisterEncounter(data)
end
