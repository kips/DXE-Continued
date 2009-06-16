local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version
local L = DXE.L

--[[
	Metadata:
		X-DXE-Zone: [STRING] - A zone or a comma separated list of zones
]]

local Loader = DXE:NewModule("Loader","AceEvent-3.0")
local ZoneModules = {}

local function AddZoneModule(name,...)
	for i=1,select("#",...) do
		local zone = L[select(i,...):trim()]
		ZoneModules[zone] = ZoneModules[zone] or DXE.new()
		ZoneModules[zone][name] = true
	end
end

function Loader:OnInitialize()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA","LoadModules")
	for i=1, GetNumAddOns() do
		local name,_,_,enabled,loadable = GetAddOnInfo(i)
		if enabled and loadable and not IsAddOnLoaded(i) then
			local zones = GetAddOnMetadata(i,"X-DXE-Zone")
			if zones then
				AddZoneModule(name,strsplit(",",zones))
			end
		end
	end
end

function Loader:LoadModules()
	local zone = GetRealZoneText()
	if ZoneModules[zone] then
		for module in pairs(ZoneModules[zone]) do
			LoadAddOn(module)
			ZoneModules[zone][module] = nil
		end
		if not next(ZoneModules[zone]) then
			ZoneModules[zone] = DXE.delete(ZoneModules[zone])
		end
		if not next(ZoneModules) then
			self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		end
	end
end

DXE.Loader = Loader
