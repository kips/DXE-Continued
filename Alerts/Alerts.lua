-- Based off RDX's alert system

local defaults = {
	profile = {
		-- Top
		TopScale = 0.9,
		TopGrowth = "DOWN",
		TopAlpha = 0.55,
		TopBarWidth = 250,
		-- Center
		CenterScale = 0.9,
		CenterGrowth = "DOWN",
		CenterAlpha = 0.75,
		CenterBarWidth = 275,
		-- Warning
		WarningBars = true,
		WarningAnchor = false,
		WarningMessages = false,
		WarningScale = 0.9,
		WarningGrowth = "DOWN",
		WarningAlpha = 0.75,
		WarningBarWidth = 275,
		SinkStorage = {},
		RedirectCenter = false,
		RedirectThreshold = 5,
		-- Flash
		FlashAlpha = 0.6,
		FlashDuration = 0.8,
		FlashOscillations = 2,
		ConstantClr = false,
		GlobalColor = {1,0,0},
		-- Bar
		BarTextJustification = "CENTER",
		BarFontSize = 10,
		BarFillDirection = "FILL",
		BarFontColor = {1,1,1,1},
		BarHeight = 30,
		-- Timer
		TimerFontColor = {1,1,1,1},
		TimerXOffset = -5,
		MinuteFontSize = 20,
		DecimalFontSize = 12,
		DecimalYOffset = 2,
		-- Icon
		IconPosition = "LEFT",
		IconOffset = 0,
		-- Toggles
		DisableDropdowns = false,
		DisableScreenFlash = false,
		DisableSounds = false,
		HideIcons = false,
		ShowBorder = true,
		-- Custom Bars
		CustomLocalClr = "TAN",
		CustomRaidClr = "TAN",
		CustomSound = "ALERT10",
	}
}

local addon = DXE
local L = addon.L
local CN = addon.CN
local AceTimer = LibStub("AceTimer-3.0")

local Colors = addon.Media.Colors
local GetTime,PlaySoundFile = GetTime,PlaySoundFile
local ipairs,pairs,next,remove = ipairs,pairs,next,table.remove
local util = addon.util

local ANIMATION_TIME = 0.3
local FADE_TIME = 2
local INSET = 2

local db,pfl

---------------------------------------
-- INITIALIZATION
---------------------------------------

local module = addon:NewModule("Alerts","LibSink-2.0")
addon.Alerts = module
local Active = {}
local TopAlertStack = {}
local CenterAlertStack = {}
local WarningAlertStack = {}
local BarPool = {}
local prototype = {}

local TopStackAnchor,CenterStackAnchor,WarningStackAnchor

function module:RefreshProfile()
	pfl = db.profile
	self:RefreshBars()
	self:SetSinkStorage(pfl.SinkStorage)
end

function module:OnInitialize()
	-- Top stack anchor
	TopStackAnchor = addon:CreateLockableFrame("AlertsTopStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Bar Top Anchor"]))
	addon:RegisterMoveSaving(TopStackAnchor,"TOP","UIParent","TOP",0,-16)
	addon:LoadPosition("DXEAlertsTopStackAnchor")

	-- Bottom stack anchor
	CenterStackAnchor = addon:CreateLockableFrame("AlertsCenterStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Bar Center Anchor"]))
	addon:RegisterMoveSaving(CenterStackAnchor,"CENTER","UIParent","CENTER",0,100)
	addon:LoadPosition("DXEAlertsCenterStackAnchor")

	WarningStackAnchor = addon:CreateLockableFrame("AlertsWarningStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Bar Warning Anchor"]))
	addon:RegisterMoveSaving(WarningStackAnchor,"CENTER","UIParent","CENTER",0,210)
	addon:LoadPosition("DXEAlertsWarningStackAnchor")

	self.db = addon.db:RegisterNamespace("Alerts", defaults)
	db = self.db
	pfl = db.profile

	self:SetSinkStorage(pfl.SinkStorage)

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
end

