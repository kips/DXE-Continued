--[[
	The invoker executes commands in encounter data

	Terminology:
	
	A command line is a hash table with one key (the command) and a value
	A command list is an array of command lines
	A command bundle is an array of command lists

	Valid commands are:
		expect 				= {"<token or value> ... <token_n or value_n>","<op>","<token' or value'> ... <token_n' or value_n'>"}
		quash 				= "<alert>"
		set 					= {<var> = <token or value>, ..., <var_n> = <token_n or value_n> }
		alert 				= "<alert>"
		scheduletimer	   = {"<timer>",<token or number>}
		canceltimer 		= "<timer>"
		resettimer 			= [BOOLEAN]
		tracing 				= {<name>,...,<name_n>}
		proximitycheck 	= {"<token>",[10,11,18, or 28]}
		raidicon 			= "<raidicon>"
		arrow 				= "<arrow>"
		removearrow 		= "<token>"
]]

local addon = DXE
local version = tonumber(("$Rev$"):match("%d+"))
addon.version = version > addon.version and version or addon.version
local L = addon.L

local type,next,select = type,next,select
local ipairs,pairs,unpack = ipairs,pairs,unpack
local tostring,tonumber = tostring,tonumber
local match,gmatch,gsub,find,split = string.match,string.gmatch,string.gsub,string.find,string.split
local wipe = table.wipe

local NID = addon.NID
local EncDB,CE,alerts,raidicons,arrows
-- Temp variable environment
local userdata = {}

---------------------------------------------
-- COMMAND LINE HANDLERS
---------------------------------------------
local handlers = {}

--@debug@
setmetatable(handlers,{
	__newindex = function(t,k,v)
		assert(type(k) == "string")
		assert(type(v) == "function")
		rawset(t,k,v)
	end,
})
--@end-debug@

---------------------------------------------
-- TABLE POOL
---------------------------------------------

local cache = {}
setmetatable(cache,{__mode = "k"})
local new = function()
	local t = next(cache)
	if t then 
		cache[t] = nil
		return t
	else
		return {} 
	end
end

local del = function(t)
	wipe(t)
	cache[t] = true
	return nil
end

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local module = addon:NewModule("Invoker","AceEvent-3.0","AceTimer-3.0")
addon.Invoker = module
local HW = addon.HW
local Alerts = addon.Alerts
local Arrows = addon.Arrows
local RaidIcons = addon.RaidIcons
-- Hold event info
local RegEvents,CombatEvents = {},{}

--@debug@
local debug

local debugDefaults = {
	-- Related to function names
	SetUserData = false,
	Alerts = false,
	REG_EVENT = false,
}

--@end-debug@

function module:OnInitialize()
	addon.RegisterCallback(self,"SetActiveEncounter","OnSet")
	addon.RegisterCallback(self,"StartEncounter","OnStart")
	addon.RegisterCallback(self,"StopEncounter","OnStop")

	--@debug@
	self.db = addon.db:RegisterNamespace("Invoker", {
		global = {
			debug = debugDefaults
		},
	})

	debug = addon:CreateDebugger("Invoker",self.db.global,debugDefaults)
	--@end-debug@
end

---------------------------------------------
-- EVENT TUPLES
---------------------------------------------

local tuple = {}

