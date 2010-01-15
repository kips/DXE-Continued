do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 300,
		key = "flameleviathan", 
		zone = L.zone["Ulduar"], 
		name = L.npc_ulduar["Flame Leviathan"], 
		triggers = {
			scan = 33113, -- Flame Leviathan
			yell = L["^Hostile entities detected. Threat assessment protocol active"],
		},
		onactivate = {
			tracing = {33113}, -- Flame Leviathan
			combatstop = true,
			defeat = 33113,
		},
		userdata = {},
		onstart = {},
		alerts = {
			overloaddur = {
				varname = format(L["%s Duration"],SN[62475]),
				type = "centerpopup", 
				text = SN[62475].."!",
				time = 20, 
				flashtime = 20,
				sound = "ALERT1", 
				color1 = "BLUE", 
				color2 = "BLUE",
				throttle = 5,
				icon = ST[62475],
			},
			flameventdur = {
				varname = format(L["%s Duration"],SN[62396]),
				type = "centerpopup", 
				text = SN[62396].."!",
				time = 10, 
				flashtime = 5,
				sound = "ALERT2", 
				color1 = "RED",
				color2 = "ORANGE",
				icon = ST[62396],
			},
			pursuedurothers = {
				varname = format(L["%s on others"],SN[62374]),
				type = "centerpopup", 
				text = format("%s: #5#",SN[62374]),
				time = 30, 
				flashtime = 30, 
				color1 = "CYAN",
				color2 = "CYAN",
				icon = ST[62374],
			},
			pursuedurself = {
				varname = format(L["%s on self"],SN[62374]),
				type = "centerpopup", 
				text = format("%s: %s!",SN[62374],L["YOU"]),
				time = 30, 
				flashtime = 30, 
				sound = "ALERT4", 
				color1 = "CYAN",
				color1 = "MAGENTA",
				flashscreen = true,
				icon = ST[62374],
			},
		},
		events = {
			-- Flame vents
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 62396, 
				execute = {
					{
						"alert","flameventdur",
					},
				},
			},
			-- Remove flame vents
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 62396,
				execute = {
					{
						"quash","flameventdur",
					},
				},
			},
			-- Overload circuits
			{
				type = "combatevent", 
				eventtype = "SPELL_AURA_APPLIED", 
				spellid = 62475, 
				execute = {
					{
						"alert","overloaddur",
					},
				},
			},
			-- Pursued
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L["pursues"]},
						"expect",{"#5#","==","&playername&"},
						"alert","pursuedurself",
					},
					{
						"expect",{"#1#","find",L["pursues"]},
						"expect",{"#5#","~=","&playername&"},
						"alert","pursuedurothers",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
