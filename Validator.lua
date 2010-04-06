---------------------------------------------
-- Validates Encounter Data
-- Based off AceConfig's validation
---------------------------------------------

local addon = DXE

local ipairs,pairs = ipairs,pairs
local gmatch,match = string.gmatch,string.match
local assert,type,select = assert,type,select
local select,concat,wipe = select,table.concat,wipe
local Gtype = type

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
local isnumberstringtable = {["number"] = true, ["string"] = true, ["table"] = true, _ = "string, number or string"}
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
	windows = opttable,
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
	alert = isstringtable,
	scheduletimer = istable,
	canceltimer = isstring,
	resettimer = isboolean,
	tracing = istable,
	proximitycheck = istable,
	outproximitycheck = istable,
	raidicon = isstring,
	removeraidicon = isstring,
	arrow = isstring,
	removearrow = isstring,
	removeallarrows = isboolean,
	announce = isstring,
	invoke = istable,
	defeat = isboolean,
	wipe = isstring,
	insert = istable,
}

local alertBaseKeys = {
	varname = isstring,
	type = isstring,
	text = isstringtable,
	text2 = optstringtable,
	text3 = optstringtable,
	text4 = optstringtable,
	text5 = optstringtable,
	text6 = optstringtable,
	text7 = optstringtable,
	text8 = optstringtable,
	text9 = optstringtable,
	time = isnumberstringtable,
	time2 = optstringnumbertable,
	time3 = optstringnumbertable,
	time4 = optstringnumbertable,
	time5 = optstringnumbertable,
	time6 = optstringnumbertable,
	time7 = optstringnumbertable,
	time8 = optstringnumbertable,
	time9 = optstringnumbertable,
	time10n = optstringnumbertable,
	time10h = optstringnumbertable,
	time25n = optstringnumbertable,
	time25h = optstringnumbertable,
	throttle = optnumber,
	flashtime = optnumber,
	sound = optstring,
	color1 = optstring,
	color2 = optstring,
	flashscreen = optboolean,
	icon = optstring,
	counter = optboolean,
	-- absorb bar
	textformat = optstring,
	values = opttable,
	npcid = optnumberstring,
	tag = optstring,
}

local alertTypeValues = {
	centerpopup = true,
	dropdown = true,
	simple = true,
	absorb = true,
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
	xpos = optnumber,
	ypos = optnumber,
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
	remove = optboolean,
}

local raidIconTypeValues = {
	FRIENDLY = true,
	MULTIFRIENDLY = true,
	ENEMY = true,
	MULTIENEMY = true,
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
		unittracing = opttable,
		defeat = optstringnumbertable,
	},
}

local eventBaseKeys = {
	type = isstring,
	event = optstring,
	eventtype = optstring,
	spellid = opttablenumber,
	spellid2 = opttablenumber,
	srcnpcid = opttablenumber,
	dstnpcid = opttablenumber,
	spellname = opttablenumber,
	spellname2 = opttablenumber,
	execute = istable,
}

local eventtypes = {
	DAMAGE_SHIELD = true,
	DAMAGE_SHIELD_MISSED = true,
	DAMAGE_SPLIT = true,
	PARTY_KILL = true,
	RANGE_DAMAGE = true,
	RANGE_MISSED = true,
	SPELL_AURA_APPLIED = true,
	SPELL_AURA_APPLIED_DOSE = true,
	SPELL_AURA_REFRESH = true,
	SPELL_AURA_REMOVED = true,
	SPELL_AURA_REMOVED_DOSE = true,
	SPELL_CAST_FAILED = true,
	SPELL_CAST_START = true,
	SPELL_CAST_SUCCESS = true,
	SPELL_CREATE = true,
	SPELL_DAMAGE = true,
	SPELL_ENERGIZE = true,
	SPELL_EXTRA_ATTACKS = true,
	SPELL_HEAL = true,
	SPELL_INTERRUPT = true,
	SPELL_MISSED = true,
	SPELL_PERIODIC_DAMAGE = true,
	SPELL_PERIODIC_ENERGIZE = true,
	SPELL_PERIODIC_HEAL = true,
	SPELL_PERIODIC_MISSED = true,
	SPELL_RESURRECT = true,
	SPELL_SUMMON = true,
	SWING_DAMAGE = true,
	SWING_MISSED = true,
	SPELL_DISPEL = true,
	UNIT_DIED = true,
}

