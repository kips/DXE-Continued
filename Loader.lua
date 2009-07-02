local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version
local L = DXE.L

--[[
	Metadata:
		X-DXE-Zone: [STRING] - A zone or a comma separated list of zones
		X-DXE-Category: [STRING] - The category of the module. Only needed if X-DXE-Zone is a list.
]]

local Loader = DXE:NewModule("Loader","AceEvent-3.0")
local ZoneModules = {}
local ModulesWithOptions = {}

local function AddZoneModule(name,zone,...)
	if not zone then return end
	zone = L[zone:trim()]
	ZoneModules[zone] = ZoneModules[zone] or {}
	ZoneModules[zone][name] = true
	AddZoneModule(name,...)
end

function Loader:OnInitialize()
	for i=1, GetNumAddOns() do
		local name,_,_,enabled,loadable = GetAddOnInfo(i)
		if enabled and loadable and not IsAddOnLoaded(i) then
			local zonedata = GetAddOnMetadata(i,"X-DXE-Zone")
			if zonedata then
				local catdata = GetAddOnMetadata(i,"X-DXE-Category")
				self:AddToOptions(catdata or zonedata,name)
				AddZoneModule(name,strsplit(",",zonedata))
			end
		end
	end
end

function Loader:OnEnable()
	if next(ZoneModules) then
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA","LoadModules")
		self:RegisterEvent("ADDON_LOADED")
		self:LoadModules()
	end
end

do
	local values = {}
	local selected

	function Loader:AddToOptions(category,module)
		if not DXE.options.args.LoaderSelect then
			selected = module
			DXE.options.args.LoaderSelect = {
				type = "select",
				order = 200,
				name = L["Module"],
				get = function() return selected end,
				set = function(info,v) selected = v end,
				values = values,
			}
			DXE.options.args.Load = {
				type = "execute",
				name = "Load",
				desc = L["Modules will automatically load when you enter the appropriate zone. Click if you want to force load the currently selected one."],
				order = 300,
				func = function() 
					LoadAddOn(selected)
				end,
				width = "half",
			}
		end
		values[module] = L[category]
	end

	function Loader:ADDON_LOADED(_,module)
		if values[module] then
			values[module] = nil
			selected = next(values)
		end
		if not next(values) then
			values = nil
			DXE.options.args.LoaderSelect = nil
			DXE.options.args.Load = nil
		end
	end
end

function Loader:LoadModules()
	local zone = GetRealZoneText()
	if ZoneModules[zone] then
		for module in pairs(ZoneModules[zone]) do
			DXE:Print(format(L["%s module loaded"],(module:match("DXE_(%w+)") or module)))
			LoadAddOn(module)
			ZoneModules[zone][module] = nil
		end
		if not next(ZoneModules[zone]) then
			ZoneModules[zone] = nil
		end
		if not next(ZoneModules) then
			self:UnregisterAllEvents()
			ZoneModules = nil
		end
	end
end

DXE.Loader = Loader
