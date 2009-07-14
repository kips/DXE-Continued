local addon = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
addon.version = version > addon.version and version or addon.version
local L = addon.L

local module = addon:NewModule("RaidIcons","AceTimer-3.0")
addon.RaidIcons = module

function module:OnDisable()
	self:RemoveAll()
end

-- unit -> handle
local units = {}
-- <icon number> -> unit
local used = {}

-- If raid icon is in use, cancel timer
-- Unit already has a raid icon. 
-- 	Case 1: Icon was not set by addon, save it to be replaced after the persist time
-- 	Case 2: Icon was set by addon, cancel timer

function module:MarkFriendly(unit,icon,persist)
	if units[unit] then self:CancelTimer(units[unit],true) end
	SetRaidTarget(unit,icon)
	units[unit] = self:ScheduleTimer("RemoveIcon",persist,unit)
end

-- TODO: Implement
function module:MarkEnemy()

end

function module:RemoveIcon(unit)
	SetRaidTarget(unit,0)
	units[unit] = nil
end

function module:RemoveAll()
	for unit,handle in pairs(units) do
		self:CancelTimer(handle,true)
		SetRaidTarget(unit,0)
		units[unit] = nil
	end
end


