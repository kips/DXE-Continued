do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local L_Gluth = L.npc_naxxramas["Gluth"]
	local data = {
		version = 298,
		key = "gluth",
		zone = L.zone["Naxxramas"],
		name = L.npc_naxxramas_Gluth,
		triggers = {
			scan = 15932, -- Gluth
		},
		onactivate = {
			tracing = {15932},
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
			defeat = 15932,
		},
		userdata = {},
		onstart = {
			{
				"alert","decimatecd",
			}
		},
		alerts = {
			decimatecd = {
				varname = format(L.alerts["%s Cooldown"],SN[28374]),
				type = "dropdown",
				text = format(L.alerts["%s Cooldown"],SN[28374]),
				time = 105, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "BROWN", 
				throttle = 5,
				icon = ST[28374],
			},
			enragewarn = {
				varname = format(L.alerts["%s Warning"],L.alerts["Enrage"]),
				type = "simple", 
				text = format("%s!",L.alerts["Enraged"]),
				time = 1.5,
				color1 = "RED",
				icon = ST[12317],
			},
		},
		events = {
			-- Decimate (hit)
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {28375,54426},
				execute = {
					{
						"alert","decimatecd",
					},
				},
			},
			-- Decimate (miss)
			{
				type = "combatevent",
				eventtype = "SPELL_MISSED",
				spellid = {28375,54426},
				execute = {
					{
						"alert","decimatecd",
					},
				},
			},
			-- Frenzy
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {28371,54427},
				execute = {
					{
						"alert","enragewarn", 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

