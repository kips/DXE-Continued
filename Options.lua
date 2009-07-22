local addon = DXE
local version = tonumber(("$Rev$"):match("%d+"))
addon.version = version > addon.version and version or addon.version
local L = addon.L

local wipe = table.wipe

local db,pfl,gbl

local EDB = addon.EDB

local DEFAULT_WIDTH = 890
local DEFAULT_HEIGHT = 575

-- Usage: t[<module>] = <func>
-- func is passed a table the module can add option groups to
local OptionInitializers = {}

-- Usage: t[<module>] = <func>
-- func is passed a table the module can add option items to options.args
local OptionArgs = {}

-- Usage: t[<key>] = true
-- List of encounters by key that haven't had their options added
local QueuedEncs = {}

-- Upvalue pointer for options.plugins.encounters.enc_group.args
local encsArgs

-- Encounter config handler
local ConfigHandler = {}

-----------------------------------------
-- MAIN
-----------------------------------------

local function RefreshProfile(newPfl)
	pfl = newPfl
end
addon:AddToRefreshProfile(RefreshProfile)

function addon:SetDBPointers()
	db = self.db
	gbl = self.db.global
	pfl = self.db.profile
end

addon.genblank = function(order)
	return {
		type = "description",
		name = "",
		order = order,
	}
end

-- Should be done in OnInitialize
function addon:AddOptionArgsItems(module,func)
	--@debug@
	assert(type(module) == "table")
	assert(type(func) == "string")
	assert(type(module[func]) == "function")
	--@end-debug@
	OptionArgs[module] = func
end

function addon:RemoveOptionArgsItems(module)
	--@debug@
	assert(type(module) == "table")
	--@end-debug@
	local func = OptionsArgs[module]
	if func then module[func] = nil end
	OptionsArgs[module] = nil
end

-- Should be done in OnInitializer
function addon:AddModuleOptionInitializer(module,func)
	--@debug@
	assert(type(module) == "table")
	assert(type(func) == "string")
	assert(type(module[func]) == "function")
	--@end-debug@
	OptionInitializers[module] = func
end

