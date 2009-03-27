local DXE = DXE

local options = {
	type = "group",
	name = "Deus Vox Encounters",
	handler = DXE,
	args = {
		test = {
			type = "execute",
			name = "Alert test",
			func = "AlertTest",
		},
	},
	plugins = {
		encounters = {
			encs_group = {
				type = "group",
				name = "Encounters",
				order = 100,
				get = function(info) return DXE.db.profile.Encounters[info[#info-1]][info[#info]]  end,
				set = function(info, v) DXE.db.profile.Encounters[info[#info-1]][info[#info]] = v end,
				args = {},
			},
		},
	}
}

do
	local function genblank(order)
		return {
			type = "description",
			name = "",
			order = order,
		}
	end
	local options_args = options.args

	local credits = {
		type = "group",
		name = "Credits",
		order = -1,
		args = {
			authors_desc = {
				type = "description",
				name = "Authors: |cffffd200Kollektiv|r and |cffffd200Fariel|r",
				order = 100,
			},
			blank1 = genblank(150),
			created_desc = {
				type = "description",
				name = "Created for |cffffd200Deus Vox|r on |cffffff78Laughing Skull|r",
				order = 200,
			},
			blank2 = genblank(250),
			visit_desc = {
				type = "description",
				name = "Visit: |cffffd244http://www.deusvox.net|r",
				order = 300,
			},
		},
	}

	options_args.credits = credits
end

DXE.options = options

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
