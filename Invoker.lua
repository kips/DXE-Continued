--[[
	The invoker executes commands in encounter data

	Terminology:
	
	A command line is every sequential pair of values (1,2), (3,4), (5,6), etc. in a command list
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
		outproximitycheck	= {"<token>",[10,11,18, or 28]}
		raidicon 			= "<raidicon>"
		removeraidicon    = "<token>"
		arrow 				= "<arrow>"
		removearrow 		= "<token>"
		removeallarrows	= [BOOLEAN]
		invoke            = command bundle
		defeat            = [BOOLEAN]
		insert            = {"<userdata>", value},
		wipe              = "<userdata>"
]]

local addon = DXE
local L = addon.L
local NID = addon.NID
local SN = addon.SN

local GetTime = GetTime
local wipe = table.wipe
local type,next,select = type,next,select
local ipairs,pairs,unpack = ipairs,pairs,unpack
local tostring,tonumber = tostring,tonumber
local match,gmatch,gsub,find,split = string.match,string.gmatch,string.gsub,string.find,string.split
local UnitGUID, UnitName, UnitExists, UnitIsUnit = UnitGUID, UnitName, UnitExists, UnitIsUnit
local UnitBuff,UnitDebuff = UnitBuff,UnitDebuff

local name_to_unit = addon.Roster.name_to_unit
local pfl,key,CE,alerts,raidicons,arrows,announces

local function RefreshProfile(db) pfl = db.profile end
addon:AddToRefreshProfile(RefreshProfile)

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
-- command bundles executed upon events
local event_to_bundle = {}
local eventtype_to_bundle = {}
local bundle_to_filter = {}

--@debug@
local debug

