do
	local L,SN = DXE.L,DXE.SN

	L_GothikTheHarvester = L["Gothik the Harvester"]

	local data = {
		version = "$Rev$",
		key = "gothiktheharvester",
		zone = L["Naxxramas"],
		name = L_GothikTheHarvester,
		triggers = {
			scan = L_GothikTheHarvester,
			yell = {L["^Foolishly you have sought"],L["^Teamanare shi rikk"]},
		},
		onactivate = {
			tracing = {L_GothikTheHarvester},
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
				varname = format(L["%s Arrival"],L_GothikTheHarvester),
				type = "dropdown",
				text = L["Arrival"],
				time = 270,
				flashtime = 5, 
				color1 = "RED",
				sound = "ALERT1", 
			},
		},
	}
	DXE:RegisterEncounter(data)
end
