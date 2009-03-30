local DXE = DXE

DXE.genblank = function(order)
	return {
		type = "description",
		name = "",
		order = order,
	}
end

function DXE:GetSlashOptions()
	return {
		type = "group",
		name = "Deus Vox Encounters",
		handler = self,
		args = {
			enable = {
				type = "execute",
				name = "Enable DXE",
				order = 100,
				func = function() self.db.global.Enabled = true; self:Enable() end,
			},
			disable = {
				type = "execute",
				name = "Disable DXE",
				order = 200,
				func = function() self.db.global.Enabled = false; self:Disable() end,
			},
			config = {
				type = "execute",
				name = "Open the configuration",
				func = "OpenConfig",
				order = 300,
			},
			paneonlyinraid = {
				type = "toggle",
				name = "Toggle showing the pane only in a raid group",
				order = 400,
				set = function(info,v) 
					self.db.global.PaneOnlyInRaid = v
					self:UpdatePaneVisibility()
				end,
				get = function() 
					return self.db.global.PaneOnlyInRaid
				end,
			},
		},
	}
end

function DXE:InitializeOptions()
	local options = {
		type = "group",
		name = "Deus Vox Encounters",
		handler = self,
		disabled = function() return not self.db.global.Enabled end,
		args = {
			Enabled = {
				type = "toggle",
				order = 100,
				name = "Enabled",
				get = "IsEnabled",
				width = "half",
				set = function(info,val) self.db.global.Enabled = val
						if val then self:Enable()
						else self:Disable() end
				end,
				disabled = function() return false end,
			},
			test = {
				type = "execute",
				name = "Alert test",
				order = 200,
				func = "AlertTest",
			},
		},
		plugins = {
			encounters = {
				encs_group = {
					type = "group",
					name = "Encounters",
					order = 200,
					get = function(info) return self.db.profile.Encounters[info[#info-1]][info[#info]]  end,
					set = function(info, v) self.db.profile.Encounters[info[#info-1]][info[#info]] = v end,
					args = {},
				},
			},
		}
	}

	local options_args = options.args
	-------ADDITIONAL GROUPS
	local general = {
		type = "group",
		name = "General",
		order = 100,
		get = function(info) return self.db.global[info[#info]] end,
		set = function(info,v) self.db.global[info[#info]] = v end,
		args = {
			PaneOnlyInRaid = {
				order = 100,
				type = "toggle",
				name = "Show Pane only in raid",
				set = function(info,v)
					self.db.global.PaneOnlyInRaid = v
					self:UpdatePaneVisibility()
				end,
			},
			AlertsScale = {
				order = 200,
				type = "range",
				name = "Alerts scale",
				min = 0.5,
				max = 1.5,
				step = 0.1,
				set = function(info,v) self.db.global.AlertsScale = v; self.callbacks:Fire("AlertsScaleChanged") end,
			},
		},
	}
	options_args.general = general

	local about = {
		type = "group",
		name = "About",
		order = -1,
		args = {
			authors_desc = {
				type = "description",
				name = "Authors: |cffffd200Kollektiv|r and |cffffd200Fariel|r",
				order = 100,
			},
			blank1 = self.genblank(150),
			created_desc = {
				type = "description",
				name = "Created for use by |cffffd200Deus Vox|r on |cffffff78Laughing Skull|r",
				order = 200,
			},
			blank2 = self.genblank(250),
			visit_desc = {
				type = "description",
				name = "Website: |cffffd244http://www.deusvox.net|r",
				order = 300,
			},
		},
	}

	options_args.about = about

	return options
end





function DXE:AddPluginOptions(name,tbl)
	self.options.plugins[name] = tbl
end

local function findversion(key)
	for name,data in pairs(DXE.EDB) do
		if data.key == key then
			return data.version
		end
	end
end

local version = {
	type = "header",
	name = function(info) return "Version: |cff00ff00"..tostring(findversion(info[#info-1])).."|r" end,
	order = 1,
	width = "full",
}

-- Only used with UnregisterEncounter
function DXE:RemoveEncounterOptions(data)
	local zonekey = data.zone:gsub(" ",""):lower()
	local groupargs = self.options.plugins.encounters.encs_group.args
	groupargs[zonekey].args[data.key] = DXE.delete(groupargs[zonekey].args[data.key])
	-- Remove zone category if there are no more encounters in it
	if not next(groupargs[zonekey].args) then
		groupargs[zonekey] = DXE.delete(groupargs[zonekey])
	end
end

function DXE:AddEncounterOptions(data)
	-- Pointer to args
	local args = self.options.plugins.encounters.encs_group.args
	-- Add a zone group if it doesn't exist
	local zonekey = data.zone:gsub(" ",""):lower()
	args[zonekey] = args[zonekey] or {	
		type = "group",
		childGroups = "select",
		name = data.zone,
		args = {}
	}
	-- Update args pointer
	args = args[zonekey].args
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
	end
end