local function err(msg,errlvl,...)
	errlvl = errlvl + 1
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
	error("DXE:ValidateData() "..concat(work)..": "..msg, errlvl + 1)
end

local function validateIsArray(tbl,errlvl,...)
	errlvl = errlvl + 1
	if #tbl < 1 then
		err("table should be an array - got an empty table",errlvl,...)
	end
	for k in pairs(tbl) do
		if type(k) ~= "number" then
			err("all keys should be numbers - invalid array",errlvl,...)
		end
	end
end

local function validateVal(v, oktypes, errlvl, ...)
	errlvl = errlvl + 1
	local isok=oktypes[type(v)]
	if not isok then
		err("expected a "..oktypes._..", got '"..tostring(v).."'", errlvl, ...)
	end
end

local function checkParams(func,params,num,errlvl,...)
	errlvl = errlvl + 1
	if select('#',string.split("|",params)) ~= num then
		err("missing parameters",errlvl,func,...)
	end
	return string.split("|",params)
end

local function validateReplaceFuncs(data,text,errlvl,...)
	errlvl = errlvl + 1
	for rep in gmatch(text,"%b&&") do
		local func = match(rep,"&(.+)&")
		local params
		if func:find("|") then func,params = match(func,"^([^|]+)|(.+)") end
		if not RepFuncs[func] then
			err("replace func does not exist, got '"..rep.."'",errlvl,...)
		end

		-- params
		if func == "closest" then
			checkParams(func,params,1,errlvl,...)
			local ud = data.userdata
			if not (ud and ud[params] and type(ud[params]) == "table" and ud[params].type == "container") then
				err("using closest replace func on an invalid userdata variable '"..params.."'",errlvl,...)
			end
		elseif func == "timeleft" then
			-- skip param checking, delta is optional
			local id,delta = string.split("|",params)
			if not data.alerts[id] then
				err("using timeleft replace func on an invalid alert id '"..id.."'",errlvl,...)
			end
			if delta and not tonumber(delta) then
				err("invalid delta passed to timeleft replace func - got '"..delta.."'",errlvl,...)
			end
		elseif func == "npcid" then
			checkParams(func,params,1,errlvl,...)
		elseif func == "playerdebuff" then
			checkParams(func,params,1,errlvl,...)
		elseif func == "playerbuff" then
			checkParams(func,params,1,errlvl,...)
		elseif func == "debuffstacks" then
			checkParams(func,params,2,errlvl,...)
		elseif func == "buffstacks" then
			checkParams(func,params,2,errlvl,...)
		elseif func == "hasicon" then
			checkParams(func,params,2,errlvl,...)
		end
	end
end

local function validateReplaceNums(data,text,errlvl,...)
	errlvl = errlvl + 1
	for var in gmatch(text,"%b##") do 
		local key = tonumber(match(var,"#(%d+)#"))
		if not key or key < 1 or key > 11 then
			err("replace num is invalid. it should be [1,11] - got '"..var.."'",errlvl,...)
		end
	end
end

local function validateReplaceVars(data,text,errlvl,...)
	errlvl = errlvl + 1
	for var in gmatch(text,"%b<>") do 
		local key = match(var,"<(.+)>")
		if not data.userdata[key] then
			err("replace var does not exist, got '"..var.."'",errlvl,...)
		end
	end
end

local function unclosed_helper(text,errlvl,left,right,...)
	errlvl = errlvl + 1

	local work = text
	-- check for opening
	if work:find(left) then
		while work ~= "" do
			-- discard closure
			local rest = work:match(left..".-"..right.."(.*)")
			-- a match implies closure
			if rest then
				-- check the rest of the string
				if not rest:find(left) then break end
				work = rest
			else
				err("unclosed "..left..right.." replace, got '"..text.."'",errlvl,...)
			end
		end
	end
