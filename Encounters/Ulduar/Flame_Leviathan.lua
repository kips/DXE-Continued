do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "flameleviathan", 
		zone = "Ulduar", 
		name = L["Flame Leviathan"], 
		triggers = {
			scan = L["Flame Leviathan"], 
			yell = L["^Hostile entities detected. Threat assessment protocol active"],
		},
		onactivate = {
			tracing = {L["Flame Leviathan"],},
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {
			overloaddur = {
				var = "overloaddur", 
				varname = format(L["%s Duration"],SN[62475]),
				type = "centerpopup", 
				text = SN[62475].."!",
				time = 20, 
				flashtime = 20,
				sound = "ALERT1", 
				color1 = "BLUE", 
				color2 = "BLUE",
				throttle = 5,
			},
			flameventdur = {
				var = "flameventdur", 
				varname = format(L["%s Duration"],SN[62396]),
				type = "centerpopup", 
				text = SN[62396].."!",
				time = 10, 
				flashtime = 5,
				sound = "ALERT2", 
				color1 = "RED",
				color2 = "ORANGE",
			},
			pursuedurother = {
				var = "pursuedur", 
				varname = format(L["%s Duration"],SN[62374]),
				type = "centerpopup", 
				text = format("%s: #5#",SN[62374]),
				time = 30, 
				flashtime = 30, 
				color1 = "CYAN",
				color2 = "CYAN",
			},
			pursuedurself = {
				var = "pursuedur", 
				varname = format(L["%s Duration"],SN[62374]),
				type = "centerpopup", 
				text = format("%s: %s!",SN[62374],L["YOU"]),
				time = 30, 
				flashtime = 30, 
				sound = "ALERT4", 
				color1 = "CYAN",
				color1 = "MAGENTA",
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
						{alert = "flameventdur"},
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
						{quash = "flameventdur"},
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
						{alert = "overloaddur"},
					},
				},
			},
			-- Pursued
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						{expect = {"#1#","find",L["pursues"]}},
						{expect = {"#5#","==","&playername&"}},
						{alert = "pursuedurself"},
					},
					{
						{expect = {"#1#","find",L["pursues"]}},
						{expect = {"#5#","~=","&playername&"}},
						{alert = "pursuedurother"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
