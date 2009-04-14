local logdata, statusbar
local activelog
local CE
local concat = table.concat

-- Reactions
local COMBATLOG_OBJECT_REACTION_FRIENDLY = 0x00000010; 
local COMBATLOG_OBJECT_REACTION_NEUTRAL = 0x00000020; 
local COMBATLOG_OBJECT_REACTION_HOSTILE = 0x00000040; 
local COMBATLOG_OBJECT_REACTION_MASK = 0x000000F0;

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local Logger = DXE:NewModule("Logger","AceEvent-3.0")

local options = {
	type = "group",
	name = "DXE Logger",
	handler = Logger,
	args = {},
	plugins = {
		Boss_plugin = {

		},
	},
}

local opt_plugins = options.plugins.Boss_plugin
local boss_args = {}
Logger.options = options

function Logger:OnInitialize()
	self.loaded = true
	self.defaults = {}
	DXE.db.profile.logdb = DXE.db.profile.logdb or {}
	self.db = DXE.db.profile.logdb
	self.db.bosses = self.db.bosses or {}
	logdata = self.db.bosses
	for k,v in pairs(logdata) do
		k = string.gsub(k, "_", " ") --De-safe string cause config is lame
		self:CreateEncLog(k)
		Logger.InsertBoss(k)
		for t,l in pairs(v) do
			Logger.InsertBossLog(k, t, l, false)
		end
	end
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Logger", self.options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("Logger", 900, 600)

	self:RegisterMessage("DXE_StartEncounter","OnStart")
	self:RegisterMessage("DXE_StopEncounter","OnStop")
end


---------------------------------------------
-- OPTIONS
---------------------------------------------
function Logger.InsertBoss(name)
	local safe_name = string.gsub(name, " ", "_")
	opt_plugins[safe_name] = {
		type = "group",
		name = name,
		args = {
			del = {
				type="execute",
				name="Delete",
				func="DeleteBoss",
			},
		},
	}
	--do return end
	boss_args[safe_name] = opt_plugins[safe_name].args		
end

function Logger.InsertBossLog(name, id, log, check)
	local safe_name = string.gsub(name, "%s", "_")
	local args = boss_args[safe_name]
	local check = check or true
	if check and args[id] then return end
	id = tostring(id)
	args[id] = {
		type = "group",
		childGroups = "tree",
		name = id,
		args = {
			del = {
				type="execute",
				name="Delete",
				func="DeleteLog",
			},
		},
	}

	local idlog = args[id].args
	for mob,mlog in pairs(log) do
		local safe_name = string.gsub(mob, "%s", "_")
		idlog[safe_name] = {
			type = "group",
			childGroups = "tab",
			name = mob,
			args = {},
		}
		local moblog = idlog[safe_name].args

		for atype, atlog in pairs(mlog) do
			if(atype == "MELEE") then
				moblog[atype] = {
					type = "group",
					name = atype,
					args = {
						title = {
							type = "header",
							name = atype,
							order = 0
						},
						data = {
							type = "input",
							dialogControl = "LogLabel",
							name = Logger.LogToString(atlog),
							width="full",
							get = function() return Logger.LogToString(atlog) end
						}
					}
				}
			else
				-- One more descent for spells
				moblog[atype] = {
					type = "group",
					childGroups = "select",
					name = atype,
					args = {}
				}
				local spllog = moblog[atype].args

				for spl,slog in pairs(atlog) do
					local name, _, icon, _,_,_, cast_time, minRange, maxRange = GetSpellInfo(spl)
					cast_time = (cast_time==0 and "Instant") or 
						string.format("%.2f",cast_time/1000*(1+GetCombatRatingBonus(18)/100))
					minRange = minRange or "*"
					maxRange = maxRange or "*"
					spllog[tostring(spl)] = {
						type = "group",
						name = name,
						args = {
							title = {
								type = "header",
								name = name,
								order = 0
							},
							info = {
								type = "description",
								name = "ID: "..spl.."\n"..
									"Cast time: "..cast_time.."\n"..
									"Range: "..minRange.."-"..maxRange,
								image = icon,
								order = 1
							},
							data = {
								type = "input",
								dialogControl = "LogLabel",
								name = Logger.LogToString(slog),
								width="full",
								get = function() return Logger.LogToString(slog) end
							}
						}
					}
				end
			end
		end
	end
end

function Logger.LogToString(log)
	local str = string.format("%-6s %-6s %-20s %-20s %-7s %-6s\n", "Time",
			" HP%", "Event", "Target", "Damage", "+delta")
	
	str = str .. concat(log, "\n") .. "\n"

	return str
end

