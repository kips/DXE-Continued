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
				name = format("%s - %s",L.loader["Deus Vox Encounters"],L.options["Version"])..format(": |cff99ff33%d|r",addon.version),
				order = 1,
				width = "full",
			},
			Enabled = {
				type = "toggle",
				order = 100,
				name = L.options["Enabled"],
				get = "IsEnabled",
				width = "half",
				set = function(info,val) db.profile.Enabled = val
						if val then addon:Enable()
						else addon:Disable() end
				end,
				disabled = function() return false end,
			},
			ToggleLock = {
				type = "execute",
				order = 200,
				name = L.options["Toggle Anchors"],
				desc = L.options["Toggle frame anchors. You can also toggle this by clicking on the pane's pad lock icon"],
				func = function() addon:ToggleLock() end,
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
			name = L.options["Minimap"],
			desc = L.options["Show minimap icon"],
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
			sounds["None"] = L.options["None"]
			return sounds
		end
	end

	---------------------------------------------
	-- GENERAL 
	---------------------------------------------

	do
		local globals_group = {
			type = "group",
			name = L.options["Globals"],
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
					name = L.options["Bar Texture"],
					desc = L.options["Bar texture used throughout the addon"],
					values = SM:HashTable("statusbar"),
					dialogControl = "LSM30_Statusbar",
				},
				Font = {
					order = 200,
					type = "select",
					name = L.options["Main Font"],
					desc = L.options["Font used throughout the addon"],
					values = SM:HashTable("font"),
					dialogControl = "LSM30_Font",
				},
				TimerFont = {
					order = 250,
					type = "select",
					name = L.options["Timer Font"],
					desc = L.options["Font used for timers"],
					values = SM:HashTable("font"),
					dialogControl = "LSM30_Font",
				},
				Border = {
					order = 300,
					type = "select",
					name = L.options["Border"],
					desc = L.options["Border used throughout the addon"],
					values = SM:HashTable("border"),
					dialogControl = "LSM30_Border",
				},
				blank = genblank(350),
				BackgroundColor = {
					order = 400,
					type = "color",
					name = L.options["Background Color"],
					desc = L.options["Background color used throughout the addon"],
					hasAlpha = true,
				},
				BorderColor = {
					order = 500,
					type = "color",
					name = L.options["Border Color"],
					desc = L.options["Border color used throughout the addon"],
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
			name = L.options["Pane"],
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
						name = L.options["Show Pane"],
						desc = L.options["Toggle the visibility of the pane"],
						disabled = function() return false end,
					},
					showpane_desc = {
						order = 150,
						type = "description",
						name = L.options["Show Pane"].."...",
					},
					OnlyInRaid = {
						order = 200,
						type = "toggle",
						name = L.options["Only in raids"],
						desc = L.options["Show the pane only in raids"],
						width = "full",
					},
					OnlyInParty = {
						order = 210,
						type = "toggle",
						name = L.options["Only in party"],
						desc = L.options["Show the pane only in party"],
						width = "full",
					},
					OnlyInRaidInstance = {
						order = 250,
						type = "toggle",
						name = L.options["Only in raid instances"],
						desc = L.options["Show the pane only in raid instances"],
						width = "full",
					},
					OnlyInPartyInstance = {
						order = 255,
						type = "toggle",
						name = L.options["Only in party instances"],
						desc = L.options["Show the pane only in party instances"],
						width = "full",
					},
					OnlyIfRunning = {
						order = 260,
						type = "toggle",
						name = L.options["Only if engaged"],
						desc = L.options["Show the pane only if an encounter is running"],
						width = "full",
					},
					OnlyOnMouseover = {
						order = 261,
						type = "toggle",
						name = L.options["Only on mouseover"],
						desc = L.options["Show the pane only if the mouse is over it"],
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
						name = L.options["Bar Growth"],
						desc = L.options["Direction health watcher bars grow. If set to automatic, they grow based on where the pane is"],
						values = {AUTOMATIC = L.options["Automatic"], UP = L.options["Up"], DOWN = L.options["Down"]},
						set = function(info,v)
							db.profile.Pane.BarGrowth = v
							addon:LayoutHealthWatchers()
						end,
						disabled = function() return not db.profile.Pane.Show end,
					},
					Scale = {
						order = 300,
						type = "range",
						name = L.options["Scale"],
						desc = L.options["Adjust the scale of the pane"],
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
						name = L.options["Width"],
						desc = L.options["Adjust the width of the pane"],
						set = function(info, v)
							db.profile.Pane.Width = v
							addon:SetPaneWidth()
						end,
						min = 175,
						max = 500,
						step = 1,
					},
					BarSpacing = {
						order = 320,
						type = "range",
						name = L.options["Bar Spacing"],
						desc = L.options["How far apart health bars are"],
						set = function(info, v)
							db.profile.Pane.BarSpacing = v
							addon:LayoutHealthWatchers()
						end,
						min = 0,
						max = 50,
						step = 0.1,
					},
					font_header = {
						type = "header",
						name = L.options["Font"],
						order = 750,
					},
					TitleFontSize = {
						order = 900,
						type = "range",
						name = L.options["Title Font Size"],
						desc = L.options["Select a font size used on health watchers"],
						min = 8,
						max = 20,
						step = 1,
					},
					HealthFontSize = {
						order = 1000,
						type = "range",
						name = L.options["Health Font Size"],
						desc = L.options["Select a font size used on health watchers"],
						min = 8,
						max = 20,
						step = 1,
					},
					FontColor = {
						order = 1100,
						type = "color",
						name = L.options["Font Color"],
						desc = L.options["Set a font color used on health watchers"],
					},
					misc_header = {
						type = "header",
						name = L.options["Miscellaneous"],
						order = 1200,
					},
					NeutralColor = {
						order = 1300,
						type = "color",
						name = L.options["Neutral Color"],
						desc = L.options["The color of the health bar when first shown"],
					},
					LostColor = {
						order = 1400,
						type = "color",
						name = L.options["Lost Color"],
						desc = L.options["The color of the health bar after losing the mob"],
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
			name = L.options["Miscellaneous"],
			get = function(info) return db.profile.Misc[info[#info]] end,
			set = function(info,v) db.profile.Misc[info[#info]] = v end,
			order = 300,
			args = {
				BlockRaidWarningFrame = {
					type = "toggle",
					name = L.options["Block raid warning frame messages from other boss mods"],
					order = 100,
					width = "full",
				},
				BlockRaidWarningMessages = {
					type = "toggle",
					name = L.options["Block raid warning messages, in the chat log, from other boss mods"],
					order = 200,
					width = "full",
				},
				BlockBossEmoteFrame = {
					type = "toggle",
					name = L.options["Block boss emote frame messages"],
					order = 300,
					width = "full",
				},
				BlockBossEmoteMessages = {
					type = "toggle",
					name = L.options["Block boss emote messages in the chat log"],
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
			name = L.options["About"],
			order = -2,
			args = {
				authors_desc = {
					type = "description",
					name = format("%s : %s",L.options["Authors"],"|cffffd200Kollektiv|r, |cffffd200Fariel|r"),
					order = 100,
				},
				blank1 = genblank(150),
				created_desc = {
					type = "description",
					name = format(L.options["Created for use by %s on %s"],"|cffffd200Deus Vox|r","|cffffff78US-Laughing Skull|r"),
					order = 200,
				},
				blank2 = genblank(250),
				visit_desc = {
					type = "description",
					name = format("%s: %s",L.options["Website"],"|cffffd244http://www.deusvox.net|r"),
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
			name = L.options["Encounters"],
			order = 200,
			childGroups = "tab",
			handler = handler,
			args = {
				simple_mode = {
					type = "execute",
					name = "Simple",
					desc = L.options["This mode only allows you to enable or disable"],
					order = 1,
					func = "SimpleMode",
					width = "half",
				},
				advanced_mode = {
					type = "execute",
					name = "Advanced",
					desc = L.options["This mode has customization options"],
					order = 2,
					func = "AdvancedMode",
				},
				modules = {
					type = "select",
					name = L.options["Modules"],
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
					name = L.options["Load"],
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
					local version = EDB[info[#info-1]].version or "|cff808080"..L.options["Unknown"].."|r"
					return L.options["Version"]..": |cff99ff33"..version.."|r"
				end,
				order = 1,
				width = "full",
			},
			EnabledToggle = {
				type = "toggle",
				name = L.options["Enabled"],
				width = "half",
				order = 1,										-- data.key     -- info.var
				set = function(info,v) db.profile.Encounters[info[#info-3]][info[#info-1]].enabled = v end,
				get = function(info) return db.profile.Encounters[info[#info-3]][info[#info-1]].enabled end,
			},
			Options = {
				alerts = {
					color1 = {
						type = "select",
						name = L.options["Main Color"],
						order = 100,
						values = "GetColor1",
					},
					color2 = {
						type = "select",
						name = L.options["Flash Color"],
						order = 200,
						values = "GetColor2",
						disabled = function(info) 
							local key,var = info[3],info[5]
							return (not db.profile.Encounters[key][var].enabled) or (EDB[key].alerts[var].type == "simple")
						end,
					},
					sound = {
						type = "select",
						name = L.options["Sound"],
						order = 300,
						values = GetSounds,
					},
					blank = genblank(350),
					flashscreen = {
						type = "toggle",
						name = L.options["Flash screen"],
						order = 400,
					},
					counter = {
						type = "toggle",
						name = L.options["Counter"],
						order = 500,
					},
					test = {
						type = "execute",
						name = L.options["Test"],
						order = 600,
						func = "TestAlert",
						disabled = function(info)
							local key,var = info[#info-4],info[#info-2]
							local info = EDB[key].alerts[var]
							return info.type == "absorb"
						end,
					},
					reset = {
						type = "execute",
						name = L.options["Reset"],
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
							if type == "FRIENDLY" or type == "ENEMY" then
								return format(L.options["Uses |cffffd200Icon %s|r"],varData.icon)
							elseif type == "MULTIFRIENDLY" or type == "MULTIENEMY" then
								return format(L.options["Uses |cffffd200Icon %s|r to |cffffd200Icon %s|r"],varData.icon,varData.icon + varData.total - 1)
							end
						end,
					},
				},
				arrows = {
					sound = {
						type = "select",
						name = L.options["Sound"],
						order = 100,
						values = GetSounds,
					},
				},
				windows = {
					-- prefix options with (%w+)window
					proxoverride = {
						type = "toggle",
						name = L.options["Custom range"],
						order = 100,
					},
					proxrange = {
						type = "range",
						name = L.options["Range"],
						order = 200,
						min = 5,
						max = 18,
						step = 1,
						disabled = function(info)
							local key = info[3]
							return not (db.profile.Encounters[key]["proxwindow"].enabled and db.profile.Encounters[key]["proxwindow"].proxoverride) 
						end,
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
			colors1simple["Clear"] = L.options["Clear"]
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
								name = L.options["Settings"],
								order = 1,
								inline = true,
								disabled = "DisableSettings",
								get = "GetOption",
								set = "SetOption",
								args = {}
							}

							local settings_args = item_args.settings.args
							for k,item in pairs(AdvancedItems.Options[optionType]) do
								-- special handling for windows since not all windows share the same options
								if optionType == "windows" then
									-- prefix needs to match
									if k:find("^"..var:match("(%w+)window")) then
										settings_args[k] = item
									end
								else
									settings_args[k] = item
								end
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
			name = L.options["Alerts"],
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
			name = L.options["Bars"],
			order = 100,
			args = {
			BarTest = {
					type = "execute",
					name = L.options["Test Bars"],
					desc = L.options["Fires a dropdown, center popup, and simple alert bars"],
					order = 100,
					func = "BarTest",
				},
				BarFillDirection = {
					order = 130,
					type = "select",
					name = L.options["Bar Fill Direction"],
					desc = L.options["The direction bars fill"],
					values = {
						FILL = L.options["Left to Right"],
						DEPLETE = L.options["Right to Left"],
					},
				},
				BarHeight = {
					order = 140,
					type = "range",
					name = L.options["Bar Height"],
					desc = L.options["Select a bar height"],
					min = 14,
					max = 40,
					step = 1,
				},
				ShowBorder = {
					order = 150,
					type = "toggle",
					name = L.options["Show Border"],
					desc = L.options["Displays a border around the bar and its icon"],
				},
				DisableDropdowns = {
					order = 160,
					type = "toggle",
					name = L.options["Disable Dropdowns"],
					desc = L.options["Anchor bars onto the center anchor only"],
					set = SetNoRefresh,
				},
			},
		}

		alerts_args.bars_group = bars_group
		local bars_args = bars_group.args

		local general_group = {
			type = "group",
			name = L.options["General"],
			order = 100,
			args = {
				
			},
		}

		local font_group = {
			type = "group",
			name = L.options["Text"],
			order = 400,
			args = {
				font_desc = {
					type = "header",
					name = L.options["Adjust the text used on timer bars"].."\n",
					order = 1,
				},
				bartext_group = {
					type = "group",
					name = L.options["Bar Text"],
					inline = true,
					order = 1,
					args = {
						BarFontSize = {
							order = 100,
							type = "range",
							name = L.options["Font Size"],
							desc = L.options["Select a font size used on bar text"],
							min = 8,
							max = 20,
							step = 1,
						},
						BarFontColor = {
							order = 200,
							type = "color",
							name = L.options["Font Color"],
							desc = L.options["Set a font color used on bar text"],
						},
						BarTextJustification = {
							order = 170,
							type = "select",
							name = L.options["Justification"],
							desc = L.options["Select a text justification"],
							values = {
								LEFT = L.options["Left"],
								CENTER = L.options["Center"],
								RIGHT = L.options["Right"],
							},
						},
					},
				},
				timertext_group = {
					type = "group",
					name = L.options["Timer Text"],
					order = 2,
					inline = true,
					args = {
						timer_desc = {
							type = "description",
							name = L.options["Timer font sizes are determined by bar height"].."\n",
							order = 1,
						},
						TimerXOffset = {
							order = 100,
							type = "range",
							name = L.options["Horizontal Offset"],
							desc = L.options["The horizontal position of the timer"],
							min = -20,
							max = 20,
							step = 1,
						},
						DecimalYOffset = {
							order = 200,
							type = "range",
							name = L.options["Decimal Vertical Offset"],
							desc = L.options["The vertical position of a timer's decimal text"],
							min = -10,
							max = 10,
							step = 1,
						},
						TimerFontColor = {
							order = 300,
							type = "color",
							name = L.options["Font Color"],
							desc = L.options["Set a font color used on bar timers"],
						},
					},
				},
			},
		}

		bars_args.font_group = font_group

		local icon_group = {
			type = "group",
			name = L.options["Icon"],
			order = 500,
			args = {
				icon_desc = {
					type = "header",
					name = L.options["Adjust the spell icon on timer bars"].."\n",
					order = 1,
				},
				HideIcons = {
					order = 100,
					type = "toggle",
					name = L.options["Hide Icons"],
					desc = L.options["Hide icons on bars"],
				},
				IconPosition = {
					order = 200,
					type = "select",
					name = L.options["Icon Position"],
					desc = L.options["Select where to show icons on bars"],
					values = {LEFT = L.options["Left"], RIGHT = L.options["Right"]},
					disabled = function() return Alerts.db.profile.HideIcons end,
				},
				IconOffset = {
					order = 300,
					type = "range",
					name = L.options["Icon Offset"],
					desc = L.options["How far away the icon is from the bar"],
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
			name = L.options["Top Anchored Bars"],
			order = 600,
			disabled = function() return Alerts.db.profile.DisableDropdowns end,
			args = {
				top_desc = {
					type = "header",
					name = L.options["Adjust settings related to the top anchor"].."\n",
					order = 1,
				},
				TopScale = {
					order = 100,
					type = "range",
					name = L.options["Bar Scale"],
					desc = L.options["Adjust the size of top bars"],
					min = 0.5,
					max = 1.5,
					step = 0.05,
				},
				TopAlpha = {
					type = "range",
					name = L.options["Bar Alpha"],
					desc = L.options["Adjust the transparency of top bars"],
					order = 200,
					min = 0.1,
					max = 1,
					step = 0.05,
				},
				TopBarWidth = {
					order = 300,
					type = "range",
					name = L.options["Bar Width"],
					desc = L.options["Adjust the width of top bars"],
					min = 220,
					max = 1000,
					step = 1,
				},
				TopGrowth = {
					order = 400,
					type = "select",
					name = L.options["Bar Growth"],
					desc = L.options["The direction top bars grow"],
					values = {DOWN = L.options["Down"], UP = L.options["Up"]},
				},
			},
		}
		bars_args.top_group = top_group

		local center_group = {
			type = "group",
			name = L.options["Center Anchored Bars"],
			order = 700,
			args = {
				center_desc = {
					type = "header",
					name = L.options["Adjust settings related to the center anchor"].."\n",
					order = 1,
				},
				CenterScale = {
					order = 100,
					type = "range",
					name = L.options["Bar Scale"],
					desc = L.options["Adjust the size of center bars"],
					min = 0.5,
					max = 1.5,
					step = 0.05,
				},
				CenterAlpha = {
					type = "range",
					name = L.options["Bar Alpha"],
					desc = L.options["Adjust the transparency of center bars"],
					order = 200,
					min = 0.1,
					max = 1,
					step = 0.05,
				},
				CenterBarWidth = {
					order = 300,
					type = "range",
					name = L.options["Bar Width"],
					desc = L.options["Adjust the width of center bars"],
					min = 220,
					max = 1000,
					step = 1,
				},
				CenterGrowth = {
					order = 400,
					type = "select",
					name = L.options["Bar Growth"],
					desc = L.options["The direction center bars grow"],
					values = {DOWN = L.options["Down"], UP = L.options["Up"]},
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

			local intro_desc = L.options["You can fire local or raid bars. Local bars are only seen by you. Raid bars are seen by you and raid members; You have to be a raid officer to fire raid bars"]
			local howto_desc = L.options["Slash commands: |cffffff00/dxelb time text|r (local bar) or |cffffff00/dxerb time text|r (raid bar): |cffffff00time|r can be in the format |cffffd200minutes:seconds|r or |cffffd200seconds|r"]
			local example1 = "/dxerb 15 Pulling in..."
			local example2 = "/dxelb 6:00 Pizza Timer"

			local custom_group = {
				type = "group",
				name = L.options["Custom Bars"],
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
						name = L.options["Local Bar Color"],
						desc = L.options["The color of local bars that you fire"],
						values = colors,
					},
					CustomRaidClr = {
						order = 3,
						type = "select",
						name = L.options["Raid Bar Color"],
						desc = L.options["The color of broadcasted raid bars fired by you or a raid member"],
						values = colors,
					},
					CustomSound = {
						order = 4,
						type = "select",
						name = L.options["Sound"],
						desc = L.options["The sound that plays when a custom bar is fired"],
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
						name = "\n"..L.options["Examples"]..":\n\n   "..example1.."\n   "..example2,
					},
				},
			}

			bars_args.custom_group = custom_group
		end

		-- WARNINGS
		local warning_bar_group = {
			type = "group",
			name = L.options["Warning Bars"],
			order = 800,
			args = {
				WarningBars = {
					type = "toggle",
					order = 100,
					name = L.options["Enable Warning Bars"],
					set = SetNoRefresh,
				},
				warning_bars = {
					type = "group",
					name = L.options["Warning Anchor"],
					order = 200,
					inline = true,
					disabled = function() return not Alerts.db.profile.WarningBars end,
					args = {
						WarningAnchor = {
							order = 100,
							type = "toggle",
							name = L.options["Enable Warning Anchor"],
							desc = L.options["Anchors all warning bars to the warning anchor instead of the center anchor"],
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
						name = L.options["Bar Scale"],
						desc = L.options["Adjust the size of warning bars"],
						min = 0.5,
						max = 1.5,
						step = 0.05,
					},
					WarningAlpha = {
						type = "range",
						name = L.options["Bar Alpha"],
						desc = L.options["Adjust the transparency of warning bars"],
						order = 200,
						min = 0.1,
						max = 1,
						step = 0.05,
					},
					WarningBarWidth = {
						order = 300,
						type = "range",
						name = L.options["Bar Width"],
						desc = L.options["Adjust the width of warning bars"],
						min = 220,
						max = 1000,
						step = 1,
					},
					WarningGrowth = {
						order = 400,
						type = "select",
						name = L.options["Bar Growth"],
						desc = L.options["The direction warning bars grow"],
						values = {DOWN = L.options["Down"], UP = L.options["Up"]},
					},
					RedirectCenter = {
						order = 500,
						type = "toggle",
						name = L.options["Redirect center bars"],
						desc = L.options["Anchor a center bar to the warnings anchor if its duration is less than or equal to threshold time"],
						width = "full",
					},
					RedirectThreshold = {
						order = 600,
						type = "range",
						name = L.options["Threshold time"],
						desc = L.options["If a center bar's duration is less than or equal to this then it anchors to the warnings anchor"],
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
			name = L.options["Warning Messages"],
			order = 140,
			args = {
				WarningMessages = {
					type = "toggle",
					name = L.options["Enable Warning Messages"],
					desc = L.options["Output to an additional interface"],
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
							name = L.options["Alerts are split into three categories: cooldowns, durations, and warnings. Cooldown and duration alerts can fire a message before they end and when they popup. Warning alerts can only fire a message when they popup. Alerts suffixed self can only fire a popup message even if it is a duration"].."\n",
							order = 2,
						},
						AnnounceToRaid = {
							order = 2.5,
							type = "toggle",
							name = L.options["Announce to raid"],
							desc = L.options["Announce warning messages through raid warning chat"],
							width = "full",
						},
						ClrWarningText = {
							order = 3,
							type = "toggle",
							name = L.options["Color Text"],
							desc = L.options["Class colors text"],
							width = "full",
						},
						SinkIcon = {
							order = 4,
							type = "toggle",
							name = L.options["Show Icon"],
							desc = L.options["Display an icon to the left of a warning message"],
							width = "full",
						},
						BeforeThreshold = {
							order = 5,
							type = "range",
							name = L.options["Before End Threshold"],
							desc = L.options["How many seconds before an alert ends to fire a warning message. This only applies to cooldown and duration type alerts"],
							min = 1,
							max = 15,
							step = 1,
						},
						filter_group = {
							type = "group",
							order = 6,
							name = L.options["Show messages for"].."...",
							inline = true,
							args = {
								filter_desc = {
									type = "description",
									name = L.options["Enabling |cffffd200X popups|r will make it fire a message on appearance. Enabling |cffffd200X before ending|r will make it fire a message before ending based on before end threshold"],
									order = 1,
								},
								CdPopupMessage = {type = "toggle", name = L.options["Cooldown popups"], order = 2, width = "full"},
								CdBeforeMessage = {type = "toggle", name = L.options["Cooldowns before ending"], order = 3, width = "full"},
								DurPopupMessage = {type = "toggle", name = L.options["Duration popups"], order = 4, width = "full"},
								DurBeforeMessage = {type = "toggle", name = L.options["Durations before ending"], order = 5, width = "full"},
								WarnPopupMessage = {type = "toggle", name = L.options["Warning popups"], order = 6, width = "full"},
							}
						},
						output_desc = {
							type = "description",
							order = 7,
							name = L.options["You can output warning messages many different ways and they will only be seen by you. If you don't want to see these then click |cffffd200'None'|r"],
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
			name = L.options["Sounds"],
			order = 150,
			set = SetNoRefresh,
			args = {
				DisableSounds = {
					order = 100,
					type = "toggle",
					name = L.options["Mute all"],
					desc = L.options["Silences all alert sounds"],
				},
				DisableAll = {
					order = 200,
					type = "execute",
					name = L.options["Set all to None"],
					desc = L.options["Sets every alert's sound to None. This affects currently loaded encounters"],
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
					name = L.options["Change encounter"],
					order = 400,
					inline = true,
					args = {
						SelectedEncounter = {
							order = 100,
							type = "select",
							name = L.options["Select encounter"],
							desc = L.options["The encounter to change"],
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
							name = L.options["Set selected to None"],
							desc = L.options["Sets every alert's sound in the selected encounter to None"],
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
			name = L.options["Screen Flash"],
			order = 200,
			args = {
				flash_desc = {
					type = "description",
					name = L.options["The color of the flash becomes the main color of the alert. Colors for each alert are set in the Encounters section. If the color is set to 'Clear' it defaults to black"].."\n",
					order = 50,
				},
				DisableScreenFlash = {
					order = 75,
					type = "toggle",
					name = L.options["Disable Screen Flash"],
					desc = L.options["Turns off all alert screen flashes"],
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
							name = L.options["Test Flash"],
							desc = L.options["Fires a flash using a random color"],
							order = 100,
							func = "FlashTest",
						},
						FlashTexture = {
							type = "select",
							name = L.options["Texture"],
							desc = L.options["Select a background texture"],
							order = 120,
							values = Alerts.FlashTextures,
							set = function(info,v) Alerts.db.profile.FlashTexture = v; Alerts:UpdateFlashSettings() end,
						},
						FlashAlpha = {
							type = "range",
							name = L.options["Alpha"],
							desc = L.options["Adjust the transparency of the flash"],
							order = 200,
							min = 0.1,
							max = 1,
							step = 0.05,
						},
						FlashDuration = {
							type = "range",
							name = L.options["Duration"],
							desc = L.options["Adjust how long the flash lasts"],
							order = 300,
							min = 0.2,
							max = 3,
							step = 0.05,
						},
						EnableOscillations = {
							type = "toggle",
							name = L.options["Enable Oscillations"],
							desc = L.options["Enables the strobing effect"],
							order = 350,
						},
						FlashOscillations = {
							type = "range",
							name = L.options["Oscillations"],
							desc = L.options["Adjust how many times the flash fades in and out"],
							order = 400,
							min = 1,
							max = 10,
							step = 1,
							disabled = function() return Alerts.db.profile.DisableScreenFlash or not Alerts.db.profile.EnableOscillations end,
						},
						blank = genblank(450),
						ConstantClr = {
							type = "toggle",
							name = L.options["Use Constant Color"],
							desc = L.options["Make the screen flash always be the global color. It will not become the main color of the alert."],
							order = 500,
						},
						GlobalColor = {
							type = "color",
							name = L.options["Global Color"],
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
			name = L.options["Arrows"],
			type = "group",
			order = 120,
			get = function(info) return Arrows.db.profile[info[#info]] end,
			set = function(info,v) Arrows.db.profile[info[#info]] = v; Arrows:RefreshArrows() end,
			args = {
				Enable = {
					type = "toggle",
					name = L.options["Enable"],
					desc = L.options["Enable the use of directional arrows"],
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
							name = L.options["Test Arrows"],
							type = "execute",
							order = 1,
							desc = L.options["Displays all arrows and then rotates them for ten seconds"],
							func = function() 
								for k,arrow in ipairs(addon.Arrows.frames) do
									arrow:Test()
								end
							end,
						},
						Scale = {
							name = L.options["Scale"],
							desc = L.options["Adjust the scale of arrows"],
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
			name = L.options["Raid Icons"],
			order = 121,
			get = function(info) return RaidIcons.db.profile[tonumber(info[#info])] end,
			set = function(info,v) RaidIcons.db.profile[tonumber(info[#info])] = v end,
			args = {
				Enabled = {
					type = "toggle",
					get = function(info) return RaidIcons.db.profile.Enabled end,
					set = function(info,v) RaidIcons.db.profile.Enabled = v end,
					name = L.options["Enable"],
					desc = L.options["Enable raid icon marking. If this is disabled then you will not mark targets even if you have raid assist and raid icons enabled in encounters"],
					order = 0.1,
				},
			}
		}

		do
			local raidicons_args = raidicons_group.args

			local desc = {
				type = "description",
				name = L.options["Most encounters only use |cffffd200Icon 1|r and |cffffd200Icon 2|r. Additional icons are used for abilities that require multi-marking (e.g. Anub'arak's Penetrating Cold). If you change an icon, make sure all icons are different from one another"],
				order = 0.5,
			}

			raidicons_args.desc = desc

			local dropdown = {
				type = "select",
				name = function(info) return format(L.options["Icon %s"],info[#info]) end,
				order = function(info) return tonumber(info[#info]) end,
				width = "double",
				values = {
					"1. "..L.options["Star"],
					"2. "..L.options["Circle"],
					"3. "..L.options["Diamond"],
					"4. "..L.options["Triangle"],
					"5. "..L.options["Moon"],
					"6. "..L.options["Square"],
					"7. "..L.options["Cross"],
					"8. "..L.options["Skull"],
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
			name = L.options["Distributor"],
			order = 350,
			get = function(info) return Distributor.db.profile[info[#info]] end,
			set = function(info,v) Distributor.db.profile[info[#info]] = v end,
			args = {
				AutoAccept = {
					type = "toggle",
					name = L.options["Auto accept"],
					desc = L.options["Automatically accepts encounters sent by players"],
					order = 50,
				},
				first_desc = {
					type = "description",
					order = 75,
					name = format(L.options["You can send encounters to the entire raid or to a player. You can check versions by typing |cffffd200/dxe %s|r or by opening the version checker from the pane"],L.options["version"]),
				},
				raid_desc = {
					type = "description",
					order = 90,
					name = "\n"..L.options["If you want to send an encounter to the raid, select an encounter, and then press '|cffffd200Send to raid|r'"],
				},
				ListSelect = {
					type = "select",
					order = 100,
					name = L.options["Select an encounter"],
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
					name = L.options["Send to raid"],
					order = 200,
					func = function() Distributor:Distribute(ListSelect) end,
					disabled = function() return GetNumRaidMembers() == 0 or not ListSelect  end,
				},
				player_desc = {
					type = "description",
					order = 250,
					name = "\n\n"..L.options["If you want to send an encounter to a player, select an encounter, select a player, and then press '|cffffd200Send to player|r'"],
				},
				PlayerSelect = {
					type = "select",
					order = 300,
					name = L.options["Select a player"],
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
					name = L.options["Send to player"],
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
			name = L.options["Windows"],
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
					name = L.options["Title Bar Color"],
					desc = L.options["Title bar color used throughout the addon"],
					hasAlpha = true,
				},
			},
		}

		opts_args.windows_group = windows_group
		local windows_args = windows_group.args

		local proximity_group = {
			type = "group",
			name = L.options["Proximity"],
			order = 150,
			get = function(info) return db.profile.Proximity[info[#info]] end,
			set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateProximitySettings() end,
			args = {
				header_desc = {
					type = "description",
					order = 1,
					name = L.options["The proximity window uses map coordinates of players to calculate distances. This relies on knowing the dimensions, in game yards, of each map. If the dimension of a map is not known, it will default to the closest range rounded up to 10, 11, or 18 game yards"].."\n",
				},
				toggles_group = {
					type = "group",
					name = L.options["Toggles"],
					order = 2,
					inline = true,
					args = {
						AutoPopup = {
							type = "toggle",
							order = 50,
							width = "full",
							name = L.options["Auto Popup"],
							desc = L.options["Automatically show the proximity window if the option is enabled in an encounter (Encounters > ... > Windows > Proximity)"],
						},
						AutoHide = {
							type = "toggle",
							order = 60,
							width = "full",
							name = L.options["Auto Hide"],
							desc = L.options["Automatically hide the proximity window when an encounter is defeated"],
						},
						Invert = {
							type = "toggle",
							order = 75,
							width = "full",
							name = L.options["Invert Bars"],
							desc = L.options["Inverts all range bars"],
						},
						Dummy = {
							type = "toggle",
							order = 80,
							width = "full",
							name = L.options["Dummy Bars"],
							desc = L.options["Displays dummy bars that can be useful for configuration"],
						},
					},
				},
				general_group = {
					type = "group",
					name = L.options["General"],
					order = 3,
					inline = true,
					args = {
						Range = {
							type = "range",
							order = 100,
							name = L.options["Range"],
							desc = L.options["The distance (game yards) a player has to be within to appear in the proximity window"],
							min = 5,
							max = 18,
							step = 1,
						},
						Delay = {
							type = "range",
							order = 200,
							name = L.options["Delay"],
							desc = L.options["The proximity window refresh rate (seconds). Increase to improve performance. |cff99ff330|r refreshes every frame"],
							min = 0,
							max = 1,
							step = 0.05,
						},
						BarAlpha = {
							type = "range",
							order = 250,
							name = L.options["Bar Alpha"],
							desc = L.options["Adjust the transparency of range bars"],
							min = 0.1,
							max = 1,
							step = 0.1,
						},
						Rows = {
							type = "range",
							order = 260,
							name = L.options["Rows"],
							desc = L.options["The number of bars to show"],
							min = 1,
							max = 15,
							step = 1,
						},
						IconPosition = {
							type = "select",
							order = 270,
							name = L.options["Icon Position"],
							desc = L.options["The position of the class icon"],
							values = {
								LEFT = L.options["Left"],
								RIGHT = L.options["Right"],
							},
						},
					},
				},
				font_group = {
					type = "group",
					name = L.options["Text"],
					order = 4,
					inline = true,
					args = {
						NameFontSize = {
							order = 1,
							type = "range",
							name = L.options["Name Font Size"],
							desc = L.options["Select a font size used on name text"],
							min = 7,
							max = 30,
							step = 1,
						},
						NameOffset = {
							order = 2,
							type = "range",
							name = L.options["Name Horizontal Offset"],
							desc = L.options["The horizontal position of name text"],
							min = -175,
							max = 175,
							step = 1,
						},
						NameAlignment = {
							order = 2.3,
							type = "select",
							name = L.options["Name Alignment"],
							desc = L.options["The text alignment of the name text"],
							values = {
								LEFT = L.options["Left"],
								CENTER = L.options["Center"],
								RIGHT = L.options["Right"],
							},
						},
						blank = genblank(2.5),
						TimeFontSize = {
							order = 3,
							type = "range",
							name = L.options["Time Font Size"],
							desc = L.options["Select a font size used on time text"],
							min = 7,
							max = 30,
							step = 1,
						},
						TimeOffset = {
							order = 4,
							type = "range",
							name = L.options["Time Horizontal Offset"],
							desc = L.options["The horizontal position of time text"],
							min = -220,
							max = 175,
							step = 1,
						},
					},
				},
				ClassFilter = {
					type = "multiselect",
					order = 5,
					name = L.options["Class Filter"],
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
			name = L.options["Sound Labels"],
			order = 295,
			args = {
				desc1 = {
					type = "description",
					name = L.options["You can change the sound labels (ALERT1, ALERT2, etc.) to any sound file in SharedMedia. First, select one to change"].."\n",
					order = 1,
				},
				identifier = {
					type = "select",
					name = L.options["Sound Label"],
					order = 2,
					get = function() return label end,
					set = function(info,v) label = v end,
					values = GetSounds,
				},
				reset = {
					type = "execute",
					name = L.options["Reset"],
					desc = L.options["Sets the selected sound label back to its default value"],
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
					name = "\n"..L.options["Now change the sound to what you want. Sounds can be tested by clicking on the speaker icons within the dropdown"].."\n",
					order = 4,
				},
				choose = {
					name = function() return format(L.options["Sound File for %s"],label) end,
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
					name = L.options["Add Sound Label"],
					order = 6,
				},
				add_desc = {
					type = "description",
					name = L.options["You can add your own sound label. Each sound label is associated with a certain sound file. Consult SharedMedia's documentation if you would like to add your own sound file. After adding a sound label, it will appear in the Sound Label list. You can then select a sound file to associate with it. Subsequently, the sound label will be available in the encounter options"],
					order = 7,
				},
				sound_label_input = {
					type = "input",
					name = L.options["Label name"],
					order = 8,
					get = function(info) return add_sound_label end,
					set = function(info,v) add_sound_label = v end,
				},
				sound_label_add = {
					type = "execute",
					name = L.options["Add"],
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
					name = "\n"..L.options["You can remove custom sounds labels. Select a sound label from the dropdown and then click remove"],
					order = 9.5,
				},
				sound_label_list = {
					type = "select",
					order = 10,
					name = L.options["Custom Sound Labels"],
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
					name = L.options["Remove"],
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
	if addon.LDS then addon.LDS:EnhanceOptions(opts_args.profile,db) end
	opts_args.profile.order = -10

	AC:RegisterOptionsTable("DXE", opts)
	ACD:SetDefaultSize("DXE", DEFAULT_WIDTH, DEFAULT_HEIGHT)
end

function module:ToggleConfig() ACD[ACD.OpenFrames.DXE and "Close" or "Open"](ACD,"DXE") end
