local addon = DXE
--[[

function addon:YOGGTEST()
	self:SetActiveEncounter("yoggsaron")
	self:StopEncounter()
	self:StartEncounter()
end

function addon:YOGGTEST1()
	self.Invoker:REG_EVENT("CHAT_MSG_RAID_BOSS_EMOTE","The illusion shatters and a path")
end

function addon:YOGGTEST2()
	self.Invoker:REG_EVENT("CHAT_MSG_MONSTER_YELL","I am the lucid dream")
end

function addon:YOGGTEST3()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,64059)
end

function addon:YOGGTEST4()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_SUCCESS",nil,nil,nil,nil,nil,nil,57688)
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


function addon:GORMOKTEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"UNIT_DIED",nil,nil,nil,"0xF1500087EC0014CE")
end

function addon:AlertsDouble()
	self.Alerts:Dropdown("AlertTest2", "Bigger City Opening", 10, 5, "None", "BLUE")
	self.Alerts:Dropdown("AlertTest2", "Bigger City Opening", 15, 10, "None", "BLUE")
end

function addon:MALADYTEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"","Takamuri",nil,63830)
end

]]

do
	local t = {}
	function addon:PENCOLDTEST()
		table.wipe(t)
		for i=1,5 do
			local unit = "raid"..math.random(1,GetNumRaidMembers())
			while t[unit] do
				unit = "raid"..math.random(1,GetNumRaidMembers())
			end
			t[unit] = true
			print("Test marking: ",(UnitName(unit)))
			self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"",(UnitName(unit)),nil,68510)
		end
	end
end


--[[
function addon:TestArrowOnTarget()
	addon.Arrows:AddTarget("target",10,"TOWARD","MOVE","Crash","None",false)
end
function addon:YOGGSQUEEZETEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"","Kruciel",nil,64125)
end

function addon:STRIKETEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,66134)
end
]]


-- Northrend Molten/Acidic Spew test

--[[
function addon:BEASTSSPEWTEST()
	self:SetActiveEncounter("northrendbeasts")
	self:StartEncounter()
	self.Invoker:COMBAT_EVENT(nil,nil,"UNIT_DIED",nil,nil,nil,"0xF1500087EC00196D")
	DXE.Alerts:QuashByPattern("zerotoone")

	self:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,66821) end, 25)
	self:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,66821) end, 46)
	self:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,66818) end, 73)
	self:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,66818) end, 94)
	self:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,66821) end, 121)
	self:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,66821) end, 142)
	
end
]]

--[==[
-- Northrend Beasts Burning Bile test
do
	local target = "Nichts"

	local selfSPELLID = 66869 -- Burning Bile
	local targetSPELLID = 67618 -- Toxin

	function addon:BEASTSBILETEST()
		self:SetActiveEncounter("northrendbeasts")
		self:StartEncounter()

		-- target gets toxin first, I get bile after
		addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"",target,nil,targetSPELLID)
		addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"0x0280000001B62984","Kollektiv",nil,selfSPELLID)
		addon:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_REMOVED",nil,nil,nil,"",target,nil,targetSPELLID) end,5)
		addon:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_REMOVED",nil,nil,nil,"0x0280000001B62984","Kollektiv",nil,selfSPELLID) end,8)
		]]

		-- i get bile first, target gets toxin after 
		addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"0x0280000001B62984","Kollektiv",nil,selfSPELLID)
		addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"",target,nil,targetSPELLID)
		addon:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_REMOVED",nil,nil,nil,"",target,nil,targetSPELLID) end,5)
		addon:ScheduleTimer(function() addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_REMOVED",nil,nil,nil,"0x0280000001B62984","Kollektiv",nil,selfSPELLID) end,8)


		addon:ScheduleTimer(function () addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_REMOVED",nil,nil,nil,"0x0280000001B62984","Kollektiv",nil,selfSPELLID) end,6.5)
		addon:ScheduleTimer(function () addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"",target,nil,targetSPELLID) end, 7)
		addon:ScheduleTimer(function () addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"0x0280000001B62984","Kollektiv",nil,selfSPELLID) end,8)
		addon:ScheduleTimer(function () addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED",nil,nil,nil,"",target,nil,targetSPELLID) end, 20)
		]]
	end
end
]==]

--[[
function addon:BEASTSIMPALETEST()
		addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED_DOSE",nil,nil,nil,"","Nokaru",nil,66331,nil,nil,nil,3)
		addon.Invoker:COMBAT_EVENT(nil,nil,"SPELL_AURA_APPLIED_DOSE",nil,nil,nil,UnitGUID("player"),"Kollektiv",nil,66331,nil,nil,nil,5)
end

]]

--[===[
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
		onstart = {
			{
				"expect",{"&buffstacks|player|Water Shield&",">=","3"},
				"alert","wswarn",
			},
		},
		alerts = {
			wswarn = {
				type = "simple",
				varname = "water shield warning",
				time = 3,
				color1 = "BLUE",
				text = "Water Shield!",
			},
		},
		events = {
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 57960,
				execute = {
					{
						"expect",{"&buffstacks|#5#|Water Shield&",">=","5"},
						"alert","wswarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
]===]