local function SetTuple(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
	tuple['1']  = a1
	tuple['2']  = a2
	tuple['3']  = a3
	tuple['4']  = a4
	tuple['5']  = a5
	tuple['6']  = a6
	tuple['7']  = a7
	tuple['8']  = a8
	tuple['9']  = a9
	tuple['10'] = a10
end


---------------------------------------------
-- CONTROLS
---------------------------------------------

function module:OnStart(_,...)
	if CE.onstart then
		self:InvokeCommands(CE.onstart,...)
	end
	if next(CombatEvents) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","COMBAT_EVENT")
	end
	for event in pairs(RegEvents) do
		self:RegisterEvent(event,"REG_EVENT")
	end
	addon:SetTracing(CE.onactivate.tracing)
	-- Reset colors if not acquired
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and not hw.tracer:First() then
			hw:SetInfoBundle("",1,0,0,1)
		end
	end
end

function module:OnStop()
	if not CE then return end
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	for event in pairs(RegEvents) do
		self:UnregisterEvent(event)
	end
	-- Reset userdata
	self:ResetUserData()
	-- Quashes all alerts
	Alerts:QuashAllAlerts()
	-- Removes Arrows
	Arrows:RemoveAll()
	-- Remove Icons
	RaidIcons:RemoveAll()
	-- Remove Timers
	self:RemoveAllTimers()
	-- Remove Throttles
	self:RemoveThrottles()
end


---------------------------------------------
-- CONDITIONS
-- Credits to PitBull4's debug for this idea
---------------------------------------------

local ops = {}

ops['=='] = function(a, b) return a == b end
ops['~='] = function(a, b) return a ~= b end
ops['find'] = function(a,b) return find(a,b) end

do
	-- Intended to be used on numbers

	ops['>'] = function(a, b)
		a,b = tonumber(a),tonumber(b)
		if not a or not b then return false 
		else return a > b end
	end

	ops['>='] = function(a, b)
		a,b = tonumber(a),tonumber(b)
		if not a or not b then return false
		else return a >= b end
	end

	ops['<'] = function(a, b)
		a,b = tonumber(a),tonumber(b)
		if not a or not b then return false
		else return a < b end
	end

	ops['<='] = function(a, b)
		a,b = tonumber(a),tonumber(b)
		if not a or not b then return false
		else return a <= b end
	end
end

do
	local t = {}
	for k, v in pairs(ops) do t[#t+1] = k end
	for _, k in ipairs(t) do
		ops["not_" .. k] = function(a, b)
			return not ops[k](a, b)
		end
	end
end

--@debug@
function module:GetConditions()
	return ops
end
--@end-debug@

local function expect(a, op, b)
	return ops[op](a,b)
end

---------------------------------------------
-- REPLACES
---------------------------------------------

local UnitGUID, UnitName, UnitExists, UnitIsUnit = UnitGUID, UnitName, UnitExists, UnitIsUnit

local function tft()
	return HW[1].tracer:First() and HW[1].tracer:First().."target" or ""
end

-- IMPORTANT - Return values should all be strings
local RepFuncs = {
	playerguid = function() return addon.PGUID end,
	playername = function() return addon.PNAME end,
	vehicleguid  = function() return UnitGUID("vehicle") or "" end,
	difficulty = function() return tostring(GetCurrentDungeonDifficulty()) end,
	-- First health watcher
	tft = tft,
	tft_unitexists = function() return tostring(UnitExists(tft())) end,
	tft_isplayer = function() return tostring(UnitIsUnit(tft(),"player")) end,
	tft_unitname = function() return tostring(UnitName(tft())) end,
	--- Functions with passable arguments
	-- Get's an alert's timeleft
	timeleft = function(id,delta) return tostring(Alerts:GetAlertTimeleft(id) + (tonumber(delta) or 0)) end,
	npcid = function(guid) return NID[guid] or "" end,
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

--@debug@
function module:GetRepFuncs()
	return RepFuncs
end
--@end-debug@

local replace_nums = tuple

local function replace_vars(str)
	local val = userdata[str]
	if type(val) == "table" then
		local ix,n = str.."__index",#val
		local i = userdata[ix]
		if i > n and not val.loop then
			i = n
		else
			i = ((i-1)%n)+1 -- Handles looping
			userdata[ix] = userdata[ix] + 1
		end
		val = val[i]
	end
	return val
end

local function replace_funcs(str)
	if find(str,"|") then
		local func,args = match(str,"^([^|]+)|(.+)") 
		return RepFuncs[func](split("|",args))
	else
		return RepFuncs[str]()
	end
end

-- Replaces special tokens with values
-- IMPORTANT: replace_funcs goes last
function ReplaceTokens(str)
	str = gsub(str,"#(.-)#",replace_nums)
	str = gsub(str,"<(.-)>",replace_vars)
	str = gsub(str,"&(.-)&",replace_funcs)
	return str
end

---------------------------------------------
-- USERDATA
---------------------------------------------

function module:ResetUserData()
	wipe(userdata)
	if not CE.userdata then return end
	-- Copy defaults into userdata
	for k,v in pairs(CE.userdata) do
		userdata[k] = v
		if type(v) == "table" then
			-- Indexing for series
			userdata[k.."__index"] = 1
		end
	end
end


local function SetUserData(info)
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
				v = ReplaceTokens(v)
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

function module:RemoveThrottles()
	wipe(Throttles)
end

local GetTime = GetTime
local function StartAlert(id,stgs)
	local info = alerts[id]
	-- Sanity check
	if not info then return true end
	-- Throttling
	if info.throttle then
		-- Initialize to 0 if non-existant
		Throttles[id] = Throttles[id] or 0
		-- Check throttle
		local t = GetTime()
		if Throttles[id] + info.throttle < t then
			Throttles[id] = t
		else
			-- Failed throttle, exit out
			return
		end
	end
	-- Replace text
	local text = ReplaceTokens(info.text)
	-- Replace time
	local time = info.time
	if type(time) == "string" then
		time = tonumber(ReplaceTokens(time))
	end
	--@debug@
	debug("Alerts","id: %s text: %s time: %s flashtime: %s sound: %s color1: %s color2: %s",id,text,time,info.flashtime,stgs.sound,stgs.color1,stgs.color2)
	--@end-debug@
	-- Sanity check
	if not time or time < 0 then return end
	-- Pass in appropriate arguments
	if info.type == "dropdown" then
		Alerts:Dropdown(id,text,time,info.flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen)
	elseif info.type == "centerpopup" then
		Alerts:CenterPopup(id,text,time,info.flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen)
	elseif info.type == "simple" then
		Alerts:Simple(text,time,stgs.sound,stgs.color1,stgs.flashscreen)
	end
end

---------------------------------------------
-- TIMERS
---------------------------------------------
local Timers = {}

local function canceltimer(name)
	if Timers[name] then
		module:CancelTimer(Timers[name].handle,true)
		Timers[name].args = del(Timers[name].args)
		Timers[name] = del(Timers[name])
	end
	return true
end

function module:RemoveAllTimers()
	for name in pairs(Timers) do
		canceltimer(name)
	end
	-- Just to be safe
	self:CancelAllTimers()
end

function module:FireTimer(name)
	-- Don't wipe Timers[name], it could be rescheduled
	self:InvokeCommands(CE.timers[name],unpack(Timers[name].args))
end

---------------------------------------------
-- Proximity Checking
---------------------------------------------

local ProximityFuncs = addon:GetProximityFuncs() 

-- @param target Name/GUID of a unit
-- @param range Number of yards to check to see if player is in range of target.
-- 				 It must be a key in ProximityFuncs. Validator ensures this.
-- @return boolean 'true' if the player is in range of the target. 'false' otherwise.
local function CheckProximity(unit,range)
	return ProximityFuncs[range](unit)
end

---------------------------------------------
-- Arrows
---------------------------------------------

local function StartArrow(name,stgs)
	local info = arrows[name]
	local unit = ReplaceTokens(info.unit)
	if not UnitExists(unit) then return end
	Arrows:AddTarget(unit,info.persist,info.action,info.msg,info.spell,stgs.sound,info.fixed)
end

---------------------------------------------
-- Raid Icons
---------------------------------------------

--[[
    0 = no icon 
    1 = Yellow 4-point Star 
    2 = Orange Circle 
    3 = Purple Diamond 
    4 = Green Triangle 
    5 = White Crescent Moon 
    6 = Blue Square 
    7 = Red "X" Cross 
    8 = White Skull 
]]

local function SetRaidIcon(name,stgs)
	local info = raidicons[name]
	if not info then return end
	if info.type == "FRIENDLY" then
		local unit = ReplaceTokens(info.unit)
		if not UnitExists(unit) then return end
		RaidIcons:MarkFriendly(unit,stgs.icon,info.persist)
	end
end

---------------------------------------------
-- FUNCTIONS TABLE
---------------------------------------------

local CommandHandlers = {
	expect = function(info)
		return expect(ReplaceTokens(info[1]),info[2],ReplaceTokens(info[3]))
	end,

	quash = function(info)
		Alerts:QuashAlertsByPattern(info)
		return true
	end,

	set = function(info)
		SetUserData(info)
		return true
	end,

	alert = function(info)
		local stgs = EncDB[info]
		if stgs.enabled then StartAlert(info,stgs) end
		return true
	end,

	scheduletimer = function(info)
		local name,time = info[1],info[2]
		-- Rescheduled Timers are overwritten
		canceltimer(name)
		Timers[name] = new()
		Timers[name].handle = module:ScheduleTimer("FireTimer",time,name)
		local args = new()
		-- Only need the first 7 (up to spellID)
		args[1],args[2],args[3],args[4],args[5],args[6],args[7] = 
		tuple[1],tuple[2],tuple[3],tuple[4],tuple[5],tuple[6],tuple[7]

		Timers[name].args = args
		return true
	end,

	canceltimer = canceltimer,

	resettimer = function(info)
		addon:ResetTimer() 
		return true
	end,

	tracing = function(info)
		addon:SetTracing(info)
		return true
	end,

	proximitycheck = function(info)
		local target,range = info[1],info[2]
		target = ReplaceTokens(target)
		return CheckProximity(target,range)
	end,

	raidicon = function(info)
		local stgs = EncDB[info]
		if addon:IsPromoted() and stgs.enabled then
			SetRaidIcon(info,stgs)
		end
		return true
	end,

	arrow = function(info)
		local stgs = EncDB[info]
		if stgs.enabled then StartArrow(info,stgs) end
		return true
	end,

	removearrow = function(info)
		info = ReplaceTokens(info)
		Arrows:RemoveTarget(info)
		return true
	end,
}

---------------------------------------------
-- INVOKING
---------------------------------------------

-- @param bundle Command bundles
-- @param ... arguments passed with the event
function module:InvokeCommands(bundle,...)
	SetTuple(...)
	for _,list in ipairs(bundle) do
		for _,line in ipairs(list) do
			local type,info = next(line)
			local handler = CommandHandlers[type]
			-- Make sure handler exists in case of an unsupported command
			if handler and not handler(info) then break end
		end
	end
end

---------------------------------------------
-- EVENTS
---------------------------------------------

--event, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName,...
function module:COMBAT_EVENT(event,timestamp,eventtype,...)
	if not CombatEvents[eventtype] then return end
	local spellID = select(7,...)
	local bundle = CombatEvents[eventtype]["*"] or CombatEvents[eventtype][spellID]
	if bundle then
		self:InvokeCommands(bundle,...)
	end
end

function module:REG_EVENT(event,...)
	--@debug@
	debug("REG_EVENT",event,...)
	--@end-debug@
	-- Pass in command list and arguments
	self:InvokeCommands(RegEvents[event],...)
end

local REG_ALIASES = {
	YELL = "CHAT_MSG_MONSTER_YELL",
	EMOTE = "CHAT_MSG_RAID_BOSS_EMOTE",
	WHISPER = "CHAT_MSG_RAID_BOSS_WHISPER",
}

function module:AddEventData()
	if not CE.events then return end
	-- Iterate over events table
	for _,info in ipairs(CE.events) do
		if info.type == "combatevent" then
			-- Register combat log event
			CombatEvents[info.eventtype] = CombatEvents[info.eventtype] or new()
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
			-- Add execute list to the appropriate key
			RegEvents[event] = info.execute
		end
	end
end

function module:WipeEvents()
	wipe(RegEvents)
	for k,v in pairs(CombatEvents) do
		if type(v) == "table" then del(v) end
		CombatEvents[k] = nil
	end
	self:UnregisterAllEvents()
end

---------------------------------------------
-- TRACER ACQUIRES
---------------------------------------------
-- Holds command bundles
local AcquiredBundles = {}
local UnitIsDead = UnitIsDead

function module:HW_TRACER_ACQUIRED(_,unit,npcid)
	if AcquiredBundles[npcid] and not UnitIsDead(unit) then
		self:InvokeCommands(AcquiredBundles[npcid])
	end
end

-- Each entry in 
function module:SetOnAcquired()
	wipe(AcquiredBundles)
	local onacquired = CE.onacquired
	if not onacquired then return end
	for npcid,bundle in pairs(onacquired) do
		AcquiredBundles[npcid] = bundle
	end
end

addon.RegisterCallback(module,"HW_TRACER_ACQUIRED")

---------------------------------------------
-- API
---------------------------------------------

function module:OnSet(_,data)
	--@debug@
	assert(type(data) == "table","Expected 'data' table as argument #1 in OnSet. Got '"..tostring(data).."'")
	--@end-debug@
	-- Set upvalues
	CE = data
	arrows = CE.arrows
	raidicons = CE.raidicons
	alerts = CE.alerts
	-- Set db upvalues
	EncDB = addon.db.profile.Encounters[CE.key]
	-- Wipe events
	self:WipeEvents()
	-- Register events
	self:AddEventData()
	-- Copy data.userdata to userdata upvalue
	self:ResetUserData()
	-- OnAcquired
	self:SetOnAcquired()
end
