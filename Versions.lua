local addon = DXE
local L = addon.L
local util = addon.util

local gmatch,format = string.gmatch,string.format
local sort,remove,concat = table.sort,table.remove,table.concat
local tonumber = tonumber

local Roster = addon.Roster
local EDB = addon.EDB
local RVS = {}

local window
local dropdown, heading, scrollframe
local list,headers = {},{}
local value = "addon"
local sortIndex = 1

local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
   edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	edgeSize = 9,             
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local NONE = -1
local GREEN = "|cff99ff33"
local BLUE  = "|cff3399ff"
local GREY  = "|cff999999"
local RED   = "|cffff3300"
local NUM_ROWS = 12
local ROW_HEIGHT = 16

---------------------------------------------
-- GUI
---------------------------------------------

local function ColorCode(text)
	if type(text) == "string" then
		return addon.CN[text]
	elseif type(text) == "number" then
		if text == NONE then
			return GREY..L["None"].."|r"
		else
			local v = value == "addon" and addon.version or EDB[value].version
			if v > text then
				return RED..text.."|r"
			elseif v < text then
				return BLUE..text.."|r"
			else
				return GREEN..text.."|r"
			end
		end
	end
end

local function UpdateScroll()
	local n = #RVS
	FauxScrollFrame_Update(scrollframe, n, NUM_ROWS, ROW_HEIGHT, nil, nil, nil, nil, nil, nil, true)
	local offset = FauxScrollFrame_GetOffset(scrollframe)
	for i = 1, NUM_ROWS do
		local j = i + offset
		if j <= n then
			for k, header in ipairs(headers) do
				local text = ColorCode(RVS[j][k])
				header.rows[i]:SetText(text)
				header.rows[i]:Show()
			end
		else
			for k, header in ipairs(headers) do
				header.rows[i]:Hide()
			end
		end
	end
end

local function SortAsc(a,b) return a[sortIndex] < b[sortIndex] end
local function SortDesc(a,b) return a[sortIndex] > b[sortIndex] end

local function SortColumn(column)
	local header = headers[column]
	sortIndex = column
	if not header.sortDir then
		sort(RVS, SortAsc)
	else
		sort(RVS, SortDesc)
	end
	UpdateScroll()
end

local function SetHeaderText(name,version)
	heading:SetText(format("%s: |cffffffff%s|r",name,version))
end

local function DropdownChanged(widget,event,v)
	value = v
	SetHeaderText(list[v],EDB[v].version)
	addon:RefreshVersionList()
	addon:RequestVersions(value)
end

local function RefreshDropdown()
	wipe(list)
	for key,data in addon:IterateEDB() do
		list[key] = data.name
	end
	dropdown:SetList(list)
end

local function CreateRow(parent)
	local text = parent:CreateFontString(nil,"OVERLAY")
	text:SetHeight(ROW_HEIGHT)
	text:SetFontObject(GameFontNormalSmall)
	text:SetJustifyH("LEFT")
	text:SetTextColor(1,1,1)
	return text
end

local function CreateHeader(content,column)
	local header = CreateFrame("Button", nil, content)
	header:SetScript("OnClick",function() header.sortDir = not header.sortDir; SortColumn(column) end)
	header:SetHeight(20)
	local title = header:CreateFontString(nil,"OVERLAY")
	title:SetPoint("LEFT",header,"LEFT",10,0)
	header:SetFontString(title)
	header:SetNormalFontObject(GameFontNormalSmall)
	header:SetHighlightFontObject(GameFontNormal)

	local rows = {}
	header.rows = rows
	local text = CreateRow(header)
	text:SetPoint("TOPLEFT",header,"BOTTOMLEFT",10,-3)
	text:SetPoint("TOPRIGHT",header,"BOTTOMRIGHT",0,-3)
	rows[1] = text

	for i=2,NUM_ROWS do
		text = CreateRow(header)
		text:SetPoint("TOPLEFT", rows[i-1], "BOTTOMLEFT")
		text:SetPoint("TOPRIGHT", rows[i-1], "BOTTOMRIGHT")
		rows[i] = text
	end

	return header
end

local function OnShow(self)
	RefreshDropdown()
	addon:RefreshVersionList()
end

