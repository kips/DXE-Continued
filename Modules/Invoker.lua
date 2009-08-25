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
		removeallarrows	= [BOOLEAN]
]]

local addon = DXE
local L = addon.L

local GetTime = GetTime
local wipe = table.wipe
local type,next,select = type,next,select
local ipairs,pairs,unpack = ipairs,pairs,unpack
local tostring,tonumber = tostring,tonumber
local match,gmatch,gsub,find,split = string.match,string.gmatch,string.gsub,string.find,string.split
local UnitGUID, UnitName, UnitExists, UnitIsUnit = UnitGUID, UnitName, UnitExists, UnitIsUnit
local UnitBuff,UnitDebuff = UnitBuff,UnitDebuff

local name_to_unit = addon.Roster.name_to_unit
local EncDB,CE,alerts,raidicons,arrows,announces

-- Temp variable environment
local userdata = {}

-- Command line handlers
local handlers = {}

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

--@debu@
local debug

local debugDefaults = {
	-- Related to function names
	Alerts = false,
	REG_EVENT = false,
	["handlers.set"] = false,
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
	if not CE then return end
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
			hw:SetInfoBundle("",1)
			hw:ApplyNeutralColor()
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
	Alerts:QuashAll()
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
-- REPLACES
---------------------------------------------

local ReplaceTokens

do
	local NID = addon.NID

	local function tft()
		return HW[1].tracer:First() and HW[1].tracer:First().."target" or ""
	end

	-- IMPORTANT - Return values should all be strings
	local RepFuncs = {
		playerguid = function() return addon.PGUID end,
		playername = function() return addon.PNAME end,
		vehicleguid  = function() return UnitGUID("vehicle") or "" end,
		difficulty = function() return tostring(GetRaidDifficulty()) end,
		-- First health watcher
		tft = tft,
		tft_unitexists = function() return tostring(UnitExists(tft())) end,
		tft_isplayer = function() return tostring(UnitIsUnit(tft(),"player")) end,
		tft_unitname = function() return tostring(UnitName(tft())) end,
		--- Functions with passable arguments
		-- Get's an alert's timeleft
		timeleft = function(id,delta) return tostring(Alerts:GetTimeleft(id) + (tonumber(delta) or 0)) end,
		npcid = function(guid) return NID[guid] or "" end,
		playerdebuff = function(debuff) return tostring(not not UnitDebuff("player",debuff)) end,
		playerbuff = function(buff) return tostring(not not UnitBuff("player",buff)) end,
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
			func = RepFuncs[func]
			if not func then return "&"..str.."&" end
			return func(split("|",args))
		else
			local func = RepFuncs[str]
			if not func then return "&"..str.."&" end
			return func()
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
end

---------------------------------------------
-- CONDITIONS
-- Credits to PitBull4's debug for this idea
---------------------------------------------

do
	local ops = {}

	ops['=='] = function(a, b) return a == b end
	ops['~='] = function(a, b) return a ~= b end
	ops['find'] = function(a,b) return find(a,b) end

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

	local t = {}
	for k, v in pairs(ops) do t[#t+1] = k end
	for _, k in ipairs(t) do
		ops["not_" .. k] = function(a, b)
			return not ops[k](a, b)
		end
	end

	--@debug@
	function module:GetConditions()
		return ops
	end
	--@end-debug@

	-- @ADD TO HANDLERS
	handlers.expect = function(info)
		return ops[info[2]](ReplaceTokens(info[1]),ReplaceTokens(info[3]))
	end
end

---------------------------------------------
-- USERDATA
---------------------------------------------

do
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

	-- @ADD TO HANDLERS
	handlers.set = function(info)
		for k,v in pairs(info) do
			local flag = true
			if type(v) == "string" then
				-- Increment/Decrement support
				if find(v,"^INCR") then
					local delta = tonumber(match(v,"^INCR|(%d+)"))
					userdata[k] = userdata[k] + delta
					flag = false
				elseif find(v,"^DECR") then
					local delta = tonumber(match(v,"^DECR|(%d+)"))
					userdata[k] = userdata[k] - delta
					flag = false
				else
					v = ReplaceTokens(v)
				end
			end
			if flag then 
				--@debug@
				debug("handlers.set","var: <%s> before: %s after: %s",k,userdata[k],v)
				--@end-debug@
				userdata[k] = v 
			end
		end
		return true
	end
end

---------------------------------------------
-- ALERTS
---------------------------------------------

do
	local Throttles = {}

	function module:RemoveThrottles()
		wipe(Throttles)
	end

	-- @ADD TO HANDLERS
	handlers.alert = function(info)
		local stgs = EncDB[info]
		if stgs.enabled then
			local alertInfo = alerts[info]
			-- Sanity check
			if not alertInfo then return true end
			-- Throttling
			if alertInfo.throttle then
				-- Initialize to 0 if non-existant
				Throttles[info] = Throttles[info] or 0
				-- Check throttle
				local t = GetTime()
				if Throttles[info] + alertInfo.throttle < t then
					Throttles[info] = t
				else
					-- Failed throttle, exit out
					return
				end
			end
			-- Replace text
			local text = ReplaceTokens(alertInfo.text)
			-- Replace time
			local time = alertInfo.time
			if type(time) == "string" then
				time = tonumber(ReplaceTokens(time))
			end
			--@debug@
			debug("Alerts","id: %s text: %s time: %s flashtime: %s sound: %s color1: %s color2: %s",info,text,time,alertInfo.flashtime,stgs.sound,stgs.color1,stgs.color2)
			--@end-debug@
			-- Sanity check
			if not time or time < 0 then return end
			-- Pass in appropriate arguments
			if alertInfo.type == "dropdown" then
				Alerts:Dropdown(info,text,time,alertInfo.flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,alertInfo.icon)
			elseif alertInfo.type == "centerpopup" then
				Alerts:CenterPopup(info,text,time,alertInfo.flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,alertInfo.icon)
			elseif alertInfo.type == "simple" then
				Alerts:Simple(text,time,stgs.sound,stgs.color1,stgs.flashscreen,alertInfo.icon)
			end
		end
		return true
	end

	handlers.quash = function(info)
		Alerts:QuashByPattern(info)
		return true
	end
end

---------------------------------------------
-- SCHEDULING
---------------------------------------------

do
	local Timers = {}

	function module:RemoveAllTimers()
		for name in pairs(Timers) do handlers.canceltimer(name) end
		-- Just to be safe
		self:CancelAllTimers()
	end

	function module:FireTimer(name)
		-- Don't wipe Timers[name], it could be rescheduled
		self:InvokeCommands(CE.timers[name],unpack(Timers[name].args))
	end

	-- @ADD TO HANDLERS
	handlers.scheduletimer = function(info)
		local name,time = info[1],info[2]
		-- Rescheduled Timers are overwritten
		handlers.canceltimer(name)
		Timers[name] = new()
		Timers[name].handle = module:ScheduleTimer("FireTimer",time,name)
		local args = new()
		-- Only need the first 7 (up to spellID)
		args[1],args[2],args[3],args[4],args[5],args[6],args[7] = 
		tuple[1],tuple[2],tuple[3],tuple[4],tuple[5],tuple[6],tuple[7]

		Timers[name].args = args
		return true
	end

	-- @ADD TO HANDLERS
	handlers.canceltimer = function(info)
		if Timers[info] then
			module:CancelTimer(Timers[info].handle,true)
			Timers[info].args = del(Timers[info].args)
			Timers[info] = del(Timers[info])
		end
		return true
	end
end

---------------------------------------------
-- ENGAGE TIMER
---------------------------------------------

do
	-- @ADD TO HANDLERS
	handlers.resettimer = function(info)
		addon:ResetTimer() 
		return true
	end
end

---------------------------------------------
-- TRACING
---------------------------------------------

do
	-- @ADD TO HANDLERS
	handlers.tracing = function(info)
		addon:SetTracing(info)
		return true
	end
end

---------------------------------------------
-- PROXIMITY CHECKING
---------------------------------------------

do
	local ProximityFuncs = addon:GetProximityFuncs() 

	-- @ADD TO HANDLERS
	handlers.proximitycheck = function(info)
		local target,range = info[1],info[2]
		target = ReplaceTokens(target)
		return ProximityFuncs[range](target)
	end
end

---------------------------------------------
-- ARROWS
---------------------------------------------

do
	-- @ADD TO HANDLERS
	handlers.arrow = function(info)
		local stgs = EncDB[info]
		if stgs.enabled then 
			local arrowInfo = arrows[info]
			local unit = ReplaceTokens(arrowInfo.unit)
			if not UnitExists(unit) then return end
			Arrows:AddTarget(unit,arrowInfo.persist,arrowInfo.action,arrowInfo.msg,arrowInfo.spell,stgs.sound,arrowInfo.fixed)
		end
		return true
	end

	-- @ADD TO HANDLERS
	handlers.removearrow = function(info)
		info = ReplaceTokens(info)
		Arrows:RemoveTarget(info)
		return true
	end

	-- @ADD TO HANDLERS
	handlers.removeallarrows = function(info)
		Arrows:RemoveAll()
		return true
	end
end

---------------------------------------------
-- RAID ICONS
---------------------------------------------

do
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

	-- @ADD TO HANDLERS
	handlers.raidicon = function(info)
		local stgs = EncDB[info]
		if addon:IsPromoted() and stgs.enabled then
			local raidInfo = raidicons[info]
			if not raidInfo then return end
			if raidInfo.type == "FRIENDLY" then
				local unit = ReplaceTokens(raidInfo.unit)
				if not UnitExists(unit) then return end
				RaidIcons:MarkFriendly(unit,stgs.icon,raidInfo.persist)
			end
		end
		return true
	end
end

---------------------------------------------
-- ANNOUNCES
---------------------------------------------

do
	local SendChatMessage = SendChatMessage

	-- @ADD TO HANDLERS
	handlers.announce = function(info)
		local stgs = EncDB[info]
		if stgs.enabled then
			local announceInfo = announces[info]
			if announceInfo.type == "SAY" then
				SendChatMessage(announceInfo.msg,"SAY")
			end
		end
		return true
	end
end

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
			local handler = handlers[type]
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
			-- Add execute list to the appropriate key
			RegEvents[event] = info.execute
		end
	end
end

function module:WipeEvents()
	wipe(RegEvents)
	for k,v in pairs(CombatEvents) do CombatEvents[k] = nil end
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
	announces = CE.announces
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
