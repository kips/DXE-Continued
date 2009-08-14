-- Based off RDX's HOT

local addon = DXE
local index_to_unit = addon.Roster.index_to_unit
local NID = addon.NID

local pairs = pairs
local UnitExists,UnitGUID = UnitExists,UnitGUID

local DELAY = 0.2

local ACQUIRED = 0
local LOST = 1

----------------------------------
-- INITIALIZATION
----------------------------------
local Tracer,prototype = {},{}
addon.Tracer = Tracer

local trackInfos = {
	npcid = { goalType = "number", attribute = function(unit) return NID[UnitGUID(unit)] end },
	name = { goalType = "string", attribute = UnitName },
}

function Tracer:New()
	local tracer = addon.AceTimer:Embed({})
	for k,v in pairs(prototype) do tracer[k] = v end
	tracer.s = LOST 			-- Status
	tracer.callbacks = {} 	-- Events

	return tracer
end

----------------------------------
-- PROTOTYPE
----------------------------------
local rIDtarget = {}
for i=1,40 do rIDtarget["raid"..i] = "raid"..i.."target" end

function prototype:Test(proto_unit)
	local unit = rIDtarget[proto_unit]
	if not UnitExists(unit) then return end
	if self.attribute(unit) == self.goal then
		return unit
	end
end

function prototype:TestFocus()
	if not UnitExists("focus") then return end
	if self.attribute("focus") == self.goal then
		return "focus"
	end
end

function prototype:SetCallback(obj,event)
	self.callbacks[event] = function() obj[event](obj) end
end

function prototype:Fire(event)
	if self.callbacks[event] then
		self.callbacks[event]()
	end
end

function prototype:Execute()
	local flag
	self.first = nil

	-- Raid unit tests
	for _,proto_unit in pairs(index_to_unit) do
		local unit = self:Test(proto_unit)
		if unit then
			self.first,flag = unit,true
			break
		end
	end

	-- Focus test
	if not self.first then
		local unit = self:TestFocus()
		if unit then 
			self.first,flag = unit,true
		end
	end

	if flag then
		if self.s == LOST then
			self.s = ACQUIRED
			self:Fire("TRACER_ACQUIRED")
		end
		self:Fire("TRACER_UPDATE")
	elseif self.s == ACQUIRED then
		self.s = LOST
		self:Fire("TRACER_LOST")
	end
end

----------------------------------
-- API
----------------------------------

function prototype:Track(trackType, goal)
	local info = trackInfos[trackType]
	--@debug@
	assert(info)
	assert(type(goal) == info.goalType)
	--@end-debug@
	self.attribute = info.attribute
	self.goal = goal
end

function prototype:IsOpen()
	return self.handle
end

function prototype:Open()
	if self.handle then return end
	--@debug@
	assert(self.goal)
	assert(self.attribute)
	--@end-debug@
	self.handle = self:ScheduleRepeatingTimer("Execute", DELAY)
end

function prototype:Close()
	if not self.handle then return end
	self.goal = nil; self.attribute = nil
	self:CancelTimer(self.handle,true)
	self.handle = nil
	self.first = nil
	self.s = LOST
end

function prototype:First() 
	return self.first
end
