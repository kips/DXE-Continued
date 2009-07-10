local addon = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
addon.version = version > addon.version and version or addon.version
local L = addon.L

local UIParent = UIParent
local SM = addon.SM
local AceGUI = addon.AceGUI
local AceTimer = addon.AceTimer
local format = string.format
local Colors,Sounds = addon.Constants.Colors,addon.Constants.Sounds

local GetTime,PlaySoundFile,ipairs,pairs,next,remove = 
		GetTime,PlaySoundFile,ipairs,pairs,next,tremove

local scale
local util = addon.util

local animationTime = 0.3
local fadeTime = 2

---------------------------------------
-- INITIALIZATION
---------------------------------------

local module = addon:NewModule("Alerts","AceTimer-3.0")
addon.Alerts = module
local Active = {}
local TopAlertStack = {}
local CenterAlertStack = {}
local AlertPool = {}

local TopStackAnchor,CenterStackAnchor

function module:OnInitialize()
	-- Top stack anchor
	TopStackAnchor = addon:CreateLockableFrame("AlertsTopStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Top Anchor"]))
	addon:RegisterMoveSaving(TopStackAnchor,"TOP","UIParent","TOP",0,-16)
	addon:LoadPosition("DXEAlertsTopStackAnchor")

	-- Bottom stack anchor
	CenterStackAnchor = addon:CreateLockableFrame("AlertsCenterStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Center Anchor"]))
	addon:RegisterMoveSaving(CenterStackAnchor,"CENTER","UIParent","CENTER",0,100)
	addon:LoadPosition("DXEAlertsCenterStackAnchor")

	scale = addon.db.global.AlertsScale
end

function module:AlertsScaleChanged()
	scale = addon.db.global.AlertsScale
	for alert in pairs(Active) do
		alert:SetScale(scale)
	end
end
addon.RegisterCallback(module,"AlertsScaleChanged")

function module:OnDisable()
	self:QuashAllAlerts()
end

---------------------------------------
-- UPDATING
---------------------------------------

local function OnUpdate(self,elapsed)
	local alert = next(Active)
	if not alert then self:Hide() return end
	local time = GetTime()
	while alert do
		if alert.countFunc then alert:countFunc(time) end
		if alert.animFunc then alert:animFunc(time) end
		alert = next(Active,alert)
	end
end

local UpdateFrame = CreateFrame("Frame",nil,UIParent)
UpdateFrame:SetScript("OnUpdate",OnUpdate)
UpdateFrame:Hide()

---------------------------------------
-- PROTOTYPE
---------------------------------------

local Prototype = {}

function Prototype:SetColor(c1,c2)
	if c1 then
		self.data.c1 = c1
		self.bar:SetStatusBarColor(c1.r,c1.g,c1.b)
	end
	if c2 then self.data.c2 = c2 end
end

function Prototype:Destroy()
	self:Hide()
	self:ClearAllPoints()
	self:RemoveFromStacks()
	self:CancelAllTimers()
	self.countFunc = nil
	self.animFunc = nil
	self.bar:SetValue(0)
	Active[self] = nil
	UIFrameFadeRemoveFrame(self)
	AlertPool[self] = true
	wipe(self.data)
	self.timer.frame:Show()
end

do
	local function SortFunc(alert1, alert2)
		local v1,v2 = 10000,10000
		local time = GetTime()
		v1 = alert1.data.endTime and alert1.data.endTime - time or v1
		v2 = alert2.data.endTime and alert2.data.endTime - time or v2
		return v1 > v2
	end

	function Prototype:LayoutAlertStack(stack,anchor)
		sort(stack, SortFunc)
		for _,alert in ipairs(stack) do
			alert:ClearAllPoints()
			alert:SetPoint("TOP",anchor,"BOTTOM")
			anchor = alert
		end
	end
end

