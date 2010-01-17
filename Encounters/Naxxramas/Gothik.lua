do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 299,
		key = "gothiktheharvester",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas["Gothik the Harvester"],
		triggers = {
			scan = 16060, -- Gothik the Harvester
			yell = {
        L.chat_naxxramas["^Foolishly you have sought"],
        L.chat_naxxramas["^Teamanare shi rikk"]
      },
		},
		onactivate = {
			tracing = {16060}, -- Gothik the Harvester
			combatstop = true,
			defeat = 16060,
		},
		userdata = {},
		onstart = {
			{
				"alert","gothikcomesdowncd",
			}
		},
		alerts = {
			gothikcomesdowncd = {
				varname = format(L.alert["%s Arrival"],L.npc_naxxramas["Gothik the Harvester"]),
				type = "dropdown",
				text = L.alert["Arrival"],
				time = 270,
				flashtime = 5, 
				color1 = "RED",
				sound = "ALERT1", 
				icon = ST[586],
			},
		},
	}
	DXE:RegisterEncounter(data)
end
