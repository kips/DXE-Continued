local addon = DXE

function addon:YOGGTEST()
	self:SetActiveEncounter("yoggsaron")
	self:StopEncounter()
	self:StartEncounter()
end

function addon:YOGGTEST2()
	self.Invoker:REG_EVENT("CHAT_MSG_RAID_BOSS_EMOTE","The illusion shatters and a path")
end

function addon:YOGGTEST3()
	self.Invoker:REG_EVENT("CHAT_MSG_MONSTER_YELL","I am the lucid dream")
end

function addon:YOGGTEST4()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_SUCCESS",nil,nil,nil,nil,nil,nil,64144)
end

function addon:YOGGTEST5()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,64059)
end

function addon:YOGGSQUEEZETEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"","Kruciel",nil,64125)
end

function addon:FREYATEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"","Kruciel",nil,63571)
end

function addon:FREYATEST2()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_REMOVED",nil,nil,nil,"","Efy",nil,62283)
end

function addon:VEZAXTEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_SUCCESS",nil,nil,nil,"","Nokaru",nil,63276)
end

function addon:KOLOGARNTEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"UNIT_DIED",nil,nil,nil,"0xF1500080A6006971")
end

function addon:KOLOGARNTEST2()
	self.Invoker:COMBAT_EVENT(nil,nil,"UNIT_DIED",nil,nil,nil,"0xF1300080A5006972")
end

function addon:TestArrowOnTarget()
	addon.Arrows:AddTarget("target",10,"TOWARD","MOVE","Crash","None",false)
end

function addon:GORMOKTEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"UNIT_DIED",nil,nil,nil,"0xF1500087EC0014CE")
end

function addon:AlertsDouble()
	self.Alerts:Dropdown("AlertTest2", "Bigger City Opening", 10, 5, "None", "BLUE")
	self.Alerts:Dropdown("AlertTest2", "Bigger City Opening", 15, 10, "None", "BLUE")
end

do
	local SN,ST = DXE.SN,DXE.ST
	local data = {
		version = 1,
		key = "testencounter", 
		zone = "Crystalsong Forest", 
		category = "Tests",
		name = "Test Encounter", 
		title = "Test",
		triggers = {
			scan = {31228, 31233, 33422, 31229, 31236},
		},
		onactivate = {
			combatstart = true,
			combatstop = true,
			sortedtracing = {31228,31233,33422, 31229, 31236}, -- Grove Walker, Sinewy Wolf
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