end

local function checkForUnclosedReplaces(data,text,errlvl,...)
	errlvl = errlvl + 1

	unclosed_helper(text,errlvl,'#','#',...)
	unclosed_helper(text,errlvl,'<','>',...)
	unclosed_helper(text,errlvl,'&','&',...)
end

local function validateReplaces(data,text,errlvl,...)
	if type(text) ~= "string" then return end
	errlvl = errlvl + 1

	checkForUnclosedReplaces(data,text,errlvl,...)

	validateReplaceFuncs(data,text,errlvl,...)
	validateReplaceVars(data,text,errlvl,...)
	validateReplaceNums(data,text,errlvl,...)
end

local function validateTracing(tbl,errlvl,...)
	errlvl = errlvl + 1
	if #tbl > 4 or #tbl == 0 then
		err("not an array with 1 <= size <= 4",errlvl,"tracing",...)
	end
	for k,v in ipairs(tbl) do
		validateVal(v,isnumber,errlvl,"tracing",...)
	end
	if tbl.powers then
		validateIsArray(tbl.powers,errlvl,"powers","tracing",...)
		for k,v in ipairs(tbl.powers) do
			validateVal(v,isboolean,errlvl,k,"powers","tracing",...)
		end
	end
end

local function validateSortedTracing(tbl,errlvl,...)
	errlvl = errlvl + 1
	validateIsArray(tbl,errlvl,"sortedtracing",...)
	if #tbl == 0 then
		err("got an empty array",errlvl,"sortedtracing",...)
	end
	for k,v in ipairs(tbl) do
		validateVal(v,isnumber,errlvl,"sortedtracing",...)
	end
end

local function validateUnitTracing(tbl,errlvl,...)
	errlvl = errlvl + 1
	validateIsArray(tbl,errlvl,"unittracing",...)
	if #tbl == 0 then
		err("got an empty array",errlvl,"unittracing",...)
	end
	for k,v in ipairs(tbl) do
		validateVal(v,isstring,errlvl,"unittracing",...)
	end
end

local validateCommandLine, validateCommandList, validateCommandBundle

