local addon = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
addon.version = version > addon.version and version or addon.version
local L = addon.L

local EDB = addon.EDB
local Alerts = addon.Alerts
local SM = addon.SM
local Constants = addon.Constants
local db,pfl,gbl
local util = addon.util

-----------------------------------------
-- MAIN
-----------------------------------------

local function RefreshProfile(newPfl)
	pfl = newPfl
end
addon:AddToRefreshProfile(RefreshProfile)

function addon:SetOptionsPointers()
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

local enc_group_args
local EncHandler = {}

function addon:GetOptions()
	local options = {
		type = "group",
		name = "DXE",
		handler = self,
		disabled = function() return not gbl.Enabled end,
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
				set = function(info,val) gbl.Enabled = val
						if val then self:Enable()
						else self:Disable() end
				end,
				disabled = function() return false end,
			},
		},
		plugins = {
			encounters = {
				encs_group = {
					type = "group",
					name = L["Encounters"],
					order = 200,
					childGroups = "tab",
					handler = EncHandler,
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
			alerts_group = {
				type = "group",
				name = L["Alerts"],
				order = 200,
				inline = true,
				args = {
					AlertsTest = {
						type = "execute",
						name = L["Alerts Test"],
						order = 100,
						func = "AlertsTest",
					},
					AlertsScale = {
						order = 200,
						type = "range",
						name = L["Alerts scale"],
						min = 0.5,
						max = 1.5,
						step = 0.1,
						set = function(info,v) gbl.AlertsScale = v; self.callbacks:Fire("AlertsScaleChanged") end,
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

function addon:AddPluginOptions(name,tbl)
	self.options.plugins[name] = tbl
end

-----------------------------------------
-- ENCOUNTER OPTIONS
-----------------------------------------

local Controls = {
	VersionHeader = {
		type = "header",
		name = function(info) 
			local version = EDB[info[#info-1]].version or "|cff808080"..L["Unknown"].."|r"
			return L["Version"]..": |cff99ff33"..tostring(version).."|r"
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
				values = "GetColors",
			},
			color2 = {
				type = "select",
				name = L["Flash Color"],
				order = 200,
				values = "GetColors",
				disabled = function(info) 
					local oInfo = pfl.Encounters[info[#info-4]][info[#info-2]]
					return (not oInfo.enabled) or (oInfo.color2 == false)
				end,
			},
			sound = {
				type = "select",
				name = L["Sound"],
				order = 300,
				values = "GetSounds",
				dialogControl = "LSM30_Sound",
			},
			test = {
				type = "execute",
				name = L["Test"],
				order = 400,
				func = "TestAlert",
			},
		},
		raidicons = {
			icon = {
				type = "select",
				name = L["Icon"],
				order = 100,
				values = {
					L["Star"],
					L["Circle"],
					L["Diamond"],
					L["Triangle"],
					L["Moon"],
					L["Square"],
					L["Cross"],
					L["Skull"],
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

function EncHandler:GetSounds()
	self.sounds = self.sounds or {}
	wipe(self.sounds)
	for _, name in pairs(SM:List("sound")) do self.sounds[name] = name end
	return self.sounds
end

function EncHandler:GetColors()
	if not self.colors then
		self.colors = {}
		for name,color in pairs(Constants.Colors) do
			self.colors[name] = ("|cff%02x%02x%02x"):format(color.r*255,color.g*255,color.b*255)..L[name].."|r"
		end
	end
	return self.colors
end

function EncHandler:DisableSettings(info)
	return not pfl.Encounters[info[#info-4]][info[#info-2]].enabled
end

function EncHandler:GetOutput(info)
	return pfl.Encounters[info[#info-4]][info[#info-2]][info[#info]]
end

function EncHandler:SetOutput(info,v)
	pfl.Encounters[info[#info-4]][info[#info-2]][info[#info]] = v
end

function EncHandler:TestAlert(info)
	local key,var = info[#info-4],info[#info-2]
	local info = EDB[key].alerts[var]
	local stgs = pfl.Encounters[key][var]

	if info.type == "dropdown" then
		Alerts:Dropdown(info.var,info.varname,10,5,stgs.sound,stgs.color1,stgs.color2)
	elseif info.type == "centerpopup" then
		Alerts:CenterPopup(name,info.varname,10,5,stgs.sound,stgs.color1,stgs.color2)
	elseif info.type == "simple" then
		Alerts:Simple(info.varname,5,stgs.sound,stgs.color1)
	end
end


local SignificantKeys = {
	alerts = {
		color1 = "RED",
		color2 = false,
		sound = "None",
	},
	raidicons = {
		icon = 8,
	},
	arrows = {
		sound = "None",
	},
}

local Filters = {
	sound = function(str)
		return "DXE "..str
	end
}

--[[
	Path
		category - A category or zone
		key      - Data key
		output   - raidicons, arrows, alerts..etc.
		var      - Variable stored in pfl.Encounters[key][var]
		control  - color1, color2, sound, icon..etc.

		[category][key][output][var].settings[control]
]]

-- @param name [STRING] raidicons, arrows, alerts...etc.
local function AddOutputOptions(key,data,args,defaults,order,name,l_name,dvalue)
	if not data then return end
	args[name] = {
		type = "group",
		name = l_name,
		order = order,
		childGroups = "select",
		arg = key,
		args = {},
	}
	args = args[name].args
	for _,info in pairs(data) do
		local ovalue
		-- Upgrading from <= r244
		if pfl.Encounters[key] and type(pfl.Encounters[key][info.var]) == "boolean" then
			pfl.Encounters[key][info.var] = nil
			ovalue = true
		end

		defaults[info.var] = {}
		if ovalue then
			-- The only reason it'd be stored if it was opposite of the default value
			defaults[info.var].enabled = not dvalue
		else
			defaults[info.var].enabled = dvalue
		end

		-- Add setting defaults
		for var,varDefault in pairs(SignificantKeys[name]) do
			-- Sounds need to be modified
			if Filters[var] then
				defaults[info.var][var] = info[var] and Filters[var](info[var]) or varDefault
			else
				defaults[info.var][var] = info[var] or varDefault
			end
		end

		args[info.var] = {
			name = info.varname,
			type = "group",
			width = "full",
			args = {},
		}

		-- Reach info.var by info[#info-1]
		-- Reach data.key by info[#info-3]
		local o_args = args[info.var].args
		o_args.enabled = Controls.EnabledToggle
		if Controls.Output[name] then
			o_args.settings = {
				type = "group",
				name = L["Settings"],
				order = 1,
				inline = true,
				disabled = "DisableSettings",
				get = "GetOutput",
				set = "SetOutput",
				args = {}
			}
			-- Reach info.var by info[#info-2]
			--       data.key by info[#info-4]
			local w_args = o_args.settings.args
			for k,control in pairs(Controls.Output[name]) do
				w_args[k] = control
			end
		end
	end
end


local function formatkey(str)
	return str:gsub(" ",""):lower()
end

function addon:AddEncounterOptions(data)
	-- Pointer to args
	local args = enc_group_args
	-- Add a zone group if it doesn't exist. category supersedes zone
	local catkey = data.category and formatkey(data.category) or formatkey(data.zone)
	args[catkey] = args[catkey] or {type = "group", name = data.category or data.zone, args = {} }
	-- Update args pointer
	args = args[catkey].args
	-- Exists, delete args
	if args[data.key] then
		args[data.key].args = {}
	else
	-- Add the encounter group
		args[data.key] = {
			type = "group",
			name = data.name,
			childGroups = "tab",
			args = {},
		}
	end
	-- Set pointer to the correct encounter group
	args = args[data.key].args
	-- Version header
	args.version = Controls.VersionHeader
	-- Add key to defaults
	self.defaults.profile.Encounters[data.key] = {}
	-- Pointer to defaults
	local defaults = self.defaults.profile.Encounters[data.key]
	AddOutputOptions(data.key,data.alerts,args,defaults,100,"alerts",L["Alerts"],true)
	AddOutputOptions(data.key,data.arrows,args,defaults,200,"arrows",L["Arrows"],true)
	AddOutputOptions(data.key,data.raidicons,args,defaults,300,"raidicons",L["Raid Icons"],false)
end


-- Only used with UnregisterEncounter
function addon:RemoveEncounterOptions(data)
	local catkey = data.category and formatkey(data.category) or formatkey(data.zone)
	enc_group_args[catkey].args[data.key] = nil
	-- Remove category if there are no more encounters in it
	if not next(enc_group_args[catkey].args) then
		enc_group_args[catkey] = nil
	end
end