function Logger:DeleteBoss(info)
	-- Delete boss attempt log
	local bossName = info[#info-1]
	local desafe_name = string.gsub(bossName, "_", " ") --De-safe string cause config is lame
	if DXE.EDB[desafe_name].version == 0 then
		-- This is a dummy encounter
		DXE:UnregisterEncounter(desafe_name)
	end

	opt_plugins[bossName] = nil
	logdata[bossName] = nil
end

function Logger:DeleteLog(info)
	-- Delete boss attempt log
	local bossName = info[#info-2]
	local logId = info[#info-1]
	boss_args[bossName][logId] = nil
	logdata[bossName][logId] = nil
end

---------------------------------------------
-- API
---------------------------------------------

function Logger:RegisterBoss(name)
	if not name then 
		DXE:Print("No target selected")
		return
	end
	DXE:Print("Registering " .. name);
	local safe_name = string.gsub(name, "%s", "_")
	if logdata[safe_name] then return end
	logdata[safe_name] = DXE.new()
	self:CreateEncLog(name)
	Logger.InsertBoss(name)
end

function Logger:SetData(data)
	assert(type(data) == "table","Expected 'data' table as argument #1 in SetData. Got '"..tostring(data).."'")
	
	-- Set data upvalue
	CE = data
	local safe_name = CE.key

	-- Log only for the appropriate encounters
	if not logdata[safe_name] then
		self:UnregisterAllEvents()
		activelog = nil
		return
	end

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatEvent")

	activelog = logdata[safe_name]
end


function Logger:CreateEncLog(name, zone)
	-- Don't create dummy encounter if that encounter already exists
	if DXE.EDB[name] then
		return
	end
	zone = zone or GetRealZoneText() -- This should be the correct zone

	local shortname = string.gsub(name, "%s", "_")
	local dummyenc = {
		version = 0, -- Dummy Encounters for recording will have a version of 0
		key = shortname,
		zone = zone,
		name = name, 
		title = name, 
		tracing = {name,},
		triggers = {
			scan = name, 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {},
	}

	DXE:RegisterEncounter(dummyenc)
end

function Logger:OnStart()
	local name = CE.name
	local safe_name = CE.key
	
	-- Log only for the appropriate encounters
	if not logdata[safe_name] then
		return
	end

	self.bossname = name
	self.starttime = GetTime()
	self.id = date("%m/%d/%y-%H:%M:%S")
	activelog[self.id] = DXE.new()
	self.log = activelog[self.id]
	statusbar = DXE.HW[1].bar
end

function Logger:OnStop()
	if self.log then
		Logger.InsertBossLog(self.bossname, self.id, self.log)
		self.starttime = nil
	end
end

---------------------------------------------
-- LOGGING
---------------------------------------------

function Logger:CombatEvent(event, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	if not self.starttime then return end -- Only monitor during fight

	if bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_MASK) ~= COMBATLOG_OBJECT_REACTION_FRIENDLY then
		local enctime = GetTime()-self.starttime

		-- Source of event is not friendly
		if not srcName then
			if eventtype == "SPELL_AURA_REFRESH" then
				-- Ignore refreshing debuff				return
			end
			srcName = ">> "..dstName
		end

		if string.find(eventtype, "^SWING_") then
			-- Melee Swing
			local entry = {
				target = dstName,
				time = enctime,
				hp = statusbar:GetValue() or 1,
				type = "MELEE",
				event = eventtype,
				damage = nil,
			}
			if(eventtype == "SWING_DAMAGE") then
				entry.damage = select(1,...)
			end

			-- Store melee attack
			local log = self.log
			log[srcName] = log[srcName] or DXE.new()

			local lasttime = 0
			local lastlog
			if log[srcName]["MELEE"] then
				lastlog = log[srcName]["MELEE"]
				lasttime = lastlog.lasttime
			else
				log[srcName]["MELEE"] = DXE.new()
				lastlog = log[srcName]["MELEE"]
			end
			entry.deltatime = entry.time-lasttime
			lastlog.lasttime = entry.time

			local dmg = entry.damage and string.format("%d", entry.damage) or "-"
			local line = string.format("%6.2f %6.2f %-20s %-20s %-7s +%6.3f", entry.time,
				entry.hp*100, entry.event, (entry.target or "<NONE>"), dmg,
				entry.deltatime)
			tinsert(lastlog, line)
		elseif string.find(eventtype, "^SPELL_") then
			-- Spell Cast
			local entry = {
				target = dstName,
				time = enctime,
				hp = statusbar:GetValue() or 1,
				type = "SPELL",
				event = eventtype,
				damage = nil,
			}
			entry.spellId = select(1,...)
			if string.find(eventtype, "^SPELL_AURA") then
				entry.type = "AURA"
			end
			local dmg = select(4,...)
			if type(dmg)=="number"	then
				entry.damage = dmg
			end

			-- Store melee attack
			local log = self.log
			log[srcName] = log[srcName] or DXE.new()
			log[srcName][entry.type] = log[srcName][entry.type] or DXE.new()

			local lasttime = 0
			local lastlog
			if log[srcName][entry.type][entry.spellId] then
				lastlog = log[srcName][entry.type][entry.spellId]
				lasttime = lastlog.lasttime
			else
				log[srcName][entry.type][entry.spellId] = DXE.new()
				lastlog = log[srcName][entry.type][entry.spellId]
			end
			entry.deltatime = entry.time-lasttime
			lastlog.lasttime = entry.time

			local dmg = entry.damage and string.format("%d", entry.damage) or "-"
			local line = string.format("%6.2f %6.2f %-20s %-20s %-7s +%6.3f", entry.time,
				entry.hp*100, entry.event, (entry.target or "<NONE>"), dmg,
				entry.deltatime)
			tinsert(lastlog, line)
		end
	-- elseif bit.band(dstFlags, COMBATLOG_OBJECT_REACTION_MASK) ~= COMBATLOG_OBJECT_REACTION_FRIENDLY then
		-- Destination of event is not friendly
	end
end

---------------------------------------------
-- GUI
---------------------------------------------

function Logger:OpenViewer()
	LibStub("AceConfigDialog-3.0"):Open("Logger")
end

DXE.Logger = Logger





