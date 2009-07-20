--[[
	Terminology:

	A pretarget of unit X is any unit Y in the group for which Y target^(n) = X for 
	some n.

	The prototarget is the pretarget at the beginning of the chain.

	Credits to RDX
]]

local addon = DXE
local version = tonumber(("$Rev$"):match("%d+"))
addon.version = version > addon.version and version or addon.version
local AceTimer = addon.AceTimer
local Roster = addon.Roster
local NID = addon.NID

-- Local accessors
local wipe = table.wipe
local pairs = pairs
local UnitIsUnit,UnitName,UnitGUID,UnitExists = 
		UnitIsUnit,UnitName,UnitGUID,UnitExists

-- Perf: default delay between traces.
local traceDelay = 0.2

----------------------------------
-- INITIALIZATION
----------------------------------

local HOT,prototype = {},{}
addon.HOT = HOT

----------------------------------
-- CORE
----------------------------------

local rIDtarget = {}
for i=1,40 do rIDtarget["raid"..i] = "raid"..i.."target" end

-- GUID NPC test
local function testguid(self,proto_uid)
	local uid = rIDtarget[proto_uid]
	local guid = UnitGUID(uid)
	if NID[guid] == self.npcid then
		return proto_uid,uid
	end
end

local function testguid_focus(self)
	if not UnitExists("focus") then return end
	local guid = UnitGUID("focus")
	if NID[guid] == self.npcid then
		return "focus","focus"
	end
end

-- Name tests
local function testname(self,proto_uid)
	local uid = rIDtarget[proto_uid]
	if UnitName(uid) == self.name then
		return proto_uid,uid
	end
end

local function testname_focus(self)
	if not UnitExists("focus") then return end
	if UnitName("focus") == self.name then 
		return "focus","focus"
	end
end

function HOT:New()
	local tracer = AceTimer:Embed({})
	for k,v in pairs(prototype) do tracer[k] = v end
	
	-- State
	tracer.distinct = true 	-- Show only distinct mobs matching the filter, or all mobs?
	tracer.n = 0 				-- The number of acquired traces
	tracer.lostTime = 0 		-- The time the signal was last lost
	tracer.proto_uids = {} 	-- The uids of all units that tripped the trace
	tracer.uids = {} 			-- The uids of all the target units
	tracer.callbacks = {} 	-- Callbacks

	return tracer
end

----------------------------------
-- PROTOTYPE
----------------------------------

function prototype:SetCallback(obj,name)
	self.callbacks[name] = function() obj[name](obj) end
end

function prototype:Fire(name)
	if self.callbacks[name] then
		self.callbacks[name]()
	end
end

function prototype:Execute()
	local uids = self.uids
	local proto_uids = self.proto_uids
	local distinct = self.distinct
	local test = self.test
	local test_focus = self.test_focus
	wipe(uids) 
	wipe(proto_uids)

	-- Local data
	local proto_uid, uid, ix, flag = nil, nil, 0, nil
	
	-- Hack to get focus in
	local testedfocus = false

	-- Scan
	for _,unit in pairs(Roster.index_to_unit) do
		-- Get unit and test it
		proto_uid = unit
		proto_uid, uid = test(self,proto_uid)

		if not proto_uid and not testedfocus then
			proto_uid, uid = test_focus(self)
			testedfocus = true
		end
		
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

	-- Postprocessing: Fire callbacks
	if(ix > 0) then
		if(self.n == 0) then
			self.n = ix
			self:Fire("TRACER_ACQUIRED")
		end
		self.n = ix
		self:Fire("TRACER_UPDATE")
	else
		if(self.n > 0) then
			self.n = 0 
			self.lostTime = GetTime()
			self:Fire("TRACER_LOST")
		end
	end
end

----------------------------------
-- PROTOTYPE API
----------------------------------

function prototype:TrackUnitName(name)
	self.name = name
	self.test = testname
	self.test_focus = testname_focus
end

function prototype:TrackNPCID(npcid)
	--@debug@
	assert(type(npcid) == "number")
	--@end-debug@
	self.npcid = npcid
	self.test = testguid
	self.test_focus = testguid_focus
end

function prototype:IsOpen()
	return self.handle
end

function prototype:Open()
	if self.handle then return end
	--@debug@
	assert(self.name or self.npcid)
	--@end-debug@
	self.handle = self:ScheduleRepeatingTimer("Execute", traceDelay)
end

function prototype:Close()
	if not self.handle then return end
	self.name = nil
	self.npcid = nil
	self.test = nil
	self.test_focus = nil
	self:CancelTimer(self.handle,true)
	self.handle = nil
	self.n = 0
end

function prototype:ProtoUIDs() 
	return self.proto_uids 
end

function prototype:UIDs() 
	return self.uids 
end

function prototype:NumMatches() 
	return self.n 
end

function prototype:First() 
	return self.uids[1] 
end

function prototype:FirstProto() 
	return self.proto_uids[1] 
end
