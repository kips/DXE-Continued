-----------------------------------------
-- DEBUGGING
-----------------------------------------

local DXE = _G.DXE

local _G,find,format,select,gsub = _G,string.find,string.format,select,string.gsub
local GetChatWindowInfo = GetChatWindowInfo
local LEFTOFVAR, RIGHTOFVAR = "|cff00ff00<|r|cffeda55f", "|r|cff00ff00>|r "

function DXE:AddDebugOptions(name,global)
	local tbl = {
		type = "group",
		name = name,
		get = function(info) return global.debug[info[#info]] end,
		set = function(info,var) global.debug[info[#info]] = var end,
		inline = true,
		args = {}
	}
	for var in pairs(global.debug) do
		tbl.args[var] = {
			name = var,
			type = "toggle",
			width = "full",
		}
	end
	self.options.args.debug.args[name] = tbl
end

local function ColorCode(str)
	str = gsub(str,"([^ ]-):","|cffffff00%1|r:") -- characters immediately before colons
	return str
end

local rep = string.rep
local formatStrings = setmetatable({},{
	__index = function(t,k)
		local s = rep("%s ",k)
		t[k] = s
		return s
	end,
})

local tostring = tostring
local function tupleToString(...)
	if select("#",...) > 0 then
		return tostring(select(1,...)),tupleToString(select(2,...))
	end
end

local function CreateDebugFunction(name,global,windowName)
	windowName = windowName or "DXE Debug"
	name = "|cff99ff33"..name.."|r"
	local prepend = setmetatable({},{
		__index = function(t,k)
			local s = name..LEFTOFVAR..k..RIGHTOFVAR
			t[k] = s
			return s
		end,
	})
	return function(var,str,...)
		if not global.debug[var] then return end
		local debugframe
		for i=1,NUM_CHAT_WINDOWS do
			local windowName = GetChatWindowInfo(i)
			if windowName == "DXE Debug" then
				debugframe = _G["ChatFrame"..i]
				break
			end
		end
		if debugframe then
			str = tostring(str)
			if find(str,"%%") then
				-- It's a format string
				local msg = format(str,tupleToString(...))
				msg = ColorCode(msg)
				debugframe:AddMessage(prepend[var]..msg)
			else
				local num = 1 + select("#",...)
				local msg = format(formatStrings[num],tupleToString(str,...))
				msg = ColorCode(msg)
				debugframe:AddMessage(prepend[var]..msg)
			end
		end
	end
end

function DXE:CreateDebugger(name,global,windowName)
	self:AddDebugOptions(name,global)
	return CreateDebugFunction(name,global,windowName)
end