function addon:InitializeOptions()
	local options = {}
	self.options = options
	options.type = "group"
	options.name = "DXE"
	options.handler = self
	options.disabled = function() return not gbl.Enabled end
	options.args = {
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
			set = function(info,val) gbl.Enabled = val
					if val then self:Enable()
					else self:Disable() end
			end,
			disabled = function() return false end,
		},
	}
	options.plugins = {
		encounters = {
			encs_group = {
				type = "group",
				name = L["Encounters"],
				order = 200,
				childGroups = "tab",
				handler = ConfigHandler,
				args = {
					simple_mode = {
						type = "execute",
						name = "Simple",
						desc = L["This mode only allows you to enable or disable"],
						order = 1,
						func = "SimpleMode",
					},
					advanced_mode = {
						type = "execute",
						name = "Advanced",
						desc = L["This mode has customization options"],
						order = 2,
						func = "AdvancedMode",
					},
				},
			},
		},
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
			get = function() return not gbl._Minimap.hide end,
			set = function(info,v) gbl._Minimap.hide = not v; LDBIcon[gbl._Minimap.hide and "Hide" or "Show"](LDBIcon,"DXE") end,
			width = "half",
		}

	end
	-------ADDITIONAL GROUPS
	local general = {
		type = "group",
		name = L["General"],
		order = 100,
		get = function(info) return gbl[info[#info]] end,
		set = function(info,v) gbl[info[#info]] = v end,
		handler = self,
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
							gbl.ShowPane = v
							self:UpdatePaneVisibility()
						end,
					},
					PaneOnlyInRaid = {
						order = 200,
						type = "toggle",
						name = L["Only in raid"],
						set = function(info,v)
							gbl.PaneOnlyInRaid = v
							self:UpdatePaneVisibility()
						end,
						disabled = function() return not gbl.ShowPane end,
					},
					PaneOnlyInInstance = {
						order = 250,
						type = "toggle",
						name = L["Only in instances"],
						set = function(info,v)
							gbl.PaneOnlyInInstance = v
							self:UpdatePaneVisibility()
						end,
						disabled = function() return not gbl.ShowPane end,
					},
					PaneScale = {
						order = 300,
						type = "range",
						name = L["Pane scale"],
						set = function(info,v)
							gbl.PaneScale = v
							self:UpdatePaneScale()
						end,
						min = 0.1,
						max = 2,
						step = 0.1,
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

	encsArgs = options.plugins.encounters.encs_group.args

	for module,func in pairs(OptionArgs) do
		module[func](module,options.args)
		module[func] = nil
	end
	OptionArgs = nil
	
	for module,func in pairs(OptionInitializers) do
		local name = module:GetName():lower()
		local area = {}
		options.plugins[name] = area
		module[func](module,area)
		module[func] = nil
	end
	OptionInitializers = nil
	self.InitializeOptions = nil

	for key in pairs(QueuedEncs) do addon:AddEncounterOptions(EDB[key]); QueuedEncs[key] = nil end

	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
	options.args.profile.order = -10

	addon.AC:RegisterOptionsTable("DXE", options)
	addon.ACD:SetDefaultSize("DXE", DEFAULT_WIDTH, DEFAULT_HEIGHT)
end

function addon:GetSlashOptions()
	return {
		type = "group",
		name = L["Deus Vox Encounters"],
		handler = self,
		args = {
			enable = {
				type = "execute",
				name = L["Enable"],
				order = 100,
				func = function() gbl.Enabled = true; self:Enable() end,
			},
			disable = {
				type = "execute",
				name = L["Disable"],
				order = 200,
				func = function() gbl.Enabled = false; self:Disable() end,
			},
			config = {
				type = "execute",
				name = L["Toggles the configuration"],
				func = "ToggleConfig",
				order = 300,
			},
			vc = {
				type = "input",
				name = L["Show version check window"],
				set = "VersionCheck",
				order = 400,
			},
		},
	}
end

-----------------------------------------
-- ENCOUNTER OPTIONS
-----------------------------------------

local Items = {
	VersionHeader = {
		type = "header",
		name = function(info) 
			local version = EDB[info[#info-1]].version or "|cff808080"..L["Unknown"].."|r"
			return L["Version"]..": |cff99ff33"..version.."|r"
		end,
		order = 1,
		width = "full",
	},
	EnabledToggle = {
		type = "toggle",
		name = L["Enabled"],
		width = "half",
		order = 1,										-- data.key     -- info.var
		set = function(info,v) pfl.Encounters[info[#info-3]][info[#info-1]].enabled = v end,
		get = function(info) return pfl.Encounters[info[#info-3]][info[#info-1]].enabled end,
	},
	Output = {
		alerts = {
			color1 = {
				type = "select",
				name = L["Main Color"],
				order = 100,
				values = "GetColor1",
			},
			color2 = {
				type = "select",
				name = L["Flash Color"],
				order = 200,
				values = "GetColor2",
				disabled = function(info) 
					local key,var = info[3],info[5]
					return (not pfl.Encounters[key][var].enabled) or (EDB[key].alerts[var].type == "simple")
				end,
			},
			sound = {
				type = "select",
				name = L["Sound"],
				order = 300,
				values = "GetSounds",
				dialogControl = "LSM30_Sound",
			},
			flashscreen = {
				type = "toggle",
				name = L["Flash screen"],
				order = 400,
			},
			test = {
				type = "execute",
				name = L["Test"],
				order = 500,
				func = "TestAlert",
			},
			reset = {
				type = "execute",
				name = L["Reset"],
				order = 600,
				func = function(info)
					local key,var = info[3],info[5]
					local defaults = addon.defaults.profile.Encounters[key][var]
					local vardb = pfl.Encounters[key][var]
					for k,v in pairs(defaults) do vardb[k] = v end
				end,
			},
		},
		raidicons = {
			icon = {
				type = "select",
				name = L["Icon"],
				order = 100,
				values = {
					"1. "..L["Star"],
					"2. "..L["Circle"],
					"3. "..L["Diamond"],
					"4. "..L["Triangle"],
					"5. "..L["Moon"],
					"6. "..L["Square"],
					"7. "..L["Cross"],
					"8. "..L["Skull"],
				},
			},
		},
		arrows = {
			sound = {
				type = "select",
				name = L["Sound"],
				order = 100,
				values = "GetSounds",
				dialogControl = "LSM30_Sound",
			},
		},
	}
}


do
	-- Output item methods

	local info_n = 7
	local info_n_MINUS_4 = info_n - 4
	local info_n_MINUS_2 = info_n - 2

	local colors1 = {}
	local colors1simple = {}
	local colors2 = {}
	for k,c in pairs(addon.Constants.Colors) do
		local hex = ("|cff%02x%02x%02x%s|r"):format(c.r*255,c.g*255,c.b*255,L[k])
		colors1[k] = hex
		colors1simple[k] = hex
		colors2[k] = hex
	end
	colors1simple["Clear"] = L["Clear"]
	colors2["Off"] = OFF

	function ConfigHandler:GetSounds()
		self.sounds = self.sounds or {}
		wipe(self.sounds)
		for _, name in pairs(addon.SM:List("sound")) do self.sounds[name] = name end
		return self.sounds
	end

	function ConfigHandler:GetColor1(info)
		local key,var = info[3],info[5]
		if EDB[key].alerts[var].type == "simple" then
			return colors1simple
		else
			return colors1
		end
	end

	function ConfigHandler:GetColor2()
		return colors2
	end

	function ConfigHandler:DisableSettings(info)
		return not pfl.Encounters[info[info_n_MINUS_4]][info[info_n_MINUS_2]].enabled
	end

	function ConfigHandler:GetOutput(info)
		return pfl.Encounters[info[info_n_MINUS_4]][info[info_n_MINUS_2]][info[info_n]]
	end

	function ConfigHandler:SetOutput(info,v)
		pfl.Encounters[info[info_n_MINUS_4]][info[info_n_MINUS_2]][info[info_n]] = v
	end

	function ConfigHandler:TestAlert(info)
		local key,var = info[info_n_MINUS_4],info[info_n_MINUS_2]
		local info = EDB[key].alerts[var]
		local stgs = pfl.Encounters[key][var]

		if info.type == "dropdown" then
			addon.Alerts:Dropdown(info.var,info.varname,10,5,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen)
		elseif info.type == "centerpopup" then
			addon.Alerts:CenterPopup(name,info.varname,10,5,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen)
		elseif info.type == "simple" then
			addon.Alerts:Simple(info.varname,5,stgs.sound,stgs.color1,stgs.flashscreen)
		end
	end
end

local Filters = {
	sound = function(str)
		if str:find("^ALERT%d+$") then
			return "DXE "..str
		else return str end
	end
}

local function formatkey(str)
	return str:gsub(" ",""):lower()
end


local outputInfos = {
	alerts = { 
		L = L["Alerts"], 
		order = 100, 
		defaultEnabled = true ,
		defaults = {
			color1 = "Clear",
			color2 = "Off",
			sound = "None",
			flashscreen = false,
		},
	},
	raidicons = { 
		L = L["Raid Icons"], 
		order = 200, 
		defaultEnabled = true,
		defaults = {
			icon = 8,
		},
	},
	arrows = { 
		L = L["Arrows"], 
		order = 300, 
		defaultEnabled = true,
		defaults = {
			sound = "None",
		},
	},
}

function ConfigHandler:GetSimpleEnable(info)
	return pfl.Encounters[info[#info-2]][info[#info]].enabled
end

function ConfigHandler:SetSimpleEnable(info,v)
	pfl.Encounters[info[#info-2]][info[#info]].enabled = v
end

-- Can only enable/disable outputs
local function InjectSimpleOptions(data,encArgs)
	for outputType,outputInfo in pairs(outputInfos) do
		local outputData = data[outputType]
		if outputData then
			encArgs[outputType] = encArgs[outputType] or {
				type = "group",
				name = outputInfo.L,
				order = order,
				args = {},
			}
			encArgs[outputType].inline = true
			encArgs[outputType].childGroups = nil

			local outputArgs = encArgs[outputType].args

			for var,info in pairs(outputData) do
				outputArgs[var] = outputArgs[var] or {
					name = info.varname,
					width = "full",
				}
				outputArgs[var].type = "toggle"
				outputArgs[var].args = nil
				outputArgs[var].set = "SetSimpleEnable"
				outputArgs[var].get = "GetSimpleEnable"
			end
		end
	end
end

local function InjectAdvancedOptions(data,encArgs)
	-- Add output options
	for outputType,outputInfo in pairs(outputInfos) do
		local outputData = data[outputType]
		if outputData then
			encArgs[outputType] = encArgs[outputType] or {
				type = "group",
				name = outputInfo.L,
				order = order,
				args = {},
			}
			encArgs[outputType].inline = nil
			encArgs[outputType].childGroups = "select"

			local outputArgs = encArgs[outputType].args
			for var,info in pairs(outputData) do
				outputArgs[var] = outputArgs[var] or {
					name = info.varname,
					width = "full",
				}

				outputArgs[var].type = "group"
				outputArgs[var].args = {}
				outputArgs[var].get = nil
				outputArgs[var].set = nil

				local itemArgs = outputArgs[var].args
				itemArgs.enabled = Items.EnabledToggle
				if Items.Output[outputType] then
					itemArgs.settings = {
						type = "group",
						name = L["Settings"],
						order = 1,
						inline = true,
						disabled = "DisableSettings",
						get = "GetOutput",
						set = "SetOutput",
						args = {}
					}

					local settingsArgs = itemArgs.settings.args
					for k,item in pairs(Items.Output[outputType]) do
						settingsArgs[k] = item
					end
				end
			end
		end
	end
end

do
	local function SwapMode()
		for catkey in pairs(encsArgs) do
			if encsArgs[catkey].type == "group" then
				local catArgs = encsArgs[catkey].args
				for key in pairs(catArgs) do
					local data = EDB[key]
					local encArgs = catArgs[key].args
					if gbl.AdvancedMode then
						InjectAdvancedOptions(data,encArgs)
					else
						InjectSimpleOptions(data,encArgs)
					end
				end
			end
		end
	end

	function ConfigHandler:SimpleMode()
		if gbl.AdvancedMode then gbl.AdvancedMode = false; SwapMode() end
	end

	function ConfigHandler:AdvancedMode()
		if not gbl.AdvancedMode then gbl.AdvancedMode = true; SwapMode() end
	end
end

function addon:AddEncounterOptions(data)
	if self.options then
		QueuedEncs[data.key] = nil
		-- Pointer to args
		local args = encsArgs
		-- Add a zone group if it doesn't exist. category supersedes zone
		local catkey = data.category and formatkey(data.category) or formatkey(data.zone)
		encsArgs[catkey] = encsArgs[catkey] or {type = "group", name = data.category or data.zone, args = {}}
		-- Update args pointer
		local catArgs = args[catkey].args
		-- Exists, delete args
		if catArgs[data.key] then
			catArgs[data.key].args = {}
		else
			-- Add the encounter group
			catArgs[data.key] = {
				type = "group",
				name = data.name,
				childGroups = "tab",
				args = {},
			}
		end
		-- Set pointer to the correct encounter group
		local encArgs = catArgs[data.key].args
		if gbl.AdvancedMode then
			InjectAdvancedOptions(data,encArgs)
		else
			InjectSimpleOptions(data,encArgs)
		end
	else
		QueuedEncs[data.key] = true
	end
end


-- Only used with UnregisterEncounter
function addon:RemoveEncounterOptions(data)
	if self.options then
		local catkey = data.category and formatkey(data.category) or formatkey(data.zone)
		encsArgs[catkey].args[data.key] = nil
		-- Remove category if there are no more encounters in it
		if not next(encsArgs[catkey].args) then
			encsArgs[catkey] = nil
		end
	end
	QueuedEncs[data.key] = nil
end

function addon:AddEncounterDefaults(data)
	local defaults = {}
	self.defaults.profile.Encounters[data.key] = defaults
	
	for outputType,outputInfo in pairs(outputInfos) do
		local outputData = data[outputType]
		if outputData then
			for var,info in pairs(outputData) do
				defaults[var] = {}
				-- Upgrading from <= r244
				-------
				local isOpposite
				if pfl.Encounters[key] and type(pfl.Encounters[key][var]) == "boolean" then
					pfl.Encounters[key][var] = nil
					isOpposite = true
				end

				if isOpposite then
					-- The only reason it'd be stored if it was opposite of the default value
					defaults[var].enabled = not outputInfo.defaultEnabled
				else
					defaults[var].enabled = outputInfo.defaultEnabled
				end
				-------

				-- Add setting defaults
				for k,varDefault in pairs(outputInfos[outputType].defaults) do
					if Filters[k] then
						defaults[var][k] = info[k] and Filters[k](info[k]) or varDefault
					else
						defaults[var][k] = info[k] or varDefault
					end
				end
			end
		end
	end
end
