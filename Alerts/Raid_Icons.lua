local defaults = {
	profile = {8,7,6,5,4,3,2,1},
	--@debug@
	global = {
		debug = {
			MarkFriendly = false,
			RemoveIcon = false,
			MarkFriendlyUnsch1 = false,
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
local UnitGUID = UnitGUID
local pairs = pairs

local module = addon:NewModule("RaidIcons","AceTimer-3.0")
addon.RaidIcons = module

local db,pfl
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

-------------------------------------------
-- FRIENDLY MARKING
-------------------------------------------

do
	local units = {} -- unit -> handle
	local friendly_cnt = {} -- multi-marking
	local count_resets = {} -- resets

	local function ResetCount(var)
		--@debug@
		debug("ResetCount","var: %s friendly_cnt[var]: %s count_resets[var]: %s",var,friendly_cnt[var],count_resets[var])
		--@end-debug@
		friendly_cnt[var] = nil
		count_resets[var] = nil
	end

	local function RemoveIcon(unit)
		--@debug@
		debug("RemoveIcon","unit: %s",unit)
		--@end-debug@
		self:CancelTimer(units[unit],true)
		SetRaidTarget(unit,0)
		units[unit] = nil
	end

	---------------------------------
	-- API
	---------------------------------

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
		units[unit] = self:ScheduleTimer(RemoveIcon,persist,unit)
	end

	-- Actual icon is chosen by increasing icon parameter
	function module:MultiMarkFriendly(var,unit,icon,persist,reset,total)
		local ix = friendly_cnt[var] or 0
		-- maxed out
		if ix >= total then return end
		self:MarkFriendly(unit,icon + ix,persist)
		friendly_cnt[var] = ix + 1
		if not count_resets[var] then
			count_resets[var] = self:ScheduleTimer(ResetCount,reset,var)
		end
	end

	function module:RemoveAllFriendly()
		for unit in pairs(units) do RemoveIcon(unit) end
		wipe(friendly_cnt)
		wipe(count_resets)
	end
end

-------------------------------------------
-- ENEMY MARKING
-------------------------------------------

do
	local unit_to_unittarget = addon.Roster.unit_to_unittarget
	local DELAY = 0.1
	local enemy_cnt = {}
	local count_resets = {}
	local execs = {}   -- guid -> handle
	local cancels = {} -- guid -> handle
	local icons = {}   -- guid -> icon

	local function MarkGUID(guid,icon)
		for _,unit in pairs(unit_to_unittarget) do
			if UnitGUID(unit) == guid then
				SetRaidTarget(unit,pfl[icon])
				return true
			end
		end
	end

	local function CancelMark(guid)
		self:CancelTimer(cancels[guid],true)
		cancels[guid] = nil

		self:CancelTimer(execs[guid],true)
		execs[guid] = nil

		icons[guid] = nil
	end

	local function ExecuteMark(guid)
		local success = MarkGUID(guid,icons[guid])
		if success then CancelMark(guid) end
	end

	local function ResetCount(var)
		enemy_cnt[var]    = nil
		count_resets[var] = nil
	end

	---------------------------------
	-- API
	---------------------------------

	-- @param persist <number> number of seconds to attempt marking
	-- @param remove <boolean> whether or not to remove after persist
	function module:MarkEnemy(guid,icon,persist,remove)
		local success = MarkGUID(guid,icon)
		if not success then
			icons[guid] = icon
			execs[guid] = self:ScheduleRepatingTimer(ExecuteMark,DELAY,guid)
			cancels[guid] = self:ScheduleTimer(CancelMark,persist,guid)
		end

		if remove then
			-- TODO: implement
		end
	end

	function module:MultiMarkEnemy(var,guid,icon,persist,remove,reset,total)
		-- var keeps track of icon count
		local ix = enemy_cnt[var] or 0
		-- maxed out
		if ix >= total then return end
		self:MarkEnemy(guid,icon + ix,persist,remove)
		enemy_cnt[var] = ix + 1
		if not count_resets[var] then
			count_resets[var] = self:ScheduleTimer(ResetCount,reset,var)
		end
	end

	function module:RemoveAllEnemy()
		for guid in pairs(icons) do CancelMark(guid) end
		wipe(enemy_cnt)
		wipe(count_resets)
	end
end

-------------------------------------------
-- CLEANUP
-------------------------------------------

function module:RemoveAll()
	self:RemoveAllFriendly()
	self:RemoveAllEnemy()
end

-------------------------------------------
-- UTIL
-------------------------------------------

function module:HasIcon(unit,icon)
	return GetRaidTargetIndex(unit) == pfl[icon]
end
