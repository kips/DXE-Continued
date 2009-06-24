local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version
local L = DXE.L

-----------------------------------------
-- MAIN
-----------------------------------------

DXE.genblank = function(order)
	return {
		type = "description",
		name = "",
		order = order,
	}
end

local enc_group_args

function DXE:InitializeOptions()
	local options = {
		type = "group",
		name = "DXE",
		handler = self,
		disabled = function() return not self.db.global.Enabled end,
		args = {
			dxe_header = {
				type = "header",
				name = format("%s - %s",L["Deus Vox Encounters"],L["Version"])..format(" |cff99ff33%d|r",self.version),
				order = 1,
				width = "full",
			},
			Enabled = {
				type = "toggle",
				order = 100,
				name = L["Enabled"],
				get = "IsEnabled",
				width = "half",
				set = function(info,val) self.db.global.Enabled = val
						if val then self:Enable()
						else self:Disable() end
				end,
				disabled = function() return false end,
			},
			AlertsTest = {
				type = "execute",
				name = L["Alerts Test"],
				order = 200,
				func = "AlertTest",
			},
		},
		plugins = {
			encounters = {
				encs_group = {
					type = "group",
					name = L["Encounters"],
					order = 200,
					childGroups = "tab",
					get = function(info) return self.db.profile.Encounters[info[#info-1]][info[#info]]  end,
					set = function(info, v) self.db.profile.Encounters[info[#info-1]][info[#info]] = v end,
					args = {},
				},
			},
		}
	}
	local options_args = options.args
	-------ADDITIONAL ROOT OPTIONS
	if LibStub("LibDBIcon-1.0",true) then
		local LDBIcon = LibStub("LibDBIcon-1.0")
		options_args.ShowMinimap = {
			type = "toggle",
			order = 150,
			name = L["Minimap"],
			desc = L["Show minimap icon"],
			get = function() return not self.db.global._Minimap.hide end,
			set = function(info,v) self.db.global._Minimap.hide = not v; LDBIcon[self.db.global._Minimap.hide and "Hide" or "Show"](LDBIcon,"DXE") end,
			width = "half",
		}

	end
	-------ADDITIONAL GROUPS
	local general = {
		type = "group",
		name = L["General"],
		order = 100,
		get = function(info) return self.db.global[info[#info]] end,
		set = function(info,v) self.db.global[info[#info]] = v end,
		args = {
			pane_group = {
				type = "group",
				name = L["Pane"],
				inline = true,
				order = 100,
				args = {
					ShowPane = {
						order = 100,
						type = "toggle",
						name = L["Show Pane"],
						set = function(info,v)
							self.db.global.ShowPane = v
							self:UpdatePaneVisibility()
						end,
					},
					PaneOnlyInRaid = {
						order = 200,
						type = "toggle",
						name = L["Only in raid"],
						set = function(info,v)
							self.db.global.PaneOnlyInRaid = v
							self:UpdatePaneVisibility()
						end,
						disabled = function() return not self.db.global.ShowPane end,
					},
					PaneOnlyInInstance = {
						order = 250,
						type = "toggle",
						name = L["Only in instances"],
						set = function(info,v)
							self.db.global.PaneOnlyInInstance = v
							self:UpdatePaneVisibility()
						end,
						disabled = function() return not self.db.global.ShowPane end,
					},
					PaneScale = {
						order = 300,
						type = "range",
						name = L["Pane scale"],
						set = function(info,v)
							self.db.global.PaneScale = v
							self:UpdatePaneScale()
						end,
						min = 0.1,
						max = 2,
						step = 0.1,
					},
				},
			},
			alerts_group = {
				type = "group",
				name = L["Alerts"],
				order = 200,
				inline = true,
				args = {
					AlertsScale = {
						order = 200,
						type = "range",
						name = L["Alerts scale"],
						min = 0.5,
						max = 1.5,
						step = 0.1,
						set = function(info,v) self.db.global.AlertsScale = v; self.callbacks:Fire("AlertsScaleChanged") end,
					},
				},
			},
		},
	}
	options_args.general = general

	local about = {
		type = "group",
		name = L["About"],
		order = -2,
		args = {
			authors_desc = {
				type = "description",
				name = format("%s : %s",L["Authors"],"|cffffd200Kollektiv|r, |cffffd200Fariel|r"),
				order = 100,
			},
			blank1 = self.genblank(150),
			created_desc = {
				type = "description",
				name = format(L["Created for use by %s on %s"],"|cffffd200Deus Vox|r","|cffffff78US-Laughing Skull|r"),
				order = 200,
			},
			blank2 = self.genblank(250),
			visit_desc = {
				type = "description",
				name = format("%s: %s",L["Website"],"|cffffd244http://www.deusvox.net|r"),
				order = 300,
			},
		},
	}

	options_args.about = about
	
	--@debug@
	local debug = {
		type = "group",
		name = "Debug",
		order = -1,
		args = {},
	}

	options_args.debug = debug
	--@end-debug@

	enc_group_args = options.plugins.encounters.encs_group.args

	return options
end

function DXE:GetSlashOptions()
	return {
		type = "group",
		name = L["Deus Vox Encounters"],
		handler = self,
		args = {
			enable = {
				type = "execute",
				name = L["Enable"],
				order = 100,
				func = function() self.db.global.Enabled = true; self:Enable() end,
			},
			disable = {
				type = "execute",
				name = L["Disable"],
				order = 200,
				func = function() self.db.global.Enabled = false; self:Disable() end,
			},
			config = {
				type = "execute",
				name = L["Toggles the configuration"],
				func = "ToggleConfig",
				order = 300,
			},
			versioncheck = {
				type = "input",
				name = L["Print versions of encounters"],
				set = "PrintRosterVersions",
				order = 400,
			},
		},
	}
end

function DXE:AddPluginOptions(name,tbl)
	self.options.plugins[name] = tbl
end

-----------------------------------------
-- ENCOUNTERS
-----------------------------------------

local function convert_to_key(str)
	return str:gsub(" ",""):lower()
end

local function findversion(key)
	for name,data in pairs(DXE.EDB) do
		if data.key == key then
			return data.version or format("|cff808080%s|r",L["Unknown"])
		end
	end
end

local version = {
	type = "header",
	name = function(info) return L["Version"]..": |cff99ff33"..tostring(findversion(info[#info-1])).."|r" end,
	order = 1,
	width = "full",
}

-- Only used with UnregisterEncounter
function DXE:RemoveEncounterOptions(data)
	local catkey = data.category and convert_to_key(data.category) or convert_to_key(data.zone)
	enc_group_args[catkey].args[data.key] = nil
	-- Remove category if there are no more encounters in it
	if not next(enc_group_args[catkey].args) then
		enc_group_args[catkey] = nil
	end
end

function DXE:GetCategoryOptions(category)
	return {
		type = "group",
		name = category,
		args = {}
	}
end

local loadmodule = {
	type = "execute",
	name = L["Load Module"],
	desc = L["This module will automatically load when you enter the appropriate zone. Click if you want to force load it."],
	func = function(info) LoadAddOn(info[#info]); DXE:ScheduleTimer("BroadcastAllVersions",5) end,
	width = "full",
}

local loadGroups = {}

function DXE:AddCategoryLoader(category,module)
	local catkey = convert_to_key(category)
	enc_group_args[catkey] = self:GetCategoryOptions(category)
	enc_group_args[catkey].args[module] = loadmodule
	loadGroups[enc_group_args[catkey]] = true
end

function DXE:AddEncounterOptions(data)
	-- Pointer to args
	local args = enc_group_args
	-- Add a zone group if it doesn't exist. category supersedes zone
	local catkey = data.category and convert_to_key(data.category) or convert_to_key(data.zone)
	args[catkey] = args[catkey] or self:GetCategoryOptions(data.category or data.zone)

	if loadGroups[args[catkey]] then
		wipe(args[catkey].args)
		loadGroups[args[catkey]] = nil
	end

	-- Update args pointer
	args = args[catkey].args
	-- Exists, wipe it for upgrading
	if args[data.key] then
		wipe(args[data.key].args)
	else
	-- Add the encounter group
		args[data.key] = {
			type = "group",
			name = data.name,
			args = {},
		}
	end
	-- Set pointer to the correct encounter group
	args = args[data.key].args
	-- Add key to defaults
	self.defaults.profile.Encounters[data.key] = self.defaults.profile.Encounters[data.key] or {}
	-- Pointer to defaults
	local defaults = self.defaults.profile.Encounters[data.key]
	-- Wipe defaults for upgrading
	wipe(defaults)
	-- Traverse alerts table
	for _,info in pairs(data.alerts) do
		-- Add var to defaults
		defaults[info.var] = true
		-- Add toggle option
		args[info.var] = args[info.var] or {}
		-- For alerts that share the same var
		wipe(args[info.var])
		args.version = version
		args[info.var].name = info.varname
		args[info.var].type = "toggle"
		args[info.var].width = "full"
	end
end
