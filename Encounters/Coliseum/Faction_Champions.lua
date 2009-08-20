do
	local faction = UnitFactionGroup("player")
	local NID_DK, NID_DRUID_CASTER, NID_DRUID_HEALER, NID_HUNTER, NID_MAGE, NID_PALADIN_HEALER, NID_PALADIN_RET
	local NID_PRIEST_HEALER, NID_PRIEST_SHADOW, NID_ROGUE, NID_SHAMAN_CASTER, NID_SHAMAN_ENH, NID_WARLOCK, NID_WARRIOR
	if faction == "Alliance" then
		NID_DK = 				34458 -- Gorgrim
		NID_DRUID_CASTER = 	34451 -- Birina 
		NID_DRUID_HEALER = 	34459 -- Erin
		NID_HUNTER = 			34448 -- Ruj'kah
		NID_MAGE = 				34449 -- Ginselle
		NID_PALADIN_HEALER = 34445 -- Liandra
		NID_PALADIN_RET = 	34456 -- Malithas
		NID_PRIEST_HEALER = 	34447 -- Caiphus
		NID_PRIEST_SHADOW = 	34441 -- Vivviene
		NID_ROGUE = 			34454 -- Maz'dinah
		NID_SHAMAN_CASTER =	34444 -- Thrakgar
		NID_SHAMAN_ENH =		34455 -- Broln
		NID_WARLOCK = 			34450 -- Harkzog
		NID_WARRIOR = 			34453 -- Narrhok
	elseif faction == "Horde" then
		NID_DK = 				34461 -- Tyrius
		NID_DRUID_CASTER = 	34460 -- Kavina
		NID_DRUID_HEALER = 	34469 -- Melador
		NID_HUNTER = 			34467 -- Alyssia
		NID_MAGE =  			99999 -- Noozle (INCOMPLETE)
		NID_PALADIN_HEALER = 34465 -- Velanaa
		NID_PALADIN_RET = 	99999 -- Baelnor (INCOMPLETE)
		NID_PRIEST_HEALER = 	99999 -- Anthar (INCOMPLETE)
		NID_PRIEST_SHADOW = 	34473 -- Brienna
		NID_ROGUE =  			34472 -- Irieth
		NID_SHAMAN_CASTER = 	34470 -- Saamul
		NID_SHAMAN_ENH = 		99999 -- Shaabad (INCOMPLETE)
		NID_WARLOCK = 			34474 -- Serissa
		NID_WARRIOR = 			34475 -- Shocuul
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
			scan = {
				NID_DK,
				NID_DRUID_CASTER,
				NID_DRUID_HEALER,
				NID_HUNTER,
				NID_MAGE,
				NID_PALADIN_HEALER,
				NID_PALADIN_RET,
				NID_PRIEST_HEALER,
				NID_PRIEST_SHADOW,
				NID_ROGUE,
				NID_SHAMAN_CASTER,
				NID_SHAMAN_ENH,
				NID_WARLOCK,
				NID_WARRIOR,
			}, 
		},
		onactivate = {
			combatstop = true,
		},
		userdata = {},
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
