local addon = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
addon.version = version > addon.version and version or addon.version
local L = addon.L

--[[
	Metadata:
		X-DXE-Zone: [STRING] - A zone or a comma separated list of zones
		X-DXE-Category: [STRING] - The category of the module. Only needed if X-DXE-Zone is a list.
]]

local module = addon:NewModule("Loader","AceEvent-3.0")
addon.Loader = module
local ZMS = {}

local function AddZoneModule(name,zone,...)
	if not zone then return end
	zone = L[zone:trim()]
	ZMS[zone] = ZMS[zone] or {}
	ZMS[zone][name] = true
	AddZoneModule(name,...)
end

function module:OnInitialize()
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

function module:OnEnable()
	if next(ZMS) then
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("ADDON_LOADED")
		self:ZONE_CHANGED_NEW_AREA()
	end
end

local modules = {}
local selected

function module:AddToOptions(category,module)
	if not addon.options.args.LoaderSelect then
		selected = module
		addon.options.args.LoaderSelect = {
			type = "select",
			order = 200,
			name = L["Module"],
			get = function() return selected end,
			set = function(info,v) selected = v end,
			values = modules,
		}
		addon.options.args.Load = {
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
	modules[module] = L[category]
end

function module:CleanZoneModules(module)
	for zone,list in pairs(ZMS) do
		for addon in pairs(list) do
			if addon == module then
				ZMS[zone][module] = nil
				break
			end
		end
		ZMS[zone] = next(ZMS[zone]) and ZMS[zone]
	end
	ZMS = next(ZMS) and ZMS
end

function module:ADDON_LOADED(_,module)
	if modules[module] then
		addon:Print(format(L["%s module loaded"],(L[module:match("DXE_(%w+)")] or module)))
		modules[module] = nil
		selected = next(modules)
		self:CleanZoneModules(module)
	end
	if not next(modules) then
		modules = nil
		self:UnregisterAllEvents()
		addon.options.args.LoaderSelect = nil
		addon.options.args.Load = nil
	end
end

function module:ZONE_CHANGED_NEW_AREA()
	local zone = GetRealZoneText()
	if ZMS[zone] then
		for module in pairs(ZMS[zone]) do
			LoadAddOn(module)
		end
	end
end

