--[[
	Terminology:
	
	A command line is a hash table with one key (the command) and a value
	A command list is an array of command lines
	A command bundle is an array of command lists

	Valid commands are:
		expect
		quash
		set
		alert
		scheduletimer
		canceltimer
		resettimer
		tracing
]]

local DXE = DXE

local type,next,select = type,next,select
local ipairs,pairs,unpack = ipairs,pairs,unpack
local tostring,tonumber = tostring,tonumber
local match,gmatch,gsub,find = string.match,string.gmatch,string.gsub,string.find

local EncDB,CE
local userdata = {}

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local Invoker = DXE:NewModule("Invoker","AceEvent-3.0","AceTimer-3.0")
local HW = DXE.HW
local Alerts = DXE.Alerts

--@debug@
local debug
--@end-debug@

function Invoker:OnInitialize()
	DXE.RegisterCallback(self,"SetActiveEncounter","OnSet")
	DXE.RegisterCallback(self,"StartEncounter","OnStart")
	DXE.RegisterCallback(self,"StopEncounter","OnStop")

	--@debug@
	self.db = DXE.db:RegisterNamespace("Invoker", {
		global = {
			debug = {
				-- Related to function names
				ReplaceFuncs = false,
				ReplaceVars = false,
				ReplaceNums = false,
				SetUserData = false,
				Alerts = false,
			},
		},
	})

	debug = DXE:CreateDebugger("Invoker",self.db.global)
	--@end-debug@
end

---------------------------------------------
-- CONTROLS
---------------------------------------------

function Invoker:OnStart()
	if CE.onstart then
		self:InvokeCommands(CE.onstart)
	end
	DXE:SetTracing(CE.tracing)
	-- Reset colors
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and not hw.tracer:First() then
			hw:SetInfoBundle(hw:GetName(),"",1,0,0,1)
		end
	end
end

function Invoker:OnStop()
	if not CE then return end
	-- Reset userdata
	self:ResetUserData()
	-- Quashes all alerts
	Alerts:StopAll()
	-- Remove Timers
	self:RemoveAllTimers()
	-- Remove Throttles
	self:RemoveThrottles()
end


---------------------------------------------
-- CONDITIONS
-- Shamelessly stolen from Pitbull. Credits: ckknight
---------------------------------------------

local conditions = {}

conditions['=='] = function(a, b)
	return a == b
end
conditions['~='] = function(a, b)
	return a ~= b
end
conditions['>'] = function(a, b)
	return type(a) == type(b) and a > b
end
conditions['>='] = function(a, b)
	return type(a) == type(b) and a >= b
end
conditions['<'] = function(a, b)
	return type(a) == type(b) and a < b
end
conditions['<='] = function(a, b)
	return type(a) == type(b) and a <= b
end

conditions['find'] = function(a,b)
	return find(tostring(a),tostring(b))
end

