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

	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 4,
		key = "factionchampions", 
		zone = L["Trial of the Crusader"], 
		category = L["Coliseum"],
		name = L["Faction Champions"], 
		title = L["Faction Champions"],
		triggers = {
			scan = npc_list,
		},
		onactivate = {
			combatstart = true,
			combatstop = true,
			sortedtracing = npc_list,
		},
		alerts = {
			bloodlustwarn = {
				varname = format(L["%s Warning"],SN[65980]),
				type = "simple",
				text = format(L["%s Casted"],SN[65980]).."! "..L["DISPEL"].."!",
				time = 3,
				sound = "ALERT1",
				color1 = "ORANGE",
				icon = ST[65980],
			},
			heroismwarn = {
				varname = format(L["%s Warning"],SN[65983]),
				type = "simple",
				text = format(L["%s Casted"],SN[65983]).."! "..L["DISPEL"].."!",
				time = 3,
				sound = "ALERT1",
				color1 = "ORANGE",
				icon = ST[65983],
			},
			divineshielddur = {
				varname = format(L["%s Duration"],SN[66010]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[66010]),
				time = 12,
				flashtime = 12,
				sound = "ALERT4",
				color1 = "MAGENTA",
				icon = ST[66010],
			},
			avengwrathdur = {
				varname = format(L["%s Duration"],SN[66011]),
				type = "centerpopup",
				text = format("%s: #2#!",SN[66011]),
				time = 20,
				flashtime = 20,
				sound = "ALERT7",
				color1 = "YELLOW",
				icon = ST[66011],
			},
			hellfirewarn = {
				varname = format(L["%s Cast"],SN[68145]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[68145]).."!",
				time = 15,
				flashtime = 15,
				color1 = "BROWN",
				color2 = "PEACH",
				icon = ST[68145],
			},
			hellfireself = {
				varname = format(L["%s on self"],SN[68145]),
				type = "simple",
				text = format("%s: %s! %s!",SN[68145],L["YOU"],L["MOVE AWAY"]),
				time = 3,
				throttle = 3,
				sound = "ALERT3",
				icon = ST[68145],
				flashscreen = true,
			},
			hopdur = {
				varname = format(L["%s Duration"],SN[66009]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[66009]),
				time = 10,
				flashtime = 10,
				sound = "ALERT5",
				color1 = "BLUE",
				icon = ST[66009],
			},
			hofdur = {
				varname = format(L["%s Duration"],SN[66115]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[66115]),
				time = 10,
				flashtime = 10,
				sound = "ALERT6",
				color1 = "GREY",
				icon = ST[66115],
			},
			bladestormdur = {
				varname = format(L["%s Duration"],SN[65947]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[65947]),
				time = 8,
				flashtime = 8,
				color1 = "INDIGO",
				color2 = "BLACK",
				icon = ST[65947],
			},
			bladestormself = {
				varname = format(L["%s on self"],SN[65947]),
				type = "simple",
				text = format("%s: %s! %s!",SN[65947],L["YOU"],L["MOVE AWAY"]),
				time = 3,
				throttle = 3,
				icon = ST[65947],
				sound = "ALERT3",
				flashscreen = true,
			},
			retaldur = {
				varname = format(L["%s Duration"],SN[65932]),
				type = "centerpopup",
				text = format("%s: #5#!",SN[65932]),
				time = 12,
				flashtime = 12,
				color1 = "GREEN",
				icon = ST[65932],
			},
			retalself = {
				varname = format(L["%s on self"],SN[65934]),
				type = "simple",
				text = format("%s: %s!",SN[65934],L["YOU"]),
				time = 3,
				throttle = 3,
				sound = "ALERT3",
				icon = ST[65934],
				flashscreen = true,
			},
			counterspellcd = {
				varname = format(L["%s Cooldown"],SN[65790]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[65790]),
				time = 24,
				flashtime = 5,
				color1 = "VIOLET",
				icon = ST[65790],
			},
			spelllockcd = {
				varname = format(L["%s Cooldown"],SN[67519]),
				type = "dropdown",
				text = format(L["%s Cooldown"],SN[67519]),
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
				spellid = {65816,68145},
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
				execute = {
					{
						"expect",{"&npcid|#4#& #10#","==",NID_WARLOCK.." 68145"},
						"quash","hellfirewarn",
					},
					{
						"expect",{"&npcid|#4#& #10#","==",NID_WARLOCK.." 65816"},
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
