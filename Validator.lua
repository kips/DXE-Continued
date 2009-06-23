---------------------------------------------
-- Validates Encounter Data
-- Based off AceConfig's validation
---------------------------------------------

local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version

local ipairs,pairs = ipairs,pairs
local gmatch,match = string.gmatch,string.match
local assert,type,select = assert,type,select
local select,concat,wipe = select,table.concat,wipe

local Sounds = DXE.Constants.Sounds
local Colors = DXE.Constants.Colors
local conditions = DXE.Invoker:GetConditions()
local RepFuncs = DXE.Invoker:GetRepFuncs()
local ProximityFuncs = DXE.Invoker:GetProximityFuncs()
local util = DXE.util

local isstring = {["string"] = true, _ = "string"}
local isstringtable = {["string"] = true, ["table"] = true, _ = "string or table"}
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
local optnumber = {["number"] = true, ["nil"] = true, _ = "number or nil"}
local optboolean = {["boolean"] = true, ["nil"] = true, _ = "boolean or nil"}

local baseKeys = {
	version = optnumberstring,
	key = isstring,
	zone = isstring,
	name = isstring,
	title = optstring,
	onstart = opttable,
	onacquired = opttable,
	timers = opttable,
	userdata = opttable,
	events = opttable,
	alerts = opttable,
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
	raidicon = istable,
}

local alertBaseKeys = {
	var = isstring,
	varname = isstring,
	type = isstring,
	text = isstring,
	time = isnumberstring,
	throttle = optnumber,
	flashtime = optnumber,
	sound = optstring,
	color1 = optstring,
	color2 = optstring,
}

local alertTypeValues = {
	centerpopup = true,
	dropdown = true,
	simple = true,
}


local baseTables = {
	triggers = {
		scan = optstringtable,
		yell = optstringtable,
	},
	onactivate = {
		autostart = optboolean,
		autostop = optboolean,
		entercombat = optboolean,
		leavecombat = optboolean,
		tracing = opttable,
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
		err(": table should be an array - invalid array",errlvl,...)
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
	for rep in gmatch(text,"%b&&") do
		local func = match(rep,"&(.+)&")
		if func:find("|") then func = match(func,"^([^|]+)|(.+)") end
		if not RepFuncs[func] then
			err(": replace func does not exist, got '"..rep.."'",errlvl,...)
		end
	end
end

local function validateReplaces(data,text,errlvl,...)
	errlvl=(errlvl or 0)+1

	validateReplaceFuncs(data,text,errlvl,...)

	for var in gmatch(text,"%b<>") do 
		local key = match(var,"<(.+)>")
		if not data.userdata[key] then
			err(": replace var does not exist, got '"..var.."'",errlvl,...)
		end
	end

	for var in gmatch(text,"%b##") do 
		local key = tonumber(match(var,"#(%d+)#"))
		if not key or key < 1 or key > 10 then
			err(": replace num is invalid. it should be [1,10] - got '"..var.."'",errlvl,...)
		end
	end
end

local function validateTracing(tbl,errlvl,...)
	errlvl=(errlvl or 0)+1
	validateIsArray(tbl,errlvl,"tracing",...)
	if #tbl > 4 or #tbl == 0 then
		err(": not an array with 1 <= size <= 4",errlvl,"tracing",...)
	end
	for k,v in ipairs(tbl) do
		validateVal(v,isstring,errlvl,"tracing",...)
	end
end

local function validateCommandLine(data,line,errlvl,...)
	local type,info = next(line)
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
		local var = next(info)
		if not data.userdata or not data.userdata[var] then
			err(": setting a non-existent userdata variable '"..var.."'",errlvl,type,...)
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
		validateVal(time,isnumber,errlvl,type,...)
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
	end
end

local function validateCommandList(data,list,errlvl,...)
	for k,line in ipairs(list) do
		validateVal(line,istable,errlvl,k,...)
		local size = util.tablesize(line)
		if size ~= 1 then
			err(": command line should only have one key",errlvl,k,...)
		end
		validateCommandLine(data,line,errlvl,k,...)
	end
end

local function validateCommandBundle(data,bundle,errlvl,...)
	errlvl=(errlvl or 0)+1
	validateIsArray(bundle,errlvl,...)
	for k,list in ipairs(bundle) do
		validateVal(list,istable,errlvl,k,...)
		validateIsArray(list,errlvl,k,...)
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
		-- TODO: Check replaces
		if info[k] then
			-- check type
			if k == "type" and not alertTypeValues[info[k]] then
				err(": expected simple, dropdown, or centerpopup - got '"..info[k].."'",errlvl,k,...)
			-- check sounds
			elseif k == "sound" and not Sounds[info[k]] then
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
end

local function validateAlerts(data,alerts,errlvl,...)
	errlvl=(errlvl or 0)+1
	for k,info in pairs(alerts) do
		validateVal(k,isstring,errlvl,...)
		validateAlert(data,info,errlvl,k,...)
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
			for name,bundle in pairs(data[k]) do
				validateVal(name,isstring,errlvl,name,"onacquired",...)
				validateCommandBundle(data,bundle,errlvl,name,"onacquired",...)
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

	-- Events
	if data.events and util.tablesize(data.events) > 0 then
		validateIsArray(data.events,errlvl,"events",...)
		validateEvents(data,data.events,errlvl,"events",...)
	end
end

function DXE:ValidateData(data)
	errlvl=(errlvl or 0)+1
	local name = data.name or data.key or "Data"
	validate(data,errlvl,name)
end
