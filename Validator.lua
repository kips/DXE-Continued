---------------------------------------------
-- Validates Encounter Data
-- Based off AceConfig's validation
---------------------------------------------

local addon = DXE

local ipairs,pairs = ipairs,pairs
local gmatch,match = string.gmatch,string.match
local assert,type,select = assert,type,select
local select,concat,wipe = select,table.concat,wipe

local Colors = addon.Media.Colors
local conditions = addon.Invoker:GetConditions()
local RepFuncs = addon.Invoker:GetRepFuncs()
local ProximityFuncs = addon:GetProximityFuncs()
local util = addon.util

local isstring = {["string"] = true, _ = "string"}
local isstringtable = {["string"] = true, ["table"] = true, _ = "string or table"}
local isstringtableboolean = {["string"] = true, ["table"] = true, ["boolean"] = true, _ = "string, table, boolean"}
local isnumber = {["number"] = true, _ = "number"}
local isboolean = {["boolean"] = true, _ = "boolean"}
local istable = {["table"] = true, _ = "table"}
local istablenumber = {["table"] = true, ["number"] = true, _ = "table or number"}
local isnumber = {["number"] = true, _ = "number"}
local isnumberstring = {["number"] = true, ["string"] = true, _ = "number or string"}
local opttablenumber = {["table"] = true, ["number"] = true, ["nil"] = true, _ = "table or number or nil"}
local optnumberstring = {["number"] = true, ["string"] = true, ["nil"] = true, _ = "number or string"}
local opttable = {["table"] = true, ["nil"] = true, _= "table or nil"}
local optstring = {["string"] = true, ["nil"] = true, _ = "string or nil"}
local optstringtable = {["string"] = true, ["table"] = true, ["nil"] = true, _ = "string or table"}
local optstringnumbertable = {["string"] = true, ["table"] = true, ["number"] = true, ["nil"] = true, _ = "string, number or table"}
local optnumber = {["number"] = true, ["nil"] = true, _ = "number or nil"}
local optboolean = {["boolean"] = true, ["nil"] = true, _ = "boolean or nil"}

local baseKeys = {
	version = optnumber,
	key = isstring,
	zone = optstring,
	name = isstring,
	title = optstring,
	onstart = opttable,
	onacquired = opttable,
	timers = opttable,
	userdata = opttable,
	events = opttable,
	alerts = opttable,
	arrows = opttable,
	raidicons = opttable,
	announces = opttable,
	onactivate = opttable,
	triggers = opttable,
	category = optstring,
}

local baseLineKeys = {
	expect = istable,
	quash = isstring,
	set = istable,
	alert = isstring,
	scheduletimer = istable,
	canceltimer = isstring,
	resettimer = isboolean,
	tracing = istable,
	proximitycheck = istable,
	raidicon = isstring,
	removeraidicon = isstring,
	arrow = isstring,
	removearrow = isstring,
	removeallarrows = isboolean,
	announce = isstring,
}

local alertBaseKeys = {
	varname = isstring,
	type = isstring,
	text = isstring,
	time = isnumberstring,
	throttle = optnumber,
	flashtime = optnumber,
	sound = optstring,
	color1 = optstring,
	color2 = optstring,
	flashscreen = optboolean,
	icon = optstring,
	counter = optboolean,
}

local alertTypeValues = {
	centerpopup = true,
	dropdown = true,
	simple = true,
}

local arrowBaseKeys = {
	varname = isstring,
	msg = isstring,
	persist = isnumber,
	unit = isstring,
	action = isstring,
	spell = isstring,
	sound = optstring,
	fixed = optboolean,
}

local arrowTypeValues = {
	TOWARD = true,
	AWAY = true,
}

local raidIconBaseKeys = {
	varname = isstring,
	type = isstring,
	persist = isnumber,
	unit = isstring,
	icon = isnumber,
	reset = optnumber,
	total = optnumber,
}

local raidIconTypeValues = {
	FRIENDLY = true,
	MULTIFRIENDLY = true,
	--ENEMY = true,
}

