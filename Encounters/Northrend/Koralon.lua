
do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 2,
		key = "koralon", 
		zone = L["Vault of Archavon"], 
		category = L["Northrend"],
		name = L["Koralon"], 
		triggers = {
			scan = {
				35013, -- Koralon
			}, 
		},
		onactivate = {
			tracing = {35013},
			tracerstart = true,
			combatstop = true,
		},
		alerts = {
			flamingcinderself = {
				varname = format(L["%s on self"],SN[67332]),
				text = format("%s: %s!",SN[67332],L["YOU"]),
				type = "simple",
				time = 3,
				throttle = 3,
				color1 = "ORANGE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[67332],
			},
		},
		events = {
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {67332,66684},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","flamingcinderself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

