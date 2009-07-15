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

local modules = {}
local selected

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
				addon:AddOptionArgsItems(self,"AddOptionItems")
				modules[name] = L[catdata or zonedata]
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


function module:AddOptionItems(args)
	selected = next(modules)
	args.LoaderSelect = {
		type = "select",
		order = 200,
		name = L["Module"],
		get = function() return selected end,
		set = function(info,v) selected = v end,
		values = modules,
	}
	args.Load = {
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

function module:CleanZoneModules(name)
	for zone,list in pairs(ZMS) do
		for addon in pairs(list) do
			if addon == name then
				ZMS[zone][name] = nil
				break
			end
		end
		ZMS[zone] = next(ZMS[zone]) and ZMS[zone]
	end
	ZMS = next(ZMS) and ZMS
end

function module:ADDON_LOADED(_,name)
	if modules[name] then
		addon:Print(format(L["%s module loaded"],L[name:match("DXE_(%w+)")]))
		modules[name] = nil
		selected = next(modules)
		self:CleanZoneModules(name)
	end
	if not next(modules) then
		modules = nil
		self:UnregisterAllEvents()
		if addon.options then
			addon.options.args.LoaderSelect = nil
			addon.options.args.Load = nil
		else
			addon:RemoveOptionArgsItems(self)
		end
	end
end

function module:ZONE_CHANGED_NEW_AREA()
	local zone = GetRealZoneText()
	if ZMS[zone] then
		for name in pairs(ZMS[zone]) do
			LoadAddOn(name)
		end
	end
end