local function CreateWindow()
	window = addon:CreateWindow("Version Check",220,295)
	window:SetScript("OnShow",OnShow)
	--@debug@
	window:AddTitleButton("Interface\\Addons\\DXE\\Textures\\Window\\Sync.tga",
									function() addon:RequestAllVersions() end)
	--@end-debug@
	local content = window.content
	local addonbutton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
	addonbutton:SetWidth(content:GetWidth()/3)
	addonbutton:SetHeight(25)
	addonbutton:SetNormalFontObject(GameFontNormalSmall)
	addonbutton:SetHighlightFontObject(GameFontHighlightSmall)
	addonbutton:SetDisabledFontObject(GameFontDisableSmall)
	addonbutton:SetText("AddOn")
	addonbutton:SetPoint("TOPLEFT",content,"TOPLEFT",0,-1)
	addonbutton:RegisterForClicks("LeftButtonUp","RightButtonUp")
	addonbutton:SetScript("OnClick",function(_,button) 
		if button == "LeftButton" then
			SetHeaderText(L["AddOn"],addon.version)
			value = "addon"
			addon:RequestVersions("addon")
		elseif button == "RightButton" then
			if not dropdown.value then return end
			SetHeaderText(list[dropdown.value],EDB[dropdown.value].version)
			value = dropdown.value
			addon:RequestVersions(value)
		end
		addon:RefreshVersionList() 
	end)
	addon:AddTooltipText(addonbutton,L["Usage"],L["|cffffff00Left Click|r to display AddOn versions. These are automatically refreshed"]
	.."\n"..L["|cffffff00Right Click|r to display the selected versions. Repeated clicks will refresh them"])

	dropdown = addon.AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(content)
	dropdown.frame:Show()
	dropdown:SetPoint("TOPRIGHT",content,"TOPRIGHT")
	dropdown:SetWidth(content:GetWidth()*2/3)
	dropdown:SetCallback("OnValueChanged", DropdownChanged)
	RefreshDropdown()
	dropdown:SetValue(next(list))

	heading = CreateFrame("Frame",nil,content)
	heading:SetWidth(content:GetWidth())
	heading:SetHeight(18)
	heading:SetPoint("TOPLEFT",addonbutton,"BOTTOMLEFT",0,-2)
	local label = heading:CreateFontString(nil,"ARTWORK")
	label:SetFont(GameFontNormalSmall:GetFont())
	label:SetPoint("CENTER")
	label:SetTextColor(1,1,0)
	function heading:SetText(text) label:SetText(text) end
	SetHeaderText(L["AddOn"],addon.version)

	local left = heading:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(8)
	left:SetPoint("LEFT",heading,"LEFT",3,0)
	left:SetPoint("RIGHT",label,"LEFT",-5,0)
	left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	left:SetTexCoord(0.81, 0.94, 0.5, 1)

	local right = heading:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(8)
	right:SetPoint("RIGHT",heading,"RIGHT",-3,0)
	right:SetPoint("LEFT",label,"RIGHT",5,0)
	right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	right:SetTexCoord(0.81, 0.94, 0.5, 1)

	for i=1,2 do headers[i] = CreateHeader(content,i) end
	headers[1]:SetPoint("TOPLEFT",heading,"BOTTOMLEFT")
	headers[1]:SetText(L["Name"])
	headers[1]:SetWidth(120)

	headers[2]:SetPoint("LEFT",headers[1],"LEFT",content:GetWidth()/2,0)
	headers[2]:SetText(L["Version"])
	headers[2]:SetWidth(80)

	scrollframe = CreateFrame("ScrollFrame", "DXEVCScrollFrame", content, "FauxScrollFrameTemplate")
	scrollframe:SetPoint("TOPLEFT", headers[1], "BOTTOMLEFT")
	scrollframe:SetPoint("BOTTOMRIGHT",-21,0)
	scrollframe:SetBackdrop(backdrop)
	scrollframe:SetBackdropBorderColor(0.33,0.33,0.33)

	local scrollbar = _G[scrollframe:GetName() .. "ScrollBar"]
	local scrollbarbg = CreateFrame("Frame",nil,scrollbar)
	scrollbarbg:SetBackdrop(backdrop)
	scrollbarbg:SetPoint("TOPLEFT",-3,19)
	scrollbarbg:SetPoint("BOTTOMRIGHT",3,-18)
	scrollbarbg:SetBackdropBorderColor(0.33,0.33,0.33)
	scrollbarbg:SetFrameLevel(scrollbar:GetFrameLevel()-2)

	scrollframe:SetScript("OnVerticalScroll", function(addon, offset) 
		FauxScrollFrame_OnVerticalScroll(addon, offset, ROW_HEIGHT, UpdateScroll) 
	end)

	addon:RefreshVersionList()
	UpdateScroll()
	CreateWindow = nil
