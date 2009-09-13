local addon = DXE
local L = addon.L
local name_to_unit = addon.Roster.name_to_unit
local name_to_class = addon.Roster.name_to_class

local window

local rows = 5
local labels = {}

local ProximityFuncs = addon:GetProximityFuncs()
local pfl
local range
local invert
local proxFunc

function addon:UpdateProximitySettings()
	range = pfl.Proximity.Range
	proxFunc = range <= 10 and ProximityFuncs[10] or (range <= 11 and ProximityFuncs[11] or ProximityFuncs[18])
	delay = pfl.Proximity.Delay
	invert = pfl.Proximity.Invert

	for i,label in ipairs(labels) do
		local r,g,b = label.bar:GetStatusBarColor()
		label.bar:SetStatusBarColor(r,g,b,pfl.Proximity.BarAlpha)
	end
end

local function RefreshProfile(db) 
	pfl = db.profile 
	addon:UpdateProximitySettings()
end
addon:AddToRefreshProfile(RefreshProfile)

local function CreateWindow()
	window = addon:CreateWindow(L["Proximity"],110,100)
	window:Hide()
	window:SetContentInset(1)
	local content = window.content
	local w,h = content:GetWidth(),content:GetHeight()/rows

	local function Destroy(self)
		self.destroyed = true
		self:Hide()
		self.curr = nil
		self.lastd = nil
		self.dblank = true
		self.left:SetText("")
		self.right:SetText("")
		self.bar:SetValue(1)
	end

	for i=1,rows do
		local label = CreateFrame("Frame",nil,content)
		label:Hide()
		label:SetWidth(w); label:SetHeight(h)
		label:SetPoint("TOP",content,"TOP",0,-(i-1)*h)

		local icon = label:CreateTexture(nil,"ARTWORK")
		icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		icon:SetWidth(h-2)
		icon:SetHeight(h-2)
		icon:SetPoint("LEFT",label,"LEFT",2,0)
		label.icon = icon

		local bar = CreateFrame("StatusBar",nil,label)
		bar:SetHeight(h-2)
		bar:SetMinMaxValues(0,1)
		bar:SetPoint("LEFT",icon,"RIGHT")
		bar:SetPoint("RIGHT",label,"RIGHT")
		addon:RegisterStatusBar(bar)
		label.bar = bar

		local name = bar:CreateFontString(nil,"ARTWORK")
		name:SetAllPoints(label)
		name:SetShadowOffset(1,-1)
		addon:RegisterFontString(name,10)
		label.name = name

		local left = bar:CreateFontString(nil,"ARTWORK")
		left:SetPoint("RIGHT",-12,0)
		left:SetShadowOffset(1,-1)
		addon:RegisterFontString(left,9)
		label.left = left

		local right = bar:CreateFontString(nil,"ARTWORK")
		right:SetPoint("BOTTOMLEFT",left,"BOTTOMRIGHT")
		right:SetShadowOffset(1,-1)
		addon:RegisterFontString(right,6)
		label.right = right

		label.Destroy = Destroy
		labels[i] = label
	end

	local ICON_COORDS = {}
	local e = 0.02
	for class,coords in pairs(CLASS_ICON_TCOORDS) do
		local l,r,t,b = unpack(coords)
		ICON_COORDS[class] = {l+e,r-e,t+e,b-e}
	end

	local unpack,select = unpack,select
	local CN = addon.CN
	local RAID_CLASS_COLORS = RAID_CLASS_COLORS
	local floor = math.floor
	local counter = 0
	local function Execute(_,elapsed)
		if delay > 0 then
			counter = counter + elapsed
			if counter < delay then return end
		end
		counter = 0
		local n = 0
		for name in pairs(name_to_unit) do
			-- Use CheckInteractDistance (proxFunc) to take the z-axis into account
			local class = name_to_class[name]
			if name ~= addon.PNAME and proxFunc(name) and pfl.Proximity.ClassFilter[class] then
				local d = addon:GetDistanceToUnit(name)
				local flag = true
				if d and d > range then flag = false end
				if flag then
					n = n + 1
					local label = labels[n]
					if not label then break
					elseif label.curr ~= name then
						label.curr = name
						label.name:SetText(CN[name])
						label.icon:SetTexCoord(unpack(ICON_COORDS[class]))
						local c = RAID_CLASS_COLORS[class]
						label.bar:SetStatusBarColor(c.r,c.g,c.b,pfl.Proximity.BarAlpha)
						label.destroyed = nil
						label:Show()
					end
					if d then
						if d ~= label.lastd then
							local perc = d / range
							label.bar:SetValue(invert and (1-perc) or perc)
							local sec = floor(d)
							label.left:SetFormattedText("%d",sec)
							label.right:SetFormattedText("%02d",100*(d - sec))
							label.dblank = nil
							label.lastd = d
						end
					elseif not label.dblank then 
						label.left:SetText("")
						label.right:SetText("")
						label.bar:SetValue(1)
						label.dblank = true 
						label.lastd = nil
					end
				end
			end
		end
		for i=n+1,#labels do 
			local label = labels[i]
			if not label.destroyed then label:Destroy() end
		end
	end

	local updateFrame = CreateFrame("Frame",nil,window)
	updateFrame:SetScript("OnUpdate",Execute)

	window:SetScript("OnShow",function(self) counter = 0 end)

	window:SetScript("OnHide",function(self)
		for i,label in ipairs(labels) do label:Destroy() end
	end)

	local function optionsFunc()
		addon:ToggleConfig()
		if not addon.Options then return end
		if LibStub("AceConfigDialog-3.0").OpenFrames.DXE then LibStub("AceConfigDialog-3.0"):SelectGroup("DXE","windows_group","proximity_group") end
	end

	addon:UpdateProximitySettings()
	
	window:AddTitleButton("Interface\\AddOns\\DXE\\Textures\\Pane\\Menu.tga",optionsFunc,L["Options"])

	window:Show()
	CreateWindow = nil
end

function addon:Proximity()
	if window then window:Show()
	else CreateWindow() end
end

addon:RegisterWindow(L["Proximity"],function() addon:Proximity() end)
