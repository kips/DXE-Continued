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
local match,gmatch,gsub = string.match,string.gmatch,string.gsub

local db,CE
local userdata = {}

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local Invoker = DXE:NewModule("Invoker","AceEvent-3.0","AceTimer-3.0")

function Invoker:OnEnable()
	self:RegisterMessage("DXE_StartEncounter","OnStart")
	self:RegisterMessage("DXE_StopEncounter","OnStop")
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
	for i,hw in ipairs(DXE.HW) do
		if hw:IsOpen() and not hw.tracer:First() then
			hw:SetInfoBundle(hw:GetName(),"",1,0,0,1)
		end
	end
end

function Invoker:OnStop()
	if not CE then return end
	if CE.onstop then
		self:InvokeCommands(CE.onstop)
	end
	-- Reset userdata
	self:ResetUserData()
	-- Quashes all alerts
	DXE.Alerts:QuashAllAlerts()
	-- Remove timers
	self:RemoveAllTimers()
	-- Remove throttles
	self:RemoveThrottles()
end


---------------------------------------------
-- CONDITIONS
-- Taken from Pitbull. Credits: ckknight
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
	return tostring(a):find(tostring(b))
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
	return DXE.HW[1].tracer:First() and DXE.HW[1].tracer:First().."target" or ""
end

-- IMPORTANT - Return values should all be strings
local pguid,pname
local RepFuncs = {
	playerguid = function() pguid = pguid or UnitGUID("player"); return pguid end,
	playername = function() pname = pname or UnitName("player"); return pname end,
	vehicleguid  = function() return UnitGUID("vehicle") or "" end,
	difficulty = function() return tostring(GetCurrentDungeonDifficulty()) end,
	-- First health watcher
	tft = tft,
	tft_unitexists = function() return tostring(UnitExists(tft())) end,
	tft_isplayer = function() return tostring(UnitIsUnit(tft(),"player")) end,
	tft_unitname = function() return tostring(UnitName(tft())) end,
}

-- Add funcs for the other health watchers
do
	for i=2,4 do
		local tft = function() return DXE.HW[i].tracer:First() and DXE.HW[i].tracer:First().."target" or "" end
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
			-- Series support
			if type(val) == "table" then
				-- Get the index value
				local key_index = key.."_index"
				local i = userdata[key_index]
				-- Sanity check to make sure we don't go out of bounds
				if i > #val then i = 1 end
				-- We are at the end of the series
				if i >= #val then
					-- Should we loop?
					if val.loop then
						-- Reset back to start
						userdata[key_index] = 1
					end
				else
					-- Not at the end so increment
					userdata[key_index] = userdata[key_index] + 1
				end
				-- Assign table value
				val = val[i]
			end
			-- Replace variable and value
			str = gsub(str,var,val)
		end
	end
	return str
end

-- TODO: Add possibility to pass arguments delimited by '|'
local function ReplaceFuncs(str)
	-- Enclosed in &&
	for rep in gmatch(str,"%b&&") do
		local func = RepFuncs[match(rep,"&(.+)&")]
		if func then
			local val = func()
			str = str:gsub(rep,val)
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
				str = str:gsub(index,val)
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
			userdata[k.."_index"] = 1
		end
	end
end


local function SetUserData(info,...)
	for k,v in pairs(info) do
		local flag = true
		if type(v) == "string" then
			-- Incr/Decr support
			if v:find("^INCR") then
				userdata[k] = userdata[k] + tonumber(v:match("^INCR|(%d+)"))
				flag = false
			elseif v:find("^DECR") then
				userdata[k] = userdata[k] - tonumber(v:match("^DECR|(%d+)"))
				flag = false
			else
				v = ReplaceTokens(v,...)
			end
		end
		if flag then userdata[k] = v end
	end
end

---------------------------------------------
-- ALERTS
---------------------------------------------
local throttles = {}

function Invoker:RemoveThrottles()
	wipe(throttles)
end

local GetTime = GetTime
local function StartAlert(alert_name,...)
	local info = CE.alerts[alert_name]
	-- Sanity check
	if not info then return end
	-- Throttling
	if info.throttle then
		-- Initialize to 0 if non-existant. Note: alert_name or data.var?
		throttles[alert_name] = throttles[alert_name] or 0
		-- Check throttle
		local t = GetTime()
		if throttles[alert_name] + info.throttle < t then
			throttles[alert_name] = t
		else
			-- Failed throttle so exit out
			return
		end
	end
	-- Replace text
	local text = ReplaceTokens(info.text,...)
	-- Replace time
	local time = tonumber(ReplaceVars(tostring(info.time)))
	-- Sanity check
	if not time then return end
	-- Pass in appropriate arguments
	if info.type == "dropdown" then
		DXE.Alerts:Dropdown(CE.key..info.var,text,time,info.flashtime,info.sound,info.color1,info.color2)
	elseif info.type == "centerpopup" then
		DXE.Alerts:CenterPopup(CE.key..info.var,text,time,info.flashtime,info.sound,info.color1,info.color2)
	elseif info.type == "simple" then
		DXE.Alerts:Simple(text,info.sound,time,info.color1)
	end
end

---------------------------------------------
-- TIMERS
---------------------------------------------
local timers = {}

function Invoker:RemoveAllTimers()
	-- Cancel all timers
	for name in pairs(timers) do
		Invoker:CancelTimer(timers[name].handle,true)
		DXE.delete(timers[name])
	end
	wipe(timers)
end

local function canceltimer(name)
	if timers[name] then
		Invoker:CancelTimer(timers[name].handle,true)
		timers[name] = DXE.delete(timers[name])
	end
	return true
end

function Invoker:FireTimer(name)
	if CE.timers[name] then
		self:InvokeCommands(CE.timers[name],unpack(timers[name].args))
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
		DXE.Alerts:QuashAlertsByPattern(info)
		return true
	end,

	set = function(info,...)
		SetUserData(info,...)
		return true
	end,

	alert = function(info,...)
		if db[CE.alerts[info].var] then StartAlert(info,...) end
		return true
	end,

	scheduletimer = function(info,...)
		local name,time = info[1],info[2]
		canceltimer(name)
		timers[name] = DXE.new()
		timers[name].handle = Invoker:ScheduleTimer("FireTimer",time,name)
		-- Easiest way to do this
		timers[name].args = {...}
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
	end
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

function Invoker:SetData(data)
	assert(type(data) == "table","Expected 'data' table as argument #1 in SetData. Got '"..tostring(data).."'")
	-- Set data upvalue
	CE = data
	-- Set db upvalue
	db = DXE.db.profile.Encounters[CE.key]
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
