local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version
local L = DXE.L

local RaidIcons = DXE:NewModule("RaidIcons","AceTimer-3.0")
DXE.RaidIcons = RaidIcons

local units = {}

function RaidIcons:MarkFriendly(unit,icon,persist)
	if units[unit] then self:CancelTimer(units[unit],true) end
	SetRaidTarget(unit,icon)
	units[unit] = self:ScheduleTimer("RemoveIcon",persist,unit)
end

function RaidIcons:MarkEnemy()

end

function RaidIcons:RemoveIcon(unit)
	SetRaidTarget(unit,0)
	units[unit] = nil
end

function RaidIcons:RemoveAll()
	for unit,handle in pairs(units) do
		self:CancelTimer(handle,true)
		SetRaidTarget(unit,0)
	end
end
