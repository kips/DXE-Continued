do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 308,
		key = "yoggsaron", 
		zone = L.zone["Ulduar"], 
		name = L["Yogg-Saron"], 
		triggers = {
			yell = L["^The time to strike at the head of the beast"],
			scan = {
				33134, -- Sara
				33288, -- Yogg-Saron
				33890, -- Brain of Yogg-Saron
				33966, -- Crusher Tentacle
				33985, -- Corruptor Tentacle
				33983, -- Constrictor Tentacle
				33136, -- Guardian of Yogg-Saron
			},
		},
		onactivate = {
			tracing = {33134}, -- Sara
			combatstop = true,
			defeat = 33288,
		},
		userdata = {
			portaltime = {73,90,loop = false},
			portaltext = {format(L["%s Soon"],L["Portals"]),format(L["Next %s"],L["Portals"]), loop = false},
			crushertime = {14,55,loop = false},
			phase = "1",
		},
		onstart = {
			{
				"alert","enragecd",
			},
		},
		alerts = {
			enragecd = {
				varname = L["Enrage"],
				type = "dropdown",
				text = L["Enrage"],
				time = 900,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			-- Phase 1
			fervorwarn = {
				varname = format(L["%s on self"],SN[63138]),
				type = "simple",
				text = format("%s: %s!",SN[63138],L["YOU"]),
				time = 2,
				sound = "ALERT4",
				color1 = "PURPLE",
				flashscreen = true,
				icon = ST[63138],
			},
			blessingwarn = {
				varname = format(L["%s on self"],SN[63134]),
				type = "simple",
				text = format("%s: %s!",SN[63134],L["YOU"]),
				time = 2,
				sound = "ALERT8",
				color1 = "CYAN",
				flashscreen = true,
				icon = ST[63134],
			},
			-- Phase 2
			brainlinkdur = {
				varname = format(L["%s on self"],SN[63802]),
				type = "centerpopup",
				text = format("%s: %s!",SN[63802],L["YOU"]),
				time = 30,
				flashtime = 30,
				color1 = "BLUE",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[63802],
			},
			portalcd = {
				varname = format(L["%s Cooldown"],L["Portals"]),
				type = "dropdown",
				text = "<portaltext>",
				time = "<portaltime>",
				flashtime = 10,
				sound = "ALERT2",
				color1 = "MAGENTA",
				color2 = "MAGENTA",
				icon = ST[66634],
			},
			weakeneddur = {
				varname = format(L["%s Duration"],L["Weakened"]),
				type = "centerpopup",
				text = L["Weakened"].."!",
				time = "&timeleft|inducewarn&",
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[64173],
			},
			inducewarn = {
				varname = format(L["%s Cast"],SN[64059]),
				type = "dropdown",
				text = format(L["%s Cast"],SN[64059]),
				time = 60,
				flashtime = 5,
				color1 = "BROWN",
				color2 = "MIDGREY",
				sound = "ALERT6",
				icon = ST[64059],
			},
			squeezewarn = {
				varname = format(L["%s on others"],SN[64126]),
				type = "simple",
				text = format("%s: #5#",SN[64126]),
				time = 4,
				color1 = "YELLOW",
				sound = "ALERT7",
				icon = ST[64126],
			},
			maladywarn = {
				varname = format(L["%s Warning"],SN[63830]),
				type = "simple",
				text = format("%s: #5#! %s",L["Malady"],L["MOVE AWAY"]),
				time = 3,
				sound = "ALERT5",
				color1 = "GREEN",
				flashscreen = true,
				icon = ST[63830],
			},
			crushertentaclewarn = {
				varname = format(L["%s Spawns"],L["Crusher Tentacle"]),
				type = "dropdown",
				text = format(L["%s Spawns"],L["Crusher Tentacle"]).."!",
				time = "<crushertime>",
				flashtime = 7,
				color1 = "DCYAN",
				color2 = "INDIGO",
				icon = ST[50234],
			},
			-- Phase 3
			empoweringshadowscd = {
				varname = format(L["%s Timer"],SN[64486]),
				type = "centerpopup",
				text = format(L["Next %s"],SN[64486]),
				time = 10, 
				flashtime = 5,
				color1 = "INDIGO",
				color2 = "RED",
				icon = ST[64486],
			},
			shadowbeaconcd = {
				varname = format(L["%s Cooldown"],SN[64465]),
				type = "dropdown",
				text = format(L["Next %s"],SN[64465]),
				time = 45, 
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[64465],
			},
			deafeningcd = {
				varname = format(L["%s Cooldown"],SN[64189]),
				type = "dropdown",
				text = format(L["Next %s"],SN[64189]),
				time = 60,
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[64189],
			},
			deafeningwarn = {
				varname = format(L["%s Cast"],SN[64189]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[64189]),
				time = 2.3,
				color1 = "ORANGE",
				sound = "ALERT5",
				icon = ST[64189],
			},
			lunaticgazewarn = {
				varname = format(L["%s Cast"],SN[64163]),
				type = "centerpopup",
				text = format("%s! %s!",SN[64163],L["LOOK AWAY"]),
				time = 4,
				color1 = "PURPLE",
				sound = "ALERT1",
				flashscreen = true,
				icon = ST[64163],
			},
			lunaticgazecd = {
				varname = format(L["%s Cooldown"],SN[64163]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[64163]),
				time = 11,
				flashtime = 5,
				color1 = "GREEN",
				color2 = "YELLOW",
				icon = ST[64163],
			},
		},
		arrows = {
			maladyarrow = {
				varname = SN[63830],
				unit = "#5#",
				persist = 4,
				action = "AWAY",
				msg = L["MOVE AWAY"],
				spell = L["Malady"],
			},
		},
		raidicons = {
			maladymark = {
				varname = SN[63830],
				type = "FRIENDLY",
				persist = 4,
				unit = "#5#",
				icon = 1,
			}
		},
		events = {
			-- Sara's Fervor
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63138,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","fervorwarn",
					},
				},
			},
			-- Sara's Blessing
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 63134,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","blessingwarn",
					},
				},
			},
			-- Lunatic Gaze
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64163,64164},
				execute = {
					{
						"alert","lunaticgazewarn",
						"alert","lunaticgazecd",
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
						"expect",{"#4#","==","&playerguid&"},
						"alert","brainlinkdur",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Phase 2
					{
						"expect",{"#1#","find",L["^I am the lucid dream"]},
						"tracing",{33288,33890}, -- Yogg-Saron, Brain of Yogg-Saron
						"alert","portalcd",
						"alert","crushertentaclewarn",
						"set",{phase = "2"},
					},
					-- Phase 3
					{
						"expect",{"#1#","find",L["^Look upon the true face"]},
						"tracing",{33288}, -- Yogg-Saron
						"quash","crushertentaclewarn",
						"quash","inducewarn",
						"quash","portalcd",
						"quash","weakeneddur",
						"alert","shadowbeaconcd",
						"set",{phase = "3"},
						"expect",{"&difficulty&","==","2"},
						"alert","deafeningcd",
					},
				},
			},
			{
				type = "event",
				event = "EMOTE",
				execute = {
					-- Portal
					{
						"expect",{"#1#","find",L["^Portals open"]},
						"alert","portalcd",
					},
					-- Weakened
					{
						"expect",{"#1#","find",L["^The illusion shatters and a path"]},
						"alert","weakeneddur",
						"quash","inducewarn",

						"expect",{"&timeleft|weakeneddur&",">","&timeleft|crushertentaclewarn&"},
						"set",{crushertime = "&timeleft|weakeneddur|5&"},
						"quash","crushertentaclewarn",
						"alert","crushertentaclewarn",
					},
				},
			},
			-- Squeeze
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {64126,64125},
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","squeezewarn",
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
						"raidicon","maladymark",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"proximitycheck",{"#5#",28},
						"alert","maladywarn",
						"arrow","maladyarrow",
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
						"alert","inducewarn",
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
						"expect",{"#4#","==","&playerguid&"},
						"quash","brainlinkdur",
					},
				},
			},
			-- Crusher Tentacle spawn -> Focused Anger
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {57688,57689},
				execute = {
					{
						"expect",{"<phase>","==","2"},
						"quash","crushertentaclewarn",
						"alert","crushertentaclewarn",
					},
				},
			},
			-- Deafening Roar
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 64189,
				execute = {
					{
						"quash","deafeningcd",
						"alert","deafeningwarn",
						"alert","deafeningcd",
					},
				},
			},
			-- Shadow Beacon, Empowering Shadows
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 64465,
				execute = {
					{
						"quash","shadowbeaconcd",
						"alert","shadowbeaconcd",
						"alert","empoweringshadowscd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
