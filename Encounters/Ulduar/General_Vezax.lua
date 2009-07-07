do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "generalvezax", 
		zone = L["Ulduar"], 
		name = L["General Vezax"], 
		triggers = {
			scan = {L["General Vezax"],L["Saronite Animus"]}, 
		},
		onactivate = {
			tracing = {L["General Vezax"],},
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {
			shadowcrashmessage = "",
			saronitecount = 1,
		},
		onstart = {
			{
				{alert = "vaporcd"},
				{alert = "enragecd"},
				{set = {saronitecount = "INCR|1"}},
			},
		},
		alerts = {
			enragecd = {
				var = "enragecd",
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
				var = "searingflamewarn",
				varname = format(L["%s Cast"],SN[62661]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[62661]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT1",
			},
			darknesswarn = {
				var = "darknesswarn",
				varname = format(L["%s Cast"],SN[62662]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[62662]),
				time = 3,
				color1 = "VIOLET",
				sound = "ALERT1",
			},
			darknessdur = {
				var = "darknessdur",
				varname = format(L["%s Duration"],SN[62662]),
				type = "centerpopup",
				text = format(L["%s Duration"],SN[62662]),
				time = 10,
				flashtime = 10,
				color1 = "VIOLET",
				color2 = "AQUA",
				sound = "ALERT2",
			},
			animuswarn = {
				var = "animuswarn",
				varname = format(L["%s Spawn"],L["Saronite Animus"]),
				type = "simple",
				text = format(L["%s Spawned"],L["Saronite Animus"]).."!",
				time = 1.5,
				sound = "ALERT3",
			},
			vaporcd = {
				var = "vaporcd",
				varname = format(L["%s Cooldown"],L["Saronite Vapor"]),
				type = "dropdown",
				text = format(L["Next %s"],L["Saronite Vapor"]).." <saronitecount>",
				time = 30,
				flashtime = 5,
				color1 = "GREEN",
			},
			shadowcrashwarn = {
				var = "shadowcrashwarn",
				varname = format(L["%s Warning"],SN[62660]),
				type = "simple",
				text = "<shadowcrashmessage>",
				time = 1.5,
				color1 = "BLACK",
				sound = "ALERT4",
			},
			facelessdurself = {
				var = "facelessdurself",
				varname = format(L["%s on self"],SN[63276]),
				type = "centerpopup",
				time = 10,
				flashtime = 10,
				text = format("%s: %s!",L["Mark"],L["YOU"]),
				sound = "ALERT5",
				color1 = "RED",
			},
			facelessdurothers = {
				var = "facelessdurothers",
				varname = format(L["%s on others"],SN[63276]),
				type = "centerpopup",
				text = format("%s: #5#",L["Mark"]),
				time = 10,
				color1 = "RED",
			},
			facelessproxwarn = {
				var = "facelessproxwarn",
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
				var = "crasharrow",
				varname = SN[62660],
				unit = "&tft_unitname&",
				persist = 5,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = L["Crash"],
			},
			facelessarrow = {
				var = "facelessarrow",
				varname = SN[63276],
				unit = "#5#",
				persist = 10,
				action = "AWAY",
				msg = L["STAY AWAY"],
				spell = L["Mark"],
			},
		},
		timers = {
			shadowcrash = {
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
						{expect = {"#5#","==",L["General Vezax"]}},
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
			{
				type = "event",
				event = "EMOTE",
				execute = {
					-- Saronite Vapors
					{
						{expect = {"#1#","find",L["^A cloud of saronite vapors"]}},
						{alert = "vaporcd"},
						{set = {saronitecount = "INCR|1"}},
					},
					-- Saronite Animus
					{
						{expect = {"#1#","find",L["A saronite barrier appears around"]}},
						{alert = "animuswarn"},
						{tracing = {L["General Vezax"],L["Saronite Animus"]}},
					},
				},
			},
			-- Saronite Animus dies
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						{expect = {"#5#","==",L["Saronite Animus"]}},
						{tracing = {L["General Vezax"]}},
					},
				},
			},
		},
	}
	DXE:RegisterEncounter(data)
end
