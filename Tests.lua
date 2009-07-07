function DXE:YOGGTEST()
	self:SetActiveEncounter("yoggsaron")
	self:StopEncounter()
	self:StartEncounter()
end

function DXE:YOGGTEST2()
	self.Invoker:REG_EVENT("CHAT_MSG_RAID_BOSS_EMOTE","The illusion shatters and a path")
end

function DXE:YOGGTEST3()
	self.Invoker:REG_EVENT("CHAT_MSG_MONSTER_YELL","I am the lucid dream")
end

function DXE:YOGGTEST4()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_SUCCESS",nil,nil,nil,nil,nil,nil,64144)
end

function DXE:YOGGTEST5()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,64059)
end

function DXE:FREYATEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"","Efy",nil,62283)
end

function DXE:FREYATEST2()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_REMOVED",nil,nil,nil,"","Efy",nil,62283)
end
