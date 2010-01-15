do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST

	local data = {
		version = 298,
		key = "instructorrazuvious", 
		zone = L.zone["Naxxramas"], 
		name = L["Instructor Razuvious"], 
		triggers = {
			scan = {
				16061, -- Razuvious
				16803, -- Death Knight Understudy
			}, 
			yell = L["^The time for practice is over!"],
		},
		onactivate = {
			tracerstop = true,
			combatstop = true,
			tracing = {16061}, -- Razuvious
			defeat = 16061,
		},
		userdata = {},
		onstart = {
			{
				"alert","shoutcd",
			}
		},
		alerts = {
			shoutcd = {
				varname = format(L["%s Cooldown"],SN[55543]),
				type = "dropdown", 
				text = format(L["Next %s"],SN[55543]),
				time = 15, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
				icon = ST[55543],
			},
			tauntdur = {
				varname = format(L["%s Duration"],SN[355]),
				type = "dropdown", 
				text = format(L["%s Duration"],SN[355]),
				time = 20, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "BLUE", 
				icon = ST[355],
			},
			shieldwalldur = {
				varname = format(L["%s Duration"],SN[871]),
				type = "dropdown", 
				text = format(L["%s Duration"],SN[871]),
				time = 20, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "YELLOW", 
				icon = ST[871],
			},
		},
		events = {
			-- Disrupting shout
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = {29107,55543}, 
				execute = {
					{
						"alert","shoutcd", 
					},
				},
			},
			-- Taunt
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 29060, 
				execute = {
					{
						
						"alert","tauntdur", 
					},
				},
			},
			-- Shield wall
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 29061, 
				execute = {
					{
						"alert","shieldwalldur", 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
