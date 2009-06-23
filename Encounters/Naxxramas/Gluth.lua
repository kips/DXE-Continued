do
	local L,SN = DXE.L,DXE.SN
	local L_Gluth = L["Gluth"]
	local data = {
		version = "$Rev$",
		key = "gluth",
		zone = L["Naxxramas"],
		name = L_Gluth,
		triggers = {
			scan = L_Gluth,
		},
		onactivate = {
			tracing = {L_Gluth},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {
			{
				{alert = "decimatecd"},
			}
		},
		alerts = {
			decimatecd = {
				var = "decimatecd",
				varname = format(L["%s Cooldown"],SN[28374]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[28374]),
				time = 105, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED", 
				throttle = 5,
			},
			enragewarn = {
				var = "enragewarn", 
				varname = format(L["%s Warning"],L["Enrage"]),
				type = "simple", 
				text = format("%s!",L["Enraged"]),
				time = 1.5, 
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
						{alert = "decimatecd"},
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
						{alert = "decimatecd"},
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
						{alert = "enragewarn"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

