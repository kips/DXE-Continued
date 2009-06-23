do
	local L,SN = DXE.L,DXE.SN

	local L_InstructorRazuvious = L["Instructor Razuvious"]

	local data = {
		version = "$Rev$",
		key = "instructorrazuvious", 
		zone = L["Naxxramas"], 
		name = L_InstructorRazuvious, 
		triggers = {
			scan = {L_InstructorRazuvious,L["Death Knight Understudy"]}, 
			yell = L["^The time for practice is over!"],
		},
		onactivate = {
			autostop = true,
			leavecombat = true,
			tracing = {L_InstructorRazuvious,},
		},
		userdata = {},
		onstart = {
			{
				{alert = "shoutcd"},
			}
		},
		alerts = {
			shoutcd = {
				var = "shoutcd", 
				varname = format(L["%s Cooldown"],SN[55543]),
				type = "dropdown", 
				text = format(L["Next %s"],SN[55543]),
				time = 15, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "MAGENTA", 
			},
			tauntdur = {
				var = "tauntdur", 
				varname = format(L["%s Duration"],SN[355]),
				type = "dropdown", 
				text = format(L["%s Duration"],SN[355]),
				time = 20, 
				flashtime = 5, 
				sound = "ALERT2", 
				color1 = "BLUE", 
			},
			shieldwalldur = {
				var = "shieldwalldur", 
				varname = format(L["%s Duration"],SN[871]),
				type = "dropdown", 
				text = format(L["%s Duration"],SN[871]),
				time = 20, 
				flashtime = 5, 
				sound = "ALERT3", 
				color1 = "YELLOW", 
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
						{alert = "shoutcd"}, 
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
						
						{alert = "tauntdur"}, 
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
						{alert = "shieldwalldur"}, 
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
