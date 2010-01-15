do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 305,
		key = "thorim", 
		zone = L.zone["Ulduar"], 
		name = L.npc_ulduar["Thorim"], 
		triggers = {
			scan = {
				32865, -- Thorim,
				32882, -- Jormungar Behemoth,
				32872, -- Runic Colossus,
				32873, -- Ancient Rune Giant,
				32874, -- Iron Ring Guard,
			},
			yell = L.chat_msg_triggers_ulduar["^Interlopers! You mortals who"],
		},
		onactivate = {
			tracing = {32872,32873}, -- Runic Colossus, Ancient Rune Giant
			combatstop = true,
			defeat = L.alerts["Stay your arms"],
		},
		userdata = {
			chargetime = 34,
			enragetime = {369,300,loop = false},
			striketext = "",
		},
		onstart = {
			{
				"alert","hardmodecd",
				"alert","enragecd",
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alerts["Enrage"], 
				type = "dropdown", 
				text = L.alerts["Enrage"], 
				time = "<enragetime>",
				flashtime = 5, 
				sound = "ALERT1", 
				color1 = "RED",
				icon = ST[12317],
			},
			hardmodecd = {
				varname = format(L.alerts["%s Timeleft"],L.alerts["Hard Mode"]),
				type = "dropdown", 
				text = format(L.alerts["%s Ends"],L.alerts["Hard Mode"]),
				time = 172.5, 
				flashtime = 5, 
				color1 = "GREY",
				sound = "ALERT1", 
				icon = ST[20573],
			},
			hardmodeactivationwarn = {
				varname = format(L.alerts["%s Warning"],L.alerts["Hard Mode"]),
				type = "simple", 
				text = format(L.alerts["%s Activated"],L.alerts["Hard Mode"]),
				time = 1.5, 
				sound = "ALERT1", 
				icon = ST[62972],
			},
			chargecd = {
				varname = format(L.alerts["%s Cooldown"],SN[62279]),
				type = "dropdown", 
				text = format(L.alerts["Next %s"],SN[62279]),
				time = "<chargetime>", 
				flashtime = 7, 
				sound = "ALERT2",
				color1 = "VIOLET",
				icon = ST[62279],
				counter = true,
			},
			chainlightningcd = {
				varname = format(L.alerts["%s Cooldown"],SN[62131]),
				type = "dropdown",
				text = format(L.alerts["%s Cooldown"],SN[62131]),
				time = 10,
				flashtime = 5,
				sound = "ALERT3",
				color1 = "ORANGE",
				color2 = "ORANGE",
				icon = ST[62131],
			},
			frostnovawarn = {
				varname = format(L.alerts["%s Cast"],SN[122]),
				type = "centerpopup",
				text = format(L.alerts["%s Cast"],SN[122]),
				time = 2.5,
				flashtime = 2.5,
				sound = "ALERT4",
				color1 = "BLUE",
				color2 = "BLUE",
				icon = ST[122],
			},
			strikecd = {
				varname = format(L.alerts["%s Cooldown"],SN[62130]),
				type = "dropdown",
				text = format(L.alerts["Next %s"],SN[62130]),
				time = 25,
				flashtime = 5,
				sound = "ALERT5",
				color1 = "BROWN",
				color2 = "BROWN",
				icon = ST[62130],
			},
			strikewarn = {
				varname = format(L.alerts["%s Warning"],SN[62130]),
				type = "simple",
				text = "<striketext>",
				time = 3,
				sound = "ALERT6",
				icon = ST[62130],
			},
		},
		events = {
			{
				type = "event",
				event = "CHAT_MSG_MONSTER_YELL",
				execute = {
					-- Phase 2
					{
						"expect",{"#1#","find",L.chat_msg_triggers_ulduar["^Impertinent"]},
						"quash","hardmodecd",
						"quash","enragecd",
						"alert","enragecd",
						"tracing",{32865}, -- Thorim
						"alert","chargecd",
						"set",{chargetime = 15},
					},
					-- Hard mode activation
					{
						"expect",{"#1#","find",L.chat_msg_triggers_ulduar["^Impossible!"]},
						"alert","hardmodeactivationwarn",
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
						"alert","chargecd",
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
						"alert","chainlightningcd",
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
						"alert","frostnovawarn",
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
						"quash","strikecd",
						"alert","strikecd",
					},
				},
			},
			-- Unbalancing Strike application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62130,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{striketext = format("%s: %s!",SN[62130],L.alerts["YOU"])},
						"alert","strikewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{striketext = format("%s: #5#!",SN[62130])},
						"alert","strikewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