function validateCommandLine(data,type,info,errlvl,...)
	errlvl = errlvl + 1
	local oktype = baseLineKeys[type]
	if not oktype then
		err("unknown command line type",errlvl,...)
	end
	validateVal(info,oktype,errlvl,type,...)
	if type == "expect" then
		validateIsArray(info,errlvl,type,...)
		if (#info + 1) % 4 ~= 0 then
			err("invalid expect array - got '"..#info.."' entries",errlvl,type,...)
		end
		for i,str in ipairs(info) do
			validateVal(str,isstring,errlvl,i,type,...)
		end
		-- check logical operators
		local nres = (#info + 1) / 4
		for i=2,nres do
			local ix = (i-1)*4
			local log_op = info[ix]
			if log_op ~= "AND" and log_op ~= "OR" then
				err("unknown logical operator - got '"..log_op.."'",errlvl,ix,type,...)
			end
		end
		-- check triplets
		for i=1,nres do
			-- left index of triplet
			local j = 4*i - 3
			local v1,op,v2 = info[j],info[j+1],info[j+2]
			if not conditions[op] then
				err("unknown condition - got '"..op.."'",errlvl,j+1,type,...)
			end
			validateReplaces(data,v1,errlvl,j,type,...)
			validateReplaces(data,v2,errlvl,j+2,type,...)
		end
	elseif type == "set" then
		for var,value in pairs(info) do
			local orig_var
			if var:match("_index$") then
				orig_var = var
				var = var:match("^(.*)_index$")
			end
			if not data.userdata or not data.userdata[var] then
				err("setting a non-existent userdata variable '"..(orig_var or var).."'",errlvl,type,...)
			end
			if Gtype(value) == "string" then
				validateReplaces(data,value,errlvl,var,type,...)
			elseif Gtype(value) == "table" then
				if value.type ~= "series" and value.type ~= "container" then
					err("invalid userdata table variable expected 'container' or 'series'",errlvl,type,...)
				end
				if value.type == "series" and #value == 0 then
					err("series requires at least one value in its array",errlvl,var,type,...)
				end
			end
		end
	elseif type == "alert" then
		if Gtype(info) == "string" then
			if not data.alerts or not data.alerts[info] then
				err("firing/quashing a non-existent alert '"..info.."'",errlvl,type,...)
			end
		elseif Gtype(info) == "table" then
			local var = info[1]
			if not data.alerts or not data.alerts[var] then
				err("firing/quashing a non-existent alert '"..var.."'",errlvl,1,type,...)
			end
			if not info.time and not info.text then
				err("missing a time or text index for '"..var.."'",errlvl,type,...)
			end
			if info.time then
				if info.time < 2 or info.time > 9 then
					err("time is out of scope - expected [2,9]",errlvl,"time",type,...)
				end
				if not data.alerts[var]["time"..info.time] then
					err("attempting to fire an alert with a non-existent time index - got '"..info.time.."'",errlvl,type,...)
				end
			end
			if info.text then
				if info.text < 2 or info.text > 9 then
					err("text is out of scope - expected [2,9]",errlvl,"time",type,...)
				end
				if not data.alerts[var]["text"..info.text] then
					err("attempting to fire an alert with a non-existent text index - got '"..info.text.."'",errlvl,type,...)
				end
			end
		end
	elseif type == "quash" then
		if not data.alerts or not data.alerts[info] then
			err("firing/quashing a non-existent alert '"..info.."'",errlvl,type,...)
		end
	elseif type == "scheduletimer" then
		validateIsArray(info,errlvl,"scheduletimer",...)
		if #info ~= 2 then
			err("array is not size 2",errlvl,type,...)
		end
		local timer,time = info[1],info[2]
		validateVal(timer,isstring,errlvl,type,...)
		validateVal(time,isnumberstring,errlvl,type,...)
		if Gtype(time) == "string" then
			validateReplaces(data,time,errlvl,type,...)
		elseif time < 0 then
			err("scheduling a timer < 0 '"..info[1].."'",errlvl,type,...)
		end
		if not data.timers or not data.timers[timer] then
			err("scheduling a non-existent timer '"..info[1].."'",errlvl,type,...)
		end
	elseif type == "canceltimer" then
		if not data.timers or not data.timers[info] then
			err("canceling a non-existent timer '"..info.."'",errlvl,type,...)
		end
	elseif type == "tracing" then
		validateTracing(info,errlvl,...)
	elseif type == "proximitycheck" or type == "outproximitycheck" then
		validateIsArray(info,errlvl,type,...)
		if #info ~= 2 then
			err("array is not size 2",errlvl,type,...)
		end
		local target,range = info[1],info[2]
		validateVal(target,isstring,errlvl,type,...)
		validateVal(range,isnumber,errlvl,type,...)
		if not target:find("^#[1-7]#$") and not target:find("^&[^&]+&$") then
			err("invalid target, has to be exactly of the form #[1-7]# or &func& - got '"..target.."'",errlvl,type,...)
		end
		if target:find("^&[^&]+&$") then
			validateReplaceFuncs(data,target,errlvl,type,...)
		end
		if not ProximityFuncs[range] then
			err("invalid range - got '"..range.."'",errlvl,type,...)
		end
	elseif type == "arrow" then
		if not data.arrows or not data.arrows[info] then
			err("starting/removing a non-existent arrow '"..info.."'",errlvl,type,...)
		end
	elseif type == "removearrow" then
		validateReplaces(data,info,errlvl,type,...)
	elseif type == "raidicon" then
		if not data.raidicons or not data.raidicons[info] then
			err("starting a non-existent raid icon '"..info.."'",errlvl,type,...)
		end
	elseif type == "removeraidicon" then
		validateReplaces(data,info,errlvl,type,...)
	elseif type == "invoke" then
		validateCommandBundle(data,info,errlvl,type,...)
	elseif type == "insert" then
		validateIsArray(info,errlvl,type,...)
		if #info ~= 2 then
			err("array is not size 2",errlvl,type,...)
		end
		local var,token = info[1],info[2]
		validateVal(var,isstring,errlvl,1,type,...)
		validateVal(token,isstring,errlvl,2,type,...)
		local ud = data.userdata
		if not (ud and ud[var] and Gtype(ud[var]) == "table" and ud[var].type == "container") then
			err("wiping an invalid userdata variable '"..var.."'",errlvl,1,type,...)
		end
		validateReplaces(data,token,errlvl,2,type,...)
	elseif type == "wipe" then
		validateVal(info,isstring,errlvl,type,...)
		local ud = data.userdata
		if not (ud and ud[info] and Gtype(ud[info]) == "table" and ud[info].type == "container") then
			err("wiping an invalid userdata variable '"..info.."'",errlvl,type,...)
		end
	end
end

function validateCommandList(data,list,errlvl,...)
	errlvl = errlvl + 1
	for k=1,#list,2 do
		validateVal(list[k],isstring,errlvl,k,...)
		validateVal(list[k+1],isstringtableboolean,errlvl,k+1,...)
		validateCommandLine(data,list[k],list[k+1],errlvl,k,...)
	end
end

function validateCommandBundle(data,bundle,errlvl,...)
	errlvl = errlvl + 1
	validateIsArray(bundle,errlvl,...)
	for k,list in ipairs(bundle) do
		validateVal(list,istable,errlvl,k,...)
		validateIsArray(list,errlvl,k,...)
		if #list < 2 or #list % 2 == 1 then
			err("command list size is < 2 or size is odd",errlvl,k,...)
		end
		validateCommandList(data,list,errlvl,k,...)
	end
end

local function validateAlert(data,info,errlvl,...)
	errlvl = errlvl + 1
	-- Consistency check
	for k in pairs(info) do
		if not alertBaseKeys[k] then
			err("unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end

	for k,oktypes in pairs(alertBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if info[k] then
			-- check type
			if k == "type" and not alertTypeValues[info[k]] then
				err("expected simple, dropdown, or centerpopup - got '"..info[k].."'",errlvl,k,...)
			-- check sounds
			elseif k == "sound" and not info[k]:find("ALERT%d+") then
				err("unknown sound '"..info[k].."'",errlvl,k,...)
			-- check colors
			elseif (k == "color1" or k == "color2") and not Colors[info[k]] then
				err("unknown color '"..info[k].."'",errlvl,k,...)
			-- check replaces
			elseif k == "npcid" or k == "spellid" or k == "tag" then
				validateReplaces(data,info[k],errlvl,k,...)
			elseif k:match("^text[2-9]?$") or k:match("^time[2-9]?$") or
					 k == "time10n" or k == "time10h" or k == "time25n" or k == "time25h" then
				local v = info[k]
				if type(v) == "string" then
					validateReplaces(data,info[k],errlvl,k,...)
				elseif type(v) == "table" then
					if v.type ~= "series" then
						err("invalid userdata table variable - expected 'type = series'",errlvl,k,...)
					end
					if #v == 0 then
						err("series requires at least one value in its array",errlvl,k,...)
					end
				end
			elseif k == "values" then
				for spellid, total in pairs(info[k]) do
					if type(spellid) ~= "number" then
						err("keys need to be valid spellids - got 'spellid'",errlvl, k, ...)
					end
					validateVal(total,isnumber,errlvl,spellid,k,...)
					local exists = GetSpellInfo(spellid)
					if not exists then
						err("["..spellid.."]: unknown spell identifier",errlvl,k,...)
					end
				end
			end
		end
	end

	-- color1 is not optional for centerpopups and dropdowns
	if (info.type == "centerpopup" or info.type == "dropdown") and type(info.color1) ~= "string" then
		err("requires color1 to be set",errlvl,...)
	end

	if info.type == "absorb" and (not info.npcid or not info.values) then
		err("absorb bars require npcid and values to be set",errlvl,...)
	end
end

local function validateAlerts(data,alerts,errlvl,...)
	errlvl = errlvl + 1
	for k,info in pairs(alerts) do
		validateVal(k,isstring,errlvl,...)
		validateAlert(data,info,errlvl,k,...)
	end
end

local function validateArrow(data,info,errlvl,...)
	errlvl = errlvl + 1
	for k in pairs(info) do
		if not arrowBaseKeys[k] then
			err("unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end
	for k,oktypes in pairs(arrowBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if info[k] then
			-- check type
			if k == "type" and not arrowTypeValues[info[k]] then
				err("expected AWAY or TOWARD - got '"..info[k].."'",errlvl,k,...)
			elseif k == "unit" then
				validateReplaces(data,info[k],errlvl,k,...)
			elseif k == "sound" and not info[k]:find("ALERT%d+") then
				err("unknown sound '"..info[k].."'",errlvl,k,...)
			end
		end
	end
end

local function validateArrows(data,arrows,errlvl,...)
	errlvl = errlvl + 1
	for k,info in pairs(arrows) do
		validateVal(k,isstring,errlvl,...)
		validateArrow(data,info,errlvl,k,...)
	end
end

local function validateRaidIcon(data,info,errlvl,...)
	errlvl = errlvl + 1
	for k in pairs(info) do
		if not raidIconBaseKeys[k] then
			err("unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end
	for k,oktypes in pairs(raidIconBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if info[k] then
			-- check type
			if k == "type" and not raidIconTypeValues[info[k]] then
				err("expected FRIENDLY or ENEMY - got '"..info[k].."'",errlvl,k,...)
			elseif k == "unit" then
				validateReplaces(data,info[k],errlvl,k,...)
			elseif k == "icon" and (info[k] > 8 or info[k] < 1)  then
				err("expected icon to be [1-8] - got '"..info[k].."'",errlvl,k,...)
			elseif k == "type" then
				if info[k] == "MULTIFRIENDLY" or info[k] == "MULTIENEMY" then
					if not info.reset then
						err("expected 'reset' to exist", errlvl,k,...)
					end
					if not info.total then
						err("expected 'total' to exist", errlvl,k,...)
					end
				end
			end
		end
	end
end

local function validateRaidIcons(data,raidicons,errlvl,...)
	errlvl = errlvl + 1
	for k,info in pairs(raidicons) do
		validateVal(k,isstring,errlvl,...)
		validateRaidIcon(data,info,errlvl,k,...)
	end
end

local function validateAnnounce(data,info,errlvl,...)
	errlvl = errlvl + 1
	for k in pairs(info) do
		if not announceBaseKeys[k] then
			err("unknown key '"..k.."'",errlvl,tostring(k),...)
		end
	end
	for k,oktypes in pairs(announceBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if info[k] then
			-- check type
			if k == "type" and not announceTypeValues[info[k]] then
				err("expected SAY - got '"..info[k].."'",errlvl,k,...)
			end
		end
	end
end

local function validateAnnounces(data,announces,errlvl,...)
	errlvl = errlvl + 1
	for k,info in pairs(announces) do
		validateVal(k,isstring,errlvl,...)
		validateAnnounce(data,info,errlvl,k,...)
	end
end

local function validateNpcid(data,info,errlvl,k,...)
	errlvl = errlvl + 1
	if info[k] and type(info[k]) == "number" then
		-- do nothing
	elseif info[k] and type(info[k]) == "table" then
		validateIsArray(info[k],errlvl,k,...)
		for i,npcid in ipairs(info[k]) do
			validateVal(npcid,isnumber,errlvl,i,k,...)
		end
	elseif info[k] then
		err("invalid npcid(s)",errlvl,k,...)
	end
end

local function validateSpellID(data,info,errlvl,k,...)
	errlvl = errlvl + 1
	if info[k] and type(info[k]) == "number" then
		local exists = GetSpellInfo(info[k])
		if not exists then
			err("["..info[k].."]: unknown spell identifier",errlvl,k,...)
		end
	elseif info[k] and type(info[k]) == "table" then
		validateIsArray(info[k],errlvl,k,...)
		for i,spellid in ipairs(info[k]) do
			local exists = GetSpellInfo(spellid)
			if not exists then
				err("["..spellid.."]: unknown spell identifier",errlvl,i,k,...)
			end
		end
	elseif info[k] then
		err("invalid spell identifier(s)",errlvl,k,...)
	end
end

local function validateUserData(data,info,errlvl,...)
	errlvl = errlvl + 1
	for var,value in pairs(info) do
		if Gtype(value) == "string" then
			validateReplaces(data,value,errlvl,...)
		elseif Gtype(value) == "table" then
			if value.type ~= "series" and value.type ~= "container" then
				err("invalid userdata table variable expected 'container' or 'series'",errlvl,"type",var,...)
			end
			if value.type == "container" then
				if value.wipein then
					validateVal(value.wipein,isnumber,errlvl,"wipein",var,...)
				end
			elseif value.type == "series" and #value == 0 then
				err("series requires at least one value in its array",errlvl,var,...)
			end
		end
	end
end

local function validateEvent(data,info,errlvl,...)
	errlvl = errlvl + 1
	for k in pairs(info) do
		if not eventBaseKeys[k] then
			err("unknown parameter",errlvl,k,...)
		end
	end
	for k, oktypes in pairs(eventBaseKeys) do
		validateVal(info[k],oktypes,errlvl,k,...)
		if k == "type" then
			if info.type == "event" and not info.event then
				err("missing event key",errlvl,k,...)
			end
			if info.type == "combatevent" and not info.eventtype then
				err("missing eventtype key",errlvl,k,...)
			end
			if info.eventtype and not eventtypes[info.eventtype] then
				err("invalid eventtype value - got '"..info.eventtype.."'",errlvl,"eventtype",...)
			end
		elseif k == "spellid" or k == "spellid2" then
			validateSpellID(data,info,errlvl,k,...)
		elseif k == "spellname" or k == "spellname2" then
			validateSpellID(data,info,errlvl,k,...)
		elseif k == "srcnpcid" or k == "dstnpcid" then
			validateNpcid(data,info,errlvl,k,...)
		elseif k == "execute" then
			validateCommandBundle(data,info.execute,errlvl,"execute",...)
		end
	end
end

local function validateEvents(data,events,errlvl,...)
	errlvl = errlvl + 1
	for k,info in pairs(events) do
		validateVal(info,istable,errlvl,k,...)
		validateEvent(data,info,errlvl,k,...)
	end
end


local function validate(data,errlvl,...)
	errlvl = errlvl + 1
	-- Consistency check
	for k in pairs(data) do
		if not baseKeys[k] then
			err("unknown key '"..k.."'",errlvl,tostring(k),...)
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
					elseif k == "unittracing" and data.onactivate.unittracing then
						validateUnitTracing(data.onactivate.unittracing,errlvl,tblName,...)
					end
					local onactivate = data.onactivate
					if (onactivate.tracing and onactivate.sortedtracing) 
						 or (onactivate.tracing and onactivate.unittracing) 
						 or (onactivate.sortedtracing and onactivate.unittracing) then
						err("cannot have tracing and/or sortedtracing and/or unittracing at the same time",errlvl,tblName,...)
					end
				end
			end
			for k in pairs(data[tblName]) do
				if not tbl[k] then
					err("unknown key - got '"..k.."'",errlvl,k,tblName,...)
				end
			end
		end
	end

	-- Userdata

	if data.userdata and util.tablesize(data.userdata) > 0 then
		validateUserData(data,data.userdata,errlvl,"userdata",...)
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
	local errlvl = 1
	local name = data.name or data.key or "Data"
	validate(data,errlvl,name)
end
