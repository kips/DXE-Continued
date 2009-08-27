local addon = DXE
local L,SM = addon.L,addon.SM

local wipe = table.wipe

local db,pfl,gbl

local EDB = addon.EDB

--local DEFAULT_WIDTH = 890
local DEFAULT_WIDTH = 723
--local DEFAULT_HEIGHT = 575
--local DEFAULT_HEIGHT = 607
local DEFAULT_HEIGHT = 650

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
	local func = OptionArgs[module]
	if func then module[func] = nil end
	OptionArgs[module] = nil
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
	options.childGroups = "tab"
	options.args = {
		dxe_header = {
			type = "header",
			name = format("%s - %s",L["Deus Vox Encounters"],L["Version"])..format(": |cff99ff33%d|r",self.version),
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
		handler = self,
		args = {
			pane_group = {
				type = "group",
				name = L["Pane"],
				--inline = true,
				order = 100,
				get = function(info) 
					local var = info[#info]
					if var:find("Color") then return unpack(pfl.Pane[var])
					else return pfl.Pane[var] end end,
				set = function(info,v) pfl.Pane[info[#info]] = v end,
				args = {
					visibility_group = {
						type = "group",
						name = "",
						inline = true,
						order = 100,
						set = function(info,v)
							pfl.Pane[info[#info]] = v
							addon:UpdatePaneVisibility()
						end,
						disabled = function() return not pfl.Pane.Show end,
						args = {
							Show = {
								order = 100,
								type = "toggle",
								name = L["Show Pane"],
								desc = L["Toggle the visibility of the pane"],
								disabled = function() return false end,
							},
							showpane_desc = {
								order = 150,
								type = "description",
								name = L["Show Pane"].."...",
							},
							OnlyInRaid = {
								order = 200,
								type = "toggle",
								name = L["Only in raids"],
								desc = L["Show the pane only in raids"],
								width = "full",
							},
							OnlyInParty = {
								order = 210,
								type = "toggle",
								name = L["Only in party"],
								desc = L["Show the pane only in party"],
								width = "full",
							},
							OnlyInRaidInstance = {
								order = 250,
								type = "toggle",
								name = L["Only in raid instances"],
								desc = L["Show the pane only in raid instances"],
								width = "full",
							},
							OnlyInPartyInstance = {
								order = 255,
								type = "toggle",
								name = L["Only in party instances"],
								desc = L["Show the pane only in party instances"],
								width = "full",
							},
							OnlyIfRunning = {
								order = 260,
								type = "toggle",
								name = L["Only if engaged"],
								desc = L["Show the pane only if an encounter is running"],
								width = "full",
							},
							OnlyOnMouseover = {
								order = 261,
								type = "toggle",
								name = L["Only on mouseover"],
								desc = L["Show the pane only if the mouse is over it"],
								width = "full",
							},
						},
					},
					skin_group = {
						type = "group",
						name = "",
						order = 200,
						inline = true,
						set = function(info,v,v2,v3,v4)
							local var = info[#info]
							if var:find("Color") then pfl.Pane[var] = {v,v2,v3,v4}
							else pfl.Pane[var] = v end
							self:SkinPane()
						end,
						args = {
							BarTexture = {
								order = 100,
								type = "select",
								name = L["Bar Texture"],
								desc = L["Select a bar texture used on health watchers"],
								values = SM:HashTable("statusbar"),
								dialogControl = "LSM30_Statusbar",
							},
							BarGrowth = {
								order = 200,
								type = "select",
								name = L["Bar Growth"],
								desc = L["Direction health watcher bars grow. If set to automatic, they grow based on where the pane is"],
								values = {AUTOMATIC = L["Automatic"], UP = L["Up"], DOWN = L["Down"]},
								set = function(info,v)
									pfl.Pane.BarGrowth = v
									addon:LayoutHealthWatchers()
								end,
								disabled = function() return not pfl.Pane.Show end,
							},
							Scale = {
								order = 300,
								type = "range",
								name = L["Scale"],
								desc = L["Adjust the scale of the pane"],
								set = function(info,v)
									pfl.Pane.Scale = v
									addon:ScalePaneAndCenter()
								end,
								min = 0.1,
								max = 2,
								step = 0.1,
							},
							border_header = {
								type = "header",
								name = L["Border"],
								order = 350,
							},
							Border = {
								order = 400,
								type = "select",
								name = L["Border"],
								desc = L["Select a border used on the pane and health watchers"],
								values = SM:HashTable("border"),
								dialogControl = "LSM30_Border",
							},
							BorderSize = {
								order = 500,
								type = "range",
								name = L["Border Size"],
								desc = L["Adjust the size of borders used on the pane and health watchers"],
								min = 6,
								max = 16,
								step = 1,
							},
							BorderColor = {
								order = 600,
								type = "color",
								name = L["Border Color"],
								desc = L["Select a border color used on the pane and health watchers"],
								hasAlpha = true,
							},
							BackgroundColor = {
								order = 700,
								type = "color",
								name = L["Background Color"],
								desc = L["Select a background color used on the pane and health watchers"],
								hasAlpha = true,
							},
							font_header = {
								type = "header",
								name = L["Font"],
								order = 750,
							},
							Font = {
								order = 800,
								type = "select",
								name = L["Font"],
								desc = L["Select a font used on the pane and health watchers"],
								values = SM:HashTable("font"),
								dialogControl = "LSM30_Font",
							},
							TitleFontSize = {
								order = 900,
								type = "range",
								name = L["Title Font Size"],
								desc = L["Select a font size used on health watchers"],
								min = 8,
								max = 20,
								step = 1,
							},
							HealthFontSize = {
								order = 1000,
								type = "range",
								name = L["Health Font Size"],
								desc = L["Select a font size used on health watchers"],
								min = 8,
								max = 20,
								step = 1,
							},
							FontColor = {
								order = 1100,
								type = "color",
								name = L["Font Color"],
								desc = L["Set a font color used on health watchers"],
							},
							misc_header = {
								type = "header",
								name = L["Miscellaneous"],
								order = 1200,
							},
							NeutralColor = {
								order = 1300,
								type = "color",
								name = L["Neutral Color"],
								desc = L["The color of the health bar when first shown"],
							},
							LostColor = {
								order = 1400,
								type = "color",
								name = L["Lost Color"],
								desc = L["The color of the health bar after losing the mob"],
							},
						},
					},
				},
			},
			misc_group = {
				type = "group",
				name = L["Miscellaneous"],
				get = function(info) return pfl.Misc[info[#info]] end,
				set = function(info,v) pfl.Misc[info[#info]] = v end,
				order = 200,
				args = {
					BlockRaidWarningFrame = {
						type = "toggle",
						name = L["Block raid warning frame messages from other boss mods"],
						order = 100,
						width = "full",
					},
					BlockRaidWarningMessages = {
						type = "toggle",
						name = L["Block raid warning messages, in the chat log, from other boss mods"],
						order = 200,
						width = "full",
					},
					BlockBossEmoteFrame = {
						type = "toggle",
						name = L["Block boss emote frame messages"],
						order = 300,
						width = "full",
					},
					BlockBossEmoteMessages = {
						type = "toggle",
						name = L["Block boss emote messages in the chat log"],
						order = 400,
						width = "full",
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
				values = addon.SM:HashTable("sound"),
				dialogControl = "LSM30_Sound",
			},
			blank = addon.genblank(350),
			flashscreen = {
				type = "toggle",
				name = L["Flash screen"],
				order = 400,
			},
			counter = {
				type = "toggle",
				name = L["Counter"],
				order = 500,
			},
			test = {
				type = "execute",
				name = L["Test"],
				order = 600,
				func = "TestAlert",
			},
			reset = {
				type = "execute",
				name = L["Reset"],
				order = 700,
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
				values = addon.SM:HashTable("sound"),
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
	for k,c in pairs(addon.Media.Colors) do
		local hex = ("|cff%02x%02x%02x%s|r"):format(c.r*255,c.g*255,c.b*255,L[k])
		colors1[k] = hex
		colors1simple[k] = hex
		colors2[k] = hex
	end
	colors1simple["Clear"] = L["Clear"]
	colors2["Off"] = OFF

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
			addon.Alerts:Dropdown(info.var,info.varname,10,5,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,info.icon)
		elseif info.type == "centerpopup" then
			addon.Alerts:CenterPopup(name,info.varname,10,5,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,info.icon)
		elseif info.type == "simple" then
			addon.Alerts:Simple(info.varname,5,stgs.sound,stgs.color1,stgs.flashscreen,info.icon)
		end
	end
end

local Filters = {
	sound = function(str)
		return str:find("^ALERT%d+$") and "DXE "..str or str
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
			counter = false,
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
	announces = {
		L = L["Announces"],
		order = 400,
		defaultEnabled = true,
		defaults = {},
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
				args = {
					version_header = Items.VersionHeader,
				},
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
