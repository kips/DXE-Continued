--[[
	Terminology:

	A pretarget of unit X is any unit Y in the group for which Y target^(n) = X for 
	some n.

	The prototarget is the pretarget at the beginning of the chain.

	Credits to RDX
]]

-- Local accessors
local wipe = table.wipe
local ipairs = ipairs
local UnitIsUnit,UnitName = UnitIsUnit,UnitName

-- Perf: default delay between traces.
local TraceDelay = 0.2

local DXE = DXE
local AceTimer = LibStub("AceTimer-3.0")
----------------------------------
-- INITIALIZATION
----------------------------------

local HOT,Prototype = {},{}

----------------------------------
-- CORE
----------------------------------

-- Unit test
local function testname(self,proto_uid)
	local uid = proto_uid.."target"
	if UnitExists(uid) and UnitName(uid) == self.name then 
		return proto_uid,uid
	else
		return nil
	end
end

local mt = {__index = Prototype}

function HOT:New(multi)
	local tracer = DXE.new()
	setmetatable(tracer, mt)
	AceTimer:Embed(tracer)
	
	-- State
	tracer.test = testname -- The test
	tracer.distinct = true -- Show only distinct mobs matching the filter, or all mobs?
	tracer.n = 0 -- The number of acquired traces
	tracer.lostTime = 0 -- The time the signal was last lost
	tracer.proto_uids = DXE.new() -- The uids of all units that tripped the trace
	tracer.uids = DXE.new() -- The uids of all the target units
	tracer.events = DXE.new() -- Callbacks

	return tracer
end

----------------------------------
-- PROTOTYPE
----------------------------------

function Prototype:SetCallback(obj,name)
	self.events[name] = function() obj[name](obj) end
end

function Prototype:Fire(name)
	if self.events[name] then
		self.events[name]()
	end
end

function Prototype:Execute()
	local uids = self.uids
	local proto_uids = self.proto_uids
	local distinct = self.distinct
	local test = self.test
	wipe(uids) 
	wipe(proto_uids)

	-- Local data
	local proto_uid, uid, ix, flag = nil, nil, 0, nil;

	-- Scan
	for _,unit in ipairs(DXE.Roster) do
		-- Get unit and test it
		proto_uid = unit
		proto_uid, uid = test(self,proto_uid)
		
		-- If it passed...
		if proto_uid then
			flag = true
			-- Uniqueness test: if UnitIsUnit(uid, prev_uids) it's not unique!
			if distinct then
				for j=1,ix do
					if UnitIsUnit(uid, uids[j]) then flag = nil break end
				end
			end
			-- If all tests passed, add it
			if flag then
				ix = ix + 1
				self.proto_uids[ix] = proto_uid
				self.uids[ix] = uid
			end
		end
	end

	-- Postprocessing: Fire events
	if(ix > 0) then
		if(self.n == 0) then
			self.n = ix
			self:Fire("TRACER_ACQUIRED")
		end
		self.n = ix
		self:Fire("TRACER_UPDATE")
		--return true
	else
		if(self.n > 0) then
			self.n = 0 
			self.lostTime = GetTime()
			self:Fire("TRACER_LOST")
		end
		-- return nil
	end
end

----------------------------------
-- PROTOTYPE API
----------------------------------

function Prototype:TrackUnitName(name)
	self.name = name
end

function Prototype:IsOpen()
	return self.handle
end

function Prototype:Open()
	if self.handle then return end
	assert(self.name or self.names,"Requires TrackUnitName or TrackUnitNames to be set")
	self.handle = self:ScheduleRepeatingTimer("Execute", TraceDelay)
end

function Prototype:Close()
	self.name = nil
	self:CancelTimer(self.handle,true)
	self.handle = nil
end

function Prototype:ProtoUIDs() 
	return self.proto_uids 
end

function Prototype:UIDs() 
	return self.uids 
end

function Prototype:NumMatches() 
	return self.n 
end

function Prototype:First() 
	return self.uids[1] 
end

function Prototype:FirstProto() 
	return self.proto_uids[1] 
end

DXE.HOT = HOT
