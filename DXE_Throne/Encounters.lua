local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- CONCLAVE OF WIND 
---------------------------------

do
	local data = {
		version = 3,
		key = "windconclave",
		zone = L.zone["Throne of the Four Winds"],
		category = L.zone["Throne"],
		name = L.npc_throne["Conclave of Wind"],
		triggers = {
			scan = {
				45870, -- Anshal
				45871, -- Nezir
				45872, -- Rohash
			},
			yell = L.chat_throne["^It shall be I that earns the favor of our lord by casting out the intruders. My calmest wind shall still prove too much for them!"],
		},
		onactivate = {
			tracing = {
				45870, -- Anshal
				45871, -- Nezir
				45872, -- Rohash
			},
			tracerstart = true,
			combatstart = true,
			combatstop = true,
			defeat = {
				45870, -- Anshal
				45871, -- Nezir
				45872, -- Rohash
			},
		},
		userdata = {
			stormshieldtime = {30,115,loop = false, type="series"},
			soothingtime = {16.3, 32.5, 32.5, loop = true, type="series"}, -- it will loop around and be erroneous during the OP move, and then predict 2nd / 3rd casts correctly.
			windblasttime = {30,82,60,loop = false, type="series"},
		},
		onstart = {
			{
				"alert", "stormshieldcd",
				"alert", "opmovecd",
				"alert", "enragecd",
				"alert", "windblastcd",
			},
		},
		raidicons = {
			creepermark = {
				varname = SN[85422],
				type = "MULTIENEMY",
				persist = 10,
				reset = 8,
				unit = "#4#",
				icon = 2,
				total = 6,
			},
		},
		alerts = {
			enragecd = {
				varname = "Enrage",
				type = "dropdown",
				text = "Enrage CD",
				time = 420,
				color1 = "RED",
				icon = ST[12317],
			},
			
			
			soothingcd = {
				varname = "Soothing Breeze Cooldown",
				type = "dropdown",
				text = "Soothing Breeze Cooldown",
				time = "<soothingtime>",
				color1 = "GREEN",
				icon = ST[86205],
			},
			
			
			creepersummon = {
				varname = "Creeper Summon",
				type = "simple",
				text = "Creeper Summon",
				time = 10,
				color1 = "YELLOW",
				sound = "ALERT12",
				icon = ST[93138],
			},
			
			creeperchannel = {
				varname = "Creeper Channel",
				type = "simple",
				text = "Creeper Channel",
				time = 10,
				color1 = "YELLOW",
				sound = "ALERT12",
				icon = ST[93138],
			},
			
			creepercast = {
				varname = "Creeper Cast",
				type = "simple",
				text = "Creeper Cast",
				time = 10,
				color1 = "YELLOW",
				sound = "ALERT12",
				icon = ST[93138],
			},
			
			
			windchillcd = {
				varname = format(L.alert["%s Cooldown"],SN[93125]),
				type = "dropdown",
				text = format("%s Cooldown",SN[93125]),
				time = 15,
				throttle = 2,
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[93125],
			},
			
			windblastwarn = {
				varname = format(L.alert["%s Warning"],SN[93138]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[93138]),
				time = 3,
				flashtime = 3,
				flashscreen = true,
				color1 = "YELLOW",
				sound = "ALERT12",
				icon = ST[93138],
			},
			windblastdur = {
				varname = format(L.alert["%s Duration"],SN[93138]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[93138]),
				time = 6,
				color1 = "YELLOW",
				icon = ST[93138],
			},
			windblastcd ={
				varname = format(L.alert["%s Cooldown"],SN[93138]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[93138]),
				time = "<windblasttime>",
				color1 = "GREEN",
				flashtime = 3,
				sound = "ALERT10",
				icon = ST[93138],
			},
			
			opmovedur = {
				varname = format(L.alert["%s Duration"], "OP Move"),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],"OP Move"),
				time = 15,
				color1 = "ORANGE",
				icon = ST[84643],
			},
			stormshieldcd ={
				varname = format(L.alert["%s Cooldown"],SN[95865]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[95865]),
				time = "<stormshieldtime>",
				color1 = "ORANGE",
				icon = ST[95865],
			},
			opmovecd = {
				varname = "OP Move",
				type = "dropdown",
				text = "OP MOVE",
				time = 90,
				color1 = "BLUE",
				icon = ST[95865],
			}
		},
		events = {
			--  Creepers
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = {85422, 85425},
				srcnpcid = 45870, -- Anshall	
				execute = {
					{
						"alert", "creepercast",
						"raidicon", "creepermark",
					}
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {85422, 85425},
				srcnpcid = 45870, -- Anshall	
				execute = {
					{
						"alert", "creeperchannel",
						"raidicon", "creepermark",
					}
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellname = {85422, 85425},
				srcnpcid = 45870, -- Anshall	
				execute = {
					{
						"alert", "creepersummon",
						"raidicon", "creepermark",
					}
				},
			},
			---------------------------------------------
			-- Nezir
			---------------------------------------------
			-- Wind Chill initial
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = {84645, 93123, 93125},
				execute = {
					{
						"quash", "windchillcd",
						"alert", "windchillcd",
					},
				}
			},
			-- Wind Chill stack
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = {84645, 93123, 93125},
				execute = {
					{
						"quash", "windchillcd",
						"alert", "windchillcd",
					},
				}
			},
			---------------------------------------------
			-- Rohash
			---------------------------------------------
			
			-- Wind Blast (initial cast)
			{
				type = "event",
				event = "UNIT_SPELLCAST_CHANNEL_START",
				execute = {
					{
						"expect",{"#2#","==",SN[86193]},
						"expect",{"&channeldur|#1#&","<","4"},
						"alert","windblastwarn",
					}
				},
			},
			-- Wind Blast (effect active cast)
			{
				type = "event",
				event = "UNIT_SPELLCAST_CHANNEL_START",
				execute = {
					{
						"expect",{"#2#","==",SN[86193]},
						"expect",{"&channeldur|#1#&",">=","6"},
						"alert","windblastdur",
					},
				},
			},
			-- Storm Shield
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 95865,
				srcnpcid = 45872, -- Rohash	
				execute = {
					{
						"alert", "stormshieldcd",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Phase 2
					{
						"expect",{"#1#", "find", L.chat_throne["^The power of our winds, UNLEASHED!"]},
						"set", {phase = "2"},
						"quash", "soothingcd",
						"alert", "opmovedur",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- AL'AKIR 
---------------------------------

do
	local data = {
		version = 5,
		key = "alakir",
		zone = L.zone["Throne of the Four Winds"],
		category = L.zone["Throne"],
		name = L.npc_throne["Al'Akir"],
		triggers = {
			scan = {
				46753, -- Al'Akir 
			},
		},
		onactivate = {
			tracing = {
				46753, -- Al'Akir 
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				46753, -- Al'Akir 
			},
		},
		userdata = {
			phase = "1",
			feedbacktext = "",
			windbursttime = "",
			stormlingtime = {10,20,loop = false, type = "series"},
		},
		onstart = {
			{
				{ 
					"expect", {"&difficulty&", "==", "1"}, --10s normal 
					"set", {windbursttime = 25},
				}, 
				{ 
					"expect", {"&difficulty&", "==", "2"}, --25s normal 
					"set", {windbursttime = {20,30,loop = false, type="series"}},
				}, 
				{ 
					"expect", {"&difficulty&", "==", "3"}, --10s heroic 
				}, 
				{ 
					"expect", {"&difficulty&", "==", "4"}, --25s heroic }, 
					"set", {windbursttime = {20,30,loop = false, type="series"}},
				},
			
				"alert", "windburstcd",
				"alert", "lightningstrikecd",
			},
		},
		alerts = {
			lightningstrikecd = {
				varname = format(L.alert["%s Cooldown"],SN[93255]),
				type = "dropdown",
				text = format("%s Cooldown",SN[93255]),
				time = 8,
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[93255],
			},
			windburstcd = {
				varname = format(L.alert["%s Cooldown"],SN[87770]),
				type = "dropdown",
				text = format("%s Cooldown",SN[87770]),
				time = 25,
				flashtime = 5,
				color1 = "BLACK",
				icon = ST[87770],
			},
			acidraincd = {
				varname = format(L.alert["%s Cooldown"],SN[88301]),
				type = "dropdown",
				text = format("%s Cooldown",SN[88301]),
				time = 15,
				throttle = 2,
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[88301],
			},
			stormlingcd = {
				varname = format(L.alert["%s Cooldown"],SN[87919]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[87919]),
				time = "<stormlingtime>",
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[87919],
			},
			feedbackdur = {
				varname = format(L.alert["%s Duration"],SN[87904]),
				type = "centerpopup",
				text = "<feedbacktext>",
				time = 20,
				flashtime = 20,
				color1 = "BLUE",
				icon = ST[87904],
			},
			lightningrodself = {
				varname = format(L.alert["%s on self"],SN[89668]),
				type = "simple",
				text = format("%s: %s!",SN[89668],L.alert["YOU"]).."!",
				time = 5,
				flashscreen = true,
				color1 = "BLUE",
				sound = "ALERT12",
				icon = ST[89668],
				throttle = 2,
			},
			lightningrodwarn = {
				varname = format(L.alert["%s Warning"],SN[89668]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[89668]),
				time = 3,
				color1 = "BLUE",
				sound = "ALERT6",
				icon = ST[89668],
			},
		},
		announces = {
			lightningrodsay = {
				varname = format(L.alert["Say %s on self"],SN[89668]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[89668]).."!",
			},
		},
		raidicons = {
			rodmark = {
				varname = SN[93294],
				type = "FRIENDLY",
				persist = 5,
				unit = "#5#",
				icon = 1,
			},
		},
		events = {
			-- Wind Burst
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 87770,
				execute = {
					{
						--"quash","windburstcd",
						"alert","windburstcd",
					},
				},
			},
			-- Feedback - stack application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 87904,
				execute = {
					{
						"quash","feedbackdur",
						"set", {feedbacktext = format("%s Duration (%s)", SN[87904], format(L.alert["%s Stacks"], "#11#"))},
						"alert","feedbackdur",
					},
				}
			},
			-- Lightning Strike
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 93255,
				execute = {
					"alert", "lightningstrikecd",
				},
			},
			-- Acid Rain Stack Application, these are triggered when the stack is increased and refreshed
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = {88290, 93281, 93280, 93279, 91216, 88301},
				execute = {
					{
						"quash", "acidraincd",
						"alert", "acidraincd",
					},
				}
			},
			-- Lightning Rod
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = {93294, 89668},
				execute = {
					{
						"raidicon","rodmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","lightningrodself",
						"announce","lightningrodsay",

					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","lightningrodwarn",

					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Phase 2
					{
						"expect",{"#1#", "find", L.chat_throne["^Your futile persistance angers me!"]},
						"set", {phase = "2"},
						"quash", "windburstcd",
						"alert", "stormlingcd",
					},
					-- Phase 3
					{
						"expect",{"#1#", "find", L.chat_throne["^Enough! I will no longer be contained!"]},
						"quash", "stormlingcd",
						"quash", "acidraincd",
						"set", {phase = "3"},
					},
					-- Stormling Summon
					{
						"expect",{"#1#", "find", L.chat_throne["^Storms! I summon you to my side!"]},
						"quash", "stormlingcd",
						"alert", "stormlingcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end


