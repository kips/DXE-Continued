local addon = DXE

--[[
local map = {1,2,3,4,5,6,7,8,9,"A","B","C","D","E","F"}
map[0] = "0"

local function tohex(num,...)
	if num == 0 then
		return table.concat({...})
	else
		return tohex(math.floor(num / 16), map[num % 16], ...)
	end
end

local function npcid(num) return "0x005000"..tohex(num).."000000" end

function addon:ANUBDEATHTEST()
	addon:COMBAT_LOG_EVENT_UNFILTERED(_, _,"UNIT_DIED", _, _, _, npcid(34564))
end

function addon:HORSEMENTEST()
	local _ = nil
	local eventtype = "UNIT_DIED"
	
	local nid1 = npcid(16064)
	local nid2 = npcid(30549)
	local nid3 = npcid(16065)
	local nid4 = npcid(16063)
	addon:COMBAT_LOG_EVENT_UNFILTERED(_, _,eventtype, _, _, _, nid1)
	addon:COMBAT_LOG_EVENT_UNFILTERED(_, _,eventtype, _, _, _, nid2)
	addon:COMBAT_LOG_EVENT_UNFILTERED(_, _,eventtype, _, _, _, nid3)
	addon:COMBAT_LOG_EVENT_UNFILTERED(_, _,eventtype, _, _, _, nid4)
end


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

--[[
function addon:LEECHINGSWARMTEST()
	self.Invoker:COMBAT_EVENT(nil,nil,"SPELL_CAST_START",nil,nil,nil,nil,nil,nil,66118)
end


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
]]


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

--[[
function addon:RAIDICONTEST()
	addon.RaidIcons:MultiMarkEnemy("test","0xF130007FAE00082F",1,10,true,10,4)
	addon.RaidIcons:MultiMarkEnemy("test","0xF130007FAB000830",2,10,true,10,4)
	addon.RaidIcons:MultiMarkEnemy("test","0xF1300072460078AF",3,10,true,10,4)
	addon.RaidIcons:MultiMarkEnemy("test","0xF130007246008337",4,10,true,10,4)
end
]]

--[CLEU] SWING_MISSED:0x0280000002BFF92A:Slivr:1300:0xF1300086C002F048:Eydis Darkbane:2632:ABSORB:5150:", -- [11700]
--[CLEU] SPELL_MISSED:         0x028000000155E9AD: Nokaru:263444:0xF1300086C002F048:Eydis Darkbane:2632:48480:Maul:1:  ABSORB:9229:", -- [11678]
--[CLEU] SPELL_PERIODIC_MISSED:0x0280000000529C7E: Lamissa:1300:0xF1300086C002F048: Eydis Darkbane:2632:49800:Rip:1:   ABSORB:3314:", -- [11705]
--[CLEU] RANGE_MISSED:         0x02800000019 AD06B:Takamuri:1300:0xF1300086C0001C3C:Eydis Darkbane:2632:75:Auto Shot:1:ABSORB:6927:", -- [35994]

--[[
function addon:ABSORBTEST()
	local values = {
		[67261] = 1200000,
		[67258] = 1200000,
		[67256] = 700000,
		[67259] = 700000,
		[67257] = 300000,
		[67260] = 300000,
		[65858] = 175000,
		[65874] = 175000,
	}


	local dstGUID = "0xF1300086C002F048"
	local bar = addon.Alerts:Absorb("absorbwarn","Shield of Light", "Shield of Light => %s/%s - %d%%",20,5,"ALERT1",
	"GREEN", "ORANGE", false, addon.ST[67261], values[67261], addon.NID[dstGUID])

	addon:ScheduleRepeatingTimer(function() 
		local onevent = bar:GetScript("OnEvent")
		if onevent then
			onevent(bar, nil, nil, "SPELL_MISSED", nil, nil, nil, dstGUID, nil, nil, "ABSORB", 50000, nil, "ABSORB", 50000)
		end
	end, 0.2)
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
