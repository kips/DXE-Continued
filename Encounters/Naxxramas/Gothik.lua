do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = "$Rev$",
		key = "gothiktheharvester",
		zone = L["Naxxramas"],
		name = L["Gothik the Harvester"],
		triggers = {
			scan = 16060, -- Gothik the Harvester
			yell = {L["^Foolishly you have sought"],L["^Teamanare shi rikk"]},
		},
		onactivate = {
			tracing = {16060}, -- Gothik the Harvester
			combatstop = true,
		},
		userdata = {},
		onstart = {
			{
				{alert = "gothikcomesdown"},
			}
		},
		alerts = {
			gothikcomesdown = {
				varname = format(L["%s Arrival"],L["Gothik the Harvester"]),
				type = "dropdown",
				text = L["Arrival"],
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
