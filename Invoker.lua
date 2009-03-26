local BCL = BCL
local DXE = DXE

local type,next,select = type,next,select
local ipairs,pairs,unpack = ipairs,pairs,unpack
local tostring,tonumber = tostring,tonumber
local match,gmatch,gsub = string.match,string.gmatch,string.gsub

local db,data
local userdata = {}

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local Invoker = {}
LibStub("AceEvent-3.0"):Embed(Invoker)
LibStub("AceTimer-3.0"):Embed(Invoker)


---------------------------------------------
-- CONTROLS
---------------------------------------------

function Invoker:OnStart()
	if data.onstart then
		self:InvokeCommands(data.onstart)
	end
end

function Invoker:OnStop()
	if not data then return end
	if data.onstop then
		self:InvokeCommands(data.onstop)
	end
	-- Reset userdata
	self:ResetUserData()
	-- Quashes all alerts
	DXE.Alerts:QuashAlertsByPattern("")
	-- Remove timers
	self:RemoveAllTimers()
	-- Remove throttles
	self:RemoveThrottles()
end

---------------------------------------------
-- MESSAGES
---------------------------------------------

Invoker:RegisterMessage("DXE_StartEncounter","OnStart")
Invoker:RegisterMessage("DXE_StopEncounter","OnStop")

---------------------------------------------
-- CONDITIONS
---------------------------------------------

local conditions = {}

conditions['=='] = function(alpha, bravo)
	return alpha == bravo
end
conditions['~='] = function(alpha, bravo)
	return alpha ~= bravo
end
conditions['>'] = function(alpha, bravo)
	return type(alpha) == type(bravo) and alpha > bravo
end
conditions['>='] = function(alpha, bravo)
	return type(alpha) == type(bravo) and alpha >= bravo
end
conditions['<'] = function(alpha, bravo)
	return type(alpha) == type(bravo) and alpha < bravo
end
conditions['<='] = function(alpha, bravo)
	return type(alpha) == type(bravo) and alpha <= bravo
end

conditions['find'] = function(alpha,bravo)
	return tostring(alpha):find(tostring(bravo))
end

-- @usage {expect = {<guid>,"guid",<expected npc id>}
conditions['npcid'] = function(alpha,bravo)
	bravo = tonumber(bravo)
	alpha = tonumber(alpha:sub(-12,-7),16)
	return alpha == bravo
end

do
	local t = {}
	for k, v in pairs(conditions) do
		t[#t+1] = k
	end
	for _, k in ipairs(t) do
		conditions["not_" .. k] = function(alpha, bravo)
			return not conditions[k](alpha, bravo)
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

local function expect(alpha, condition, bravo)
	return conditions[condition](alpha,bravo)
end

local function tft()
	return DXE.Tracer:First() and DXE.Tracer:First().."target" or ""
end

-- IMPORTANT - Return values should all be strings
local RepFuncs = {
	playerguid = function() return UnitGUID("player") end,
	playername = function() return UnitName("player") end,
	vehicleguid  = function() return UnitGUID("vehicle") or "" end,
	difficulty = function() return tostring(GetCurrentDungeonDifficulty()) end,
	tft = tft,
	tft_unitexists = function() return tostring(UnitExists(tft())) end,
	tft_isplayer = function() return tostring(UnitIsUnit(tft(),"player")) end,
	tft_unitname = function() return tostring(UnitName(tft())) end,
}

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
	if not data.userdata then return end
	-- Copy defaults into userdata
	for k,v in pairs(data.userdata) do
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

local function StartAlert(alert_name,...)
	local info = data.alerts[alert_name]
	-- Sanity check
	if not info then return end
	-- Throttling
	if info.throttle then
		-- Initialize to 0 if non-existant. Note: alert_name or data.var?
		throttles[alert_name] = throttles[alert_name] or 0
		-- Check throttle
		if throttles[alert_name] + info.throttle < GetTime() then
			throttles[alert_name] = GetTime()
		-- Failed throttle so exit out
		else
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
		DXE.Alerts:Dropdown(data.key..info.var,text,time,info.flashtime,info.sound,info.color1,info.color2)
	elseif info.type == "centerpopup" then
		DXE.Alerts:CenterPopup(data.key..info.var,text,time,info.flashtime,info.sound,info.color1,info.color2)
	elseif info.type == "simple" then
		DXE.Alerts:Simple(text,info.sound,time)
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
		BCL.deltable(timers[name])
	end
	wipe(timers)
end

local function canceltimer(name,nodel)
	if timers[name] then
		Invoker:CancelTimer(timers[name].handle,true)
		timers[name] = BCL.deltable(timers[name])
	end
	return true
end

function Invoker:FireTimer(name)
	if data.timers[name] then
		self:InvokeCommands(data.timers[name],unpack(timers[name].args))
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
		if db[data.alerts[info].var] then StartAlert(info,...) end
		return true
	end,

	scheduletimer = function(info,...)
		local name,time = info[1],info[2]
		canceltimer(name)
		timers[name] = BCL.newtable()
		timers[name].handle = Invoker:ScheduleTimer("FireTimer",time,name)
		-- Easiest way to do this
		timers[name].args = {...}
		return true
	end,

	canceltimer = canceltimer,
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

function Invoker:RegisterEvents()
	if not data.events then return end
	-- Iterate over events table
	for _,info in ipairs(data.events) do
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
			-- Register regular event
			self:RegisterEvent(info.event,"REG_EVENT")
			-- Add execute list to the appropriate key
			RegEvents[info.event] = info.execute
		end
	end
end

function Invoker:WipeEvents()
	wipe(RegEvents)
	wipe(CombatEvents)
	self:UnregisterAllEvents()
end

---------------------------------------------
-- API
---------------------------------------------

function Invoker:SetData(encData)
	assert(type(encData) == "table","Expected encData table as argument #1 in SetData. Got "..tostring(encData).." as argument")
	-- Set data upvalue
	data = encData
	-- Set db upvalue
	db = DXE.db.profile.Encounters[data.key]
	-- Wipe events
	self:WipeEvents()
	-- Register events
	self:RegisterEvents()
	-- Copy data.userdata to userdata upvalue
	self:ResetUserData()
end

DXE.Invoker = Invoker
