do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "icctrash", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = L["Trash"], 
		title = L["Trash"],
		triggers = {
			scan = {
				37007, -- Deathbound Ward
			},
		},
		onactivate = {
			combatstart = true,
			combatstop = true,
		},
		alerts = {
			disruptshout = {
				varname = format(L["%s Cast"],SN[71022]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71022]),
				time = 3,
				flashtime = 3,
				color1 = "ORANGE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[71022],
			},
		},
		events = {
			-- Disrupting Shout
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71022, -- 10/25
				execute = {
					{
						"alert","disruptshout"
					},
				}
			}
		},
	}

	DXE:RegisterEncounter(data)
end
