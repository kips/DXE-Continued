do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "generalvezax", 
		zone = L["Ulduar"], 
		name = L["General Vezax"], 
		triggers = {
			scan = {33271,33524}, -- Vezax, Animus
		},
		onactivate = {
			tracing = {33271}, -- Vezax
			tracerstart = true,
			tracerstop = true,
			combatstop = true,
		},
		userdata = {
			shadowcrashmessage = "",
			saronitecount = 1,
		},
		onstart = {
			{
				{alert = "vaporcd"},
				{alert = "enragecd"},
				{alert = "animuscd"},
				{set = {saronitecount = "INCR|1"}},
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 600,
				flashtime = 5,
				sound = "ALERT7",
				color1 = "BROWN",
				color2 = "BROWN",
			},
			searingflamewarn = {
				varname = format(L["%s Cast"],SN[62661]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[62661]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT1",
			},
			darknesswarn = {
				varname = format(L["%s Cast"],SN[62662]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[62662]),
				time = 3,
				color1 = "VIOLET",
				sound = "ALERT1",
			},
			darknessdur = {
				varname = format(L["%s Duration"],SN[62662]),
				type = "centerpopup",
				text = format(L["%s Duration"],SN[62662]),
				time = 10,
				flashtime = 10,
				color1 = "VIOLET",
				color2 = "CYAN",
				sound = "ALERT2",
			},
			animuscd = {
				varname = format(L["%s Timer"],L["Saronite Animus"]),
				type = "dropdown",
				text = format(L["%s Spawns"],L["Saronite Animus"]),
				time = 259,
				flashtime = 10,
				sound = "ALERT3",
				color1 = "YELLOW",
			},
			vaporcd = {
				varname = format(L["%s Cooldown"],L["Saronite Vapor"]),
				type = "dropdown",
				text = format(L["Next %s"],L["Saronite Vapor"]).." <saronitecount>",
				time = 30,
				flashtime = 5,
				color1 = "GREEN",
			},
			shadowcrashwarn = {
				varname = format(L["%s Warning"],SN[62660]),
				type = "simple",
				text = "<shadowcrashmessage>",
				time = 1.5,
				color1 = "BLACK",
				sound = "ALERT4",
				flashscreen = true,
			},
			facelessdurself = {
				varname = format(L["%s on self"],SN[63276]),
				type = "centerpopup",
				time = 10,
				flashtime = 10,
				text = format("%s: %s!",L["Mark"],L["YOU"]),
				sound = "ALERT5",
				color1 = "RED",
				flashscreen = true,
			},
			facelessdurothers = {
				varname = format(L["%s on others"],SN[63276]),
				type = "centerpopup",
				text = format("%s: #5#",L["Mark"]),
				time = 10,
				color1 = "RED",
			},
			facelessproxwarn = {
				varname = format(L["%s Proximity Warning"],SN[63276]),
				type = "simple",
				text = format("%s: #5#! %s",L["Mark"],L["YOU ARE CLOSE"]).."!",
				time = 1.5,
				color1 = "MAGENTA",
				sound = "ALERT6",
			},
		},
		arrows = {
			crasharrow = {
				varname = SN[62660],
				unit = "&tft_unitname&",
				persist = 5,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = L["Crash"],
				fixed = true,
			},
			facelessarrow = {
				varname = SN[63276],
				unit = "#5#",
				persist = 10,
				action = "AWAY",
				msg = L["STAY AWAY"],
				spell = L["Mark"],
			},
		},
		raidicons = {
			crashmark = {
				varname = SN[62660],
				type = "FRIENDLY",
				persist = 5,
				unit = "&tft_unitname&",
				icon = 7,
			},
			facelessmark = {
				varname = SN[63276],
				type = "FRIENDLY",
				persist = 10,
				unit = "#5#",
				icon = 8,
			},
		},
		timers = {
			shadowcrash = {
				{
					{raidicon = "crashmark"},
				},
				{
					{expect = {"&tft_unitexists& &tft_isplayer&","==","1 1"}},
					{set = {shadowcrashmessage = format("%s: %s! %s!",L["Crash"],L["YOU"],L["MOVE"])}},
					{alert = "shadowcrashwarn"},
				},
				{
					{expect = {"&tft_unitexists& &tft_isplayer&","==","1 nil"}},
					{proximitycheck = {"&tft_unitname&",28}},
					{set = {shadowcrashmessage = format("%s: %s! %s!",L["Crash"],"&tft_unitname&",L["CAREFUL"])}},
					{alert = "shadowcrashwarn"},
					{arrow = "crasharrow"},
				},
				{
					{expect = {"&tft_unitexists&","==","nil"}},
					{set = {shadowcrashmessage = format("%s: %s!",L["Crash"],UNKNOWN:upper())}},
					{alert = "shadowcrashwarn"},
				},
			},
		},
		events = {
			-- Searing Flame cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 62661,
				execute = {
					{
						{alert = "searingflamewarn"},
					},
				},
			},
			-- Searing Flame interrupt
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					{
						{expect = {"&npcid|#4#&","==","33271"}},
						{quash = "searingflamewarn"},
					},
				},
			},
			-- Surge of Darkness cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 62662,
				execute = {
					{
						{alert = "darknesswarn"},
					},
				},
			},
			-- Surge of Darkness gain
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 62662,
				execute = {
					{
						{quash = "darknesswarn"},
						{alert = "darknessdur"},
					},
				},
			},
			-- Shadow Crash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {60835,62660},
				execute = {
					{
						{scheduletimer = {"shadowcrash",0.1}},
					},
				},
			},
			-- Mark of the Faceless
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 63276,
				execute = {
					{
						{raidicon = "facelessmark"},
					},
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "facelessdurself"},
					},
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "facelessdurothers"},
						{proximitycheck = {"#5#",18}},
						{alert = "facelessproxwarn"},
						{arrow = "facelessarrow"},
					},
				},
			},
			-- Saronite Vapors
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						{expect = {"#1#","find",L["^A cloud of saronite vapors"]}},
						{alert = "vaporcd"},
						{set = {saronitecount = "INCR|1"}},
					},
				},
			},
			-- Saronite Barrier
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63364,
				execute = {
					{
						{tracing = {33271,33524}}, -- Vezax, Saronite Animus
					},
				},
			},
			-- NPC Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						{expect = {"&npcid|#4#&","==","33524"}}, -- Saronite Animus
						{tracing = {33271}},
					},
					{
						{expect = {"&npcid|#4#&","==","33488"}}, -- Saronite Vapor
						{quash = "animuscd"},
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end