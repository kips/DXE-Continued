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
				DXE:AddCategoryLoader(catdata or zonedata,name)
				AddZoneModule(name,strsplit(",",zonedata))
			end
		end
	end
end

function Loader:OnEnable()
	if next(ZoneModules) then
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA","LoadModules")
		self:LoadModules()
	end
end

function Loader:LoadModules()
	local zone = GetRealZoneText()
	if ZoneModules[zone] then
		for module in pairs(ZoneModules[zone]) do
			DXE:Print(format(L["%s module loaded"],(module:match("DXE_(%w+)") or module)))
			LoadAddOn(module)
			DXE:ScheduleTimer("BroadcastAllVersions",5)
			ZoneModules[zone][module] = nil
		end
		if not next(ZoneModules[zone]) then
			ZoneModules[zone] = nil
		end
		if not next(ZoneModules) then
			self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
			ZoneModules = nil
		end
	end
end

DXE.Loader = Loader