end

---------------------------------------------
-- CORE FUNCTIONS
---------------------------------------------

function addon:VersionCheck()
	self:RequestVersions(value)
	if window then
		window:Show()
	else
		CreateWindow()
	end
end
addon:RegisterWindow(L["Version Check"],function() addon:VersionCheck() end)

function addon:RefreshVersionList()
	if window and window:IsShown() then
		for k,v in ipairs(RVS) do
			v[2] = v.versions[value] or NONE
		end

		for name in pairs(Roster.name_to_unit) do
			if not util.search(RVS,name,1) and name ~= addon.PNAME then
				RVS[#RVS+1] = {name,NONE,versions = {}}
			end
		end

		SortColumn(sortIndex)
	end
end

function addon:CleanVersions()
	local n,i = #RVS,1
	while i <= n do
		local v = RVS[i]
		if Roster.name_to_unit[v[1]] then i = i + 1
		else remove(RVS,i); n = n - 1 end
	end
	addon:RefreshVersionList()
end

-- Version string
function addon:GetVersionString()
	local work = {}
	work[1] = format("%s,%s","addon",self.version)
	for key, data in self:IterateEDB() do
		work[#work+1] = format("%s,%s",data.key,data.version)
	end
	return concat(work,":")
end

function addon:RequestAllVersions()
	self:SendRaidComm("RequestAllVersions")
end
addon:ThrottleFunc("RequestAllVersions",5,true)


function addon:BroadcastAllVersions()
	self:SendRaidComm("AllVersionsBroadcast",self:GetVersionString())
end
addon:ThrottleFunc("BroadcastAllVersions",5,true)

function addon:RequestVersions(key)
	if not EDB[key] and key ~= "addon" then return end
	self:SendRaidComm("RequestVersions",key)
end
addon:ThrottleFunc("RequestVersions",0.5,true)

function addon:RequestAddOnVersions()
	self:SendRaidComm("RequestAddOnVersion")
end

function addon:BroadcastVersion(key)
	if not EDB[key] and key ~= "addon" then return end
	self:SendRaidComm("VersionBroadcast",key,key == "addon" and addon.version or EDB[key].version)
end

---------------------------------------------
-- COMM HANDLER
---------------------------------------------
local CommHandler = {}

function CommHandler:OnCommRequestAllVersions()
	addon:BroadcastAllVersions()
end

function CommHandler:OnCommAllVersionsBroadcast(event,commType,sender,versionString)
	local k = util.search(RVS,sender,1)
	if not k then 
		k = #RVS+1
		RVS[k] = {sender, versions={}}
	end

	local versions = RVS[k].versions

	for key,version in gmatch(versionString,"([^:,]+),([^:,]+)") do
		versions[key] = tonumber(version)
	end

	addon:RefreshVersionList()
end

function CommHandler:OnCommRequestVersions(event,commType,sender,key)
	if not EDB[key] and key ~= "addon" then return end
	addon:SendWhisperComm(sender,"VersionBroadcast",key,key == "addon" and addon.version or EDB[key].version)
end

function CommHandler:OnCommRequestAddOnVersion()
	addon:BroadcastVersion("addon")
end

function CommHandler:OnCommVersionBroadcast(event,commType,sender,key,version)
	local k = util.search(RVS,sender,1)
	if not k then
		k = #RVS+1
		RVS[k] = {sender, versions = {}}
	end

	RVS[k].versions[key] = tonumber(version)

	addon:RefreshVersionList()
end

addon.RegisterCallback(CommHandler,"OnCommRequestAllVersions")
addon.RegisterCallback(CommHandler,"OnCommAllVersionsBroadcast")
addon.RegisterCallback(CommHandler,"OnCommRequestVersions")
addon.RegisterCallback(CommHandler,"OnCommRequestAddOnVersion")
addon.RegisterCallback(CommHandler,"OnCommVersionBroadcast")