function module:OnDisable()
	self:QuashAll()
end

---------------------------------------------
-- SCREEN FLASH
---------------------------------------------

do
	local FLASH_DURATION,PERIOD,AMP,MULT

	local flash = CreateFrame("Frame","DXEAlertsFlash",UIParent)
	flash:SetFrameStrata("BACKGROUND")
	flash:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
	flash:SetAllPoints(true)
	flash:Hide()
	
	local counter
	local function OnUpdate(self,elapsed)
		counter = counter + elapsed
		if counter > FLASH_DURATION then self:Hide() end
		local p = counter % PERIOD
		if p > AMP then p = PERIOD - p end
		self:SetAlpha(p * MULT)
	end

	flash:SetScript("OnUpdate",OnUpdate)

	function module:FlashScreen(c) 
		if pfl.DisableScreenFlash then return end
		if pfl.ConstantClr then
			local r,g,b = unpack(pfl.GlobalColor)
			flash:SetBackdropColor(r,g,b,pfl.FlashAlpha)
		else
			c = c or Colors.BLACK
			flash:SetBackdropColor(c.r,c.g,c.b,pfl.FlashAlpha)
		end
		counter = 0
		FLASH_DURATION = pfl.FlashDuration
		PERIOD = FLASH_DURATION / pfl.FlashOscillations
		AMP = PERIOD / 2
		MULT = 1 / AMP
		flash:SetAlpha(0)
		flash:Show()
	end
end

---------------------------------------
-- UPDATING
---------------------------------------

local function OnUpdate(self,elapsed)
	local bar = next(Active)
	if not bar then self:Hide() return end
	local time = GetTime()
	while bar do
		if bar.countFunc then bar:countFunc(time) end
		if bar.animFunc then bar:animFunc(time) end
		bar = next(Active,bar)
	end
end

local UpdateFrame = CreateFrame("Frame",nil,UIParent)
UpdateFrame:SetScript("OnUpdate",OnUpdate)
UpdateFrame:Hide()

---------------------------------------
-- PROTOTYPE
---------------------------------------
local wipe = table.wipe

function prototype:SetColor(c1,c2)
	self.data.c1 = c1
	self.statusbar:SetStatusBarColor(c1.r,c1.g,c1.b)
	self.data.c2 = c2 or c1
end

function prototype:Destroy()
	self:Hide()
	self:ClearAllPoints()
	self:RemoveFromStacks()
	self:CancelAllTimers()
	self.countFunc = nil
	self.animFunc = nil
	self.statusbar:SetValue(0)
	Active[self] = nil
	UIFrameFadeRemoveFrame(self)
	BarPool[self] = true
	wipe(self.data)
	self.timer:Show()
	self.icon:Hide()
	self.icon.t:SetTexture("")
end

do
	local function SortDesc(a1, a2)
		return (a1.data.timeleft or 10000) > (a2.data.timeleft or 10000)
	end

	function prototype:LayoutAlertStack(stack,anchor,growth)
		sort(stack, SortDesc)
		local point,relpoint,mult
		if growth == "DOWN" then
			point,relpoint,mult = "TOP","BOTTOM",-1
		elseif growth == "UP" then
			point,relpoint,mult = "BOTTOM","TOP",1
		end
		for i,bar in ipairs(stack) do
			bar:ClearAllPoints()
			bar:SetPoint(point,anchor,relpoint,0,mult*(i-1)*pfl.BarHeight)
		end
	end
end

