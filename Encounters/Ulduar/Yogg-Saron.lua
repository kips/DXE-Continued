do
	local L,SN = DXE.L,DXE.SN
	local data = {
		version = "$Rev$",
		key = "yoggsaron", 
		zone = L["Ulduar"], 
		name = L["Yogg-Saron"], 
		triggers = {
			yell = L["^The time to strike at the head of the beast"],
			scan = {
				L["Yogg-Saron"],
				L["Sara"],
				L["Crusher Tentacle"],
				L["Corruptor Tentacle"],
				L["Constrictor Tentacle"],
				L["Guardian of Yogg-Saron"],
				L["Brain of Yogg-Saron"],
			},
		},
		onactivate = {
			tracing = {"Sara"},
			leavecombat = true,
		},
		userdata = {
			portaltime = {73,90,loop = false},
			portaltext = {format(L["%s Soon"],L["Portals"]),format(L["Next %s"],L["Portals"]), loop = false},
			crushertime = 14,
			allowcrusher = 1,
			phase = "1",
			brainlinkpartner = "",
		},
		onstart = {
			{
				{alert = "enragecd"},
			},
		},
		alerts = {
			lunaticgazewarn = {
				var = "lunaticgazewarn",
				varname = format(L["%s Cast"],SN[64163]),
				type = "centerpopup",
				text = format("%s! %s!",SN[64163],L["LOOK AWAY"]),
				time = 4,
				color1 = "PURPLE",
				sound = "ALERT1",
			},
			lunaticgazecd = {
				var = "lunaticgazecd",
				varname = format(L["%s Cooldown"],SN[64163]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[64163]),
				time = 11,
				flashtime = 5,
				color1 = "GREEN",
				color2 = "YELLOW",
				sound = "ALERT2",
			},
			brainlinkdur = {
				var = "brainlinkdur",
				varname = format(L["%s on self"],SN[63802]),
				type = "centerpopup",
				text = format("%s: %s!",SN[63802],L["YOU"]),
				time = 30,
				flashtime = 30,
				color1 = "BLUE",
				sound = "ALERT3",
			},
			enragecd = {
				var = "enragecd",
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 900,
				flashtime = 10,
				color1 = "RED",
			},
			portalcd = {
				var = "portalcd",
				varname = format(L["%s Cooldown"],L["Portals"]),
				type = "dropdown",
				text = "<portaltext>",
				time = "<portaltime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "MAGENTA",
				color2 = "MAGENTA",
			},
			weakeneddur = {
				var = "weakeneddur",
				varname = format(L["%s Duration"],L["Weakened"]),
				type = "centerpopup",
				text = L["Weakened"].."!",
				time = "&timeleft|inducewarn&",
				flashtime = 5,
				color1 = "ORANGE",
			},
			inducewarn = {
				var = "inducewarn",
				varname = format(L["%s Cast"],SN[64059]),
				type = "dropdown",
				text = format(L["%s Cast"],SN[64059]),
				time = 60,
				flashtime = 5,
				color1 = "BROWN",
				color2 = "MIDGREY",
				sound = "ALERT6",
			},
			squeezewarn = {
				var = "squeezewarn",
				varname = format(L["%s on others"],SN[64126]),
				type = "simple",
				text = format("%s: #5#",SN[64126]),
				time = 3,
				color1 = "YELLOW",
				sound = "ALERT7",
			},
			maladywarn = {
				var = "maladywarn",
				varname = format(L["%s Warning"],SN[63830]),
				type = "simple",
				text = format("%s: #5#! %s",L["Malady"],L["MOVE AWAY"]),
				time = 3,
				sound = "ALERT5",
				color1 = "GREEN",
			},
			empoweringshadowscd = {
				var = "empoweringshadowscd",
				varname = format(L["%s Cooldown"],SN[64486]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[64486]),
				time = 45, 
				flashtime = 5,
				sound = "ALERT8",
				color1 = "INDIGO",
				color2 = "RED",
			},
			crushertentaclespawn = {
				var = "crushertentaclespawn",
				varname = format(L["%s Spawns"],L["Crusher Tentacle"]),
				type = "dropdown",
				text = format(L["%s Spawns"],L["Crusher Tentacle"]).."!",
				time = "<crushertime>",
				flashtime = 7,
				color1 = "DCYAN",
				color2 = "INDIGO",
			},
		},
		arrows = {
			maladyarrow = {
				var = "maladyarrow",
				varname = SN[63830],
				unit = "#5#",
				persist = 4,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = L["Malady"],
			},
			brainlinkarrow = {
				var = "brainlinkarrow",
				varname = SN[63802],
				unit = "<brainlinkpartner>",
				persist = 29.9,
				action = "TOWARD",
				msg = L["CONVERGE"],
				spell = SN[63802],
			},
		},
		raidicons = {
			maladymark = {
				var = "maladymark",
				varname = SN[63830],
				type = "FRIENDLY",
				persist = 4,
				unit = "#5#",
				icon = 8,
			}
		},
		timers = {
			startbrainarrow = {{{arrow = "brainlinkarrow"}}},
		},
		events = {
			-- Lunatic Gaze
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64163,64164},
				execute = {
					{
						{alert = "lunaticgazewarn"},
						{alert = "lunaticgazecd"},
					},
				},
			},
			-- Brain Link
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63802,
				execute = {
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{set = {brainlinkpartner = "#5#"}},
					},
					{
						{expect = {"#4#","==","&playerguid&"}},
						{alert = "brainlinkdur"},
						{scheduletimer = {"startbrainarrow",0.1}},
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Phase 2
					{
						{expect = {"#1#","find",L["^I am the lucid dream"]}},
						{tracing = {L["Yogg-Saron"],L["Brain of Yogg-Saron"]}},
						{alert = "portalcd"},
						{alert = "crushertentaclespawn"},
						{set = {phase = "2"}},
					},
					-- Phase 3
					{
						{expect = {"#1#","find",L["^Look upon the true face"]}},
						{tracing = {L["Yogg-Saron"]}},
						{quash = "crushertentaclespawn"},
						{quash = "inducewarn"},
						{quash = "portalcd"},
						{set = {phase = "3"}},
					},
				},
			},
			{
				type = "event",
				event = "EMOTE",
				execute = {
					-- Portal
					{
						{expect = {"#1#","find",L["^Portals open"]}},
						{alert = "portalcd"},
					},
					-- Weakened
					{
						{expect = {"#1#","find",L["^The illusion shatters and a path"]}},
						{alert = "weakeneddur"},
						{quash = "inducewarn"},

						{expect = {"&timeleft|weakeneddur&",">","&timeleft|crushertentaclespawn&"}},
						{set = {crushertime = "&timeleft|weakeneddur|1&"}},
						{quash = "crushertentaclespawn"},
						{alert = "crushertentaclespawn"},
					},
					-- Empowering Shadows
					{
						{expect = {"#1#","find",L["prepares to unleash Empowering Shadows!$"]}},
						{alert = "empoweringshadowscd"},
					},
				},
			},
			-- Squeeze
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 64126,
				execute = {
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{alert = "squeezewarn"},
					},
				},
			},
			-- Malady of the Mind
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {63830,63881},
				execute = {
					{
						{expect = {"#4#","~=","&playerguid&"}},
						{proximitycheck = {"#5#",28}},
						{alert = "maladywarn"},
						{arrow = "maladyarrow"},
						{raidicon = "maladymark"},
					},
				},
			}, 
			-- Induce Madness
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64059,
				execute = {
					{
						{alert = "inducewarn"},
					},
				},
			},
			-- Brain Link removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {63802,63803,63804},
				execute = {
					{
						{expect = {"#4#","==","&playerguid&"}},
						{quash = "brainlinkdur"},
					},
				},
			},
			-- Crusher Tentacle spawn
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64144,
				execute = {
					{
						{expect = {"&timeleft|crushertentaclespawn&","<","0.5"}},
						{expect = {"<phase>","==","2"}},
						{set = {crushertime = 50}},
						{quash = "crushertentaclespawn"},
						{alert = "crushertentaclespawn"},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
