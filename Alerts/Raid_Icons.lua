local defaults = {
	profile = {8,7,6,5,4,3,2,1},
	--@debug@
	global = {
		debug = {
			MarkFriendly = false,
			RemoveIcon = false,
		},
	},
	--@end-debug@
}

local addon = DXE
local L = addon.L

local wipe = table.wipe
local SetRaidTarget = SetRaidTarget
local pairs = pairs

local module = addon:NewModule("RaidIcons","AceTimer-3.0")
addon.RaidIcons = module

local db,pfl
local used = {} -- icon -> unit
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

	-- Unschedule previous icon owners icon-removal timer
	if used[icon] and units[used[icon]] then 
		self:CancelTimer(units[used[icon]],true) 
		units[used[icon]] = nil
		used[icon] = nil
	end
	
	-- Unschedule unit's icon removal. The schedule is effectively reset.
	if units[unit] then 
		self:CancelTimer(units[unit],true) 
		units[unit] = nil
	end

	SetRaidTarget(unit,pfl[icon])
	units[unit] = self:ScheduleTimer("RemoveIcon",persist,unit)
	used[icon] = unit
end

-- Actual icon is chosen by increasing icon parameter
function module:MultiMarkFriendly(var,unit,icon,persist,reset)
	local ix = cnt[var] or 0
	self:MarkFriendly(unit,icon + ix,persist)
	cnt[var] = ix + 1
	if not rsts[var] then
		rsts[var] = self:ScheduleTimer("ResetCount",reset,var)
	end
end

function module:ResetCount(var)
	cnt[var] = nil
	rsts[var] = nil
end

-- TODO: Implement
function module:MarkEnemy()

end

function module:RemoveIcon(unit,b)
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
	wipe(used)
end
