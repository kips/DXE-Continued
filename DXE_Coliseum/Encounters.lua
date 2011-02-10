local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- ANUB
---------------------------------

do
	local data = {
		version = 37,
		key = "anubcoliseum",
		zone = L.zone["Trial of the Crusader"],
		category = L.zone["Coliseum"],
		name = L.npc_coliseum["Anub'arak"],
		triggers = {
			scan = {
				34564, -- Anub
			},
			yell = L.chat_coliseum["^This place will serve as"],
		},
		onactivate = {
			tracing = {34564},
			combatstop = true,
			defeat = 34564,
		},
		onstart = {
			{
				"alert","burrowcd",
				"alert","enragecd",
				"alert","nerubiancd",
				"scheduletimer",{"firenerubian",10},
				"set",{nerubiantime = 5.5},
				"expect",{"&difficulty&",">=","3"},
				"alert","shadowstrikecd",
				"scheduletimer",{"fireshadowstrike",30.5},
			},
		},
		userdata = {
			burrowtime = {80,75,loop = false, type = "series"},
			nerubiantime = 10.5,
			leeching = 0,
			burrowed = 0,
			striketime = 30.5,
		},
		timers = {
			firenerubian = {
				{
					"set",{nerubiantime = 46.5},
					"alert","nerubiancd",
					"expect",{"&difficulty&",">=","3"},
					"scheduletimer",{"firenerubian2",46},
				},
			},
			firenerubian2 = {
				{
					"alert","nerubiancd",
					"scheduletimer",{"firenerubian2",46},
				},
			},
			fireshadowstrike = {
				{
					"alert","shadowstrikecd",
					"scheduletimer",{"fireshadowstrike",30.5},
				},
			},
		},
		alerts = {
			enragecd = {
				type = "dropdown",
				varname = L.alert["Enrage"],
				text = L.alert["Enrage"],
				time = 570,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			pursueself = {
				varname = format(L.alert["%s on self"],SN[62374]),
				type = "centerpopup",
				time = 60,
				flashtime = 60,
				text = format("%s: %s! %s!",SN[62374],L.alert["YOU"],L.alert["RUN"]),
				sound = "ALERT1",
				color1 = "BROWN",
				color2 = "GREY",
				icon = ST[67574],
			},
			pursueothers = {
				varname = format(L.alert["%s on others"],SN[62374]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[62374]),
				time = 60,
				flashtime = 60,
				color1 = "BROWN",
				icon = ST[67574],
			},
			burrowcd = {
				varname = format(L.alert["%s Cooldown"],SN[26381]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[26381]),
				time = "<burrowtime>",
				flashtime = 10,
				color1 = "ORANGE",
				icon = ST[1784],
			},
			burrowdur = {
				varname = format(L.alert["%s Duration"],SN[26381]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[26381]),
				time = 64,
				flashtime = 10,
				color1 = "GREEN",
				icon = ST[56504],
			},
			shadowstrikewarn = {
				varname = format(L.alert["%s Casting"],SN[66134]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[66134]),
				time = 8,
				flashtime = 8,
				color1 = "PURPLE",
				sound = "ALERT5",
				icon = ST[66134],
				throttle = 2,
			},
			shadowstrikecd = {
				varname = format(L.alert["%s Cooldown"],SN[66134]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[66134]),
				time = "<striketime>",
				flashtime = 10,
				color1 = "VIOLET",
				icon = ST[66135],
			},
			leechingswarmwarn = {
				varname = format(L.alert["%s Casting"],SN[66118]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[66118]),
				time = 1.5,
				flashtime = 1.5,
				color1 = "DCYAN",
				sound = "ALERT7",
				icon = ST[66118],
			},
			nerubiancd = {
				varname = format(L.alert["%s Timer"],SN[66333]),
				type = "dropdown",
				text = format(L.alert["%s Spawns"],SN[66333]),
				time = "<nerubiantime>",
				flashtime = 10,
				color1 = "INDIGO",
				icon = ST[66333],
			},
			slashwarn = {
				varname = format(L.alert["%s on others"],SN[66012]),
				type = "centerpopup",
				time = 3,
				flashtime = 3,
				text = format("%s: #5#!",SN[66012]),
				color1 = "BLUE",
				icon = ST[66012],
				sound = "ALERT8",
			},
			slashcd = {
				varname = format(L.alert["%s Cooldown"],SN[66012]),
				type = "dropdown",
				time = 20,
				flashtime = 5,
				text = format(L.alert["%s Cooldown"],SN[66012]),
				color1 = "YELLOW",
				icon = ST[66012],
			},
			coldcd = {
				varname = format(L.alert["%s Cooldown"],SN[68509]),
				type = "dropdown",
				time = 16,
				flashtime = 5,
				text = format(L.alert["%s Cooldown"],SN[68509]),
				color1 = "TURQUOISE",
				icon = ST[68509],
			},
			coldselfwarn = {
				varname = format(L.alert["%s on self"],SN[68509]),
				type = "simple",
				time = 3,
				text = format("%s: %s!",SN[68509],L.alert["YOU"]),
				flashscreen = true,
				sound = "ALERT9",
				icon = ST[68509],
			},
			colddur = {
				varname = format(L.alert["%s Duration"],SN[68509]),
				type = "centerpopup",
				time = 18,
				flashtime = 18,
				text = format(L.alert["%s Duration"],SN[68509]),
				color1 = "MAGENTA",
				sound = "ALERT2",
				icon = ST[68509],
			},
		},
		raidicons = {
			coldmark = {
				varname = SN[68509],
				type = "MULTIFRIENDLY",
				persist = 18,
				reset = 3,
				unit = "#5#",
				icon = 2,
				total = 5,
			},
			pursuemark = {
				varname = SN[62374],
				type = "FRIENDLY",
				persist = 60,
				unit = "#5#",
				icon = 1,
			},
		},
		arrows = {
			pursuedarrow = {
				varname = SN[62374],
				unit = "#5#",
				persist = 60,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = L.alert["Burrow"],
			},
		},
		events = {
			-- Shadow Strike (Hard Mode) - Only tracks up to 1
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 66134,
				execute = {
					{
						"alert","shadowstrikewarn",
						"quash","shadowstrikecd",
						"alert","shadowstrikecd",
						"scheduletimer",{"fireshadowstrike",30.5},
					},
				},
			},
			-- Shadow Strike (Hard Mode) interrupt
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","34607"},
						"quash","shadowstrikewarn",
					},
				},
			},
			-- Pursued by Anub'arak
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 67574,
				execute = {
					{
						"raidicon","pursuemark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","pursueself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","pursueothers",
						"arrow","pursuedarrow",
					},
				},
			},
			-- Pursued on Anub'arak removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 67574,
				execute = {
					{
						"removeraidicon","#5#",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","pursueself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","pursueothers",
						"removearrow","#5#",
					},
				},
			},
			-- Leeching Swarm
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					66118, -- 10 normal
					68646, -- 10 hard
					67630, -- 25 normal
					68647, -- 25 hard
				},
				execute = {
					{
						"quash","burrowcd",
						"alert","leechingswarmwarn",
						"set",{leeching = 1},
						"expect",{"&difficulty&","<=","2"},
						"quash","nerubiancd",
						"canceltimer","firenerubian",
					},
					{
						"expect",{"&difficulty&",">=","3"},
						"expect",{"&timeleft|shadowstrikecd&",">","0"},
						"set",{striketime = "&timeleft|shadowstrikecd|1.5&"},
						"quash","shadowstrikecd",
						"alert","shadowstrikecd",
						"scheduletimer",{"fireshadowstrike","<striketime>"},
						"set",{striketime = 30.5},
					},
				},
			},
			-- Burrows/Emerges
			{
				type = "event",
				event = "EMOTE",
				execute = {
					-- Burrows
					{
						"expect",{"#1#","find",L.chat_coliseum["burrows into the ground!$"]},
						"set",{burrowed = 1},
						"alert","burrowdur",
						"quash","slashcd",
						"quash","nerubiancd",
						"canceltimer","firenerubian2",
						"canceltimer","fireshadowstrike",
						"quash","shadowstrikecd",
					},
					-- Emerges
					{
						"expect",{"#1#","find",L.chat_coliseum["emerges from the ground!$"]},
						"set",{burrowed = 0},
						"alert","burrowcd",
						"set",{nerubiantime = 5.5},
						"alert","nerubiancd",
						"scheduletimer",{"firenerubian",5},
						"scheduletimer",{"fireshadowstrike",5},
					},
				},
			},
			-- Freezing Slash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 66012,
				execute = {
					{
						"quash","slashcd",
						"alert","slashcd",
					},
				},
			},
			-- Freezing Slash application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66012,
				execute = {
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","slashwarn",
					},
				},
			},
			-- Penetrating Cold
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					68509, -- 10 normal
					66013, -- 10 hard
					67700, -- 25 normal
					68510, -- 25 hard
				},
				execute = {
					{
						"expect",{"<leeching>","==","1"},
						"alert","coldcd",
						"alert","colddur",
					},
				},
			},
			-- Penetrating Cold self
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					68509, -- 10 normal
					66013, -- 10 hard
					67700, -- 25 normal
					68510, -- 25 hard
				},
				execute = {
					{
						"raidicon","coldmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","coldselfwarn",
					},
				},
			},
			-- Penetrating Cold removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					68509, -- 10 normal
					66013, -- 10 hard
					67700, -- 25 normal
					68510, -- 25 hard
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- Penetrating Cold refreshes
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REFRESH",
				spellid = {
					68509, -- 10 normal
					66013, -- 10 hard
					67700, -- 25 normal
					68510, -- 25 hard
				},
				execute = {
					{
						"raidicon","coldmark",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- FACTION CHAMPIONS
---------------------------------

do
	local faction = UnitFactionGroup("player")
	local npc_list

	local NID_MAGE,NID_WARLOCK

	if faction == "Alliance" then
		-- Horde npcs
		npc_list = {
			34458, -- Gorgrim	  	DK
			34451, -- Birana	  	DRUID_CASTER
			34459, -- Erin		  	DRUID_HEALER
			34448, -- Ruj'kah	  	HUNTER
			34449, -- Ginselle  	MAGE
			34445, -- Liandra	  	PALADIN_HEALER
			34456, -- Malithas  	PALADIN_RET
			34447, -- Caiphus   	PRIEST_HEALER
			34441, -- Vivienne  	PRIEST_SHADOW
			34454, -- Maz'dinah 	ROGUE
			34444, -- Thrakgar  	SHAMAN_CASTER
			34455, -- Broln	  	SHAMAN_ENH
			34450, -- Harkzog   	WARLOCK
			34453, -- Narrhok   	WARRIOR
		}
		NID_MAGE = "34449"
		NID_WARLOCK = "34450"
	elseif faction == "Horde" then
		-- Alliance npcs
		npc_list = {
			34461, -- Tyrius 		DK
			34460, -- Kavina 		DRUID_CASTER
			34469, -- Melador 	DRUID_HEALER
			34467, -- Alyssia 	HUNTER
			34468, -- Noozle 		MAGE
			34465, -- Velanaa 	PALADIN_HEALER
			34471, -- Baelnor 	PALADIN_RET
			34466, -- Anthar 		PRIEST_HEALER
			34473, -- Brienna		PRIEST_SHADOW
			34472, -- Irieth 		ROGUE
			34470, -- Saamul 		SHAMAN_CASTER
			34463, -- Shaabad 	SHAMAN_ENH
			34474, -- Serissa 	WARLOCK
			34475, -- Shocuul 	WARRIOR
		}
		NID_MAGE = "34468"
		NID_WARLOCK = "34474"
	else
		error("DXE_Coliseum Faction Champions: Unable to detect faction. Please report this bug.")
	end
	npc_list[#npc_list+1] = 35465 -- Zhaagrym (Warlock Felhunter pet)
	npc_list[#npc_list+1] = 35610 -- Cat (Hunter pet)

	local data = {
		version = 9,
		key = "factionchampions",
		zone = L.zone["Trial of the Crusader"],
		category = L.zone["Coliseum"],
		name = L.npc_coliseum["Faction Champions"],
		title = L.npc_coliseum["Faction Champions"],
		triggers = {
			scan = npc_list,
		},
		onactivate = {
			combatstart = true,
			combatstop = true,
			sortedtracing = npc_list,
			defeat = L.chat_coliseum["^A shallow and tragic victory"],
		},
		alerts = {
			bloodlustwarn = {
				varname = format(L.alert["%s Warning"],SN[65980]),
				type = "simple",
				text = format(L.alert["%s Cast"],SN[65980]).."! "..L.alert["DISPEL"].."!",
				time = 3,
				sound = "ALERT1",
				color1 = "ORANGE",
				icon = ST[65980],
			},
			heroismwarn = {
				varname = format(L.alert["%s Warning"],SN[65983]),
				type = "simple",
				text = format(L.alert["%s Cast"],SN[65983]).."! "..L.alert["DISPEL"].."!",
				time = 3,
				sound = "ALERT1",
				color1 = "ORANGE",
				icon = ST[65983],
			},
			divineshielddur = {
				varname = format(L.alert["%s Duration"],SN[66010]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[66010]),
				time = 12,
				flashtime = 12,
				sound = "ALERT4",
				color1 = "MAGENTA",
				icon = ST[66010],
			},
			avengwrathdur = {
				varname = format(L.alert["%s Duration"],SN[66011]),
				type = "centerpopup",
				text = format("%s: #2#!",SN[66011]),
				time = 20,
				flashtime = 20,
				sound = "ALERT7",
				color1 = "YELLOW",
				icon = ST[66011],
			},
			hellfirewarn = {
				varname = format(L.alert["%s Casting"],SN[68145]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[68145]).."!",
				time = 15,
				flashtime = 15,
				color1 = "BROWN",
				color2 = "PEACH",
				icon = ST[68145],
			},
			hellfireself = {
				varname = format(L.alert["%s on self"],SN[68145]),
				type = "simple",
				text = format("%s: %s! %s!",SN[68145],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				throttle = 3,
				sound = "ALERT3",
				icon = ST[68145],
				flashscreen = true,
			},
			hopdur = {
				varname = format(L.alert["%s Duration"],SN[66009]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[66009]),
				time = 10,
				flashtime = 10,
				sound = "ALERT5",
				color1 = "BLUE",
				icon = ST[66009],
			},
			hofdur = {
				varname = format(L.alert["%s Duration"],SN[66115]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[66115]),
				time = 10,
				flashtime = 10,
				sound = "ALERT6",
				color1 = "GREY",
				icon = ST[66115],
			},
			bladestormdur = {
				varname = format(L.alert["%s Duration"],SN[65947]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[65947]),
				time = 8,
				flashtime = 8,
				color1 = "INDIGO",
				color2 = "BLACK",
				icon = ST[65947],
			},
			bladestormself = {
				varname = format(L.alert["%s on self"],SN[65947]),
				type = "simple",
				text = format("%s: %s! %s!",SN[65947],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				throttle = 3,
				icon = ST[65947],
				sound = "ALERT3",
				flashscreen = true,
			},
			retaldur = {
				varname = format(L.alert["%s Duration"],SN[65932]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[65932]),
				time = 12,
				flashtime = 12,
				color1 = "GREEN",
				icon = ST[65932],
			},
			retalself = {
				varname = format(L.alert["%s on self"],SN[65934]),
				type = "simple",
				text = format("%s: %s!",SN[65934],L.alert["YOU"]),
				time = 3,
				throttle = 3,
				sound = "ALERT3",
				icon = ST[65934],
				flashscreen = true,
			},
			counterspellcd = {
				varname = format(L.alert["%s Cooldown"],SN[65790]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[65790]),
				time = 24,
				flashtime = 5,
				color1 = "VIOLET",
				icon = ST[65790],
			},
			spelllockcd = {
				varname = format(L.alert["%s Cooldown"],SN[67519]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[67519]),
				time = 24,
				flashtime = 5,
				color1 = "TAN",
				icon = ST[67519],
			},
			-- Possibly add Earth Shield
			-- Add in Ice Block
		},
		events = {
			-- Bloodlust
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 65980,
				execute = {
					{
						"alert","bloodlustwarn",
					},
				},
			},
			-- Heroism
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 65983,
				execute = {
					{
						"alert","heroismwarn",
					},
				},
			},
			-- Hellfire channel
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					65816,
					68145,
					68147,
					68146,
				},
				execute = {
					{
						"alert","hellfirewarn",
					},
				},
			},
			-- Hellfire interrupt
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				spellid2 = {68145,65816,68147,68146},
				execute = {
					{
						"expect",{"&npcid|#4#&","==",NID_WARLOCK},
						"quash","hellfirewarn",
					},
				},
			},
			-- Hellfire on self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {65817,68142},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","hellfireself",
					},
				},
			},
			-- Divine Shield
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66010,
				execute = {
					{
						"alert","divineshielddur",
					},
				},
			},
			-- Divine Shield removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 66010,
				execute = {
					{
						"quash","divineshielddur",
					},
				},
			},
			-- Hand of Protection
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66009,
				execute = {
					{
						"alert","hopdur",
					},
				},
			},
			-- Hand of Protection removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 66009,
				execute = {
					{
						"quash","hopdur",
					},
				},
			},
			-- Hand of Freedom
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {66115,68756},
				execute = {
					{
						"alert","hofdur",
					},
				},
			},
			-- Hand of Freedom removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {66115,68756},
				execute = {
					{
						"quash","hofdur",
					},
				},
			},
			-- Avenging Wrath
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66011,
				execute = {
					{
						"alert","avengwrathdur",
					},
				},
			},
			-- Avenging Wrath removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 66011,
				execute = {
					{
						"quash","avengwrathdur",
					},
				},
			},

			-- Bladestorm
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 65947,
				execute = {
					{
						"alert","bladestormdur",
					},
				},
			},
			-- Bladestorm on self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = 65946,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","bladestormself",
					},
				},
			},
			-- Retaliation
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 65932,
				execute ={
					{
						"alert","retaldur",
					},
				},
			},
			-- Retaliation removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = 65932,
				execute ={
					{
						"quash","retaldur",
					},
				},
			},
			-- Retaliation on self
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = 65934,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","retalself",
					}
				},
			},
			-- Counterspell
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 65790,
				execute = {
					{
						"alert","counterspellcd",
					}
				},
			},
			-- Spell Lock
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 67519,
				execute = {
					{
						"alert","spelllockcd",
					}
				},
			},
			-- Unit Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","35465"}, -- Zhaargrym
						"quash","spelllockcd",
					},
					{
						"expect",{"&npcid|#4#&","==",NID_MAGE}, -- Mage (Ginselle|Noozle)
						"quash","counterspellcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- LORD JARAXXUS
---------------------------------

do
	local data = {
		version = 323,
		key = "jaraxxus",
		zone = L.zone["Trial of the Crusader"],
		category = L.zone["Coliseum"],
		name = L.npc_coliseum["Lord Jaraxxus"],
		triggers = {
			scan = {
				34780, -- Jaraxxus
				34826, -- Mistress of Pain
			},
		},
		onactivate = {
			tracing = {34780,34826},
			tracerstart = true,
			combatstop = true,
			defeat = 34780,
		},
		userdata = {
			eruptiontime = {80,120, loop = false, type = "series"},
			portaltime = {20,120, loop = false, type = "series"},
			fleshtime = {14, 21, loop = false, type = "series"},
			flametime = {9, 30, loop = false, type = "series"},
			mistresstime = 8,
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"},
				"tracing",{
					34780, -- Jaraxxus
					34826, -- Mistress
					34825, -- Nether Portal
					34813, -- Infernal Volcano
				},
				"set",{mistresstime = 6},
			},
			{
				"alert","enragecd",
				"alert","portalcd",
				"alert","legionflamecd",
				"alert","eruptioncd",
				"alert","fleshcd",
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				text = L.alert["Enrage"],
				type = "dropdown",
				time = 600,
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			legionflameself = {
				varname = format(L.alert["%s on self"],SN[68123]),
				text = format("%s: %s!",SN[68123],L.alert["YOU"]),
				type = "centerpopup",
				time = 8, -- +2 seconds because it falls off and then reapplies
				flashtime = 8,
				color1 = "GREEN",
				color2 = "MAGENTA",
				flashscreen = true,
				sound = "ALERT1",
				icon = ST[68123],
			},
			legionflamecd = {
				varname = format(L.alert["%s Cooldown"],SN[68123]),
				text = format(L.alert["%s Cooldown"],SN[68123]),
				type = "dropdown",
				time = "<flametime>",
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[68123],
			},
			legionflameproximitywarn = {
				varname = format(L.alert["%s Proximity Warning"],SN[68123]),
				text = format("%s: #5#! %s!",SN[68123],L.alert["MOVE AWAY"]),
				type = "simple",
				time = 2,
				color1 = "GOLD",
				sound = "ALERT3",
				icon = ST[68123],
				flashscreen = true,
			},
			fleshself = {
				varname = format(L.alert["%s on self"],SN[67051]),
				text = format("%s: %s!",SN[67051],L.alert["YOU"]),
				type = "centerpopup",
				time = 12,
				flashtime = 12,
				color1 = "ORANGE",
				color2 = "BLACK",
				flashscreen = true,
				sound = "ALERT2",
				icon = ST[67051],
			},
			fleshwarn = {
				varname = format(L.alert["%s on others"],SN[67051]),
				text = format("%s: #5#!",SN[67051]),
				type = "centerpopup",
				time = 12,
				flashtime = 12,
				color1 = "ORANGE",
				icon = ST[67051],
			},
			fleshcd = {
				varname = format(L.alert["%s Cooldown"],SN[67051]),
				text = format(L.alert["%s Cooldown"],SN[67051]),
				type = "dropdown",
				time = "<fleshtime>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[67051],
			},
			eruptioncd = {
				varname = format(L.alert["%s Cooldown"],SN[67901]),
				text = format(L.alert["Next %s"],SN[67901]),
				type = "dropdown",
				time = "<eruptiontime>",
				flashtime = 10,
				color1 = "BROWN",
				icon = ST[67901],
			},
			portalcd = {
				varname = format(L.alert["%s Cooldown"],SN[67898]),
				text = format(L.alert["Next %s"],SN[67898]),
				type = "dropdown",
				time = "<portaltime>",
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[67898],
			},
			netherpowerwarn = {
				varname = format(L.alert["%s Warning"],SN[66228]),
				text = format("%s! %s!",SN[66228],L.alert["DISPEL"]),
				type = "simple",
				time = 3,
				color1 = "WHITE",
				sound = "ALERT4",
				icon = ST[66228],
			},
			mistresswarn = {
				varname = format(L.alert["%s Timer"],L.npc_coliseum["Mistress of Pain"]),
				text = format(L.alert["%s Spawns"],L.npc_coliseum["Mistress of Pain"]).."!",
				type = "centerpopup",
				time = "<mistresstime>",
				color1 = "TAN",
				icon = ST[67905],
			},
			kissselfdur = {
				type = "centerpopup",
				varname = format(L.alert["%s on self"],SN[67907]),
				text = format("%s: %s! %s!",SN[67907],L.alert["YOU"],L.alert["CAREFUL"]),
				time = 15,
				flashtime = 15,
				color1 = "CYAN",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[67907],
			},
			felinfernowarn = {
				type = "simple",
				varname = format(L.alert["%s on self"],SN[68718]),
				text = format("%s: %s! %s!",SN[68718],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				sound = "ALERT7",
				flashscreen = true,
				icon = ST[68718],
				throttle = 3,
			},
		},
		arrows = {
			flamearrow = {
				varname = SN[68123],
				unit = "#5#",
				persist = 3,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[68123],
				sound = "ALERT8",
			},
		},
		raidicons = {
			legionflamemark = {
				varname = SN[68123],
				type = "FRIENDLY",
				persist = 6,
				unit = "#5#",
				icon = 2,
			},
			fleshmark = {
				varname = SN[67051],
				type = "FRIENDLY",
				persist = 12,
				unit = "#5#",
				icon = 1,
			},
		},
		announces = {
			flamesay = {
				varname = format(L.alert["Say %s on self"],SN[68123]),
				type = "SAY",
				msg = format(L.alert["%s on Me"],SN[68123]).."!",
			},
		},
		events = {
			-- Legion Flame Note: Use spellid with buff description 'Flame begins to spread from your body!'
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					68125,
					68124, -- 10 hard
					66197, -- 10 normal
					68123, -- 25 normal
				},
				execute = {
					{
						"alert","legionflamecd",
						"raidicon","legionflamemark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","legionflameself",
						"announce","flamesay",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"proximitycheck",{"#5#",11},
						"alert","legionflameproximitywarn",
						"arrow","flamearrow",
					},
				},
			},
			-- Incinerate Flesh
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67050, -- 10 hard
					67051,
					66237, -- 10 normal
					67049, -- 25 normal
				},
				execute = {
					{
						"alert","fleshcd",
						"raidicon","fleshmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","fleshself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","fleshwarn",
					},
				},
			},
			-- Incinerate Flesh - Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67050, -- 10 hard
					67051,
					66237, -- 10 normal
					67049, -- 25 normal
				},
				execute = {
					{
						"removeraidicon","#5#",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","fleshself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","fleshwarn",
					},
				},
			},
			-- Infernal Eruption
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					67902, -- 10 hard
					67903,
					66258, -- 10 normal
					67901, -- 25 normal
				},
				execute = {
					{
						"alert","eruptioncd",
					},
				},
			},
			-- Nether Portal
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					67900,
					66269, -- 10 normal
					67898, -- 25 normal
					67899, -- 10m hard
				},
				execute = {
					{
						"alert","portalcd",
						"alert","mistresswarn",
					},
				},
			},
			-- Nether Power
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 67009, -- 10/25 normal
				execute = {
					{
						"alert","netherpowerwarn",
					},
				},
			},
			-- Mistress' Kiss (hard)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67906, -- 10 hard
					67907, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","kissselfdur",
					},
				},
			},
			-- Mistress' Kiss removal (hard)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67906, -- 10 hard
					67907, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","kissselfdur",
					},
				},
			},
			-- Fel Inferno
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					68718, -- 25 hard
					68716, -- 25 normal
					68717, -- 10 hard
					66496, -- 10 normal
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","felinfernowarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- NORTHREND BEASTS
---------------------------------

