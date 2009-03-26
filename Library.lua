-------------------------
-- BIGCITY LIBRARY
-------------------------

local BCL = {}
_G.BCL = BCL
local ipairs,pairs=ipairs,pairs

-------------------------
-- FUNCTIONS
-------------------------

BCL.noop = function() end

-- Requires a ChatWindow named 'DXE Debug'
BCL.debug = function(...)
	local debugframe
	for i=1,NUM_CHAT_WINDOWS do
		local windowName = GetChatWindowInfo(i);
		if windowName == "DXE Debug" then
			debugframe = _G["ChatFrame"..i]
			break
		end
	end
	if debugframe then
		DXE:Print(debugframe,...)
	end
end

do
	local cache = {}
	setmetatable(cache,{__mode = "kv"})
	local newtable = function()
		local t = next(cache) or {}
		cache[t] = nil
		return t
	end

	local deltable = function(t)
		if type(t) ~= "table" then return end
		for k in pairs(t) do
			t[k] = nil
		end
		cache[t] = true
		return nil
	end

	BCL.newtable = newtable
	BCL.deltable = deltable
end

BCL.tablesize = function(t)
	local n = 0
	for _ in pairs(t) do n = n + 1 end
	return n
end

-------------------------
-- TABLES
-------------------------

BCL.icons = setmetatable({}, {__index =
	function(self, key)
		if not key then return end
		local value = nil
		if type(key) == "number" then value = select(3, GetSpellInfo(key)) end
		self[key] = value
		return value
	end
})
