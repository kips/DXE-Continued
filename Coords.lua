local addon = DXE
local version = tonumber(("$Rev$"):match("%d+"))
addon.version = version > addon.version and version or addon.version

local MapDims
local GetPlayerMapPosition = GetPlayerMapPosition
local SetMapToCurrentZone = SetMapToCurrentZone
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local GetMapInfo = GetMapInfo

function addon:GetPlayerMapPosition(unit)
	local x,y = GetPlayerMapPosition(unit)
	if x <= 0 and y <= 0 then
		SetMapToCurrentZone()
		x,y = GetPlayerMapPosition(unit)
	end
	return x,y
end

-- Computes the distance between the player and unit in game yards
-- Intended to be used when the player and unit are in the same map
-- Supported: Ulduar, Naxxramas, The Eye of Eternity, The Obsidian Sanctum
function addon:GetDistanceToUnit(unit,fx2,fy2)
	local x1,y1 = self:GetPlayerMapPosition("player")
	local x2,y2

	if fx2 and fy2 then
		x2,y2 = fx2,fy2
	else
		x2,y2 = self:GetPlayerMapPosition(unit)
	end

	local dims = MapDims[GetMapInfo()][GetCurrentMapDungeonLevel()]
	local dx = (x2 - x1) * dims.w
	local dy = (y2 - y1) * dims.h

	return (dx*dx + dy*dy)^(0.5),dx,dy -- dx*dx is faster than dx^2
end

-------------------------
-- MAP DIMENSIONS
-------------------------

MapDims= {
	-- Keyed by GetMapInfo()
	Ulduar = {
		-- Keyed by GetCurrentMapDungeonLevel()
		[0] = {w = 3064.9614761023, h = 2039.5413309668}, 	-- Expedition Base Camp
		[1] = {w = 624.19069622949, h = 415.89374357805}, 	-- Antechamber of Ulduar
		[2] = {w = 1238.37427179,   h = 823.90183235628}, 	-- Conservatory of Life
		[3] = {w = 848.38069183829, h = 564.6688835337}, 	-- Prison of Yogg-Saron
		[4] = {w = 1460.4694647684, h = 974.65312886234},  -- Spark of Imagination
	},
	Naxxramas = {
		[1] = {w = 1018.3655494957, h = 679.40523953718}, -- Construct
		[2] = {w = 1019.1310739251, h = 679.18864376555}, -- Arachnid
		[3] = {w = 1118.1083638787, h = 744.57895516418}, -- Military
		[4] = {w = 1117.0809918236, h = 745.97398439776}, -- Plague
		[5] = {w = 1927.3190541014, h = 1284.6530841959}, -- Entrance
		[6] = {w = 610.62737087301, h = 407.3875157986},  -- KT/Sapphiron
	},
	TheObsidianSanctum = {
		[0] = {w = 1081.6334214432, h = 721.79860069158},
	},
	TheEyeofEternity = {
		[1] = {w = 400.728405332355, h = 267.09113174487},
	},
	--@debug@
	Ironforge = {
		[0] = {w = 790, h = 527},
	},
	--@end-debug@
}