local announceBaseKeys = {
	varname = isstring,
	type = isstring,
	msg = isstring,
}

local announceTypeValues = {
	SAY = true
}

local baseTables = {
	triggers = {
		scan = optstringnumbertable,
		yell = optstringtable,
	},
	onactivate = {
		tracerstart = optboolean,
		tracerstop = optboolean,
		combatstop = optboolean,
		combatstart = optboolean,
		tracing = opttable,
		sortedtracing = opttable,
	},
}

local eventBaseKeys = {
	type = isstring,
	event = optstring,
	eventtype = optstring,
	spellid = opttablenumber,
	execute = istable,
}

local function err(msg, errlvl, ...)
	local work = {}
	for i=select("#",...),1,-1 do
		local key = (select(i,...))
		if type(key) == "number" then
			key = "["..key.."]"
		elseif i ~= select("#",...) then
			key = "."..key
		else
			key = "["..key.."]: data"
		end
		work[#work+1] = key
	end
	error("DXE:ValidateOptions() "..concat(work)..msg, errlvl+2)
end

local function validateIsArray(tbl,errlvl,...)
	errlvl = (errlvl or 0)+1
	if #tbl < 1 then
		err(": table should be an array - got an empty table",errlvl,...)
	end
	for k in pairs(tbl) do
		if type(k) ~= "number" then
			err(": all keys should be numbers - invalid array",errlvl,...)
		end
	end
end

local function validateVal(v, oktypes, errlvl, ...)
	errlvl = (errlvl or 0)+1
	local isok=oktypes[type(v)]
	if not isok then
		err(": expected a "..oktypes._..", got '"..tostring(v).."'", errlvl, ...)
	end
end

local function validateReplaceFuncs(data,text,errlvl,...)
	errlvl=(errlvl or 0)+1
	for rep in gmatch(text,"%b&&") do
		local func = match(rep,"&(.+)&")
		if func:find("|") then func = match(func,"^([^|]+)|(.+)") end
		if not RepFuncs[func] then
			err(": replace func does not exist, got '"..rep.."'",errlvl,...)
		end
	end
end

local function validateReplaceNums(data,text,errlvl,...)
	errlvl=(errlvl or 0)+1
	for var in gmatch(text,"%b##") do 
		local key = tonumber(match(var,"#(%d+)#"))
		if not key or key < 1 or key > 11 then
			err(": replace num is invalid. it should be [1,11] - got '"..var.."'",errlvl,...)
		end
	end
end

local function validateReplaceVars(data,text,errlvl,...)
	errlvl=(errlvl or 0)+1
	for var in gmatch(text,"%b<>") do 
		local key = match(var,"<(.+)>")
		if not data.userdata[key] then
			err(": replace var does not exist, got '"..var.."'",errlvl,...)
		end
	end
end

local function validateReplaces(data,text,errlvl,...)
	errlvl=(errlvl or 0)+1

	validateReplaceFuncs(data,text,errlvl,...)
	validateReplaceVars(data,text,errlvl,...)
	validateReplaceNums(data,text,errlvl,...)
end

local function validateTracing(tbl,errlvl,...)
	errlvl=(errlvl or 0)+1
	validateIsArray(tbl,errlvl,"tracing",...)
	if #tbl > 4 or #tbl == 0 then
		err(": not an array with 1 <= size <= 4",errlvl,"tracing",...)
	end
	for k,v in ipairs(tbl) do
		validateVal(v,isnumber,errlvl,"tracing",...)
	end
end

local function validateSortedTracing(tbl,errlvl,...)
	errlvl=(errlvl or 0)+1
	validateIsArray(tbl,errlvl,"sortedtracing",...)
	if #tbl == 0 then
		err(": got an empty array",errlvl,"sortedtracing",...)
	end
	for k,v in ipairs(tbl) do
		validateVal(v,isnumber,errlvl,"sortedtracing",...)
	end
end

local function validateCommandLine(data,type,info,errlvl,...)
	local oktype = baseLineKeys[type]
	if not oktype then
		err(": unknown command line type",errlvl,...)
	end
	validateVal(info,oktype,errlvl,type,...)
	if type == "expect" then
		validateIsArray(info,errlvl,type,...)
		if #info ~= 3 then
			err(": not an array of size 3",errlvl,type,...)
		end
		for _,str in ipairs(info) do
			validateVal(str,isstring,errlvl,type,...)
		end
		if not conditions[info[2]] then
			err(": unknown condition",errlvl,type,...)
		end
		validateReplaces(data,info[1],errlvl,type,...)
		validateReplaces(data,info[3],errlvl,type,...)
	elseif type == "set" then
		for var,value in pairs(info) do
			if not data.userdata or not data.userdata[var] then
				err(": setting a non-existent userdata variable '"..var.."'",errlvl,type,...)
			end
			if _G.type(value) == "string" then
				validateReplaces(data,value,errlvl,var,type,...)
			end
		end
	elseif type == "alert" or type == "quash" then
		if not data.alerts or not data.alerts[info] then
			err(": firing/quashing a non-existent alert '"..info.."'",errlvl,type,...)
		end
	elseif type == "scheduletimer" then
		validateIsArray(info,errlvl,"scheduletimer",...)
		if #info ~= 2 then
			err(": array is not size 2",errlvl,type,...)
		end
		local timer,time = info[1],info[2]
		validateVal(timer,isstring,errlvl,type,...)
		validateVal(time,isnumberstring,errlvl,type,...)
		if _G.type(time) == "string" then
			validateReplaces(data,time,errlvl,type,...)
		elseif time < 0 then
			err(": scheduling a timer < 0 '"..info[1].."'",errlvl,type,...)
		end
		if not data.timers or not data.timers[timer] then
			err(": scheduling a non-existent timer '"..info[1].."'",errlvl,type,...)
		end
	elseif type == "canceltimer" then
		if not data.timers or not data.timers[info] then
			err(": canceling a non-existent timer '"..info.."'",errlvl,type,...)
		end
	elseif type == "tracing" then
		validateTracing(info,errlvl,...)
	elseif type == "proximitycheck" then
		validateIsArray(info,errlvl,"proximitycheck",...)
		if #info ~= 2 then
			err(": array is not size 2",errlvl,type,...)
		end
		local target,range = info[1],info[2]
		validateVal(target,isstring,errlvl,type,...)
		validateVal(range,isnumber,errlvl,type,...)
		if not target:find("^#[1-7]#$") and not target:find("^&[^&]+&$") then
			err(": invalid target, has to be exactly of the form #[1-7]# or &func& - got '"..target.."'",errlvl,type,...)
		end
		if target:find("^&[^&]+&$") then
			validateReplaceFuncs(data,target,errlvl,type,...)
		end
		if not ProximityFuncs[range] then
			err(": invalid range - got '"..range.."'",errlvl,type,...)
		end
	elseif type == "arrow" then
		if not data.arrows or not data.arrows[info] then
			err(": starting/removing a non-existent arrow '"..info.."'",errlvl,type,...)
		end
	elseif type == "removearrow" then
		validateReplaces(data,info,errlvl,type,...)
	elseif type == "raidicon" then
		if not data.raidicons or not data.raidicons[info] then
			err(": starting a non-existent raid icon '"..info.."'",errlvl,type,...)
		end
	elseif type == "removeraidicon" then
		validateReplaces(data,info,errlvl,type,...)
	end
end

local function validateCommandList(data,list,errlvl,...)
	for k=1,#list,2 do
		validateVal(list[k],isstring,errlvl,k,...)
		validateVal(list[k+1],isstringtableboolean,errlvl,k+1,...)
		validateCommandLine(data,list[k],list[k+1],errlvl,k,...)
	end
end

local function validateCommandBundle(data,bundle,errlvl,...)
	errlvl=(errlvl or 0)+1
	validateIsArray(bundle,errlvl,...)
	for k,list in ipairs(bundle) do
		validateVal(list,istable,errlvl,k,...)
		validateIsArray(list,errlvl,k,...)
		if #list < 2 or #list % 2 == 1 then
			err(": command list size is < 2 or size is odd",errlvl,k,...)
		end
		validateCommandList(data,list,errlvl,k,...)
	end
end

local function validateAlert(data,info,errlvl,...)
	errlvl=(errlvl or 0)+1
	-- Consistency check
	for k in pairs(info) do
		if not alertBaseKeys[k] then
			err(": unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end

	for k,oktypes in pairs(alertBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if info[k] then
			-- check type
			if k == "type" and not alertTypeValues[info[k]] then
				err(": expected simple, dropdown, or centerpopup - got '"..info[k].."'",errlvl,k,...)
			-- check sounds
			elseif k == "sound" and not info[k]:find("ALERT%d+") then
				err(": unknown sound '"..info[k].."'",errlvl,k,...)
			-- check colors
			elseif (k == "color1" or k == "color2") and not Colors[info[k]] then
				err(": unknown color '"..info[k].."'",errlvl,k,...)
			-- check replaces
			elseif k == "time" or k == "text" then
				validateReplaces(data,info[k],errlvl,k,...)
			end
		end
	end

	-- color1 is not optional for centerpopups and dropdowns
	if (info.type == "centerpopup" or info.type == "dropdown") and type(info.color1) ~= "string" then
		err(": requires color1 to be set",errlvl,...)
	end
end

local function validateAlerts(data,alerts,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k,info in pairs(alerts) do
		validateVal(k,isstring,errlvl,...)
		validateAlert(data,info,errlvl,k,...)
	end
end

local function validateArrow(data,info,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k in pairs(info) do
		if not arrowBaseKeys[k] then
			err(": unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end
	for k,oktypes in pairs(arrowBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if info[k] then
			-- check type
			if k == "type" and not arrowTypeValues[info[k]] then
				err(": expected AWAY or TOWARD - got '"..info[k].."'",errlvl,k,...)
			elseif k == "unit" then
				validateReplaces(data,info[k],errlvl,k,...)
			elseif k == "sound" and not info[k]:find("ALERT%d+") then
				err(": unknown sound '"..info[k].."'",errlvl,k,...)
			end
		end
	end
end

local function validateArrows(data,arrows,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k,info in pairs(arrows) do
		validateVal(k,isstring,errlvl,...)
		validateArrow(data,info,errlvl,k,...)
	end
end

local function validateRaidIcon(data,info,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k in pairs(info) do
		if not raidIconBaseKeys[k] then
			err(": unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end
	for k,oktypes in pairs(raidIconBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if info[k] then
			-- check type
			if k == "type" and not raidIconTypeValues[info[k]] then
				err(": expected FRIENDLY or ENEMY - got '"..info[k].."'",errlvl,k,...)
			elseif k == "unit" then
				validateReplaces(data,info[k],errlvl,k,...)
			elseif k == "icon" and (info[k] > 8 or info[k] < 1)  then
				err(": expected icon to be [1-8] - got '"..info[k].."'",errlvl,k,...)
			end
		end
	end
end

local function validateRaidIcons(data,raidicons,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k,info in pairs(raidicons) do
		validateVal(k,isstring,errlvl,...)
		validateRaidIcon(data,info,errlvl,k,...)
	end
end

local function validateAnnounce(data,info,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k in pairs(info) do
		if not announceBaseKeys[k] then
			err(": unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end
	for k,oktypes in pairs(announceBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if info[k] then
			-- check type
			if k == "type" and not announceTypeValues[info[k]] then
				err(": expected SAY - got '"..info[k].."'",errlvl,k,...)
			end
		end
	end
end

local function validateAnnounces(data,announces,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k,info in pairs(announces) do
		validateVal(k,isstring,errlvl,...)
		validateAnnounce(data,info,errlvl,k,...)
	end
end

local function validateEvent(data,info,errlvl,...)
	for k in pairs(info) do
		if not eventBaseKeys[k] then
			err(": unknown parameter",errlvl,k,...)
		end
	end
	for k, oktypes in pairs(eventBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if k == "type" then
			if info.type == "event" and not info.event then
				err(": missing event key",errlvl,k,...)
			end
			if info.type == "combatevent" and not info.eventtype then
				err(": missing eventtype key",errlvl,k,...)
			end
		elseif k == "spellid" then
			if info.spellid and type(info.spellid) == "number" then
				local exists = GetSpellInfo(info.spellid)
				if not exists then
					err("["..info.spellid.."]: unknown spellid",errlvl,k,...)
				end
			elseif info.spellid and type(info.spellid) == "table" then
				validateIsArray(info.spellid,errlvl,"spellid",...)
				for i,spellid in ipairs(info.spellid) do
					local exists = GetSpellInfo(spellid)
					if not exists then
						err("["..spellid.."]: unknown spellid",errlvl,i,k,...)
					end
				end
			end
		elseif k == "execute" then
			validateCommandBundle(data,info.execute,errlvl,"execute",...)
		end
	end
end

local function validateEvents(data,events,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k,info in pairs(events) do
		validateVal(info,istable,errlvl,k,...)
		validateEvent(data,info,errlvl,k,...)
	end
end


local function validate(data,errlvl,...)
	errlvl=(errlvl or 0)+1
	-- Consistency check
	for k in pairs(data) do
		if not baseKeys[k] then
			err(": unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end
	-- Base keys
	for k,oktypes in pairs(baseKeys) do
		validateVal(data[k],oktypes,errlvl,k,...)
		if k == "onstart" and data[k] and util.tablesize(data[k]) > 0 then
			validateCommandBundle(data,data.onstart,errlvl,"onstart",...)
		elseif k == "onacquired" and data[k] and util.tablesize(data[k]) > 0 then
			for npcid,bundle in pairs(data[k]) do
				validateVal(npcid,isnumber,errlvl,npcid,"onacquired",...)
				validateCommandBundle(data,bundle,errlvl,npcid,"onacquired",...)
			end
		elseif k == "timers" and data.timers then
			for name,bundle in pairs(data.timers) do
				validateVal(bundle,istable,errlvl,name,"timers",...)
				validateCommandBundle(data,bundle,errlvl,name,"timers",...)
			end
		end
	end

	-- Base tables
	for tblName,tbl in pairs(baseTables) do
		if data[tblName] then
			for k,oktypes in pairs(tbl) do
				validateVal(data[tblName][k],oktypes,errlvl,k,tblName,...)
				if tblName == "onactivate" then
					if k == "tracing" and data.onactivate.tracing then
						validateTracing(data.onactivate.tracing,errlvl,tblName,...)
					elseif k == "sortedtracing" and data.onactivate.sortedtracing then
						validateSortedTracing(data.onactivate.sortedtracing,errlvl,tblName,...)
					end
					if data.onactivate.tracing and data.onactivate.sortedtracing then
						err(": cannot have tracing and sortedtracing at the same time",errlvl,tblName,...)
					end
				end
			end
			for k in pairs(data[tblName]) do
				if not tbl[k] then
					err(": unknown key - got '"..k.."'",errlvl,k,tblName,...)
				end
			end
		end
	end

	-- Alerts
	if data.alerts and util.tablesize(data.alerts) > 0 then
		validateAlerts(data,data.alerts,errlvl,"alerts",...)
	end

	-- Arrows
	if data.arrows and util.tablesize(data.arrows) > 0 then
		validateArrows(data,data.arrows,errlvl,"arrows",...)
	end

	-- Announces
	if data.announces and util.tablesize(data.announces) > 0 then
		validateAnnounces(data,data.announces,errlvl,"announces",...)
	end

	-- Raid Icons
	if data.raidicons and util.tablesize(data.raidicons) > 0 then
		validateRaidIcons(data,data.raidicons,errlvl,"raidicons",...)
	end

	-- Events
	if data.events and util.tablesize(data.events) > 0 then
		validateIsArray(data.events,errlvl,"events",...)
		validateEvents(data,data.events,errlvl,"events",...)
	end
end

function addon:ValidateData(data)
	errlvl=(errlvl or 0)+1
	local name = data.name or data.key or "Data"
	validate(data,errlvl,name)
end