do
	local data = {
		version = 337,
		key = "northrendbeasts",
		zone = L.zone["Trial of the Crusader"],
		category = L.zone["Coliseum"],
		name = L.npc_coliseum["Northrend Beasts"],
		triggers = {
			scan = {
				34796, -- Gormok
				35144, -- Acidmaw
				34799, -- Dreadscale
				34797, -- Icehowl
			},
			yell = L.chat_coliseum["^Hailing from the deepest, darkest caverns of the Storm Peaks"]
		},
		onactivate = {
			tracing = {34796}, -- Gormok
			defeat = 34797,
			combatstop = true,
		},
		userdata = {
			enragetime = 900,
			acidmawdead = 0,
			dreadscaledead = 0,
			moltenspewtime = {10,21,loop = false, type = "series"},
			acidicspewtime = {27,21,loop = true, type = "series"},
			firemoltencd = 1,
			fireacidiccd = 1,
			impaletext = "",
			lasttoxin = "NONE",
			lastbile = "NONE",
			hastoxin = 0,
			hasbile = 0,
			tmp = "",
			crashtext = {format(L.alert["Next %s"],SN[66683]),format(L.alert["%s Cooldown"],SN[66683]),loop = false, type = "series"},
			crashtime = {36,55,loop = false, type = "series"},
			enragetext = {format(L.alert["Next %s"],L.alert["Phase"]),format(L.alert["Next %s"],L.alert["Phase"]),L.alert["Enrage"], loop = false, type = "series"},
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"},
				"set",{enragetime = 143},
			},
			{
				"expect",{"&difficulty&","<=","2"},
				"set",{enragetext = L.alert["Enrage"]},
			},
			{
				"alert","zerotoonecd",
				"scheduletimer",{"fireenrage",22},
			},
		},
		windows = {
			proxwindow = true,
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = "<enragetext>",
				time = "<enragetime>",
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			-- Gormok
			firebombwarnself = {
				varname = format(L.alert["%s on self"],SN[66313]),
				type = "simple",
				text = format("%s: %s! %s!",SN[66313],L.alert["YOU"],L.alert["MOVE"]),
				time = 2,
				throttle = 3,
				color1 = "ORANGE",
				sound = "ALERT3",
				flashscreen = true,
				icon = ST[66313],
			},
			impalecd = {
				varname = format(L.alert["%s Cooldown"],SN[66331]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[66331]),
				time = 10,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[66331],
				counter = true,
			},
			impalewarn = {
				varname = format(L.alert["%s Warning"],SN[66331]),
				type = "simple",
				text = "<impaletext>",
				time = 3,
				icon = ST[66331],
				sound = "ALERT1",
			},
			stompwarn = {
				varname = format(L.alert["%s Casting"],SN[66330]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[48131]),
				time = 0.5,
				color1 = "BROWN",
				sound = "ALERT5",
				icon = ST[66330],
			},
			stompcd = {
				varname = format(L.alert["%s Cooldown"],SN[66330]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[48131]),
				time = 20.8,
				flashtime = 5,
				color1 = "TAN",
				color2 = "TAN",
				sound = "ALERT7",
				icon = ST[66330],
			},
			-- Jormungars
			submergecd = {
				varname = format(L.alert["%s Cooldown"],SN[56504]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[56504]),
				time = 45,
				flashtime = 10,
				color1 = "BROWN",
				sound = "ALERT4",
				icon = ST[56504],
			},
			bileonself = {
				varname = format(L.alert["%s on self"],SN[66870]),
				type = "centerpopup",
				text = format("%s: %s",SN[66870],L.alert["YOU"]).."!",
				time = 24,
				flashtime = 24,
				sound = "ALERT3",
				color1 = "CYAN",
				color2 = "ORANGE",
				flashscreen = true,
				icon = ST[66870],
			},
			toxinonself = {
				varname = format(L.alert["%s on self"],SN[66823]),
				type = "centerpopup",
				text = format("%s: %s",SN[66823],L.alert["YOU"]).."!",
				time = 60,
				flashtime = 60,
				sound = "ALERT2",
				color1 = "GREEN",
				color2 = "PINK",
				flashscreen = true,
				icon = ST[66823],
			},
			slimepoolself = {
				varname = format(L.alert["%s on self"],SN[67638]),
				type = "simple",
				text = format("%s: %s!",SN[67638],L.alert["YOU"]),
				time = 3,
				sound = "ALERT1",
				color1 = "TURQUOISE",
				icon = ST[67638],
				throttle = 3,
				flashscreen = true,
			},
			enragewarn = {
				varname = format(L.alert["%s Warning"],SN[5229]),
				type = "simple",
				text = format("%s: #5#!",SN[5229]),
				time = 3,
				sound = "ALERT5",
				icon = ST[68335],
			},
			moltenspewcd = {
				varname = format(L.alert["%s Cooldown"],SN[66821]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[66821]),
				time = "<moltenspewtime>",
				color1 = "MAGENTA",
				flashtime = 5,
				icon = ST[66821],
			},
			moltenspewwarn = {
				varname = format(L.alert["%s Casting"],SN[66821]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[66821]),
				time = 3.5,
				flashtime = 3.5,
				color1 = "MAGENTA",
				color2 = "GREY",
				sound = "ALERT7",
				icon = ST[66821],
			},
			acidicspewcd = {
				varname = format(L.alert["%s Cooldown"],SN[66818]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[66818]),
				time = "<acidicspewtime>",
				flashtime = 5,
				color1 = "TEAL",
				icon = ST[66818],
			},
			acidicspewwarn = {
				varname = format(L.alert["%s Casting"],SN[66818]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[66818]),
				time = 3.5,
				flashtime = 3.5,
				color1 = "TEAL",
				color2 = "GREY",
				sound = "ALERT7",
				icon = ST[66818],
			},
			-- Icehowl
			breathwarn = {
				varname = format(L.alert["%s Casting"],SN[66689]),
				type = "centerpopup",
				text = SN[66689].."!",
				time = 5,
				color1 = "BLUE",
				sound = "ALERT6",
				throttle = 6,
				icon = ST[66689],
			},
			ragewarn = {
				varname = format(L.alert["%s Warning"],SN[67657]),
				type = "centerpopup",
				text = format("%s! %s!",SN[67657],L.alert["DISPEL"]),
				time = 15,
				throttle = 15,
				color1 = "DCYAN",
				sound = "ALERT4",
				icon = ST[67657],
			},
			dazedur = {
				varname = format(L.alert["%s Duration"],SN[66758]),
				type = "centerpopup",
				text = SN[66758].."!",
				time = 15,
				color1 = "GREY",
				icon = ST[66758],
			},
			crashwarn = {
				varname = format(L.alert["%s Casting"],SN[66683]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[66683]),
				time = 1,
				color1 = "INDIGO",
				sound = "ALERT8",
				icon = ST[66683],
			},
			crashcd = {
				varname = format(L.alert["%s Cooldown"],SN[66683]),
				type = "dropdown",
				text = "<crashtext>",
				time = "<crashtime>",
				flashtime = 10,
				color1 = "YELLOW",
				icon = ST[66683],
			},
			tramplewarnself = {
				type = "centerpopup",
				varname = format(L.alert["%s on self"],SN[66734]),
				text = format("%s: %s! %s",SN[66734],L.alert["YOU"],L.alert["MOVE"]),
				time = 4.5,
				flashtime = 4.5,
				color1 = "ORANGE",
				color2 = "GREEN",
				sound = "ALERT9",
				icon = ST[66734],
				flashscreen = true,
			},
			tramplewarnothers = {
				type = "centerpopup",
				varname = format(L.alert["%s on others"],SN[66734]),
				time = 4.5,
				text = format("%s: #5#! %s!",SN[66734],L.alert["MOVE AWAY"]),
				color1 = "ORANGE",
				sound = "ALERT9",
				icon = ST[66734],
				flashscreen = true,
			},
			--- Phase Changes
			zerotoonecd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase One"]),
				type = "centerpopup",
				text = format(L.alert["%s Begins"],L.alert["Phase One"]),
				time = 22,
				flashtime = 22,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
			onetotwocd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Two"]),
				type = "centerpopup",
				text = format(L.alert["%s Begins"],L.alert["Phase Two"]),
				time = 15,
				flashtime = 15,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
			twotothreecd = {
				varname = format(L.alert["%s Timer"],L.alert["Phase Three"]),
				type = "centerpopup",
				text = format(L.alert["%s Begins"],L.alert["Phase Three"]),
				time = 10,
				flashtime = 10,
				color1 = "MIDGREY",
				icon = ST[3648],
			},
		},
		arrows = {
			tramplearrow = {
				varname = SN[66734],
				unit = "#5#",
				persist = 8,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[66734],
				fixed = true,
			},
			toxinarrow = {
				varname = SN[66823],
				unit = "<lasttoxin>",
				persist = 10,
				action = "TOWARD",
				msg = L.alert["MOVE TOWARD"],
				spell = L.alert["Toxin"],
				sound = "ALERT3",
			},
			bilearrow = {
				varname = SN[66870],
				unit = "<lastbile>",
				persist = 10,
				action = "TOWARD",
				msg = L.alert["MOVE TOWARD"],
				spell = L.alert["Bile"],
				sound = "ALERT5",
			},
		},
		raidicons = {
			tramplemark = {
				varname = SN[66734],
				type = "FRIENDLY",
				persist = 8,
				unit = "#5#",
				icon = 1,
			},
		},
		timers = {
			firesubmerge = {
				{
					"alert","submergecd",
					"scheduletimer",{"firesubmerge",45},
				},
			},
			fireenrage = {
				{
					"alert","enragecd",
				},
			},
			reset = {
				{"resettimer",true},
			},
			firemolten = {
				{
					"alert","moltenspewcd",
					"set",{moltenspewtime = {27,21,loop = true, type = "series"}},
				},
			},
			firecrash = {
				{
					"alert","crashcd",
				},
			},
		},
		events = {
			---------------
			-- Gormok
			---------------

			-- Fire Bomb on self - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					67472,
					66320,
					67473, -- 10 hard
					67475, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","firebombwarnself",
					}
				},
			},
			-- Impale - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {
					67477,
					66331,
					67478, -- 10 hard
					67479, -- 25 hard
				},
				execute = {
					{
						"alert","impalecd",
					},
				},
			},
			-- Impale - Gormok application
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67477,
					66331,
					67478, -- 10 hard
					67479, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{impaletext = format("%s: %s!",SN[66331],L.alert["YOU"])},
						"alert","impalewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{impaletext = format("%s: #5#!",SN[66331])},
						"alert","impalewarn",
					},
				},
			},
			-- Impale Stacks - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {
					67477,
					66331,
					67478, -- 10 hard
					67479, -- 25 hard
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{impaletext = format("%s: %s! %s!",SN[66331],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
						"alert","impalewarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{impaletext = format("%s: #5#! %s!",SN[66331],format(L.alert["%s Stacks"],"#11#")) },
						"alert","impalewarn",
					},
				},
			},
			-- Staggering Stomp - Gormok
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67647,
					66330,
					67648, -- 10m hard
					67649, -- 10m hard
				},
				execute = {
					{
						"alert","stompwarn",
						"alert","stompcd",
					},
				},
			},

			---------------
			-- Jormungars
			---------------

			-- Paralytic Toxin - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67618,
					66823,
					67619, -- 10m hard
					67620,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","toxinonself",
						"set",{hastoxin = 1},
						"expect",{"<lastbile>","~=","NONE"},
						"arrow","bilearrow",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{lasttoxin = "#5#"},
						"expect",{"<hasbile>","==","1"},
						-- Fires toxinarrow using #5#
						"set",{tmp = "<lasttoxin>"},
						"set",{lasttoxin = "#5#"},
						"arrow","toxinarrow",
						"set",{lasttoxin = "<tmp>"},
					},
				},
			},
			-- Paralytic Toxin Removal - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67618,
					66823,
					67619, -- 10m hard
					67620,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","toxinonself",
						"set",{hastoxin = 0},
						"removeallarrows",true,
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"removearrow","#5#",
						"expect",{"#5#","==","<lasttoxin>"},
						"set",{lasttoxin = "NONE"},
					},
				},
			},
			-- Burning Bile - Jormungars - Dreadmaw
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {66869,66870},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","bileonself",
						"set",{hasbile = 1},
						"expect",{"<lasttoxin>","~=","NONE"},
						"arrow","toxinarrow",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{lastbile = "#5#"},
						"expect",{"<hastoxin>","==","1"},
						-- Fires bilearrow using #5#
						"set",{tmp = "<lastbile>"},
						"set",{lastbile = "#5#"},
						"arrow","bilearrow",
						"set",{lastbile = "<tmp>"},
					},
				},
			},
			-- Burning Bile Removal - Jormungars - Dreadmaw
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {66869,66870},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","bileonself",
						"removeallarrows",true,
						"set",{hasbile = 0},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"removearrow","#5#",
						"expect",{"#5#","==","<lastbile>"},
						"set",{lastbile = "NONE"},
					},
				},
			},
			-- Slime Pool - Jormungars - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {
					66881,
					67638,
					67639, -- 10 hard
					67640,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","slimepoolself",
					},
				},
			},
			-- Enrage - Jormungars
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 68335,
				execute = {
					{
						"alert","enragewarn",
					},
				},
			},
			-- Acidic Spew - Acidmaw
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 66818,
				execute = {
					{
						"quash","acidicspewcd",
						"alert","acidicspewwarn",
					},
					{
						"expect",{"<fireacidiccd> <dreadscaledead>","==","0 0"},
						"alert","moltenspewcd",
						"set",{firemoltencd = 1},
					},
					{
						"expect",{"<fireacidiccd> <dreadscaledead>","==","1 0"},
						"alert","acidicspewcd",
						"set",{fireacidiccd = 0},
					},
					{
						"expect",{"<dreadscaledead>","==","1"},
						"set",{acidicspewtime = 21},
						"alert","acidicspewcd",
					},
				},
			},
			-- Molten Spew - Dreadscale
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 66821,
				execute = {
					{
						"quash","moltenspewcd",
						"alert","moltenspewwarn",
					},
					{
						"expect",{"<firemoltencd> <acidmawdead>","==","0 0"},
						"alert","acidicspewcd",
						"set",{fireacidiccd = 1},
					},
					{
						"expect",{"<firemoltencd> <acidmawdead>","==","1 0"},
						"alert","moltenspewcd",
						"set",{firemoltencd = 0},
					},
					{
						"expect",{"<acidmawdead>","==","1"},
						"set",{moltenspewtime = 21},
						"alert","moltenspewcd",
					},
				},
			},

			---------------
			-- Icehowl
			---------------

			-- Arctic Breath - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67650,
					66689,
					67651, -- 10 hard
					67652, -- 25 hard
				},
				execute = {
					{
						"alert","breathwarn",
					},
				},
			},
			-- Frothing Rage - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67657,
					67658, -- 10 hard
					66759,
					67659, -- 25 hard
				},
				execute = {
					{
						"alert","ragewarn",
					},
				},
			},
			-- Frothing Removal - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67657,
					67658,
					66759,
					67659, -- 25 hard
				},
				execute = {
					{
						"quash","ragewarn",
					},
				},
			},
			-- Staggered Daze - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 66758,
				execute = {
					{
						"alert","dazedur",
					},
				},
			},
			-- Massive Crash - Icehowl
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67660,
					66683,
					67661, -- 10m hard
					67662,
				},
				execute = {
					{
						"alert","crashwarn",
						"alert","crashcd",
					},
				},
			},
			-- Trample - Icehowl
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_coliseum["lets out a bellowing roar!$"]},
						"expect",{"#5#","~=","&playername&"},
						"proximitycheck",{"#5#",18},
						"alert","tramplewarnothers",
						"arrow","tramplearrow",
					},
					{
						"expect",{"#1#","find",L.chat_coliseum["lets out a bellowing roar!$"]},
						"expect",{"#5#","==","&playername&"},
						"alert","tramplewarnself",
					},
					{
						"expect",{"#1#","find",L.chat_coliseum["lets out a bellowing roar!$"]},
						"raidicon","tramplemark",
					},
				},
			},
			-- Phase Transitions
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Gormok dies
					{
						"expect",{"#1#","find",L.chat_coliseum["^Steel yourselves, heroes, for the twin terrors"]},
						"tracing",{35144,34799},
						"alert","onetotwocd",
						"scheduletimer",{"firesubmerge",15},
						"scheduletimer",{"reset",15},
						"scheduletimer",{"firemolten",15},
						"expect",{"&difficulty&",">=","3"},
						"set",{enragetime = 183},
						"quash","enragecd",
						"scheduletimer",{"fireenrage",15},
					},
					-- Jormungars die
					{
						"expect",{"#1#","find",L.chat_coliseum["^The air itself freezes with the introduction"]},
						"tracing",{34797}, -- Icehowl
						"alert","twotothreecd",
						"quash","submergecd",
						"canceltimer","firesubmerge",
						"scheduletimer",{"reset",10},
						"scheduletimer",{"firecrash",10},
						"expect",{"&difficulty&",">=","3"},
						"set",{enragetime = 210},
						"quash","enragecd",
						"scheduletimer",{"fireenrage",10},
					},
				},
			},
			-- Deaths
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","34796"}, -- Gormok
						"quash","impalecd",
						"quash","stompcd",
					},
					{
						"expect",{"&npcid|#4#&","==","35144"}, -- Acidmaw
						"quash","moltenspewcd",
						"quash","acidicspewcd",
						"set",{acidmawdead = 1},
					},
					{
						"expect",{"&npcid|#4#&","==","34799"}, -- Dreadscale
						"quash","moltenspewcd",
						"quash","acidicspewcd",
						"set",{dreadscaledead = 1},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

---------------------------------
-- TWIN VALKYR
---------------------------------

do

	local DE = SN[67176] -- Dark Essence
	local LE = SN[67223] -- Light Essence

	local data = {
		version = 18,
		key = "twinvalkyr",
		zone = L.zone["Trial of the Crusader"],
		category = L.zone["Coliseum"],
		name = L.npc_coliseum["Twin Val'kyr"],
		triggers = {
			scan = {
				34496, -- Eydis Darkbane
				34497, -- Fjola Lightbane
			},
		},
		onactivate = {
			tracing = {
				34496, -- Eydis Darkbane
				34497, -- Fjola Lightbane
			},
			tracerstart = true,
			combatstop = true,
			defeat = 34496,
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"},
				"set",{vortextime = 6, enragetime = 360},
			},
			{
				"alert","enragecd",
				"alert","shieldvortexcd",
			},
		},
		userdata = {
			vortextime = 8,
			enragetime = 480,
		},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				text = L.alert["Enrage"],
				type = "dropdown",
				time = "<enragetime>",
				flashtime = 10,
				color1 = "RED",
				icon = ST[12317],
			},
			darkvortexwarn = {
				varname = format(L.alert["%s Casting"],SN[67182]),
				text = format(L.alert["%s Casting"],SN[67182]),
				type = "centerpopup",
				time = "<vortextime>",
				flashtime = 6,
				color1 = "BROWN",
				sound = "ALERT1",
				icon = ST[67184],
			},
			darkvortexdur = {
				varname = format(L.alert["%s Channel"],SN[67182]),
				text = format(L.alert["%s Channel"],SN[67182]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[67184],
			},
			lightvortexwarn = {
				varname = format(L.alert["%s Casting"],SN[67206]),
				text = format(L.alert["%s Casting"],SN[67206]),
				type = "centerpopup",
				time = "<vortextime>",
				flashtime = 6,
				color1 = "PURPLE",
				sound = "ALERT2",
				icon = ST[67208],
			},
			lightvortexdur = {
				varname = format(L.alert["%s Channel"],SN[67206]),
				text = format(L.alert["%s Channel"],SN[67206]),
				type = "centerpopup",
				time = 5,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[67208],
			},
			shieldofdarknesswarn = {
				varname = format(L.alert["%s Absorbs"],SN[67256]),
				text = SN[67256].."!",
				textformat = format("%s => %%s/%%s - %%d%%%%",L.alert["Shield"]),
				type = "absorb",
				time = 15,
				flashtime = 5,
				color1 = "INDIGO",
				color2 = "YELLOW",
				sound = "ALERT3",
				icon = ST[67256],
				npcid = 34496,
				values = {
					[67258] = 1200000,
					[67256] = 700000,
					[67257] = 300000,
					[65874] = 175000,
				}
			},
			shieldoflightwarn = {
				varname = format(L.alert["%s Absorbs"],SN[67259]),
				text = SN[67259].."!",
				textformat = format("%s => %%s/%%s - %%d%%%%",L.alert["Shield"]),
				type = "absorb",
				time = 15,
				flashtime = 5,
				color1 = "YELLOW",
				color2 = "INDIGO",
				sound = "ALERT4",
				icon = ST[67259],
				npcid = 34497,
				values = {
					[67261] = 1200000,
					[67259] = 700000,
					[67260] = 300000,
					[65858] = 175000,
				},
			},
			twinspactwarn = {
				varname = format(L.alert["%s Casting"],SN[67303]),
				text = format(L.alert["%s Casting"],SN[67303]),
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				color1 = "ORANGE",
				icon = ST[67308],
			},
			switchtodarkwarn = {
				varname = format(L.alert["%s Warning"],format(L.alert["Switch to %s"],DE)),
				text = format(L.alert["Switch to %s"],DE):upper().."!",
				type = "simple",
				time = 3,
				color1 = "BLACK",
				flashscreen = true,
				sound = "ALERT5",
				icon = ST[67176],
			},
			switchtolightwarn = {
				varname = format(L.alert["%s Warning"],format(L.alert["Switch to %s"],LE)),
				text = format(L.alert["Switch to %s"],LE):upper().."!",
				type = "simple",
				time = 3,
				color1 = "WHITE",
				flashscreen = true,
				sound = "ALERT6",
				icon = ST[67223],
			},
			shieldvortexcd = {
				varname = format(L.alert["%s Cooldown"],SN[56105].."/"..L.alert["Shield"]),
				text = format(L.alert["Next %s"],SN[56105].."/"..L.alert["Shield"]),
				type = "dropdown",
				time = 45,
				flashtime = 10,
				color1 = "TEAL",
				sound = "ALERT7",
				icon = ST[56105],
			},
			empoweredlightself = {
				varname = format(L.alert["%s on self"],SN[67217]),
				text = SN[67217].."!",
				type = "centerpopup",
				time = 15,
				flashtime = 15,
				color1 = "GOLD",
				sound = "ALERT8",
				icon = ST[67217],
			},
			empowereddarkself = {
				varname = format(L.alert["%s on self"],SN[67214]),
				text = SN[67214].."!",
				type = "centerpopup",
				time = 20,
				flashtime = 20,
				color1 = "BLUE",
				sound = "ALERT8",
				icon = ST[67214],
			},
			touchlightself = {
				varname = format(L.alert["%s on self"],SN[67298]),
				text = format("%s: %s!",SN[67298],L.alert["YOU"]),
				type = "centerpopup",
				time = 20,
				flashtime = 20,
				color1 = "MAGENTA",
				icon = ST[67298],
			},
			touchdarkself = {
				varname = format(L.alert["%s on self"],SN[67283]),
				text = format("%s: %s!",SN[67283],L.alert["YOU"]),
				type = "centerpopup",
				time = 20,
				flashtime = 20,
				color1 = "MAGENTA",
				icon = ST[67283],
			},
		},
		events = {
			-- Twin's Pact
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67305,
					67304,
					67303,
					65875,
					65876,
					67308,
					67307,
					67306,
				},
				execute = {
					{
						"alert","twinspactwarn",
					},
				},
			},
			-- Twin's Pact interrupt
			{
				type = "combatevent",
				eventtype = "SPELL_INTERRUPT",
				spellid2 = {
					67305,
					67304,
					67303,
					65875,
					65876,
					67308,
					67307,
					67306,
				},
				execute = {
					{
						"quash","twinspactwarn",
					},
				},
			},
			-- Empowered Light
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67217, -- 10 hard
					65748, -- 10 normal
					67216, -- 25 normal
					67218,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","empoweredlightself",
					},
				},
			},
			-- Empowered Darkness
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67214, -- 10 hard
					65724, -- 10 normal
					67213, -- 25 normal
					67215,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","empowereddarkself",
					},
				},
			},
			-- Dark Vortex Cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67182, -- 25 normal
					66058, -- 10 normal
					67183, -- 10 hard
					67184, -- 25 hard
				},
				execute = {
					{
						"alert","darkvortexwarn",
						"alert","shieldvortexcd",
						"expect",{"&playerdebuff|"..LE.."&","==","true"},
						"alert","switchtodarkwarn",
					},
				},
			},
			-- Dark Vortex Channel
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67182, -- 25 normal
					66058, -- 10 normal
					67183, -- 10 hard
					67184, -- 25 hard
				},
				execute = {
					{
						"quash","darkvortexwarn",
						"alert","darkvortexdur",
					},
				},
			},
			-- Light Vortex Cast
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {
					67206, -- 25 normal
					66046, -- 10 normal
					67207, -- 10 hard
					67208, -- 25 hard
				},
				execute = {
					{
						"alert","lightvortexwarn",
						"alert","shieldvortexcd",
						"expect",{"&playerdebuff|"..DE.."&","==","true"},
						"alert","switchtolightwarn",
					},
				},
			},
			-- Light Vortex Channel
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67206, -- 25 normal
					66046, -- 10 normal
					67207, -- 10 hard
					67208, -- 25 hard
				},
				execute = {
					{
						"quash","lightvortexwarn",
						"alert","lightvortexdur",
					},
				},
			},
			-- Shield of Darkness
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67256, -- 25 normal
					65874,
					67257, -- 10 hard
					67258,
				},
				execute = {
					{
						"alert","shieldofdarknesswarn",
						"alert","shieldvortexcd",
					},
				},
			},
			-- Shield of Darkness Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67256, -- 25 normal
					65874,
					67257, -- 10 hard
					67258,
				},
				execute = {
					{
						"quash","shieldofdarknesswarn",
					},
				},
			},
			-- Shield of Lights
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67259, -- 25 normal
					65858, -- 10 normal
					67260,
					67261, -- 25 hard
				},
				execute = {
					{
						"alert","shieldoflightwarn",
						"alert","shieldvortexcd",
					},
				},
			},
			-- Shield of Lights Removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67259, -- 25 normal
					65858, -- 10 normal
					67260,
					67261, -- 25 hard
				},
				execute = {
					{
						"quash","shieldoflightwarn",
					},
				},
			},
			-- Touch of Darkness
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67283, -- 25 hard
					66001,
					67281,
					67282,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","switchtodarkwarn",
						"alert","touchdarkself",
					},
				},
			},
			-- Touch of Darkness removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67283, -- 25 hard
					66001,
					67281,
					67282,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","touchdarkself",
					},
				},
			},
			-- Touch of Light
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {
					67298, -- 25 hard
					67297,
					67296,
					65950,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","switchtolightwarn",
						"alert","touchlightself",
					},
				},
			},
			-- Touch of Light removal
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {
					67298, -- 25 hard
					67297,
					67296,
					65950,
				},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","touchlightself",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
