-- Parses LibBabble-Zone-3.0 for boss names

local L = {}

L["Naxxramas"] = "Naxxramas"
L["The Eye of Eternity"] = "The Eye of Eternity"
L["The Obsidian Sanctum"] = "The Obsidian Sanctum"
L["Ulduar"] = "Ulduar"
L["Vault of Archavon"] = "Vault of Archavon"


local bossFile = io.input("./LibBabble-Zone-3.0.lua","r")
local out = io.output("Zones_output.lua","w")

local state = "OUT"
local match = 'elseif GAME_LOCALE == "(.+)" then'
for line in bossFile:lines() do
	if line:match(match) then
		local locale = line:match(match)
		out:write("-- ",locale,"\n")
		state = "IN"
	end

	if state == "IN" and line == "}" then
		state = "OUT"
		out:write("\n")
	end

	if state == "IN" then
		local englishName = line:match('%["(.+)"%] = ".+",') or line:match('(%w+) = ".+"')
		local localizedName = line:match('%[.+%] = "(.+)",') or line:match('.+ = "(.+)"')
		if L[englishName] then
			out:write(string.format('L[%q] = %q',englishName,localizedName),"\n")
		end
	end
end

out:close()