do
	local t = {}
	for k, v in pairs(conditions) do
		t[#t+1] = k
	end
	for _, k in ipairs(t) do
		conditions["not_" .. k] = function(a, b)
			return not conditions[k](a, b)
		end
	end
end

function Invoker:GetConditions()
	return conditions
end

---------------------------------------------
-- REPLACES
---------------------------------------------

local UnitGUID, UnitName, UnitExists, UnitIsUnit = UnitGUID, UnitName, UnitExists, UnitIsUnit

local function expect(a, condition, b)
	return conditions[condition](a,b)
end

local function tft()
	return HW[1].tracer:First() and HW[1].tracer:First().."target" or ""
end

-- IMPORTANT - Return values should all be strings
local RepFuncs = {
	playerguid = function() return DXE.pGUID end,
	playername = function() return DXE.pName end,
	vehicleguid  = function() return UnitGUID("vehicle") or "" end,
	difficulty = function() return tostring(GetCurrentDungeonDifficulty()) end,
	-- First health watcher
	tft = tft,
	tft_unitexists = function() return tostring(UnitExists(tft())) end,
	tft_isplayer = function() return tostring(UnitIsUnit(tft(),"player")) end,
	tft_unitname = function() return tostring(UnitName(tft())) end,
	-- Get's an alert's timeleft
	timeleft = function(name,delta) return tostring(Alerts:GetAlertTimeleft(name) + (tonumber(delta) or 0)) end,
}

-- Add funcs for the other health watchers
do
	for i=2,4 do
		local tft = function() return HW[i].tracer:First() and HW[i].tracer:First().."target" or "" end
		local tft_unitexists = function() return tostring(UnitExists(tft())) end
		local tft_isplayer = function() return tostring(UnitIsUnit(tft(),"player")) end
		local tft_unitname = function() return tostring(UnitName(tft())) end
		RepFuncs["tft"..i] = tft
		RepFuncs["tft"..i.."_unitexists"] = tft_unitexists
		RepFuncs["tft"..i.."_isplayer"] = tft_isplayer
		RepFuncs["tft"..i.."_unitname"] = tft_unitname
	end
end

function Invoker:GetRepFuncs()
	return RepFuncs
end

local function ReplaceVars(str)
	-- Enclosed in <>
	for var in gmatch(str,"%b<>") do 
		local key = match(var,"<(.+)>")
		local val = userdata[key]
		if val then
			--- Series support
			-- Post increments the index
			if type(val) == "table" then
				local ix,n = key.."_index",#val
				local i = userdata[ix]
				if i > n and not val.loop then
					i = n
				else
					i = ((i-1)%n)+1 -- Handles looping
					userdata[ix] = userdata[ix] + 1
				end
				val = val[i]
			end
			--@debug@
			debug("ReplaceVars","str: %s var: %s val: %s",str,var,val)
			--@end-debug@

			-- Replace variable and value
			str = gsub(str,var,val)
		end
	end
	return str
end

local split = string.split
local function ReplaceFuncs(str)
	-- Enclosed in &&
	for rep in gmatch(str,"%b&&") do
		local info = match(rep,"&(.+)&")
		local funcid,args
		if find(info,"|") then funcid,args = match(info,"^([^|]+)|(.+)") 
		else funcid = info end
		local func = RepFuncs[funcid]
		if func then
			local val
			if args then val = func(split("|",args))
			else val = func() end
			--@debug@
			debug("ReplaceFuncs","funcid: %s str: %s rep: %s val: %s",funcid,str,rep,val)
			--@end-debug@
			str = gsub(str,rep,val)
		end
	end
	return str
end

local function ReplaceNums(str,...)
	if ... then
		-- Enclosed in ##
		for index in gmatch(str,"%b##") do
			local num = tonumber(match(index,"#(%d)#"))
			local val = num and select(num,...)
			if num and val then
				--@debug@
				debug("ReplaceNums","str: %s index: %s val: %s",str,index,val)
				--@end-debug@
				str = gsub(str,index,val)
			end
		end
	end
	return str
end

-- Replaces special tokens with values
local function ReplaceTokens(str,...)
	if type(str) ~= "string" then return str end
	-- Replace userdata values
	str = ReplaceVars(str)
	str = ReplaceFuncs(str)
	str = ReplaceNums(str,...)
	return str
end

---------------------------------------------
-- USERDATA
---------------------------------------------

function Invoker:ResetUserData()
	wipe(userdata)
	if not CE.userdata then return end
	-- Copy defaults into userdata
	for k,v in pairs(CE.userdata) do
		userdata[k] = v
		if type(v) == "table" then
			-- Indexing for series
			userdata[k.."_index"] = 1
		end
	end
end


local function SetUserData(info,...)
	for k,v in pairs(info) do
		local flag = true
		--@debug@
		local before = userdata[k]
		--@end-debug@
		if type(v) == "string" then
			-- Increment/Decrement support
			if find(v,"^INCR") then
				local delta = tonumber(match(v,"^INCR|(%d+)"))
				userdata[k] = userdata[k] + delta
				--@debug@
				debug("SetUserData","INCR var: %s before: %s after: %s delta: %d",k,before,userdata[k],delta)
				--@end-debug@
				flag = false
			elseif find(v,"^DECR") then
				local delta = tonumber(match(v,"^DECR|(%d+)"))
				userdata[k] = userdata[k] - delta
				flag = false
				--@debug@
				debug("SetUserData","DECR var: %s before: %s after: %s delta: %d",k,before,userdata[k],delta)
				--@end-debug@
			else
				v = ReplaceTokens(v,...)
			end
		end
		if flag then 
			--@debug@
			debug("SetUserData","var: %s before: %s after: %s",k,userdata[k],v)
			--@end-debug@
			userdata[k] = v 
		end
	end
end

---------------------------------------------
-- ALERTS
---------------------------------------------
local Throttles = {}

function Invoker:RemoveThrottles()
	wipe(Throttles)
end

local GetTime = GetTime
local function StartAlert(name,...)
	local info = CE.alerts[name]
	-- Sanity check
	if not info then return end
	-- Throttling
	if info.throttle then
		-- Initialize to 0 if non-existant
		Throttles[name] = Throttles[name] or 0
		-- Check throttle
		local t = GetTime()
		if Throttles[name] + info.throttle < t then
			Throttles[name] = t
		else
			-- Failed throttle so exit out
			return
		end
	end
	-- Replace text
	local text = ReplaceTokens(info.text,...)
	-- Replace time
	local time = info.time
	if type(time) == "string" then
		time = tonumber(ReplaceFuncs(ReplaceVars(time)))
	end
	--@debug@
	debug("Alerts","name: %s text: %s time: %d flashtime: %d sound: %s color1: %s color2: %s",name,text,time,info.flashtime,info.sound,info.color1,info.color2)
	--@end-debug@
	-- Sanity check
	if not time or time < 0 then return end
	-- Pass in appropriate arguments
	if info.type == "dropdown" then
		Alerts:Dropdown(name,text,time,info.flashtime,info.sound,info.color1,info.color2)
	elseif info.type == "centerpopup" then
		Alerts:CenterPopup(name,text,time,info.flashtime,info.sound,info.color1,info.color2)
	elseif info.type == "simple" then
		Alerts:Simple(text,info.sound,time,info.color1)
	end
end

---------------------------------------------
-- TIMERS
---------------------------------------------
local Timers = {}
Invoker.Timers = Timers

local function canceltimer(name)
	if Timers[name] then
		Invoker:CancelTimer(Timers[name].handle,true)
		Timers[name] = DXE.rdelete(Timers[name])
	end
	return true
end

function Invoker:RemoveAllTimers()
	for name in pairs(Timers) do
		canceltimer(name)
	end
	-- Just to be safe
	self:CancelAllTimers()
end

function Invoker:FireTimer(name)
	if CE.timers[name] then
		-- Don't wipe Timers[name], it could be rescheduled
		self:InvokeCommands(CE.timers[name],unpack(Timers[name].args))
	end
end

---------------------------------------------
-- Proximity Checking
---------------------------------------------

-- 18 yards
local bandages = {
	[21991] = true, -- Heavy Netherweave Bandage
	[21990] = true, -- Netherweave Bandage
	[14530] = true, -- Heavy Runecloth Bandage
	[14529] = true, -- Runecloth Bandage
	[8545] = true, -- Heavy Mageweave Bandage
	[8544] = true, -- Mageweave Bandage
	[6451] = true, -- Heavy Silk Bandage
	[6450] = true, -- Silk Bandage
	[3531] = true, -- Heavy Wool Bandage
	[3530] = true, -- Wool Bandage
	[2581] = true, -- Heavy Linen Bandage
	[1251] = true, -- Linen Bandage
}
-- CheckInteractDistance(unit,i)
-- 2 = Trade, 11.11 yards 
-- 3 = Duel, 9.9 yards 
-- 4 = Follow, 28 yards 

local IsItemInRange = IsItemInRange
-- Keys refer to yards
local ProximityFuncs = {
	[10] = function(unit) return CheckInteractDistance(unit,3) end,
	[11] = function(unit) return CheckInteractDistance(unit,2) end,
	[18] = function(unit)  
		for itemid in pairs(bandages) do
			if IsItemInRange(itemid,unit) == 1 then
				return true
			end
		end
		return false
	end,
	[28] = function(unit) return CheckInteractDistance(unit,4) end,
}

function Invoker:GetProximityFuncs()
	return ProximityFuncs
end

-- @param target Name/GUID of a unit
-- @param range Number of yards to check to see if player is in range of target.
-- 				 It must be a key in ProximityFuncs. Validator ensures this.
-- @return boolean 'true' if the player is in range of the target. 'false' otherwise.
local function CheckProximity(target,range)
	local uid = DXE:GetUnitID(target)
	if not uid then return false end
	local test = ProximityFuncs[range]
	return test(uid)
end

---------------------------------------------
-- FUNCTIONS TABLE
---------------------------------------------

local CommandFuncs = {
	expect = function(info,...)
		local flag = expect(ReplaceTokens(info[1],...),info[2],ReplaceTokens(info[3],...))
		return flag
	end,

	quash = function(info,...)
		Alerts:QuashAlertsByPattern(info)
		return true
	end,

	set = function(info,...)
		SetUserData(info,...)
		return true
	end,

	alert = function(info,...)
		if EncDB[CE.alerts[info].var] then StartAlert(info,...) end
		return true
	end,

	scheduletimer = function(info,...)
		local name,time = info[1],info[2]
		-- Rescheduled Timers are overwritten
		canceltimer(name)
		Timers[name] = DXE.new()
		Timers[name].handle = Invoker:ScheduleTimer("FireTimer",time,name)
		local args = DXE.new()
		-- Only need the first 7 (up to spellID)
		args[1],args[2],args[3],args[4],args[5],args[6],args[7] = ...
		Timers[name].args = args
		return true
	end,

	canceltimer = canceltimer,

	resettimer = function(info,...) 
		DXE:ResetTimer() 
		return true
	end,

	tracing = function(info,...)
		DXE:SetTracing(info)
		return true
	end,

	proximitycheck = function(info,...)
		local target,range = info[1],info[2]
		target = ReplaceNums(target,...)
		target = ReplaceFuncs(target)
		return CheckProximity(target,range)
	end,
}

---------------------------------------------
-- INVOKING
---------------------------------------------

-- @param bundle Command bundles
-- @param ... arguments passed with the event
function Invoker:InvokeCommands(bundle,...)
	for _,list in ipairs(bundle) do
		for _,line in ipairs(list) do
			local type,info = next(line)
			if CommandFuncs[type] then
				local flag = CommandFuncs[type](info,...)
				if not flag then break end
			end
		end
	end
end

---------------------------------------------
-- EVENTS
---------------------------------------------

local RegEvents,CombatEvents = {},{}

--event, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName,...
function Invoker:COMBAT_EVENT(event,timestamp,eventtype,...)
	if not CombatEvents[eventtype] then return end
	local spellID = select(7,...)
	local bundle = CombatEvents[eventtype]["*"] or CombatEvents[eventtype][spellID]
	if bundle then
		self:InvokeCommands(bundle,...)
	end
end

function Invoker:REG_EVENT(event,...)
	-- Pass in command list and arguments
	self:InvokeCommands(RegEvents[event],...)
end

local REG_ALIASES = {
	YELL = "CHAT_MSG_MONSTER_YELL",
	EMOTE = "CHAT_MSG_RAID_BOSS_EMOTE",
	WHISPER = "CHAT_MSG_RAID_BOSS_WHISPER",
}

function Invoker:RegisterEvents()
	if not CE.events then return end
	-- Iterate over events table
	for _,info in ipairs(CE.events) do
		if info.type == "combatevent" then
			-- Register combat log event
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","COMBAT_EVENT")
			CombatEvents[info.eventtype] = CombatEvents[info.eventtype] or {}
			if not info.spellid then
				CombatEvents[info.eventtype]["*"] = info.execute
			else
				if type(info.spellid) == "table" then
					for _,spellid in ipairs(info.spellid) do
						CombatEvents[info.eventtype][spellid] = info.execute
					end
				else
					CombatEvents[info.eventtype][info.spellid] = info.execute
				end
			end
		elseif info.type == "event" then
			local event = REG_ALIASES[info.event] or info.event
			-- Register regular event
			self:RegisterEvent(event,"REG_EVENT")
			-- Add execute list to the appropriate key
			RegEvents[event] = info.execute
		end
	end
end

function Invoker:WipeEvents()
	wipe(RegEvents)
	wipe(CombatEvents)
	self:UnregisterAllEvents()
end

---------------------------------------------
-- TRACER ACQUIRES
---------------------------------------------
-- Holds command bundles
local AcquiredBundles = {}
local UnitIsDead = UnitIsDead

function Invoker:HW_TRACER_ACQUIRED(event,uid)
	local name = UnitName(uid)
	if AcquiredBundles[name] and not UnitIsDead(uid) then
		self:InvokeCommands(AcquiredBundles[name])
	end
end

-- Each entry in 
function Invoker:SetOnAcquired()
	wipe(AcquiredBundles)
	local onacquired = CE.onacquired
	if not onacquired then return end
	for name,bundle in pairs(onacquired) do
		AcquiredBundles[name] = bundle
	end
end

DXE.RegisterCallback(Invoker,"HW_TRACER_ACQUIRED")

---------------------------------------------
-- API
---------------------------------------------

function Invoker:OnSet(_,data)
	assert(type(data) == "table","Expected 'data' table as argument #1 in OnSet. Got '"..tostring(data).."'")
	-- Set data upvalue
	CE = data
	-- Set db upvalue
	EncDB = DXE.db.profile.Encounters[CE.key]
	-- Wipe events
	self:WipeEvents()
	-- Register events
	self:RegisterEvents()
	-- Copy data.userdata to userdata upvalue
	self:ResetUserData()
	-- OnAcquired
	self:SetOnAcquired()
end

DXE.Invoker = Invoker
