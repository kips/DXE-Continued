local defaults = {
	profile = {8,7,6,5,4,3,2,1},
	--@debug@
	global = {
		debug = {
			MarkGUID = false,
			MarkEnemy = false,
			MultiMarkEnemy = false,
			CancelMark = false,
			ResetCount = false,
			RemovePlayerIcon = false,
			RemoveSingleIcon = false,
			RemoveMultipleIcons = false,
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
local ipairs,pairs = ipairs,pairs

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
	local units = {}        -- unit -> handle
	local friendly_cnt = {} -- var  -> count
	local count_resets = {} -- var  -> handle

	local function ResetCount(var)
		friendly_cnt[var] = nil
		count_resets[var] = nil
	end

	---------------------------------
	-- API
	---------------------------------

	function module:RemoveIcon(unit)
		module:CancelTimer(units[unit],true)
		SetRaidTarget(unit,0)
		units[unit] = nil
	end

	function module:MarkFriendly(unit,icon,persist)
		-- Unschedule unit's icon removal. The schedule is effectively reset.
		if units[unit] then 
			self:CancelTimer(units[unit],true) 
			units[unit] = nil
		end

		SetRaidTarget(unit,pfl[icon])
		units[unit] = self:ScheduleTimer("RemoveIcon",persist,unit)
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
		for unit in pairs(units) do self:RemoveIcon(unit) end
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
	local enemy_cnt = {}      -- var  -> count
	local count_resets = {}   -- var  -> handle
	local execs = {}          -- guid -> handle
	local cancels = {}        -- guid -> handle
	local icons = {}          -- guid -> icon
	local used_icons = {}     -- var  -> {icons}
	local removes = {}        -- var  -> handle

	local function MarkGUID(guid,icon)
		for _,unit in pairs(unit_to_unittarget) do
			if UnitGUID(unit) == guid then
				--@debug@
				debug("MarkGUID","guid: %s icon: %s",guid,icon)
				--@end-debug@
				SetRaidTarget(unit,pfl[icon])
				return true
			end
		end
	end

	local function CancelMark(guid)
		--@debug@
		debug("CancelMark","guid: %s",guid)
		--@end-debug@

		module:CancelTimer(cancels[guid],true)
		cancels[guid] = nil

		module:CancelTimer(execs[guid],true)
		execs[guid] = nil

		icons[guid] = nil
	end

	local function ExecuteMark(guid)
		local success = MarkGUID(guid,icons[guid])
		if success then CancelMark(guid) end
	end

	local function ResetCount(var)
		--@debug@
		debug("ResetCount","Executed")
		--@end-debug@
		enemy_cnt[var]    = nil
		count_resets[var] = nil
	end

	-- Removals

	-- Note: SetRaidTarget("player",[1-8]); SetRaidTarget("player",0) doesn't work
	-- so the second call has to be scheduled 0.1s later

	local function RemovePlayerIcon()
		--@debug@
		debug("RemovePlayerIcon","Executed")
		--@end-debug@
		SetRaidTarget("player",0)
	end

	local function RemoveSingleIcon(icon)
		--@debug@
		debug("RemoveSingleIcon","icon: %s",icon)
		--@end-debug@
		SetRaidTarget("player",pfl[icon])
		module:ScheduleTimer(RemovePlayerIcon,0.1)
	end

	local function RemoveMultipleIcons(var)
		local t = used_icons[var]
		if t then
			--@debug@
			debug("RemoveMultipleIcons","var: %s icons: %s",var,table.concat(t,", "))
			--@end-debug@
			for i,icon in ipairs(t) do
				SetRaidTarget("player",pfl[icon])
				t[i] = nil
			end
		end
		removes[var] = nil
		module:ScheduleTimer(RemovePlayerIcon,0.1)
	end

	---------------------------------
	-- API
	---------------------------------

	-- @param persist <number> number of seconds to attempt marking
	-- @param remove <boolean> whether or not to remove after persist
	function module:MarkEnemy(guid,icon,persist,remove)
		local success = MarkGUID(guid,icon)
		--@debug@
		debug("MarkEnemy","guid: %s icon: %s persist: %s remove: %s",guid,icon,persist,remove)
		--@end-debug@
		if not success then
			icons[guid] = icon
			execs[guid] = self:ScheduleRepeatingTimer(ExecuteMark,DELAY,guid)
			cancels[guid] = self:ScheduleTimer(CancelMark,persist,guid)
		end

		if remove then self:ScheduleTimer(RemoveSingleIcon,persist,icon) end
	end

	function module:MultiMarkEnemy(var,guid,icon,persist,remove,reset,total)
		--@debug@
		debug("MultiMarkEnemy","Executed")
		--@end-debug@

		-- var keeps track of icon count
		local ix = enemy_cnt[var] or 0
		-- maxed out
		if ix >= total then return end
		self:MarkEnemy(guid,icon + ix,persist) -- ignore single icon removing
		enemy_cnt[var] = ix + 1
		if not count_resets[var] then
			count_resets[var] = self:ScheduleTimer(ResetCount,reset,var)
		end

		-- multiple removes
		if remove then
			local t = used_icons[var]
			if not t then
				t = {}
				used_icons[var] = t
			end
			t[#t+1] = icon + ix
			-- make sure we only schedule one
			if not removes[var] then
				removes[var] = self:ScheduleTimer(RemoveMultipleIcons,persist,var)
			end
		end
	end

	function module:RemoveAllEnemy()
		wipe(execs)
		wipe(cancels)
		wipe(icons)
		wipe(enemy_cnt)
		wipe(count_resets)
		wipe(used_icons)
		wipe(removes)
	end
end

-------------------------------------------
-- CLEANUP
-------------------------------------------

function module:RemoveAll()
	self:RemoveAllFriendly()
	self:RemoveAllEnemy()
	self:CancelAllTimers()
end

-------------------------------------------
-- UTIL
-------------------------------------------

function module:HasIcon(unit,icon)
	icon = tonumber(icon)
	return icon and GetRaidTargetIndex(unit) == pfl[icon]
end
