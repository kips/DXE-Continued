local defaults = {
	profile = {8,7,6,5,4,3,2,1},
}

local addon = DXE
local L = addon.L

local wipe = table.wipe
local SetRaidTarget = SetRaidTarget

local module = addon:NewModule("RaidIcons","AceTimer-3.0")
addon.RaidIcons = module

local db,pfl
local units = {} -- unit -> handle
local cnt = {} -- multi-marking
local hdls = {}

function module:RefreshProfile() pfl = db.profile end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("RaidIcons", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
end

function module:OnDisable()
	self:RemoveAll()
end

function module:MarkFriendly(unit,icon,persist)
	if units[unit] then self:CancelTimer(units[unit],true) end
	SetRaidTarget(unit,pfl[icon])
	units[unit] = self:ScheduleTimer("RemoveIcon",persist,unit)
end

-- Actual icon is chosen by increasing icon parameter
function module:MultiMarkFriendly(var,unit,icon,persist,reset)
	local ix = cnt[var] or 0
	self:MarkFriendly(unit,icon + ix,persist)
	cnt[var] = ix + 1
	if not hdls[var] then
		hdls[var] = self:ScheduleTimer("ResetCount",reset,var)
	end
end

function module:ResetCount(var)
	cnt[var] = nil
	hdls[var] = nil
end

-- TODO: Implement
function module:MarkEnemy()

end

function module:RemoveIcon(unit)
	self:CancelTimer(units[unit],true)
	SetRaidTarget(unit,0)
	units[unit] = nil
end

function module:RemoveAll()
	for unit in pairs(units) do self:RemoveIcon(unit) end
	wipe(cnt)
	wipe(hdls)
end
