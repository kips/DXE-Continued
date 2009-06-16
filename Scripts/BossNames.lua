-- Parses LibBabble-Boss-3.0 for boss names

local L = {}

L["Aerial Command Unit"] = "Aerial Command Unit"
L["Algalon the Observer"] = "Algalon the Observer"
L["Ancient Conservator"] = "Ancient Conservator"
L["Ancient Rune Giant"] = "Ancient Rune Giant"
L["Ancient Water Spirit"] = "Ancient Water Spirit"
L["Anub'Rekhan"] = "Anub'Rekhan"
L["Archavon the Stone Watcher"] = "Archavon the Stone Watcher"
L["Auriaya"] = "Auriaya"
L["Baron Rivendare"] = "Baron Rivendare"
L["Brain of Yogg-Saron"] = "Brain of Yogg-Saron"
L["Constrictor Tentacle"] = "Constrictor Tentacle"
L["Corruptor Tentacle"] = "Corruptor Tentacle"
L["Crusher Tentacle"] = "Crusher Tentacle"
L["Dark Rune Commoner"] = "Dark Rune Commoner"
L["Dark Rune Guardian"] = "Dark Rune Guardian"
L["Dark Rune Sentinel"] = "Dark Rune Sentinel"
L["Dark Rune Thunderer"] = "Dark Rune Thunderer"
L["Death Knight Understudy"] = "Death Knight Understudy"
L["Detonating Lasher"] = "Detonating Lasher"
L["Emalon the Storm Watcher"] = "Emalon the Storm Watcher"
L["Eonar's Gift"] = "Eonar's Gift"
L["Feral Defender"] = "Feral Defender"
L["Feugen"] = "Feugen"
L["Flame Leviathan"] = "Flame Leviathan"
L["Freya"] = "Freya"
L["General Vezax"] = "General Vezax"
L["Gluth"] = "Gluth"
L["Gothik the Harvester"] = "Gothik the Harvester"
L["Grand Widow Faerlina"] = "Grand Widow Faerlina"
L["Grobbulus"] = "Grobbulus"
L["Guardian of Icecrown"] = "Guardian of Icecrown"
L["Guardian of Yogg-Saron"] = "Guardian of Yogg-Saron"
L["Heart of the Deconstructor"] = "Heart of the Deconstructor"
L["Heigan the Unclean"] = "Heigan the Unclean"
L["Hodir"] = "Hodir"
L["Ignis the Furnace Master"] = "Ignis the Furnace Master"
L["Instructor Razuvious"] = "Instructor Razuvious"
L["Iron Ring Guard"] = "Iron Ring Guard"
L["Jormungar Behemoth"] = "Jormungar Behemoth"
L["Kel'Thuzad"] = "Kel'Thuzad"
L["Kologarn"] = "Kologarn"
L["Lady Blaumeux"] = "Lady Blaumeux"
L["Left Arm"] = "Left Arm"
L["Leviathan Mk II"] = "Leviathan Mk II"
L["Loatheb"] = "Loatheb"
L["Maexxna"] = "Maexxna"
L["Malygos"] = "Malygos"
L["Mimiron"] = "Mimiron"
L["Nexus Lord"] = "Nexus Lord"
L["Noth the Plaguebringer"] = "Noth the Plaguebringer"
L["Patchwerk"] = "Patchwerk"
L["Plagued Champion"] = "Plagued Champion"
L["Plagued Guardian"] = "Plagued Guardian"
L["Power Spark"] = "Power Spark"
L["Razorscale"] = "Razorscale"
L["Right Arm"] = "Right Arm"
L["Runemaster Molgeim"] = "Runemaster Molgeim"
L["Runic Colossus"] = "Runic Colossus"
L["Sanctum Sentry"] = "Sanctum Sentry"
L["Sapphiron"] = "Sapphiron"
L["Sara"] = "Sara"
L["Saronite Animus"] = "Saronite Animus"
L["Saronite Vapor"] = "Saronite Vapor"
L["Sartharion"] = "Sartharion"
L["Scion of Eternity"] = "Scion of Eternity"
L["Shadron"] = "Shadron"
L["Sir Zeliek"] = "Sir Zeliek"
L["Snaplasher"] = "Snaplasher"
L["Soldier of the Frozen Wastes"] = "Soldier of the Frozen Wastes"
L["Soul Weaver"] = "Soul Weaver"
L["Stalagg"] = "Stalagg"
L["Steelbreaker"] = "Steelbreaker"
L["Stormcaller Brundir"] = "Stormcaller Brundir"
L["Storm Lasher"] = "Storm Lasher"
L["Tenebron"] = "Tenebron"
L["Thaddius"] = "Thaddius"
L["Thane Korth'azz"] = "Thane Korth'azz"
L["The Four Horsemen"] = "The Four Horsemen"
L["The Iron Council"] = "The Iron Council"
L["Thorim"] = "Thorim"
L["Unstoppable Abomination"] = "Unstoppable Abomination"
L["Vesperon"] = "Vesperon"
L["VX-001"] = "VX-001"
L["XT-002 Deconstructor"] = "XT-002 Deconstructor"
L["Yogg-Saron"] = "Yogg-Saron"

local bossFile = io.input("./LibBabble-Boss-3.0.lua","r")
local out = io.output("BossNames_output.lua","w")

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
