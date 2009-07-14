--[[
	The invoker executes commands in encounter data

	Terminology:
	
	A command line is a hash table with one key (the command) and a value
	A command list is an array of command lines
	A command bundle is an array of command lists

	Valid commands are:
		expect 				= {"<token or value> ... <token_n or value_n>","<condition>","<token' or value'> ... <token_n' or value_n'>"}
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
local version = tonumber(("$Rev$"):sub(7, -3))
addon.version = version > addon.version and version or addon.version
local L = addon.L

local type,next,select = type,next,select
local ipairs,pairs,unpack = ipairs,pairs,unpack
local tostring,tonumber = tostring,tonumber
local match,gmatch,gsub,find = string.match,string.gmatch,string.gsub,string.find
local wipe = table.wipe

local UT,NID = addon.UT,addon.NID
local EncDB,CE,alerts,raidicons,arrows
local userdata = {}

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
	ReplaceFuncs = false,
	ReplaceVars = false,
	ReplaceNums = false,
	SetUserData = false,
	Alerts = false,
	REG_EVENT = false,
	HW_TRACER_ACQUIRED = false,
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
	-- Reset colors
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and not hw.tracer:First() then
			hw:SetInfoBundle(hw:GetName(),"",1,0,0,1)
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
-- Shamelessly stolen from Pitbull. Credits: ckknight
---------------------------------------------

local conditions = {}

conditions['=='] = function(a, b)
	return a == b
end
conditions['~='] = function(a, b)
	return a ~= b
end

conditions['find'] = function(a,b)
	return find(a,b)
end

-- Intended to be used on numbers
conditions['>'] = function(a, b)
	a,b = tonumber(a),tonumber(b)
	if not a or not b then return false 
	else return a > b end
end

conditions['>='] = function(a, b)
	a,b = tonumber(a),tonumber(b)
	if not a or not b then return false
	else return a >= b end
end

conditions['<'] = function(a, b)
	a,b = tonumber(a),tonumber(b)
	if not a or not b then return false
	else return a < b end
end

conditions['<='] = function(a, b)
	a,b = tonumber(a),tonumber(b)
	if not a or not b then return false
	else return a <= b end
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

function module:GetConditions()
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
	unitname = function(name) return tostring(UnitName(name)) end,
	npcid = function(guid) if UT[guid] ~= 3 then return "" else return NID[guid] or "" end end,
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

function module:GetRepFuncs()
	return RepFuncs
end

local ReplaceVars,ReplaceNums,ReplaceFuncs,ReplaceTokens

ReplaceVars = function(str)
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
--- Helper function for ReplaceFuncs. For now we only need to use ReplaceNum
local function replace_args(args,...)
	for val in gmatch(args,"[^|]+") do
		local newVal = ReplaceNums(val,...)
		args = gsub(args,val,newVal)
	end
	return args
end

ReplaceFuncs = function(str,...)
	-- Enclosed in &&
	for rep in gmatch(str,"%b&&") do
		local info = match(rep,"&(.+)&")
		local funcid,args
		if find(info,"|") then funcid,args = match(info,"^([^|]+)|(.+)") 
		else funcid = info end
		local func = RepFuncs[funcid]
		if func then
			local val
			if args then 
				args = replace_args(args,...)
				val = func(split("|",args))
			else 
				val = func() 
			end
			--@debug@
			debug("ReplaceFuncs","funcid: %s str: %s rep: %s val: %s",funcid,str:gsub("|","||"),rep:gsub("|","||"),val)
			--@end-debug@
			str = gsub(str,rep,val)
		end
	end
	return str
end

ReplaceNums = function(str,...)
	if select("#",...) > 0 then
		-- Enclosed in ##
		for index in gmatch(str,"%b##") do
			local num = tonumber(match(index,"#(%d+)#"))
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
ReplaceTokens = function(str,...)
	if type(str) ~= "string" then return str end
	-- Replace userdata values
	str = ReplaceVars(str)
	str = ReplaceFuncs(str,...)
	str = ReplaceNums(str,...)
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

function module:RemoveThrottles()
	wipe(Throttles)
end

local GetTime = GetTime
local function StartAlert(id,stgs,...)
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
	debug("Alerts","id: %s text: %s time: %s flashtime: %s sound: %s color1: %s color2: %s",id,text,time,info.flashtime,stgs.sound,stgs.color1,stgs.color2)
	--@end-debug@
	-- Sanity check
	if not time or time < 0 then return end
	-- Pass in appropriate arguments
	if info.type == "dropdown" then
		Alerts:Dropdown(id,text,time,info.flashtime,stgs.sound,stgs.color1,stgs.color2)
	elseif info.type == "centerpopup" then
		Alerts:CenterPopup(id,text,time,info.flashtime,stgs.sound,stgs.color1,stgs.color2)
	elseif info.type == "simple" then
		Alerts:Simple(text,time,stgs.sound,stgs.color1)
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
	if CE.timers[name] then
		-- Don't wipe Timers[name], it could be rescheduled
		self:InvokeCommands(CE.timers[name],unpack(Timers[name].args))
	end
end

---------------------------------------------
-- Proximity Checking
---------------------------------------------

local ProximityFuncs = addon:GetProximityFuncs() 

-- @param target Name/GUID of a unit
-- @param range Number of yards to check to see if player is in range of target.
-- 				 It must be a key in ProximityFuncs. Validator ensures this.
-- @return boolean 'true' if the player is in range of the target. 'false' otherwise.
local function CheckProximity(target,range)
	local unit = addon:GetUnitID(target)
	if not unit then return false end
	return ProximityFuncs[range](unit)
end

---------------------------------------------
-- Arrows
---------------------------------------------

local function StartArrow(name,stgs,...)
	local info = arrows[name]
	if not info then return end
	local unit = ReplaceTokens(info.unit,...)
	unit = addon:GetUnitID(unit)
	if not UnitExists(unit or "") then return end
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

local function SetRaidIcon(name,stgs,...)
	local info = raidicons[name]
	if not info then return end
	if info.type == "FRIENDLY" then
		local unit = ReplaceTokens(info.unit,...)
		unit = addon:GetUnitID(unit)
		if not UnitExists(unit or "") then return end
		RaidIcons:MarkFriendly(unit,stgs.icon,info.persist)
	end
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
		local stgs = EncDB[info]
		if stgs.enabled then StartAlert(info,stgs,...) end
		return true
	end,

	scheduletimer = function(info,...)
		local name,time = info[1],info[2]
		-- Rescheduled Timers are overwritten
		canceltimer(name)
		Timers[name] = new()
		Timers[name].handle = module:ScheduleTimer("FireTimer",time,name)
		local args = new()
		-- Only need the first 7 (up to spellID)
		args[1],args[2],args[3],args[4],args[5],args[6],args[7] = ...
		Timers[name].args = args
		return true
	end,

	canceltimer = canceltimer,

	resettimer = function(info,...) 
		addon:ResetTimer() 
		return true
	end,

	tracing = function(info,...)
		addon:SetTracing(info)
		return true
	end,

	proximitycheck = function(info,...)
		local target,range = info[1],info[2]
		target = ReplaceNums(target,...)
		target = ReplaceFuncs(target)
		return CheckProximity(target,range)
	end,

	raidicon = function(info,...)
		local stgs = EncDB[info].enabled
		if addon:IsPromoted() and stgs.enabled then
			SetRaidIcon(info,stgs,...)
		end
		return true
	end,

	arrow = function(info,...)
		local stgs = EncDB[info]
		if stgs.enabled then StartArrow(info,stgs,...) end
		return true
	end,

	removearrow = function(info,...)
		info = ReplaceTokens(info,...)
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

function module:HW_TRACER_ACQUIRED(event,unit)
	local name = UnitName(unit)
	--@debug@
	debug("HW_TRACER_ACQUIRED","name: %s",name)
	--@end-debug@
	if AcquiredBundles[name] and not UnitIsDead(unit) then
		self:InvokeCommands(AcquiredBundles[name])
	end
end

-- Each entry in 
function module:SetOnAcquired()
	wipe(AcquiredBundles)
	local onacquired = CE.onacquired
	if not onacquired then return end
	for name,bundle in pairs(onacquired) do
		AcquiredBundles[name] = bundle
	end
end

addon.RegisterCallback(module,"HW_TRACER_ACQUIRED")

---------------------------------------------
-- API
---------------------------------------------

function module:OnSet(_,data)
	assert(type(data) == "table","Expected 'data' table as argument #1 in OnSet. Got '"..tostring(data).."'")
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

