local addon = DXE
local ACD,L = addon.ACD,addon.L
local name_to_unit = addon.Roster.name_to_unit
local name_to_class = addon.Roster.name_to_class

local window

local rows = 5
local delay = 0.2

local ProximityFuncs = addon:GetProximityFuncs()

local pfl
local function RefreshProfile(db) pfl = db.profile end
addon:AddToRefreshProfile(RefreshProfile)

local range
local proxFunc
local function UpdateSettings()
	range = pfl.Proximity.Range
	proxFunc = range <= 10 and ProximityFuncs[10] or (range <= 11 and ProximityFuncs[11] or ProximityFuncs[18])
	delay = pfl.Proximity.Delay
end

-- Options
local handler = {}
function handler:AddOptionItems(args)
	args.general_group.args.proximity_group = {
		type = "group",
		name = L["Proximity"],
		order = 150,
		get = function(info) return pfl.Proximity[info[#info]] end,
		set = function(info,v) pfl.Proximity[info[#info]] = v; UpdateSettings() end,
		args = {
			header_desc = {
				type = "description",
				order = 1,
				name = L["The proximity window uses map coordinates of players to calculate distances. This relies on knowing the dimensions, in game yards, of each map. If the dimension of a map is not known, it will default to the closest range rounded up to 10, 11, or 18 game yards"].."\n",
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
			ClassFilter = {
				type = "multiselect",
				order = 300,
				name = L["Class Filter"],
				get = function(info,v) return pfl.Proximity.ClassFilter[v] end,
				set = function(info,v,v2) pfl.Proximity.ClassFilter[v] = v2 end,
				values = LOCALIZED_CLASS_NAMES_MALE,
			},
		},
	}
end
addon:AddOptionArgsItems(handler,"AddOptionItems")

-- nil'd after called
local function CreateWindow()
	window = addon:CreateWindow(L["Proximity"],110,100)
	window:Hide()
	window:SetContentInset(1)
	local content = window.content
	local w,h = content:GetWidth(),content:GetHeight()/rows
	local labels = {}

	local function Destroy(self)
		self.destroyed = true
		self:Hide()
		self.curr = nil
		self.lastd = nil
		self.dblank = true
		self.left:SetText("")
		self.right:SetText("")
		self.bg:SetWidth(self.bg.maxWidth)
	end

	for i=1,rows do
		local label = CreateFrame("Frame",nil,content)
		label:Hide()
		label:SetWidth(w); label:SetHeight(h)
		label:SetPoint("TOP",content,"TOP",0,-(i-1)*h)

		local name = label:CreateFontString(nil,"ARTWORK")
		name:SetFont(GameFontNormal:GetFont(),10)
		name:SetAllPoints(true)
		name:SetShadowOffset(1,-1)
		label.name = name

		local icon = label:CreateTexture(nil,"ARTWORK")
		icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		icon:SetWidth(h-2)
		icon:SetHeight(h-2)
		icon:SetPoint("LEFT",label,"LEFT",2,0)
		label.icon = icon

		local bg = label:CreateTexture(nil,"BACKGROUND")
		bg:SetPoint("LEFT")
		bg:SetPoint("TOPLEFT",icon,"TOPRIGHT")
		bg:SetPoint("BOTTOMLEFT",icon,"BOTTOMRIGHT")
		bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
		bg.maxWidth = w - ((h-2) + 2) -- bg starts at the icon. If we use 'w' it will go off the window
		label.bg = bg

		local left = label:CreateFontString(nil,"ARTWORK")
		left:SetFont(GameFontNormal:GetFont(),9)
		left:SetPoint("RIGHT",label,"RIGHT",-12,0)
		left:SetShadowOffset(1,-1)
		label.left = left

		local right = label:CreateFontString(nil,"ARTWORK")
		right:SetFont(GameFontNormal:GetFont(),6)
		right:SetPoint("BOTTOMLEFT",left,"BOTTOMRIGHT")
		right:SetShadowOffset(1,-1)
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
						label.bg:SetVertexColor(c.r,c.g,c.b,0.4)
						label.destroyed = nil
						label:Show()
					end
					if d then
						if d ~= label.lastd then
							local perc = d / range
							label.bg:SetWidth(label.bg.maxWidth * perc)
							local sec = floor(d)
							label.left:SetFormattedText("%d",sec)
							label.right:SetFormattedText("%02d",100*(d - sec))
							label.dblank = nil
							label.lastd = d
						end
					elseif not label.dblank then 
						label.left:SetText("")
						label.right:SetText("")
						label.bg:SetWidth(label.bg.maxWidth)
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
		if ACD.OpenFrames.DXE then ACD:SelectGroup("DXE","general_group","proximity_group") end
	end

	UpdateSettings()
	
	window:AddTitleButton("Interface\\AddOns\\DXE\\Textures\\Pane\\Menu.tga",optionsFunc,L["Options"])

	window:Show()
	CreateWindow = nil
end

function addon:Proximity()
	if window then window:Show()
	else CreateWindow() end
end

addon:RegisterWindow(L["Proximity"],function() addon:Proximity() end)