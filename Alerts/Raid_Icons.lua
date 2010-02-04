local defaults = {
	profile = {8,7,6,5,4,3,2,1},
	--@debug@
	global = {
		debug = {
			MarkFriendly = false,
			RemoveIcon = false,
			MarkFriendlyUnsch1 = false,
			ResetCount = false,
		},
	},
	--@end-debug@
}

-- WORKS: SetRaidTarget(unit,0); SetRaidTarget(unit,[1,8]) 
-- BROKEN: SetRaidTarget(unit,[1,8]); SetRaidTarget(unit,0) 

local addon = DXE
local L = addon.L

local wipe = table.wipe
local SetRaidTarget = SetRaidTarget
local GetRaidTargetIndex = GetRaidTargetIndex
local pairs = pairs

local module = addon:NewModule("RaidIcons","AceTimer-3.0")
addon.RaidIcons = module

local db,pfl
local units = {} -- unit -> handle
local cnt = {} -- multi-marking
local rsts = {} -- resets

local debug

function module:RefreshProfile() pfl = db.profile end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("RaidIcons", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

	--@debug@
	debug = addon:CreateDebugger("RaidIcons",db.global,db.global.debug)
	--@end-debug@
end

function module:OnDisable()
	self:RemoveAll()
end

function module:MarkFriendly(unit,icon,persist)
	--@debug@
	debug("MarkFriendly","unit: %s",unit)
	--@end-debug@

	-- Unschedule unit's icon removal. The schedule is effectively reset.
	if units[unit] then 
		--@debug@
		debug("MarkFriendlyUnsch1","unit: %s",unit)
		--@end-debug@
		self:CancelTimer(units[unit],true) 
		units[unit] = nil
	end

	SetRaidTarget(unit,pfl[icon])
	units[unit] = self:ScheduleTimer("RemoveIcon",persist,unit)
end

-- Actual icon is chosen by increasing icon parameter
function module:MultiMarkFriendly(var,unit,icon,persist,reset,total)
	local ix = cnt[var] or 0
	-- maxed out
	if ix >= total then return end
	self:MarkFriendly(unit,icon + ix,persist)
	cnt[var] = ix + 1
	if not rsts[var] then
		rsts[var] = self:ScheduleTimer("ResetCount",reset,var)
	end
end

function module:ResetCount(var)
	--@debug@
	debug("ResetCount","var: %s cnt[var]: %s rsts[var]: %s",var,cnt[var],rsts[var])
	--@end-debug@
	cnt[var] = nil
	rsts[var] = nil
end

-- TODO: Implement
function module:MarkEnemy()

end

function module:RemoveIcon(unit)
	--@debug@
	debug("RemoveIcon","unit: %s",unit)
	--@end-debug@
	self:CancelTimer(units[unit],true)
	SetRaidTarget(unit,0)
	units[unit] = nil
end

function module:RemoveAll()
	for unit in pairs(units) do self:RemoveIcon(unit) end
	wipe(cnt)
	wipe(rsts)
end

function module:HasIcon(unit,icon)
	return GetRaidTargetIndex(unit) == pfl[icon]
end