function prototype:AnchorToTop()
	self.data.anchor = "TOP"
	self:SetAlpha(pfl.TopAlpha)
	self:SetScale(pfl.TopScale)
	self:SetWidth(pfl.TopBarWidth)
	self:RemoveFromStacks()
	TopAlertStack[#TopAlertStack+1] = self
	self:LayoutAlertStack(TopAlertStack, TopStackAnchor, pfl.TopGrowth)
end

function prototype:AnchorToCenter()
	if self.data.sound and not pfl.DisableSounds then PlaySoundFile(self.data.sound) end
	self.data.anchor = "CENTER"
	self:SetAlpha(pfl.CenterAlpha)
	self:SetScale(pfl.CenterScale)
	self:SetWidth(pfl.CenterBarWidth)
	self:RemoveFromStacks()
	CenterAlertStack[#CenterAlertStack+1] = self
	self:LayoutAlertStack(CenterAlertStack, CenterStackAnchor, pfl.CenterGrowth)
end

function prototype:AnchorToWarning()
	if self.data.sound and not pfl.DisableSounds then PlaySoundFile(self.data.sound) end
	self.data.anchor = "WARNING"
	self:SetAlpha(pfl.WarningAlpha)
	self:SetScale(pfl.WarningScale)
	self:SetWidth(pfl.WarningBarWidth)
	self:RemoveFromStacks()
	WarningAlertStack[#WarningAlertStack+1] = self
	self:LayoutAlertStack(WarningAlertStack, WarningStackAnchor, pfl.WarningGrowth)
end

do
	local UIParent = UIParent
	local function AnimationFunc(self,time)
		local data = self.data
		local perc = (time - data.t0) / ANIMATION_TIME
		if perc < 0 or perc > 1 then 
			self.animFunc = nil
			self:AnchorToCenter()
			if self.data.flashscreen then
				module:FlashScreen(self.data.c1)
			end
		else
			local a = pfl.TopAlpha + ((pfl.CenterAlpha - pfl.TopAlpha) * perc)
			self:SetAlpha(a)

			local s = pfl.TopScale + ((pfl.CenterScale - pfl.TopScale) * perc)
			self:SetScale(s)

			local w = pfl.TopBarWidth + ((pfl.CenterBarWidth - pfl.TopBarWidth) * perc)
			self:SetWidth(w)

			local escale = self:GetEffectiveScale()
			local x = (data.fx + ((data.tox - data.fx) * perc)) / escale
			local y = (data.fy + ((data.toy - data.fy) * perc)) / escale
			self:ClearAllPoints()
			self:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y)
		end
	end

	function prototype:TranslateToCenter()
		self.data.anchor = nil
		self:RemoveFromStacks()
		local x,y = self:GetCenter()
		self:ClearAllPoints()
		self:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y)
		self:LayoutAlertStack(TopAlertStack, TopStackAnchor, pfl.TopGrowth)

		local worldscale,escale = UIParent:GetEffectiveScale(),self:GetEffectiveScale()
		local fx,fy = x*escale, y*escale
		local cx,cy = CenterStackAnchor:GetCenter()
		local mult = pfl.CenterGrowth == "DOWN" and -1 or 1
		cy = cy + mult*5 -- CenterStackAnchor:GetHeight() / 2

		local offset = (pfl.BarHeight * #CenterAlertStack + pfl.BarHeight/2) * (pfl.CenterScale * worldscale)
		local tox,toy = cx*worldscale,cy*worldscale
		toy = toy + mult*(offset)

		local data = self.data
		data.t0 = GetTime()
		data.fx = fx
		data.fy = fy
		data.tox = tox
		data.toy = toy
		self.animFunc = AnimationFunc
	end
end

function prototype:RemoveFromStack(stack)
	for i,bar in ipairs(stack) do
		if bar == self then 
			remove(stack,i) 
			return
		end
	end
end

function prototype:RemoveFromStacks()
	self:RemoveFromStack(TopAlertStack)
	self:RemoveFromStack(CenterAlertStack)
	self:RemoveFromStack(WarningAlertStack)
end

do
	local function CountdownFunc(self,time)
		local timeleft = self.data.endTime - time
		self.data.timeleft = timeleft
		if timeleft < 0 then 
			self.countFunc = nil
			self.timer:SetTime(0)
			return 
		end
		self.timer:SetTime(timeleft)
		local value = 1 - (timeleft / self.data.totalTime)
		self.statusbar:SetValue(pfl.BarFillDirection == "FILL" and value or 1 - value)
	end

	local cos = math.cos
	local function CountdownFlashFunc(self,time)
		local data = self.data
		local timeleft = data.endTime - time
		self.data.timeleft = timeleft
		if timeleft < 0 then 
			self.countFunc = nil
			self.timer:SetTime(0)
			return 
		end
		self.timer:SetTime(timeleft)
		local value = 1 - (timeleft / data.totalTime)
		self.statusbar:SetValue(pfl.BarFillDirection == "FILL" and value or 1 - value)
		if timeleft < data.flashTime then 
			self.statusbar:SetStatusBarColor(util.blend(data.c1, data.c2, 0.5*(cos(timeleft*12) + 1))) 
		end
	end

	function prototype:Countdown(totalTime, flashTime)
		local endTime = GetTime() + totalTime
		self.data.endTime,self.data.totalTime = endTime, totalTime
		if flashTime and self.data.c1 ~= self.data.c2 then
			self.data.flashTime = flashTime
			self.countFunc = CountdownFlashFunc
		else
			self.countFunc = CountdownFunc
		end
	end
end

function prototype:Fade()
	local fadeTable = self.fadeTable
	fadeTable.startAlpha = self:GetAlpha()
	fadeTable.fadeTimer = 0
	fadeTable.finishedFunc = self.Destroy
	UIFrameFade(self,fadeTable)
end

function prototype:SetID(id)
	self.data.id = id
end

function prototype:SetTimeleft(timeleft)
	self.data.timeleft = timeleft
end

function prototype:SetSound(sound)
	self.data.sound = sound
end

function prototype:SetFlashScreen(flashscreen)
	self.data.flashscreen = flashscreen
end

do
	local gsub = string.gsub
	local function colorname(prefix,word)
		return prefix..CN[word]
	end

	function prototype:SetText(text)
		text = gsub(text,"(.+: )([^!.]+)",colorname)
		self.text:SetText(text)
	end
end

function prototype:SetIcon(texture)
	if not texture then self.icon:Hide() return end
	self.data.icon = texture
	if pfl.HideIcons then return end
	self.icon:Show()
	self.icon.t:SetTexture(texture)
end

local function SkinBar(bar)
	if pfl.HideIcons then bar.icon:Hide() 
	else bar:SetIcon(bar.data.icon) end

	bar.statusbar:ClearAllPoints()
	bar.icon.t:ClearAllPoints()
	bar.bg:ClearAllPoints()
	if pfl.ShowBorder then
		bar.border:Show()
		bar.icon.border:Show()
		bar.statusbar:SetPoint("TOPLEFT",INSET,-INSET)
		bar.statusbar:SetPoint("BOTTOMRIGHT",-INSET,INSET)
		bar.icon.t:SetPoint("TOPLEFT",bar.icon,"TOPLEFT",INSET,-INSET)
		bar.icon.t:SetPoint("BOTTOMRIGHT",bar.icon,"BOTTOMRIGHT",-INSET,INSET)
		bar.bg:SetPoint("TOPLEFT",INSET,-INSET)
		bar.bg:SetPoint("BOTTOMRIGHT",-INSET,INSET)
	else
		bar.border:Hide()
		bar.icon.border:Hide()
		bar.statusbar:SetPoint("TOPLEFT")
		bar.statusbar:SetPoint("BOTTOMRIGHT")
		bar.icon.t:SetPoint("TOPLEFT",bar.icon,"TOPLEFT")
		bar.icon.t:SetPoint("BOTTOMRIGHT",bar.icon,"BOTTOMRIGHT")
		bar.bg:SetPoint("TOPLEFT")
		bar.bg:SetPoint("BOTTOMRIGHT")
	end

	bar:SetHeight(pfl.BarHeight)

	local fontsize = 
	bar.timer.left:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",(0.4375*pfl.BarHeight)+6.875)
	bar.timer.right:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",(0.25*pfl.BarHeight)+4.5)

	bar.timer.right:ClearAllPoints()
	bar.timer.right:SetPoint("BOTTOMLEFT",bar.timer.left,"BOTTOMRIGHT",0,pfl.DecimalYOffset)

	bar.timer:ClearAllPoints()
	bar.timer:SetPoint("RIGHT",bar,"RIGHT",pfl.TimerXOffset,0)
	bar.timer.right:SetVertexColor(unpack(pfl.TimerFontColor))
	bar.timer.left:SetVertexColor(unpack(pfl.TimerFontColor))

	bar.icon:ClearAllPoints()
	if pfl.IconPosition == "LEFT" then
		bar.icon:SetPoint("RIGHT",bar,"LEFT",-pfl.IconOffset,0)
	elseif pfl.IconPosition == "RIGHT" then
		bar.icon:SetPoint("LEFT",bar,"RIGHT",pfl.IconOffset,0)
	end
	bar.icon:SetWidth(pfl.BarHeight)
	bar.icon:SetHeight(pfl.BarHeight)

	bar.text:SetFont(bar.text:GetFont(),pfl.BarFontSize)
	bar.text:SetVertexColor(unpack(pfl.BarFontColor))
	bar.text:SetJustifyH(pfl.BarTextJustification)

	local data = bar.data
	if data.anchor == "TOP" then
		bar:SetScale(pfl.TopScale)
		bar:SetAlpha(pfl.TopAlpha)
		bar:SetWidth(pfl.TopBarWidth)
	elseif data.anchor == "CENTER" then
		bar:SetScale(pfl.CenterScale)
		bar:SetAlpha(pfl.CenterAlpha)
		bar:SetWidth(pfl.CenterBarWidth)
	elseif data.anchor == "WARNING" then
		bar:SetScale(pfl.WarningScale)
		bar:SetAlpha(pfl.WarningAlpha)
		bar:SetWidth(pfl.WarningBarWidth)
	end
end

function module:RefreshBars()
	if not next(Active) and not next(BarPool) then return end
	for bar in pairs(Active) do SkinBar(bar) end
	for bar in pairs(BarPool) do SkinBar(bar) end
	prototype:LayoutAlertStack(TopAlertStack, TopStackAnchor, pfl.TopGrowth)
	prototype:LayoutAlertStack(CenterAlertStack, CenterStackAnchor, pfl.CenterGrowth)
	prototype:LayoutAlertStack(WarningAlertStack, WarningStackAnchor, pfl.WarningGrowth)
end

local BarCount = 1
local function CreateBar()
	local self = CreateFrame("Frame","DXEAlertBar"..BarCount,UIParent)
	self:SetHeight(pfl.BarHeight)

	local bg = self:CreateTexture(nil,"BACKGROUND")
	addon:RegisterBackground(bg)
	self.bg = bg

	self.data = {}

	local statusbar = CreateFrame("StatusBar",nil,self)
	statusbar:SetMinMaxValues(0,1) 
	statusbar:SetValue(0)
	addon:RegisterStatusBar(statusbar)
	self.statusbar = statusbar

	local border = CreateFrame("Frame",nil,self)
	border:SetAllPoints(true)
	border:SetFrameLevel(statusbar:GetFrameLevel()+1)
	addon:RegisterBorder(border)
	self.border = border

	local timer = addon.Timer:New(self)
	timer:SetFrameLevel(self:GetFrameLevel()+1)
	timer.left:SetShadowOffset(1,-1)
	timer.right:SetShadowOffset(1,-1)
	self.timer = timer

	local text = statusbar:CreateFontString(nil,"ARTWORK")
	text:SetPoint("LEFT",self,"LEFT",5,0)
	-- Adjust if we ever have a timer > 1 hour
	text:SetPoint("RIGHT",self.timer,"LEFT",7,0)
	text:SetShadowOffset(1,-1)
	addon:RegisterFontString(text,10)
	self.text = text

	local icon = CreateFrame("Frame",nil,self)
	self.icon = icon

	icon.t = icon:CreateTexture(nil,"BACKGROUND")
	icon.t:SetTexCoord(0.07,0.93,0.07,0.93)

	icon.border = CreateFrame("Frame",nil,icon)
	icon.border:SetAllPoints(true)
	addon:RegisterBorder(icon.border)


	AceTimer:Embed(self)
	for k,v in pairs(prototype) do self[k] = v end

	self.fadeTable = {mode = "OUT", timeToFade = FADE_TIME, endAlpha = 0, finishedArg1 = self }

	BarCount = BarCount + 1

	SkinBar(self)

	return self
end

local function GetBar()
	local bar = next(BarPool)
	if bar then BarPool[bar] = nil
	else bar = CreateBar() end
	Active[bar] = true
	UpdateFrame:Show()
	bar:Show()

	return bar
end

---------------------------------------
-- UTILITY
---------------------------------------

local SM = LibStub("LibSharedMedia-3.0")
local Sounds = addon.Media.Sounds
local function GetMedia(sound,c1,c2)
	return Sounds:GetFile(sound),Colors[c1],Colors[c2]
end

---------------------------------------
-- API
---------------------------------------

function module:QuashAll()
	for bar in pairs(Active) do bar:Destroy() end
end

local find = string.find
function module:QuashByPattern(pattern)
	for bar in pairs(Active) do
		if bar.data.id and find(bar.data.id,pattern) then
			bar:Destroy()
		end
	end
end

function module:GetTimeleft(id)
	for bar in pairs(Active) do
		if bar.data.id == id then
			return bar.data.timeleft
		end
	end
	return -1
end

function module:Dropdown(id, text, totalTime, flashTime, sound, c1, c2, flashscreen, icon)
	if pfl.DisableDropdowns then self:CenterPopup(id, text, totalTime, flashTime, sound, c1, c2, flashscreen, icon) return end
	local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local bar = GetBar()
	bar:SetID(id)
	bar:SetIcon(icon)
	bar:SetTimeleft(totalTime)
	bar:SetText(text) 
	bar:SetFlashScreen(flashscreen)
	bar:SetColor(c1Data,c2Data)
	bar:SetSound(soundFile)
	bar:Countdown(totalTime,flashTime)
	bar:AnchorToTop()
	if flashTime then 
		local waitTime = totalTime - flashTime
		if waitTime < 0 then bar:TranslateToCenter()
		else bar:ScheduleTimer("TranslateToCenter",waitTime) end
	end
	bar:ScheduleTimer("Fade",totalTime)
end

function module:CenterPopup(id, text, totalTime, flashTime, sound, c1, c2, flashscreen, icon)
	local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local bar = GetBar()
	bar:SetID(id)
	bar:SetIcon(icon)
	bar:SetTimeleft(totalTime)
	bar:SetColor(c1Data,c2Data)
	bar:SetText(text)
	bar:Countdown(totalTime, flashTime)
	bar:SetSound(soundFile)
	if pfl.WarningAnchor and pfl.RedirectCenter and totalTime <= pfl.RedirectThreshold then
		bar:AnchorToWarning()
	else
		bar:AnchorToCenter()
	end
	bar:ScheduleTimer("Fade",totalTime)
	if flashscreen then self:FlashScreen(c1Data) end
end

function module:Simple(text, totalTime, sound, c1, flashscreen, icon)
	local soundFile,c1Data = GetMedia(sound,c1)
	if soundFile and not pfl.DisableSounds then PlaySoundFile(soundFile) end
	if flashscreen then self:FlashScreen(c1Data) end
	if pfl.WarningBars then
		local bar = GetBar()
		if c1Data then 
			bar:SetColor(c1Data)
			bar.statusbar:SetValue(1)
		end
		bar:SetIcon(icon)
		bar:SetText(text) 
		bar.timer:Hide()
		bar[pfl.WarningAnchor and "AnchorToWarning" or "AnchorToCenter"](bar)
		bar:ScheduleTimer("Fade",totalTime)
	end

	if pfl.WarningMessages then
		local c = c1Data or Colors.WHITE
		self:Pour(text,c.r,c.g,c.b,nil,nil,nil,nil,nil,icon)
	end
end

---------------------------------------------
-- CUSTOM BARS
---------------------------------------------

do
	local function fire(time,text,icon,color)
		if time > 15 then
			module:Dropdown("custom"..text,text,time,15,pfl.CustomSound,color,nil,nil,icon)
		else
			module:CenterPopup("custom"..text,text,time,nil,pfl.CustomSound,color,nil,nil,icon)
		end
	end

	local function parsetime(str)
		local t = tonumber(str)
		if t then return t
		else
			local m,s = str:trim():match("^(%d+):(%d+)$")
			if m and s then
				return (tonumber(m) * 60) + tonumber(s)
			end
		end
		addon:Print(L["Invalid time. The form must be |cffffd200minutes:seconds|r or |cffffd200seconds|r (e.g. 1:30 or 90)"])
	end

	local function parsemsg(msg)
		if type(msg) ~= "string" then addon:Print(L["Invalid bar format. The format is |cffffd200time text|r"]) return end
		local time,text = msg:match("([%d:]+)%s+(.*)")
		if not time or not text then addon:Print(L["Invalid bar format. The format is |cffffd200time text|r"]) return end
		time = parsetime(time)
		if not time then return end
		return time,text
	end

	function SlashCmdList.DXEALERTLOCALBAR(msg)
		local time,text = parsemsg(msg)
		if not time or not text then return end
		fire(time,L["YOU"]..": "..text,"Interface\\Icons\\INV_Misc_PocketWatch_02",pfl.CustomLocalClr)
	end

	SLASH_DXEALERTLOCALBAR1 = "/dxelb"

	function SlashCmdList.DXEALERTRAIDBAR(msg)
		if not UnitIsRaidOfficer("player") then DXE:Print(L["You need to be a raid officer"]) return end
		local time,text = parsemsg(msg)
		if not time or not text then return end
		
		fire(time,L["YOU"]..": "..text,"Interface\\Icons\\INV_Misc_PocketWatch_01",pfl.CustomRaidClr)
		addon:SendRaidComm("AlertsRaidBar",time,CN[addon.PNAME]..": "..text)
	end

	SLASH_DXEALERTRAIDBAR1 = "/dxerb"

	function module:OnCommAlertsRaidBar(event,commType,sender,time,text)
		if not UnitIsRaidOfficer(sender) then return end
		fire(time,text,"Interface\\Icons\\INV_Misc_PocketWatch_01",pfl.CustomRaidClr)
	end

	addon.RegisterCallback(module,"OnCommAlertsRaidBar")
end

---------------------------------------------
-- ALERT TESTS
---------------------------------------------

function module:BarTest()
	self:CenterPopup("AlertTest1", "Decimating. Life Tap Now!", 10, 5, "DXE ALERT1", "DCYAN", nil, nil, addon.ST[28374])
	self:Dropdown("AlertTest2", "Bigger City Opening", 20, 5, "DXE ALERT2", "BLUE", "ORANGE", nil, addon.ST[64813])
	self:Simple("Just Kill It!",3,"DXE ALERT3","RED", nil, addon.ST[53351])
end

local lookup
function module:FlashTest()
	if not lookup then
		lookup = {}
		for k,v in pairs(Colors) do lookup[#lookup+1] = k end
	end
	local i = math.random(1,#lookup)
	local c = Colors[lookup[i]]
	self:FlashScreen(c)
end
