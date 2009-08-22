do
	local faction = UnitFactionGroup("player")
	local npc_list
	
	if faction == "Alliance" then
		npc_list = {
			34458, -- Gorgrim	  DK
			34451, -- Birana	  DRUID_CASTER
			34459, -- Erin		  DRUID_HEALER
			34448, -- Ruj'kah	  HUNTER
			34449, -- Ginselle  MAGE
			34445, -- Liandra	  PALADIN_HEALER
			34456, -- Malithas  PALADIN_RET
			34447, -- Caiphus   PRIEST_HEALER
			34441, -- Vivienne  PRIEST_SHADOW
			34454, -- Maz'dinah ROGUE
			34444, -- Thrakgar  SHAMAN_CASTER
			34455, -- Broln	  SHAMAN_ENH
			34450, -- Harkzog   WARLOCK
			34453, -- Narrhok   WARRIOR
		}
	elseif faction == "Horde" then
		npc_list = {
			34461, -- Tyrius 	DK
			34460, -- Kavina 	DRUID_CASTER
			34469, -- Melador DRUID_HEALER
			34467, -- Alyssia HUNTER
			34468, -- Noozle 	MAGE
			34465, -- Velanaa PALADIN_HEALER
			34471, -- Baelnor PALADIN_RET
			34466, -- Anthar 	PRIEST_HEALER
			34473, -- Brienna	PRIEST_SHADOW
			34472, -- Irieth 	ROGUE
			34470, -- Saamul 	SHAMAN_CASTER
			34463, -- Shaabad SHAMAN_ENH
			34474, -- Serissa WARLOCK
			34475, -- Shocuul WARRIOR
		}
	else
		error("DXE_Coliseum Faction Champions: faction upvalue missing") 
	end

	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 322,
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
		--[[
		onstart = {
		},
		alerts = {
		},
		events = { 
		},
		]]
	}

	DXE:RegisterEncounter(data)
end