function Prototype:AnchorToTop()
	self:RemoveFromStacks()
	TopAlertStack[#TopAlertStack+1] = self
	self:LayoutAlertStack(TopAlertStack, TopStackAnchor)
end

function Prototype:AnchorToCenter()
	if self.data.sound then PlaySoundFile(self.data.sound) end
	self:RemoveFromStacks()
	CenterAlertStack[#CenterAlertStack+1] = self
	self:LayoutAlertStack(CenterAlertStack, CenterStackAnchor)
end

do
	local function AnimationFunc(self,time)
		local data = self.data
		local perc = (time - data.t0) / animationTime
		if perc > 1 or perc < 0 then 
			self.animFunc = nil
			self:AnchorToCenter()
			return 
		end
		local x = data.fx + ((data.tox - data.fx) * perc)
		local y = data.fy + ((data.toy - data.fy) * perc)
		self:ClearAllPoints()
		self:SetPoint("TOP",UIParent,"BOTTOMLEFT",x,y)
	end

	function Prototype:TranslateToCenter()
		self:RemoveFromStacks()
		local worldscale,escale = UIParent:GetEffectiveScale(),self:GetEffectiveScale()
		local fx,fy = self:GetCenter()
		fy = fy + self:GetHeight()/2
		local cx,cy = CenterStackAnchor:GetCenter()
		cy = cy - CenterStackAnchor:GetHeight()/2
		local tox,toy = cx*worldscale/escale,cy*worldscale/escale
		local data = self.data
		data.t0 = GetTime()
		data.fx = fx
		data.fy = fy
		data.tox = tox
		data.toy = toy
		self.animFunc = AnimationFunc
	end
end

function Prototype:RemoveFromStack(stack)
	for i,alert in ipairs(stack) do
		if alert == self then 
			remove(stack,i) 
			return
		end
	end
end

function Prototype:RemoveFromStacks()
	self:RemoveFromStack(TopAlertStack)
	self:RemoveFromStack(CenterAlertStack)
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
		self.bar:SetValue(value)
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
		self.bar:SetValue(value)
		if timeleft < data.flashTime then 
			self.bar:SetStatusBarColor(util.blend(data.c1, data.c2, 0.5*(cos(timeleft*12) + 1))) 
		end
	end

	function Prototype:Countdown(totalTime, flashTime)
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

function Prototype:RemoveCountdownFunc()
	self.countFunc = nil
end

local UIFrameFadeOut = UIFrameFadeOut
function Prototype:Fade()
	UIFrameFadeOut(self,fadeTime,self:GetAlpha(),0)
end

function Prototype:SetID(id)
	self.data.id = id
end

function Prototype:SetTimeleft(timeleft)
	self.data.timeleft = timeleft
end

function Prototype:SetSound(sound)
	self.data.sound = sound
end

function Prototype:SetText(text)
	self.text:SetText(text)
end

local Backdrop = {bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", tileSize=16, insets = {left = 2, right = 2, top = 1, bottom = 2}}
local BackdropBorder = {edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 9, insets = {left = 2, right = 2, top = 3, bottom = 2}}

local function CreateAlert()
	local self = CreateFrame("Frame",nil,UIParent)
	self:SetWidth(250)
	self:SetHeight(30)
	self:SetBackdrop(Backdrop)

	self.data = {}

	local bar = CreateFrame("StatusBar",nil,self)
	bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	bar:SetPoint("TOPLEFT",2,-2)
	bar:SetPoint("BOTTOMRIGHT",-2,2)
	bar:SetMinMaxValues(0,1) 
	bar:SetValue(0)
	self.bar = bar

	local border = CreateFrame("Frame",nil,self)
	border:SetAllPoints(true)
	border:SetBackdrop(BackdropBorder)
	border:SetFrameLevel(bar:GetFrameLevel()+1)

	local text = bar:CreateFontString(nil,"ARTWORK")
	text:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf",10)
	text:SetWidth(160) 
	text:SetHeight(20)
	text:SetPoint("TOPLEFT",self,"TOPLEFT",5,-5)
	self.text = text

	self.timer = AceGUI:Create("DXE_Timer")
	self.timer:SetPoint("LEFT",self.text,"RIGHT")
	self.timer.frame:SetFrameLevel(self:GetFrameLevel()+1)
	self.timer.frame:SetParent(self)

	AceTimer:Embed(self)
	for k,v in pairs(Prototype) do self[k] = v end

	return self
end

local function GetAlert()
	local alert = next(AlertPool)
	if alert then AlertPool[alert] = nil
	else alert = CreateAlert() end
	Active[alert] = true
	UpdateFrame:Show()
	alert:Show()
	alert:SetAlpha(0.6)
	alert:SetScale(scale)
	alert:SetColor(Colors.RED,Colors.WHITE)
	return alert
end

---------------------------------------
-- UTILITY
---------------------------------------

local function GetMedia(sound,c1,c2)
	return SM:Fetch("sound",sound),Colors[c1],Colors[c2]
end

---------------------------------------
-- API
---------------------------------------

function module:QuashAllAlerts()
	for alert in pairs(Active) do alert:Destroy() end
end

local find = string.find
function module:QuashAlertsByPattern(pattern)
	for alert in pairs(Active) do
		if alert.data.id and find(alert.data.id,pattern) then
			alert:Destroy()
		end
	end
end

function module:GetAlertTimeleft(id)
	for alert in pairs(Active) do
		if alert.data.id == id then
			return alert.data.timeleft
		end
	end
	return -1
end

-- Dropdown countdown alert
-- This alert counts down a timer at the top of the screen
-- When a "Lead Time" is achieved, it drops to the center, announces a message, and plays a sound effect
-- When it expires, it fades off the screen
function module:Dropdown(id, text, totalTime, flashTime, sound, c1, c2)
	local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local alert = GetAlert()
	alert:SetID(id)
	alert:SetTimeleft(totalTime)
	alert:SetText(text) 
	alert:SetColor(c1Data,c2Data)
	alert:SetSound(soundFile)
	alert:Countdown(totalTime,flashTime)
	alert:AnchorToTop()
	if flashTime then 
		local waitTime = totalTime - flashTime
		if waitTime < 0 then alert:TranslateToCenter()
		else alert:ScheduleTimer("TranslateToCenter",waitTime) end
	end
	alert:ScheduleTimer("Fade",totalTime)
	alert:ScheduleTimer("Destroy",totalTime+fadeTime)
	return alert
end


-- Center popup countdown alert
-- This alert plays a sound right away, then displays a (short) countdown midscreen.
function module:CenterPopup(id, text, totalTime, flashTime, sound, c1, c2)
	local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local alert = GetAlert()
	alert:SetID(id)
	alert:SetTimeleft(totalTime)
	alert:SetColor(c1Data,c2Data)
	alert:SetText(text)
	alert:Countdown(totalTime, flashTime)
	alert:SetSound(soundFile)
	alert:AnchorToCenter()
	alert:ScheduleTimer("Fade",totalTime)
	alert:ScheduleTimer("Destroy",totalTime+fadeTime)
	return alert
end

-- Center popup, simple text
function module:Simple(text, totalTime, sound, c1)
	local soundFile,c1Data = GetMedia(sound,c1)
	local alert = GetAlert()
	if c1Data then 
		alert:SetColor(c1Data)
		alert.bar:SetValue(1)
	end
	alert:SetText(text) 
	alert.timer.frame:Hide()
	alert:SetSound(soundFile)
	alert:AnchorToCenter()
	alert:ScheduleTimer("Fade",totalTime)
	alert:ScheduleTimer("Destroy",totalTime+fadeTime)
	return alert
end

---------------------------------------------
-- ALERT TEST
---------------------------------------------

function addon:AlertsTest()
	module:CenterPopup("AlertTest1", "Decimating. Life Tap Now!", 10, 5, "DXE ALERT1", "DCYAN")
	module:Dropdown("AlertTest2", "Biger City Opening", 20, 5, "DXE ALERT2", "BLUE")
	module:Simple("Gay",3,"DXE ALERT3","RED")
end

