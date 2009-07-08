do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "thorim", 
		zone = L["Ulduar"], 
		name = L["Thorim"], 
		triggers = {
			scan = {
				L["Thorim"],
				L["Jormungar Behemoth"],
				L["Runic Colossus"],
				L["Ancient Rune Giant"],
				L["Iron Ring Guard"],
				L["Dark Rune Thunderer"],
				L["Dark Rune Commoner"],
			},
			yell = L["^Interlopers! You mortals who"],
		},
		onactivate = {
			tracing = {L["Runic Colossus"],L["Ancient Rune Giant"]},
			leavecombat = true,
		},
		userdata = {
			chargecount = 1,
			chargetime = 34,
		},
		onstart = {
			{
				{alert = "hardmodecd"},
				{scheduletimer = {"hardmodefailed", 180}},
			},
		},
		timers = {
			hardmodefailed = {
				{
					{alert = "enrage2cd"},
				},
			},
		},
		alerts = {
			enrage2cd = {
				var = "enrage2cd", 
				varname = L["Enrage"], 
				type = "dropdown", 
				text = L["Enrage"], 
				time = 120, 
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED",
			},
			hardmodecd = {
				var = "hardmodecd", 
				varname = format(L["%s Timeleft"],L["Hard Mode"]),
				type = "dropdown", 
				text = format(L["%s Ends"],L["Hard Mode"]),
				time = 180, 
				flashtime = 5, 
				sound = "ALERT1", 
			},
			hardmodeactivation = {
				var = "hardmodeactivation", 
				varname = format(L["%s Warning"],L["Hard Mode"]),
				type = "simple", 
				text = format(L["%s Activated"],L["Hard Mode"]),
				time = 1.5, 
				sound = "ALERT1", 
			},
			chargecd = {
				var = "chargecd", 
				varname = format(L["%s Cooldown"],SN[62279]),
				type = "dropdown", 
				text = format(L["Next %s"],SN[62279]).." <chargecount>",
				time = "<chargetime>", 
				flashtime = 7, 
				sound = "ALERT2",
				color1 = "VIOLET",
			},
			chainlightningcd = {
				var = "chainlightningcd",
				varname = format(L["%s Cooldown"],SN[62131]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[62131]),
				time = 10,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "ORANGE",
				color2 = "ORANGE",
			},
			frostnovacast = {
				var = "frostnovacast",
				varname = format(L["%s Cast"],SN[122]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[122]),
				time = 2.5,
				flashtime = 2.5,
				sound = "ALERT4",
				color1 = "BLUE",
				color2 = "BLUE",
			},
			strikecd = {
				var = "strikecd",
				varname = format(L["%s Cooldown"],SN[62130]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[62130]),
				time = 25,
				flashtime = 5,
				sound = "ALERT5",
				color1 = "BROWN",
				color2 = "BROWN",
			},
		},
		events = {
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Phase 3
					{
						{expect = {"#1#","find",L["^Impertinent"]}},
						{quash = "hardmodecd"},
						{quash = "enrage2cd"},
						{canceltimer = "hardmodefailed"},
						{tracing = {"Thorim"}},
						{alert = "chargecd"},
						{set = {chargetime = 15}},
					},
					-- Hard mode activation
					{
						{expect = {"#1#","find",L["^Impossible!"]}},
						{alert = "hardmodeactivation"},
					},
				},
			},
			-- Lightning Charge
			{
				type = "combatevent", 
				eventtype = "SPELL_CAST_SUCCESS", 
				spellid = 62279, 
				execute = {
					{
						{set = {chargecount = "INCR|1"}},
						{alert = "chargecd"},
					},
				},
			},
			-- Chain Lightning
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {64390,62131},
				execute = {
					{
						{alert = "chainlightningcd"},
					},
				},
			},
			-- Sif's Frost Nova
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {62605,62597},
				execute = {
					{
						{alert = "frostnovacast"},
					},
				},
			},
			-- Unbalancing Strike
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 62130,
				execute = {
					{
						{alert = "strikecd"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

