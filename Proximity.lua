local addon = DXE
local L = addon.L
local name_to_unit= addon.Roster.name_to_unit
local window

local rows = 5
local delay = 0.5

local function CreateWindow()
	window = addon:CreateWindow(L["Proximity"],110,100)
	window:Hide()
	window:SetContentInset(1)
	local content = window.content
	local w,h = content:GetWidth(),content:GetHeight()/rows
	local labels = {}
	for i=1,rows do
		local label = CreateFrame("Frame",nil,content)
		label:Hide()
		label:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", insets = {left = 1, right = 1, top = 1, bottom = 1}})
		label:SetBackdropBorderColor(0.33,0.33,0.33)
		label:SetWidth(w); label:SetHeight(h)
		label:SetPoint("TOP",content,"TOP",0,-(i-1)*h)
		local fs = label:CreateFontString(nil,"ARTWORK")
		fs:SetFont(GameFontNormal:GetFont(),10)
		fs:SetAllPoints(true)
		label.fs = fs
		local icon = label:CreateTexture(nil,"ARTWORK")
		icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		icon:SetWidth(h-4)
		icon:SetHeight(h-4)
		icon:SetPoint("LEFT",label,"LEFT",3,0)
		label.icon = icon
		labels[i] = label
	end

	local ICON_COORDS = {}
	local e = 0.02
	for class,coords in pairs(CLASS_ICON_TCOORDS) do
		local l,r,t,b = unpack(coords)
		ICON_COORDS[class] = {l+e,r-e,t+e,b-e}
	end

	local CheckInteractDistance = CheckInteractDistance
	local unpack,select = unpack,select
	local CN = addon.CN
	local UnitClass = UnitClass
	local function Execute()
		local n = 0
		for name in pairs(name_to_unit) do
			if name ~= addon.PNAME and CheckInteractDistance(name,3) then
				n = n + 1
				local label = labels[n]
				if not label then break
				elseif label.curr ~= name then
					label.curr = name
					label.fs:SetText(CN[name])
					label.icon:SetTexCoord(unpack(ICON_COORDS[select(2,UnitClass(name))]))
					label:Show()
				end
			end
		end
		for i=n+1,#labels do
			labels[i]:Hide()
			labels[i].curr = nil
		end
	end

	window:SetScript("OnShow",function(self)
		self.handle = addon.AceTimer:ScheduleRepeatingTimer(Execute,delay)
	end)

	window:SetScript("OnHide",function(self)
		addon.AceTimer:CancelTimer(self.handle)
		self.handle = nil
		for i,label in ipairs(labels) do
			label:Hide()
			label.curr = nil
		end
	end)

	window:Show()
	CreateWindow = nil
end

function addon:Proximity()
	if window then
		window:Show()
	else
		CreateWindow()
	end
end

addon:RegisterWindow(L["Proximity"],function() addon:Proximity() end)
