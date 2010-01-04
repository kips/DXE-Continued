local addon,L = DXE,DXE.L
local EDB = addon.EDB
local module = addon:NewModule("Options")
addon.Options = module

local db
local opts
local opts_args

local DEFAULT_WIDTH = 890
local DEFAULT_HEIGHT = 650

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local SM = LibStub("LibSharedMedia-3.0")

local function genblank(order) return {type = "description", name = "", order = order} end

local function InitializeOptions()
	opts = {
		type = "group",
		name = "DXE",
		handler = addon,
		disabled = function() return not db.profile.Enabled end,
		args = {
			dxe_header = {
				type = "header",
				name = format("%s - %s",L["Deus Vox Encounters"],L["Version"])..format(": |cff99ff33%d|r",addon.version),
				order = 1,
				width = "full",
			},
			Enabled = {
				type = "toggle",
				order = 100,
				name = L["Enabled"],
				get = "IsEnabled",
				width = "half",
				set = function(info,val) db.profile.Enabled = val
						if val then addon:Enable()
						else addon:Disable() end
				end,
				disabled = function() return false end,
			},
		},
	}

	module.opts = opts

	opts_args = opts.args

	-- Minimap
	if LibStub("LibDBIcon-1.0",true) then
		local LDBIcon = LibStub("LibDBIcon-1.0")
		opts_args.ShowMinimap = {
			type = "toggle",
			order = 150,
			name = L["Minimap"],
			desc = L["Show minimap icon"],
			get = function() return not DXEIconDB.hide end,
			set = function(info,v) DXEIconDB.hide = not v; LDBIcon[DXEIconDB.hide and "Hide" or "Show"](LDBIcon,"DXE") end,
			width = "half",
		}
	end

	---------------------------------------------
	-- UTILITY
	---------------------------------------------

	local GetSounds

	do
		local sounds = {}
		function GetSounds()
			table.wipe(sounds)
			for id,name in pairs(db.profile.Sounds) do
				if id:find("^ALERT") then sounds[id] = id end
			end
			for id,name in pairs(db.profile.CustomSounds) do
				sounds[id] = id
			end
			sounds["None"] = L["None"]
			return sounds
		end
	end

	---------------------------------------------
	-- GENERAL 
	---------------------------------------------

	do
		local globals_group = {
			type = "group",
			name = L["Globals"],
			order = 50,
			get = function(info) 
				local var = info[#info]
				if var:find("Color") then return unpack(db.profile.Globals[var])
				else return db.profile.Globals[var] end
			end,
			set = function(info,v,v2,v3,v4)
				local var = info[#info]
				if var:find("Color") then
					local t = db.profile.Globals[var]
					t[1],t[2],t[3],t[4] = v,v2,v3,v4
					addon["Notify"..var.."Changed"](addon,v,v2,v3,v4)
				else
					db.profile.Globals[var] = v
					addon["Notify"..var.."Changed"](addon,v)
				end
			end,
			args = {
				BarTexture = {
					type = "select",
					order = 100,
					name = L["Bar Texture"],
					desc = L["Bar texture used throughout the addon"],
					values = SM:HashTable("statusbar"),
					dialogControl = "LSM30_Statusbar",
				},
				Font = {
					order = 200,
					type = "select",
					name = L["Font"],
					desc = L["Font used throughout the addon"],
					values = SM:HashTable("font"),
					dialogControl = "LSM30_Font",
				},
				Border = {
					order = 300,
					type = "select",
					name = L["Border"],
					desc = L["Border used throughout the addon"],
					values = SM:HashTable("border"),
					dialogControl = "LSM30_Border",
				},
				blank = genblank(350),
				BackgroundColor = {
					order = 400,
					type = "color",
					name = L["Background Color"],
					desc = L["Background color used throughout the addon"],
					hasAlpha = true,
				},
				BorderColor = {
					order = 500,
					type = "color",
					name = L["Border Color"],
					desc = L["Border color used throughout the addon"],
					hasAlpha = true,
				},
			},
		}

		opts_args.globals_group = globals_group

	end

	---------------------------------------------
	-- PANE
	---------------------------------------------

	do
		local pane_group = {
			type = "group",
			name = L["Pane"],
			order = 100,
			get = function(info) 
				local var = info[#info]
				if var:find("Color") then return unpack(db.profile.Pane[var])
				else return db.profile.Pane[var] end end,
			set = function(info,v) db.profile.Pane[info[#info]] = v end,
			args = {}
		}
		opts_args.pane_group = pane_group

		local pane_args = pane_group.args
		do
			local visibility_group = {
				type = "group",
				name = "",
				inline = true,
				order = 100,
				set = function(info,v)
					db.profile.Pane[info[#info]] = v
					addon:UpdatePaneVisibility()
				end,
				disabled = function() return not db.profile.Pane.Show end,
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
			}

			pane_args.visibility_group = visibility_group

			local skin_group = {
				type = "group",
				name = "",
				order = 200,
				inline = true,
				set = function(info,v,v2,v3,v4)
					local var = info[#info]
					if var:find("Color") then db.profile.Pane[var] = {v,v2,v3,v4}
					else db.profile.Pane[var] = v end
					addon:SkinPane()
				end,
				args = {
					BarGrowth = {
						order = 200,
						type = "select",
						name = L["Bar Growth"],
						desc = L["Direction health watcher bars grow. If set to automatic, they grow based on where the pane is"],
						values = {AUTOMATIC = L["Automatic"], UP = L["Up"], DOWN = L["Down"]},
						set = function(info,v)
							db.profile.Pane.BarGrowth = v
							addon:LayoutHealthWatchers()
						end,
						disabled = function() return not db.profile.Pane.Show end,
					},
					Scale = {
						order = 300,
						type = "range",
						name = L["Scale"],
						desc = L["Adjust the scale of the pane"],
						set = function(info,v)
							db.profile.Pane.Scale = v
							addon:ScalePaneAndCenter()
						end,
						min = 0.1,
						max = 2,
						step = 0.1,
					},
					Width = {
						order = 310,
						type = "range",
						name = L["Width"],
						desc = L["Adjust the width of the pane"],
						set = function(info, v)
							db.profile.Pane.Width = v
							addon:SetPaneWidth()
						end,
						min = 175,
						max = 500,
						step = 1,
					},
					font_header = {
						type = "header",
						name = L["Font"],
						order = 750,
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
			}

			pane_args.skin_group = skin_group
		end
	end

	---------------------------------------------
	-- MISCELLANEOUS
	---------------------------------------------
	do
		local misc_group = {
			type = "group",
			name = L["Miscellaneous"],
			get = function(info) return db.profile.Misc[info[#info]] end,
			set = function(info,v) db.profile.Misc[info[#info]] = v end,
			order = 300,
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
		}

		opts_args.misc_group = misc_group
	end

	---------------------------------------------
	-- ABOUT
	---------------------------------------------

	do
		local about_group = {
			type = "group",
			name = L["About"],
			order = -2,
			args = {
				authors_desc = {
					type = "description",
					name = format("%s : %s",L["Authors"],"|cffffd200Kollektiv|r, |cffffd200Fariel|r"),
					order = 100,
				},
				blank1 = genblank(150),
				created_desc = {
					type = "description",
					name = format(L["Created for use by %s on %s"],"|cffffd200Deus Vox|r","|cffffff78US-Laughing Skull|r"),
					order = 200,
				},
				blank2 = genblank(250),
				visit_desc = {
					type = "description",
					name = format("%s: %s",L["Website"],"|cffffd244http://www.deusvox.net|r"),
					order = 300,
				},
			},
		}
		opts_args.about_group = about_group
	end

	---------------------------------------------
	-- ENCOUNTERS
	---------------------------------------------

	do
		local loadselect
		local handler = {}
		local encs_group = {
			type = "group",
			name = L["Encounters"],
			order = 200,
			childGroups = "tab",
			handler = handler,
			args = {
				simple_mode = {
					type = "execute",
					name = "Simple",
					desc = L["This mode only allows you to enable or disable"],
					order = 1,
					func = "SimpleMode",
					width = "half",
				},
				advanced_mode = {
					type = "execute",
					name = "Advanced",
					desc = L["This mode has customization options"],
					order = 2,
					func = "AdvancedMode",
				},
				modules = {
					type = "select",
					name = L["Modules"],
					order = 3,
					get = function() 
						loadselect = loadselect or next(addon.Loader.Z_MODS_LIST)
						return loadselect end,
					set = function(info,v) loadselect = v end,
					values = function() return addon.Loader.Z_MODS_LIST end,
					disabled = function() return not loadselect end,
				},
				load = {
					type = "execute",
					name = L["Load"],
					order = 4,
					func  = function() addon.Loader:Load(loadselect) end,
					disabled = function() return not loadselect end,
					width = "half",
				},
			},
		}

		function handler:OnLoadZoneModule() loadselect = next(addon.Loader.Z_MODS_LIST) end
		addon.RegisterCallback(handler,"OnLoadZoneModule")

		opts_args.encs_group = encs_group
		local encs_args = encs_group.args

		-- SIMPLE MODE
		function handler:GetSimpleEnable(info) return db.profile.Encounters[info[#info-2]][info[#info]].enabled end
		function handler:SetSimpleEnable(info,v) db.profile.Encounters[info[#info-2]][info[#info]].enabled = v end

		-- Can only enable/disable outputs
		local function InjectSimpleOptions(data,enc_args)
			for optionType,optionInfo in pairs(addon.EncDefaults) do
				local encData = data[optionType]
				local override = optionInfo.override
				if encData or override then
					enc_args[optionType] = enc_args[optionType] or {
						type = "group",
						name = optionInfo.L,
						order = optionInfo.order,
						args = {},
					}
					enc_args[optionType].inline = true
					enc_args[optionType].childGroups = nil

					local option_args = enc_args[optionType].args

					for var,info in pairs(override and optionInfo.list or encData) do
						option_args[var] = option_args[var] or {
							name = info.varname,
							width = "full",
						}
						option_args[var].type = "toggle"
						option_args[var].args = nil
						option_args[var].set = "SetSimpleEnable"
						option_args[var].get = "GetSimpleEnable"
					end
				end
			end
		end

		-- ADVANCED MODE

		local AdvancedItems = {
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
				set = function(info,v) db.profile.Encounters[info[#info-3]][info[#info-1]].enabled = v end,
				get = function(info) return db.profile.Encounters[info[#info-3]][info[#info-1]].enabled end,
			},
			Options = {
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
							return (not db.profile.Encounters[key][var].enabled) or (EDB[key].alerts[var].type == "simple")
						end,
					},
					sound = {
						type = "select",
						name = L["Sound"],
						order = 300,
						values = GetSounds,
					},
					blank = genblank(350),
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
							local vardb = db.profile.Encounters[key][var]
							for k,v in pairs(defaults) do vardb[k] = v end
						end,
					},
				},
				raidicons = {
					desc = {
						type = "description",
						order = 100,
						name = function(info)
							local key,var = info[3],info[5]
							local varData = EDB[key].raidicons[var]
							local type = varData.type
							if type == "FRIENDLY" then
								return format(L["Uses |cffffd200Icon %s|r"],varData.icon)
							elseif type == "MULTIFRIENDLY" then
								return format(L["Uses |cffffd200Icon %s|r to |cffffd200Icon %s|r"],varData.icon,varData.icon + varData.total - 1)
							end
						end,
					},
				},
				arrows = {
					sound = {
						type = "select",
						name = L["Sound"],
						order = 100,
						values = GetSounds,
					},
				},
			}
		}

		do
			local info_n = 7						 -- var
			local info_n_MINUS_4 = info_n - 4 -- type
			local info_n_MINUS_2 = info_n - 2 -- key

			local colors = {}
			local colors1simple = {}
			local colors2 = {}
			for k,c in pairs(addon.Media.Colors) do
				local hex = ("|cff%02x%02x%02x%s|r"):format(c.r*255,c.g*255,c.b*255,L[k])
				colors[k] = hex
				colors1simple[k] = hex
				colors2[k] = hex
			end
			colors1simple["Clear"] = L["Clear"]
			colors2["Off"] = OFF

			function handler:GetColor1(info)
				local key,var = info[3],info[5]
				if EDB[key].alerts[var].type == "simple" then
					return colors1simple
				else
					return colors
				end
			end

			function handler:GetColor2()
				return colors2
			end

			function handler:DisableSettings(info)
				return not db.profile.Encounters[info[info_n_MINUS_4]][info[info_n_MINUS_2]].enabled
			end

			function handler:GetOption(info)
				return db.profile.Encounters[info[info_n_MINUS_4]][info[info_n_MINUS_2]][info[info_n]]
			end

			function handler:SetOption(info,v)
				db.profile.Encounters[info[info_n_MINUS_4]][info[info_n_MINUS_2]][info[info_n]] = v
			end

			function handler:TestAlert(info)
				local key,var = info[info_n_MINUS_4],info[info_n_MINUS_2]
				local info = EDB[key].alerts[var]
				local stgs = db.profile.Encounters[key][var]

				if info.type == "dropdown" then
					addon.Alerts:Dropdown(var,info.varname,10,5,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,info.icon)
				elseif info.type == "centerpopup" then
					addon.Alerts:CenterPopup(var,info.varname,10,5,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,info.icon)
				elseif info.type == "simple" then
					addon.Alerts:Simple(info.varname,5,stgs.sound,stgs.color1,stgs.flashscreen,info.icon)
				end
			end
		end

		local function InjectAdvancedOptions(data,enc_args)
			-- Add output options
			for optionType,optionInfo in pairs(addon.EncDefaults) do
				local encData = data[optionType]
				local override = optionInfo.override
				if encData or override then
					enc_args[optionType] = enc_args[optionType] or {
						type = "group",
						name = optionInfo.L,
						order = optionInfo.order,
						args = {},
					}
					enc_args[optionType].inline = nil
					enc_args[optionType].childGroups = "select"

					local option_args = enc_args[optionType].args
					for var,info in pairs(override and optionInfo.list or encData) do
						option_args[var] = option_args[var] or {
							name = info.varname,
							width = "full",
						}

						option_args[var].type = "group"
						option_args[var].args = {}
						option_args[var].get = nil
						option_args[var].set = nil

						local item_args = option_args[var].args
						item_args.enabled = AdvancedItems.EnabledToggle
						if AdvancedItems.Options[optionType] then
							item_args.settings = {
								type = "group",
								name = L["Settings"],
								order = 1,
								inline = true,
								disabled = "DisableSettings",
								get = "GetOption",
								set = "SetOption",
								args = {}
							}

							local settings_args = item_args.settings.args
							for k,item in pairs(AdvancedItems.Options[optionType]) do
								settings_args[k] = item
							end
						end
					end
				end
			end
		end

		-- MODE SWAPPING

		local function SwapMode()
			for catkey in pairs(encs_args) do
				if encs_args[catkey].type == "group" then
					local cat_args = encs_args[catkey].args
					for key in pairs(cat_args) do
						local data = EDB[key]
						local enc_args = cat_args[key].args
						if db.global.AdvancedMode then
							InjectAdvancedOptions(data,enc_args)
						else
							InjectSimpleOptions(data,enc_args)
						end
					end
				end
			end
		end

		function handler:SimpleMode()
			if db.global.AdvancedMode then db.global.AdvancedMode = false; SwapMode() end
		end

		function handler:AdvancedMode()
			if not db.global.AdvancedMode then db.global.AdvancedMode = true; SwapMode() end
		end

		-- ADDITIONS/REMOVALS

		local function formatkey(str) return str:gsub(" ",""):lower() end

		local function AddEncounterOptions(data)
			-- Add a zone group if it doesn't exist. category supersedes zone
			local catkey = data.category and formatkey(data.category) or formatkey(data.zone)
			encs_args[catkey] = encs_args[catkey] or {type = "group", name = data.category or data.zone, args = {}}
			-- Update args pointer
			local cat_args = encs_args[catkey].args
			-- Exists, delete args
			if cat_args[data.key] then
				cat_args[data.key].args = {}
			else
				-- Add the encounter group
				cat_args[data.key] = {
					type = "group",
					name = data.name,
					childGroups = "tab",
					args = {
						version_header = AdvancedItems.VersionHeader,
					},
				}
			end
			-- Set pointer to the correct encounter group
			local enc_args = cat_args[data.key].args
			if db.global.AdvancedMode then
				InjectAdvancedOptions(data,enc_args)
			else
				InjectSimpleOptions(data,enc_args)
			end
		end


		local function RemoveEncounterOptions(data)
			local catkey = data.category and formatkey(data.category) or formatkey(data.zone)
			encs_args[catkey].args[data.key] = nil
			-- Remove category if there are no more encounters in it
			if not next(encs_args[catkey].args) then
				encs_args[catkey] = nil
			end
		end

		function handler:OnRegisterEncounter(event,data) AddEncounterOptions(data); ACR:NotifyChange("DXE") end
		function handler:OnUnregisterEncounter(event,data) RemoveEncounterOptions(data); ACR:NotifyChange("DXE") end

		addon.RegisterCallback(handler,"OnRegisterEncounter")
		addon.RegisterCallback(handler,"OnUnregisterEncounter")

		function module:FillEncounters() for key,data in addon:IterateEDB() do AddEncounterOptions(data) end end
	end

	---------------------------------------------
	-- ALERTS
	---------------------------------------------

	do
		local Alerts = addon.Alerts

		local function SetNoRefresh(info,v,v2,v3,v4)
			local var = info[#info]
			if var:find("Color") then 
				local c = Alerts.db.profile[var]
				c[1],c[2],c[3],c[4] = v,v2,v3,v4
			else Alerts.db.profile[var] = v end
		end

		local SelectedEncounter
		local EncounterList = {}

		local alerts_group = {
			type = "group",
			name = L["Alerts"],
			order = 200,
			handler = Alerts,
			childGroups = "tab",
			get = function(info) 
				local var = info[#info]
				if var:find("Color") then return unpack(Alerts.db.profile[var])
				else return Alerts.db.profile[var] end
			end,
			set = function(info,v,v2,v3,v4) 
				local var = info[#info]
				if var:find("Color") then 
					local c = Alerts.db.profile[var]
					c[1],c[2],c[3],c[4] = v,v2,v3,v4
				else Alerts.db.profile[var] = v end
				Alerts:RefreshBars()
			end,
			args = {}
		}

		opts_args.alerts_group = alerts_group
		local alerts_args = alerts_group.args

		local bars_group = {
			type = "group",
			name = L["Bars"],
			order = 100,
			args = {
			BarTest = {
					type = "execute",
					name = L["Test Bars"],
					desc = L["Fires a dropdown, center popup, and simple alert bars"],
					order = 100,
					func = "BarTest",
				},
				BarFillDirection = {
					order = 130,
					type = "select",
					name = L["Bar Fill Direction"],
					desc = L["The direction bars fill"],
					values = {
						FILL = L["Left to Right"],
						DEPLETE = L["Right to Left"],
					},
				},
				BarHeight = {
					order = 140,
					type = "range",
					name = L["Bar Height"],
					desc = L["Select a bar height"],
					min = 14,
					max = 40,
					step = 1,
				},
				ShowBorder = {
					order = 150,
					type = "toggle",
					name = L["Show Border"],
					desc = L["Displays a border around the bar and its icon"],
				},
				DisableDropdowns = {
					order = 160,
					type = "toggle",
					name = L["Disable Dropdowns"],
					desc = L["Anchor bars onto the center anchor only"],
					set = SetNoRefresh,
				},
			},
		}

		alerts_args.bars_group = bars_group
		local bars_args = bars_group.args

		local general_group = {
			type = "group",
			name = L["General"],
			order = 100,
			args = {
				
			},
		}

		local font_group = {
			type = "group",
			name = L["Text"],
			order = 400,
			args = {
				font_desc = {
					type = "header",
					name = L["Adjust the text used on timer bars"].."\n",
					order = 1,
				},
				bartext_group = {
					type = "group",
					name = L["Bar Text"],
					inline = true,
					order = 1,
					args = {
						BarFontSize = {
							order = 100,
							type = "range",
							name = L["Font Size"],
							desc = L["Select a font size used on bar text"],
							min = 8,
							max = 20,
							step = 1,
						},
						BarFontColor = {
							order = 200,
							type = "color",
							name = L["Font Color"],
							desc = L["Set a font color used on bar text"],
						},
						BarTextJustification = {
							order = 170,
							type = "select",
							name = L["Justification"],
							desc = L["Select a text justification"],
							values = {
								LEFT = L["Left"],
								CENTER = L["Center"],
								RIGHT = L["Right"],
							},
						},
					},
				},
				timertext_group = {
					type = "group",
					name = L["Timer Text"],
					order = 2,
					inline = true,
					args = {
						timer_desc = {
							type = "description",
							name = L["Timer font sizes are determined by bar height"].."\n",
							order = 1,
						},
						TimerXOffset = {
							order = 100,
							type = "range",
							name = L["Horizontal Offset"],
							desc = L["The horizontal position of the timer"],
							min = -20,
							max = 20,
							step = 1,
						},
						DecimalYOffset = {
							order = 200,
							type = "range",
							name = L["Decimal Vertical Offset"],
							desc = L["The vertical position of a timer's decimal text"],
							min = -10,
							max = 10,
							step = 1,
						},
						TimerFontColor = {
							order = 300,
							type = "color",
							name = L["Font Color"],
							desc = L["Set a font color used on bar timers"],
						},
					},
				},
			},
		}

		bars_args.font_group = font_group

		local icon_group = {
			type = "group",
			name = L["Icon"],
			order = 500,
			args = {
				icon_desc = {
					type = "header",
					name = L["Adjust the spell icon on timer bars"].."\n",
					order = 1,
				},
				HideIcons = {
					order = 100,
					type = "toggle",
					name = L["Hide Icons"],
					desc = L["Hide icons on bars"],
				},
				IconPosition = {
					order = 200,
					type = "select",
					name = L["Icon Position"],
					desc = L["Select where to show icons on bars"],
					values = {LEFT = L["Left"], RIGHT = L["Right"]},
					disabled = function() return Alerts.db.profile.HideIcons end,
				},
				IconOffset = {
					order = 300,
					type = "range",
					name = L["Icon Offset"],
					desc = L["How far away the icon is from the bar"],
					min = -4,
					max = 10,
					step = 0.1,
					disabled = function() return Alerts.db.profile.HideIcons end,
				},
			},
		}

		bars_args.icon_group = icon_group
						
		local top_group = {
			type = "group",
			name = L["Top Anchored Bars"],
			order = 600,
			disabled = function() return Alerts.db.profile.DisableDropdowns end,
			args = {
				top_desc = {
					type = "header",
					name = L["Adjust settings related to the top anchor"].."\n",
					order = 1,
				},
				TopScale = {
					order = 100,
					type = "range",
					name = L["Bar Scale"],
					desc = L["Adjust the size of top bars"],
					min = 0.5,
					max = 1.5,
					step = 0.05,
				},
				TopAlpha = {
					type = "range",
					name = L["Bar Alpha"],
					desc = L["Adjust the transparency of top bars"],
					order = 200,
					min = 0.1,
					max = 1,
					step = 0.05,
				},
				TopBarWidth = {
					order = 300,
					type = "range",
					name = L["Bar Width"],
					desc = L["Adjust the width of top bars"],
					min = 220,
					max = 1000,
					step = 1,
				},
				TopGrowth = {
					order = 400,
					type = "select",
					name = L["Bar Growth"],
					desc = L["The direction top bars grow"],
					values = {DOWN = L["Down"], UP = L["Up"]},
				},
			},
		}
		bars_args.top_group = top_group

		local center_group = {
			type = "group",
			name = L["Center Anchored Bars"],
			order = 700,
			args = {
				center_desc = {
					type = "header",
					name = L["Adjust settings related to the center anchor"].."\n",
					order = 1,
				},
				CenterScale = {
					order = 100,
					type = "range",
					name = L["Bar Scale"],
					desc = L["Adjust the size of center bars"],
					min = 0.5,
					max = 1.5,
					step = 0.05,
				},
				CenterAlpha = {
					type = "range",
					name = L["Bar Alpha"],
					desc = L["Adjust the transparency of center bars"],
					order = 200,
					min = 0.1,
					max = 1,
					step = 0.05,
				},
				CenterBarWidth = {
					order = 300,
					type = "range",
					name = L["Bar Width"],
					desc = L["Adjust the width of center bars"],
					min = 220,
					max = 1000,
					step = 1,
				},
				CenterGrowth = {
					order = 400,
					type = "select",
					name = L["Bar Growth"],
					desc = L["The direction center bars grow"],
					values = {DOWN = L["Down"], UP = L["Up"]},
				},
			},
		}

		bars_args.center_group = center_group

		do
			local colors = {}
			for k,c in pairs(addon.Media.Colors) do
				local hex = ("|cff%02x%02x%02x%s|r"):format(c.r*255,c.g*255,c.b*255,L[k])
				colors[k] = hex
			end

			local intro_desc = L["You can fire local or raid bars. Local bars are only seen by you. Raid bars are seen by you and raid members; You have to be a raid officer to fire raid bars"]
			local howto_desc = L["Slash commands: |cffffff00/dxelb time text|r (local bar) or |cffffff00/dxerb time text|r (raid bar): |cffffff00time|r can be in the format |cffffd200minutes:seconds|r or |cffffd200seconds|r"]
			local example1 = "/dxerb 15 Pulling in..."
			local example2 = "/dxelb 6:00 Pizza Timer"

			local custom_group = {
				type = "group",
				name = L["Custom Bars"],
				order = 750,
				args = {
					intro_desc = {
						type = "description",
						name = intro_desc,
						order = 1,
					},
					CustomLocalClr = {
						order = 2,
						type = "select",
						name = L["Local Bar Color"],
						desc = L["The color of local bars that you fire"],
						values = colors,
					},
					CustomRaidClr = {
						order = 3,
						type = "select",
						name = L["Raid Bar Color"],
						desc = L["The color of broadcasted raid bars fired by you or a raid member"],
						values = colors,
					},
					CustomSound = {
						order = 4,
						type = "select",
						name = L["Sound"],
						desc = L["The sound that plays when a custom bar is fired"],
						values = GetSounds,
					},
					howto_desc = {
						type = "description",
						name = "\n"..howto_desc,
						order = 5,
					},
					examples_desc = {
						type = "description",
						order = 6,
						name = "\n"..L["Examples"]..":\n\n   "..example1.."\n   "..example2,
					},
				},
			}

			bars_args.custom_group = custom_group
		end

		-- WARNINGS
		local warning_bar_group = {
			type = "group",
			name = L["Warning Bars"],
			order = 800,
			args = {
				WarningBars = {
					type = "toggle",
					order = 100,
					name = L["Enable Warning Bars"],
					set = SetNoRefresh,
				},
				warning_bars = {
					type = "group",
					name = L["Warning Anchor"],
					order = 200,
					inline = true,
					disabled = function() return not Alerts.db.profile.WarningBars end,
					args = {
						WarningAnchor = {
							order = 100,
							type = "toggle",
							name = L["Enable Warning Anchor"],
							desc = L["Anchors all warning bars to the warning anchor instead of the center anchor"],
							width = "full",
						},
					}
				},
			},
		}

		bars_args.warning_bar_group = warning_bar_group

		do
			local warning_bars_args = warning_bar_group.args.warning_bars.args
						
			local warning_settings_group = {
				type = "group",
				name = "",
				order = 300,
				disabled = function() return not Alerts.db.profile.WarningAnchor or not Alerts.db.profile.WarningBars end,
				args = {
					WarningScale = {
						order = 100,
						type = "range",
						name = L["Bar Scale"],
						desc = L["Adjust the size of warning bars"],
						min = 0.5,
						max = 1.5,
						step = 0.05,
					},
					WarningAlpha = {
						type = "range",
						name = L["Bar Alpha"],
						desc = L["Adjust the transparency of warning bars"],
						order = 200,
						min = 0.1,
						max = 1,
						step = 0.05,
					},
					WarningBarWidth = {
						order = 300,
						type = "range",
						name = L["Bar Width"],
						desc = L["Adjust the width of warning bars"],
						min = 220,
						max = 1000,
						step = 1,
					},
					WarningGrowth = {
						order = 400,
						type = "select",
						name = L["Bar Growth"],
						desc = L["The direction warning bars grow"],
						values = {DOWN = L["Down"], UP = L["Up"]},
					},
					RedirectCenter = {
						order = 500,
						type = "toggle",
						name = L["Redirect center bars"],
						desc = L["Anchor a center bar to the warnings anchor if its duration is less than or equal to threshold time"],
						width = "full",
					},
					RedirectThreshold = {
						order = 600,
						type = "range",
						name = L["Threshold time"],
						desc = L["If a center bar's duration is less than or equal to this then it anchors to the warnings anchor"],
						min = 1,
						max = 15,
						step = 1,
						disabled = function() return not Alerts.db.profile.WarningBars or not Alerts.db.profile.WarningAnchor or not Alerts.db.profile.RedirectCenter end
					},
				},
			}
			warning_bars_args.warning_settings_group = warning_settings_group
		end

		local warning_message_group = {
			type = "group",
			name = L["Warning Messages"],
			order = 140,
			args = {
				WarningMessages = {
					type = "toggle",
					name = L["Enable Warning Messages"],
					desc = L["Output to an additional interface"],
					order = 1,
					width = "full",
				},
				inner_group = {
					type = "group",
					name = "",
					disabled = function() return not Alerts.db.profile.WarningMessages end,
					inline = true,
					args = {
						warning_desc = {
							type = "description",
							name = L["Alerts are split into three categories: cooldowns, durations, and warnings. Cooldown and duration alerts can fire a message before they end and when they popup. Warning alerts can only fire a message when they popup. Alerts suffixed self can only fire a popup message even if it is a duration"].."\n",
							order = 2,
						},
						ClrWarningText = {
							order = 3,
							type = "toggle",
							name = L["Color Text"],
							desc = L["Class colors text"],
							width = "full",
						},
						SinkIcon = {
							order = 4,
							type = "toggle",
							name = L["Show Icon"],
							desc = L["Display an icon to the left of a warning message"],
							width = "full",
						},
						BeforeThreshold = {
							order = 5,
							type = "range",
							name = L["Before End Threshold"],
							desc = L["How many seconds before an alert ends to fire a warning message. This only applies to cooldown and duration type alerts"],
							min = 1,
							max = 15,
							step = 1,
						},
						filter_group = {
							type = "group",
							order = 6,
							name = L["Show messages for"].."...",
							inline = true,
							args = {
								filter_desc = {
									type = "description",
									name = L["Enabling |cffffd200X popups|r will make it fire a message on appearance. Enabling |cffffd200X before ending|r will make it fire a message before ending based on before end threshold"],
									order = 1,
								},
								CdPopupMessage = {type = "toggle", name = L["Cooldown popups"], order = 2, width = "full"},
								CdBeforeMessage = {type = "toggle", name = L["Cooldowns before ending"], order = 3, width = "full"},
								DurPopupMessage = {type = "toggle", name = L["Duration popups"], order = 4, width = "full"},
								DurBeforeMessage = {type = "toggle", name = L["Durations before ending"], order = 5, width = "full"},
								WarnPopupMessage = {type = "toggle", name = L["Warning popups"], order = 6, width = "full"},
							}
						},
						Output = Alerts:GetSinkAce3OptionsDataTable(),
					},
				},
			},
		}
		alerts_args.warning_message_group = warning_message_group
		warning_message_group.args.inner_group.args.Output.disabled = function() return not Alerts.db.profile.WarningMessages end
		warning_message_group.args.inner_group.args.Output.inline = true
		warning_message_group.args.inner_group.args.Output.order = -1

		local sounds_group = {
			type = "group",
			name = L["Sounds"],
			order = 150,
			set = SetNoRefresh,
			args = {
				DisableSounds = {
					order = 100,
					type = "toggle",
					name = L["Mute all"],
					desc = L["Silences all alert sounds"],
				},
				DisableAll = {
					order = 200,
					type = "execute",
					name = L["Set all to None"],
					desc = L["Sets every alert's sound to None. This affects currently loaded encounters"],
					func = function()
						for key,tbl in pairs(db.profile.Encounters) do 
							for var,stgs in pairs(tbl) do 
								if stgs.sound then stgs.sound = "None" end 
							end 
						end
					end,
					confirm = true,
				},
				curr_enc_group = {
					type = "group",
					name = L["Change encounter"],
					order = 400,
					inline = true,
					args = {
						SelectedEncounter = {
							order = 100,
							type = "select",
							name = L["Select encounter"],
							desc = L["The encounter to change"],
							get = function() return SelectedEncounter end,
							set = function(info,value) SelectedEncounter = value end,
							values = function()
								wipe(EncounterList)
								for k in addon:IterateEDB() do
									EncounterList[k] = addon.EDB[k].name
								end
								return EncounterList
							end,
						},
						DisableSelected = {
							order = 200,
							type = "execute",
							name = L["Set selected to None"],
							desc = L["Sets every alert's sound in the selected encounter to None"],
							disabled = function() return not SelectedEncounter end,
							confirm = true,
							func = function()
								for var,stgs in pairs(db.profile.Encounters[SelectedEncounter]) do
									if stgs.sound then stgs.sound = "None" end
								end
							end,
						},
					},
				},
			},
		}

		alerts_args.sounds_group = sounds_group

		local flash_group = {
			type = "group",
			name = L["Screen Flash"],
			order = 200,
			args = {
				flash_desc = {
					type = "description",
					name = L["The color of the flash becomes the main color of the alert. Colors for each alert are set in the Encounters section. If the color is set to 'Clear' it defaults to black"].."\n",
					order = 50,
				},
				DisableScreenFlash = {
					order = 75,
					type = "toggle",
					name = L["Disable Screen Flash"],
					desc = L["Turns off all alert screen flashes"],
					set = SetNoRefresh,
					width = "full",
				},
				flash_inner_group = {
					name = "",
					type = "group",
					order = 100,
					inline = true,
					disabled = function() return Alerts.db.profile.DisableScreenFlash end,
					args = {
						FlashTest = {
							type = "execute",
							name = L["Test Flash"],
							desc = L["Fires a flash using a random color"],
							order = 100,
							func = "FlashTest",
						},
						FlashTexture = {
							type = "select",
							name = L["Texture"],
							desc = L["Select a background texture"],
							order = 120,
							values = Alerts.FlashTextures,
							set = function(info,v) Alerts.db.profile.FlashTexture = v; Alerts:UpdateFlashSettings() end,
						},
						FlashAlpha = {
							type = "range",
							name = L["Alpha"],
							desc = L["Adjust the transparency of the flash"],
							order = 200,
							min = 0.1,
							max = 1,
							step = 0.05,
						},
						FlashDuration = {
							type = "range",
							name = L["Duration"],
							desc = L["Adjust how long the flash lasts"],
							order = 300,
							min = 0.2,
							max = 3,
							step = 0.05,
						},
						FlashOscillations = {
							type = "range",
							name = L["Oscillations"],
							desc = L["Adjust how many times the flash fades in and out"],
							order = 400,
							min = 1,
							max = 10,
							step = 1,
						},
						blank = genblank(450),
						ConstantClr = {
							type = "toggle",
							name = L["Use Constant Color"],
							desc = L["Make the screen flash always be the global color. It will not become the main color of the alert."],
							order = 500,
						},
						GlobalColor = {
							type = "color",
							name = L["Global Color"],
							order = 600,
							disabled = function() return Alerts.db.profile.DisableScreenFlash or not Alerts.db.profile.ConstantClr end,
						},
					},
				},
			},
		}

		alerts_args.flash_group = flash_group

		local Arrows = addon.Arrows
		local arrows_group = {
			name = L["Arrows"],
			type = "group",
			order = 120,
			get = function(info) return Arrows.db.profile[info[#info]] end,
			set = function(info,v) Arrows.db.profile[info[#info]] = v; Arrows:RefreshArrows() end,
			args = {
				Enable = {
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable the use of directional arrows"],
					order = 1,
				},
				enable_group = {
					type = "group",
					order = 2,
					name = "",
					inline = true,
					disabled = function() return not Arrows.db.profile.Enable end,
					args = {
						TestArrows = {
							name = L["Test Arrows"],
							type = "execute",
							order = 1,
							desc = L["Displays all arrows and then rotates them for ten seconds"],
							func = function() 
								for k,arrow in ipairs(addon.Arrows.frames) do
									arrow:Test()
								end
							end,
						},
						Scale = {
							name = L["Scale"],
							desc = L["Adjust the scale of arrows"],
							type = "range",
							min = 0.3,
							max = 2,
							step = 0.1
						},
					},
				},
			},
		}

		alerts_args.arrows_group = arrows_group

		local RaidIcons = addon.RaidIcons

		local raidicons_group = {
			type = "group",
			name = L["Raid Icons"],
			order = 121,
			get = function(info) return RaidIcons.db.profile[tonumber(info[#info])] end,
			set = function(info,v) RaidIcons.db.profile[tonumber(info[#info])] = v end,
			args = {}
		}

		do
			local raidicons_args = raidicons_group.args

			local desc = {
				type = "description",
				name = L["Most encounters only use |cffffd200Icon 1|r and |cffffd200Icon 2|r. Additional icons are used for abilities that require multi-marking (e.g. Anub'arak's Penetrating Cold). If you change an icon, make sure all icons are different from one another"],
				order = 0.5,
			}

			raidicons_args.desc = desc

			local dropdown = {
				type = "select",
				name = function(info) return format(L["Icon %s"],info[#info]) end,
				order = function(info) return tonumber(info[#info]) end,
				width = "double",
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
			}

			for i=1,8 do raidicons_args[tostring(i)] = dropdown end
		end

		alerts_args.raidicons_group = raidicons_group

	end

	---------------------------------------------
	-- DISTRIBUTOR
	---------------------------------------------

	do
		local list,names = {},{}
		local ListSelect,PlayerSelect
		local Distributor = addon.Distributor
		local dist_group = {
			type = "group",
			name = L["Distributor"],
			order = 350,
			get = function(info) return Distributor.db.profile[info[#info]] end,
			set = function(info,v) Distributor.db.profile[info[#info]] = v end,
			args = {
				AutoAccept = {
					type = "toggle",
					name = L["Auto accept"],
					desc = L["Automatically accepts encounters sent by players"],
					order = 50,
				},
				first_desc = {
					type = "description",
					order = 75,
					name = format(L["You can send encounters to the entire raid or to a player. You can check versions by typing |cffffd200/dxe %s|r or by opening the version checker from the pane"],L["version"]),
				},
				raid_desc = {
					type = "description",
					order = 90,
					name = "\n"..L["If you want to send an encounter to the raid, select an encounter, and then press '|cffffd200Send to raid|r'"],
				},
				ListSelect = {
					type = "select",
					order = 100,
					name = L["Select an encounter"],
					get = function() return ListSelect end,
					set = function(info,value) ListSelect = value end,
					values = function()
						wipe(list)
						for k in addon:IterateEDB() do list[k] = addon.EDB[k].name end
						return list
					end,
				},
				DistributeToRaid = {
					type = "execute",
					name = L["Send to raid"],
					order = 200,
					func = function() Distributor:Distribute(ListSelect) end,
					disabled = function() return GetNumRaidMembers() == 0 or not ListSelect  end,
				},
				player_desc = {
					type = "description",
					order = 250,
					name = "\n\n"..L["If you want to send an encounter to a player, select an encounter, select a player, and then press '|cffffd200Send to player|r'"],
				},
				PlayerSelect = {
					type = "select",
					order = 300,
					name = L["Select a player"],
					get = function() return PlayerSelect end,
					set = function(info,value) PlayerSelect = value end,
					values = function()
						wipe(names)
						for name in pairs(addon.Roster.name_to_unit) do
							if name ~= addon.PNAME then names[name] = name end
						end
						return names
					end,
					disabled = function() return GetNumRaidMembers() == 0 or not ListSelect end,
				},
				DistributeToPlayer = {
					type = "execute",
					order = 400,
					name = L["Send to player"],
					func = function() Distributor:Distribute(ListSelect, "WHISPER", PlayerSelect) end,
					disabled = function() return not PlayerSelect end,
				},
			},
		}

		opts_args.dist_group = dist_group
	end

	---------------------------------------------
	-- WINDOWS
	---------------------------------------------

	do
		windows_group = {
			type = "group",
			name = L["Windows"],
			order = 290,
			childGroups = "tab",
			args = {
				TitleBarColor = {
					order = 100,
					type = "color",
					set = function(info,v,v2,v3,v4) 
						local t = db.profile.Windows.TitleBarColor
						t[1],t[2],t[3],t[4] = v,v2,v3,v4
						addon:UpdateWindowSettings()
					end,
					get = function(info) return unpack(db.profile.Windows.TitleBarColor) end,
					name = L["Title Bar Color"],
					desc = L["Title bar color used throughout the addon"],
					hasAlpha = true,
				},
			},
		}

		opts_args.windows_group = windows_group
		local windows_args = windows_group.args

		local proximity_group = {
			type = "group",
			name = L["Proximity"],
			order = 150,
			get = function(info) return db.profile.Proximity[info[#info]] end,
			set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateProximitySettings() end,
			args = {
				header_desc = {
					type = "description",
					order = 1,
					name = L["The proximity window uses map coordinates of players to calculate distances. This relies on knowing the dimensions, in game yards, of each map. If the dimension of a map is not known, it will default to the closest range rounded up to 10, 11, or 18 game yards"].."\n",
				},
				AutoPopup = {
					type = "toggle",
					order = 50,
					width = "full",
					name = L["Auto Popup"],
					desc = L["Automatically show the proximity window if the option is enabled in an encounter (Encounters > ... > Windows > Proximity)"],
				},
				Range = {
					type = "range",
					order = 100,
					name = L["Range"],
					desc = L["The distance (game yards) a player has to be within to appear in the proximity window"],
					min = 5,
					max = 18,
					step = 1,
				},
				Delay = {
					type = "range",
					order = 200,
					name = L["Delay"],
					desc = L["The proximity window refresh rate (seconds). Increase to improve performance. |cff99ff330|r refreshes every frame"],
					min = 0,
					max = 1,
					step = 0.05,
				},
				BarAlpha = {
					type = "range",
					order = 250,
					name = L["Bar Alpha"],
					desc = L["Adjust the transparency of range bars"],
					min = 0.1,
					max = 1,
					step = 0.1,
				},
				Invert = {
					type = "toggle",
					order = 275,
					name = L["Invert Bars"],
					desc = L["Inverts all range bars"],
				},
				ClassFilter = {
					type = "multiselect",
					order = 300,
					name = L["Class Filter"],
					get = function(info,v) return db.profile.Proximity.ClassFilter[v] end,
					set = function(info,v,v2) db.profile.Proximity.ClassFilter[v] = v2 end,
					values = LOCALIZED_CLASS_NAMES_MALE,
				},
			},
		}

		windows_args.proximity_group = proximity_group
	end

	---------------------------------------------
	-- SOUNDS
	---------------------------------------------

	do
		local sounds = {}
		-- Same function at the very top of this function, without adding None
		local function GetSounds()
			table.wipe(sounds)
			for id,name in pairs(db.profile.Sounds) do
				if id:find("^ALERT") or id == "VICTORY" then sounds[id] = id end
			end
			for id,name in pairs(db.profile.CustomSounds) do
				sounds[id] = id
			end
			return sounds
		end


		local label = "ALERT1"
		local add_sound_label = ""
		local remove_sound_label = ""
		local remove_list = {}

		local sound_defaults = addon.defaults.profile.Sounds

		local sounds_group = {
			type = "group",
			name = L["Sound Labels"],
			order = 295,
			args = {
				desc1 = {
					type = "description",
					name = L["You can change the sound labels (ALERT1, ALERT2, etc.) to any sound file in SharedMedia. First, select one to change"].."\n",
					order = 1,
				},
				identifier = {
					type = "select",
					name = L["Sound Label"],
					order = 2,
					get = function() return label end,
					set = function(info,v) label = v end,
					values = GetSounds,
				},
				reset = {
					type = "execute",
					name = L["Reset"],
					desc = L["Sets the selected sound label back to its default value"],
					func = function() 
						if sound_defaults[label] then
							db.profile.Sounds[label] = sound_defaults[label] 
						else
							db.profile.CustomSounds[label] = "None"
						end
					end,
					order = 3
				},
				desc2 = {
					type = "description",
					name = "\n"..L["Now change the sound to what you want. Sounds can be tested by clicking on the speaker icons within the dropdown"].."\n",
					order = 4,
				},
				choose = {
					name = function() return format(L["Sound File for %s"],label) end,
					order = 5,
					type = "select",
					get = function(info) return sound_defaults[label] and db.profile.Sounds[label] or db.profile.CustomSounds[label] end,
					set = function(info,v) 
						if sound_defaults[label] then
							db.profile.Sounds[label] = v 
						else
							db.profile.CustomSounds[label] = v
						end
					end,
					dialogControl = "LSM30_Sound",
					values = addon.SM:HashTable("sound"),
				},
				sound_label_header = {
					type = "header",
					name = L["Add Sound Label"],
					order = 6,
				},
				add_desc = {
					type = "description",
					name = L["You can add your own sound label. Each sound label is associated with a certain sound file. Consult SharedMedia's documentation if you would like to add your own sound file. After adding a sound label, it will appear in the Sound Label list. You can then select a sound file to associate with it. Subsequently, the sound label will be available in the encounter options"],
					order = 7,
				},
				sound_label_input = {
					type = "input",
					name = L["Label name"],
					order = 8,
					get = function(info) return add_sound_label end,
					set = function(info,v) add_sound_label = v end,
				},
				sound_label_add = {
					type = "execute",
					name = L["Add"],
					order = 9,
					func = function()
						db.profile.CustomSounds[add_sound_label] = "None"
						label = add_sound_label
						add_sound_label = ""
					end,
					disabled = function() return add_sound_label == "" end
				},
				remove_desc = {
					type = "description",
					name = "\n"..L["You can remove custom sounds labels. Select a sound label from the dropdown and then click remove"],
					order = 9.5,
				},
				sound_label_list = {
					type = "select",
					order = 10,
					name = L["Custom Sound Labels"],
					get = function()
						return remove_sound_label
					end,
					set = function(info,v)
						remove_sound_label = v
					end,
					values = function()
						table.wipe(remove_list)
						for k,v in pairs(db.profile.CustomSounds) do remove_list[k] = k end
						return remove_list
					end,
				},
				sound_label_remove = {
					type = "execute",
					name = L["Remove"],
					order = 11,
					func = function()
						db.profile.CustomSounds[remove_sound_label] = nil
						if label == remove_sound_label then
							label = "ALERT1"
						end
						remove_sound_label = ""
					end,
					disabled = function() return remove_sound_label == "" end,
				},
			},
		}

		opts_args.sounds_group = sounds_group
	end

	---------------------------------------------
	-- DEBUG
	---------------------------------------------
	
	--@debug@
	local debug_group = {
		type = "group",
		order = -2,
		name = "Debug",
		args = {},
	}
	opts_args.debug_group = debug_group
	addon:AddDebugOptions(debug_group.args)
	--@end-debug@

end

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

function module:OnInitialize()
	db = addon.db
	InitializeOptions()
	InitializeOptions = nil
	self:FillEncounters()

	opts_args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
	opts_args.profile.order = -10

	AC:RegisterOptionsTable("DXE", opts)
	ACD:SetDefaultSize("DXE", DEFAULT_WIDTH, DEFAULT_HEIGHT)
end

function module:ToggleConfig() ACD[ACD.OpenFrames.DXE and "Close" or "Open"](ACD,"DXE") end
