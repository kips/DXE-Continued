local addon = DXE
local version = tonumber(("$Rev$"):match("%d+"))
addon.version = version > addon.version and version or addon.version

local MapDims = addon.Constants.MapDims
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