local debugDefaults = {
	-- Related to function names
	Alerts = false,
	REG_EVENT = false,
	["handlers.set"] = false,
	replace_funcs = false,
	insert = false,
	wipe = false,
	wipe_container = false,
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

local function SetTuple(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11)
	-- TODO: add or "nil" to each line before Cataclysm; it would break compatability if added now
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
	tuple['11'] = a11
end

---------------------------------------------
-- CONTROLS
---------------------------------------------

function module:OnStart(_,...)
	if not CE then return end
	if next(eventtype_to_bundle) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","COMBAT_EVENT")
	end
	for event in pairs(event_to_bundle) do
		self:RegisterEvent(event,"REG_EVENT")
	end
	addon:SetTracing(CE.onactivate.tracing)
	-- Reset colors if not acquired
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and not hw.tracer:First() then
			hw:SetInfoBundle("",1,1)
			hw:ApplyNeutralColor()
		end
	end
	if CE.onstart then
		self:InvokeCommands(CE.onstart,...)
	end
end

function module:OnStop()
	if not CE then return end
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	for event in pairs(event_to_bundle) do
		self:UnregisterEvent(event)
	end
	self:ResetUserData()
	Alerts:QuashByPattern("^invoker")
	Arrows:RemoveAll()
	RaidIcons:RemoveAll()
	self:RemoveAllTimers()
	self:ResetAlertData()
end

---------------------------------------------
-- REPLACES
---------------------------------------------

local ReplaceTokens

do
	local function tft()
		return HW[1].tracer:First() and HW[1].tracer:First().."target" or ""
	end

	local RepFuncs = {
		playerguid = function() return addon.PGUID end,
		playername = function() return addon.PNAME end,
		vehicleguid  = function() return UnitGUID("vehicle") or "" end,
		difficulty = function() return tostring(addon:GetRaidDifficulty()) end,
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
		debuffstacks = function(unit,debuff) local c = select(4,UnitDebuff(unit,debuff)) return tostring(c) end,
		buffstacks = function(unit,buff) local c = select(4,UnitBuff(unit,buff)) return tostring(c) end,
		hasicon = function(unit,icon) return tostring(RaidIcons:HasIcon(unit,icon)) end,
		closest = function(container) return addon:FindClosestUnit(userdata[container]) end,
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
			if not func then return end
			--@debug@
			debug("replace_funcs",format("func: %s ret: %s",str,func(split("|",args))))
			--@end-debug@
			return func(split("|",args))
		else
			local func = RepFuncs[str]
			if not func then return end
			--@debug@
			debug("replace_funcs",format("func: %s ret: %s",str,func()))
			--@end-debug@
			return func()
		end
	end

	-- Replaces special tokens with values
	-- IMPORTANT: replace_funcs goes last
	function ReplaceTokens(str)
		if type(str) ~= "string" then return str end
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
	local wipeins = {} -- var -> handles

	function module:ResetUserData()
		wipe(userdata)
		for k,handle in pairs(wipeins) do
			module:CancelTimer(handle)
			wipeins[k] = nil
		end
		if not CE.userdata then return end
		-- Copy defaults into userdata
		for k,v in pairs(CE.userdata) do
			if type(v) == "table" then
				-- Indexing for series
				userdata[k.."__index"] = 1
				if v.type == "series" then
					userdata[k] = v
				elseif v.type == "container" then
					userdata[k] = {}
				end
			else
				userdata[k] = v
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

	local function wipe_container(k)
		wipeins[k] = nil
		wipe(userdata[k])
		--@debug@
		debug("wipe_container","var: %s table values: %s",k,table.concat(userdata[k],", "))
		--@end-debug@
	end

	-- @ADD TO HANDLERS
	handlers.insert = function(info)
		local k,v = info[1],info[2]
		v = ReplaceTokens(v)
		local t = userdata[k]
		t[#t+1] = v

		local ct = CE.userdata[k]
		if ct.wipein and not wipeins[k] then
			wipeins[k] = module:ScheduleTimer(wipe_container,ct.wipein,k)
		end

		--@debug@
		debug("insert","var: %s value: %s table values: %s",k,v,table.concat(userdata[k],", "))
		--@end-debug@

		return true
	end

	-- @ADD TO HANDLERS
	handlers.wipe = function(info)
		wipe(userdata[info])
		--@debug@
		debug("wipe","var: %s table values: %s",info,table.concat(userdata[info],", "))
		--@end-debug@
		return true
	end
end

---------------------------------------------
-- ALERTS
---------------------------------------------

do
	local Throttles = {}
	local Counters = {}

	function module:ResetAlertData()
		wipe(Throttles)
		wipe(Counters)
	end

	-- @ADD TO HANDLERS
	handlers.alert = function(info)
		local stgs = pfl.Encounters[key][info]
		if stgs.enabled then
			local alertInfo = alerts[info]
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
					return true
				end
			end
			-- Replace text
			local text = ReplaceTokens(alertInfo.text)
			-- Tag
			local tag = ReplaceTokens(alertInfo.tag) or ""
			-- Counters
			if stgs.counter then
				local c = Counters[info] or 0
				c = c + 1
				text = text.." "..c
				Counters[info] = c
			end
			-- Replace time
			local time = alertInfo.time
			if type(time) == "string" then
				time = tonumber(ReplaceTokens(time))
			end
			--@debug@
			debug("Alerts","id: %s text: %s time: %s flashtime: %s sound: %s color1: %s color2: %s",info,text,time,alertInfo.flashtime,stgs.sound,stgs.color1,stgs.color2)
			--@end-debug@
			-- Sanity check
			if not time or time < 0 then return true end
			-- Pass in appropriate arguments
			if alertInfo.type == "dropdown" then
				Alerts:Dropdown("invoker"..info..tag,text,time,alertInfo.flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,alertInfo.icon)
			elseif alertInfo.type == "centerpopup" then
				Alerts:CenterPopup("invoker"..info..tag,text,time,alertInfo.flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,alertInfo.icon)
			elseif alertInfo.type == "simple" then
				Alerts:Simple(text,time,stgs.sound,stgs.color1,stgs.flashscreen,alertInfo.icon)
			elseif alertInfo.type == "absorb" then
				Alerts:Absorb("invoker"..info..tag,text,alertInfo.textformat,time,alertInfo.flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,alertInfo.icon,
				              alertInfo.values[tuple['7']],ReplaceTokens(alertInfo.npcid))
			end
		end
		return true
	end

	handlers.quash = function(info)
		local alertInfo = alerts[info]
		local tag = ReplaceTokens(alertInfo.tag) or ""
		Alerts:QuashByPattern("^invoker"..info..tag)
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

		-- time is a token
		if type(time) == "string" then
			time = tonumber(ReplaceTokens(time))
		end

		-- sanity check
		if not time or time < 0 then return true end

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

	handlers.outproximitycheck = function(info)
		local target,range = info[1],info[2]
		target = ReplaceTokens(target)
		return not ProximityFuncs[range](target)
	end
end

---------------------------------------------
-- ARROWS
---------------------------------------------

do
	-- @ADD TO HANDLERS
	handlers.arrow = function(info)
		local stgs = pfl.Encounters[key][info]
		if stgs.enabled then 
			local arrowInfo = arrows[info]
			local unit = ReplaceTokens(arrowInfo.unit)
			if UnitExists(unit) then 
				Arrows:AddTarget(unit,arrowInfo.persist,arrowInfo.action,arrowInfo.msg,arrowInfo.spell,stgs.sound,arrowInfo.fixed,
												 arrowInfo.xpos,arrowInfo.ypos)
			end
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

	local function is_guid(str)
		return type(str) == "string" and #str == 18 and str:find("%xx%x+")
	end

	-- @ADD TO HANDLERS
	handlers.raidicon = function(info)
		local stgs = pfl.Encounters[key][info]
		if addon:IsPromoted() and stgs.enabled then
			local raidInfo = raidicons[info]
			local unit = ReplaceTokens(raidInfo.unit)
			if UnitExists(unit) then 
				if raidInfo.type == "FRIENDLY" then
					RaidIcons:MarkFriendly(unit,raidInfo.icon,raidInfo.persist) 
				elseif raidInfo.type == "MULTIFRIENDLY" then
					RaidIcons:MultiMarkFriendly(info,unit,raidInfo.icon,raidInfo.persist,raidInfo.reset,raidInfo.total)
				end
			elseif is_guid(unit) then
				if raidInfo.type == "ENEMY" then
					RaidIcons:MarkEnemy(unit,raidInfo.icon,raidInfo.persist,raidInfo.remove)
				elseif raidInfo.type == "MULTIENEMY" then
					RaidIcons:MultiMarkEnemy(info,unit,raidInfo.icon,raidInfo.persist,raidInfo.remove,raidInfo.reset,raidInfo.total)
				end
			end
		end
		return true
	end

	-- @ADD TO HANDLERS
	handlers.removeraidicon = function(info)
		local unit = ReplaceTokens(info)
		if UnitExists(unit) then 
			RaidIcons:RemoveIcon(unit) 
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
		local stgs = pfl.Encounters[key][info]
		if stgs.enabled then
			local announceInfo = announces[info]
			if announceInfo.type == "SAY" then
				local msg = ReplaceTokens(announceInfo.msg)
				SendChatMessage(announceInfo.msg,"SAY")
			end
		end
		return true
	end
end

---------------------------------------------
-- INVOKING
---------------------------------------------

do
	local flag = true

	-- @param bundle Command bundles
	-- @param ... arguments passed with the event
	function module:InvokeCommands(bundle,...)
		if flag then SetTuple(...) end
		for _,list in ipairs(bundle) do
			for i=1,#list,2 do
				local type,info = list[i],list[i+1]
				local handler = handlers[type]
				-- Make sure handler exists in case of an unsupported command
				if handler and not handler(info) then break end
			end
		end
	end

	-- @ADD TO HANDLERS
	handlers.invoke = function(info)
		-- tuple has already been set
		flag = false; module:InvokeCommands(info); flag = true
		return true
	end
end

---------------------------------------------
-- EVENTS
---------------------------------------------

do
	local attribute_handles = {
		spellid = function(hash,...)
			return hash[select(7,...)]
		end,

		spellid2 = function(hash,...)
			return hash[select(10,...)]
		end,

		spellname = function(hash,...)
			return hash[select(8,...)]
		end,

		spellname2 = function(hash,...)
			return hash[select(11,...)]
		end,

		srcnpcid = function(hash,...)
			return hash[NID[...]]
		end,

		dstnpcid = function(hash,...)
			return hash[NID[select(4,...)]]
		end,
	}

	local transforms = {
		spellname = function(spellid) return SN[spellid] end,
		spellname2 = function(spellid) return SN[spellid] end,
	}

	function module:COMBAT_EVENT(event,timestamp,eventtype,...)
		local bundles = eventtype_to_bundle[eventtype]
		if bundles then
			for _,bundle in ipairs(bundles) do
				local filter = bundle_to_filter[bundle]
				local flag = true
				for attr,hash in pairs(filter) do
					-- all conditions have to pass for the bundle to fire
					if not attribute_handles[attr](hash,...) then
						flag = false
						break
					end
				end
				if flag then
					self:InvokeCommands(bundle,...)
				end
			end
		end
	end

	local function to_hash(work,trans)
		if type(work) ~= "table" then
			if trans then work = trans(work) end
			return {[work] = true}
		else
			-- work is an array
			local t = {}
			for k,v in pairs(work) do
				if trans then v = trans(v) end
				t[v] = true
			end
			return t
		end
	end

	-- filter structure = {
	-- 	[attribute] = {
	-- 		[value] = true,
	--			...
	--			[valueN] = true,
	--		},
	--    .
	--    .
	--    .
	-- 	[valueN] = {
	-- 		[value] = true,
	--			...
	--			[valueN] = true,
	--		},
	-- }

	local function create_filter(info)
		local filter = {}
		for attr in pairs(attribute_handles) do
			if info[attr] then
				filter[attr] = to_hash(info[attr],transforms[attr])
			end
		end
		return filter
	end

	local REG_ALIASES = {
		YELL = "CHAT_MSG_MONSTER_YELL",
		EMOTE = "CHAT_MSG_RAID_BOSS_EMOTE",
		WHISPER = "CHAT_MSG_RAID_BOSS_WHISPER",
	}

	function module:REG_EVENT(event,...)
		--@debug@
		debug("REG_EVENT",event,...)
		--@end-debug@
		-- Pass in command list and arguments
		self:InvokeCommands(event_to_bundle[event],...)
	end

	function module:AddEventData()
		if not CE.events then return end
		-- Iterate over events table
		for _,info in ipairs(CE.events) do
			if info.type == "combatevent" then
				local t = eventtype_to_bundle[info.eventtype]
				if not t then
					t = {}
					eventtype_to_bundle[info.eventtype] = t
				end
				t[#t+1] = info.execute

				bundle_to_filter[info.execute] = create_filter(info)
			elseif info.type == "event" then
				local event = REG_ALIASES[info.event] or info.event
				-- Register regular event
				-- Add execute list to the appropriate key
				event_to_bundle[event] = info.execute
			end
		end
	end
end

function module:WipeEvents()
	wipe(event_to_bundle)
	wipe(eventtype_to_bundle)
	wipe(bundle_to_filter)
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
	key = CE.key
	-- Wipe events
	self:WipeEvents()
	-- Register events
	self:AddEventData()
	-- Copy data.userdata to userdata upvalue
	self:ResetUserData()
	-- OnAcquired
	self:SetOnAcquired()
end
