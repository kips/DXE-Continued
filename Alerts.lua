local UIParent = UIParent
local DXE = DXE
local AceGUI = DXE.AceGUI
local Colors,Sounds = DXE.Constants.Colors,DXE.Constants.Sounds

local GetTime,PlaySoundFile = GetTime,PlaySoundFile
local ipairs, pairs = ipairs, pairs
local remove= table.remove

local scale

---------------------------------------
-- INITIALIZATION
---------------------------------------

local Alerts = DXE:NewModule("Alerts","AceTimer-3.0")

---------------------------------------
-- ALERT ANCHORS
---------------------------------------
local TopStackAnchor,CenterStackAnchor

function Alerts:OnInitialize()
	-- Top stack anchor
	TopStackAnchor = DXE:CreateLockableFrame("AlertsTopStackAnchor",245,10,"Alerts - Top Anchor")
	DXE:RegisterMoveSaving(TopStackAnchor,"TOP","UIParent","TOP",0,-16)

	-- Bottom stack anchor
	CenterStackAnchor = DXE:CreateLockableFrame("AlertsCenterStackAnchor",245,10,"Alerts - Center Anchor")
	DXE:RegisterMoveSaving(CenterStackAnchor,"CENTER","UIParent","CENTER",0,100)

	scale = DXE.db.global.AlertsScale
end

function Alerts:OnDisable()
	self:QuashAllAlerts()
end


---------------------------------------
-- ALERT UPDATING
---------------------------------------
-- The active alerts
local Active= {}
Alerts.Active = Active
local frame = CreateFrame("Frame",nil,UIParent)
local function OnUpdate(self,elapsed)
	if #Active == 0 then frame:SetScript("OnUpdate",nil) end
	local time = GetTime()
	for i=1,#Active do
		local alert = Active[i]
		if alert.userdata.dataFunc then alert.userdata.dataFunc(alert,time) end
		if alert.userdata.animFunc then alert.userdata.animFunc(alert,time) end
	end
end

function Alerts:StartUpdating()
	if not frame:GetScript("OnUpdate") then frame:SetScript("OnUpdate",OnUpdate) end
end

---------------------------------------
-- ALERT STACKS
---------------------------------------
-- The top alert stack
local TopAlertStack = {}
-- The center alert stack
local CenterAlertStack = {}

-- Sort: highest countdowns first
local function StackSortFunc(alert1, alert2)
	local v1,v2 = 10000,10000
	local time = GetTime()
	v1 = alert1.userdata.endt and alert1.userdata.endt - time or v1
	v2 = alert2.userdata.endt and alert2.userdata.endt - time or v2
	return v1 > v2
end

local sort = table.sort
function Alerts:LayoutAlertStack(stack, anchor)
	sort(stack, StackSortFunc)
	for i=1,#stack do
		local alert = stack[i]
		alert:Anchor("TOP",anchor,"BOTTOM")
		anchor = alert.frame
	end
end

function Alerts:RemoveAlertFromStack(alert, stack)
	for i,_alert in ipairs(stack) do
		if _alert == alert then remove(stack,i) break end
	end
end

----------------------------------------
-- ALERT UTILITIES
----------------------------------------

-- Timer cache
local Timers = {}
Alerts.Timers = Timers

function Alerts:AlertsScaleChanged()
	scale = DXE.db.global.AlertsScale
	for _,alert in ipairs(Active) do
		alert.frame:SetScale(scale)
	end
end
DXE.RegisterCallback(Alerts,"AlertsScaleChanged")

function Alerts:GetAlert()
	local alert = AceGUI:Create("DXE_Alert")
	alert.frame:SetScale(scale)
	Active[#Active+1] = alert
	return alert
end

function Alerts:RemoveAlert(alert)
	for i,nextAlert in ipairs(Active) do
		if nextAlert == alert then 
			remove(Active,i) 
			break 
		end
	end
end

function Alerts:StopAll()
	self:QuashAllAlerts()
	-- Just to be safe
	self:CancelAllTimers()
end

function Alerts:QuashAllAlerts()
	local n,i = #Active, 1
	while(i <= n) do
		local alert = Active[i]
		self:Destroy(alert)
		n = n - 1
	end
end

local find = string.find
function Alerts:QuashAlertsByPattern(pattern)
	local n,i = #Active, 1
	while(i <= n) do
		local alert = Active[i]
		if alert.userdata.name and find(alert.userdata.name,pattern) then
			self:Destroy(alert)
			n = n - 1
		else i = i + 1 end
	end
end

function Alerts:CancelAlertTimers(alert)
	for handle,nextAlert in pairs(Timers) do
		if nextAlert == alert then 
			self:CancelTimer(handle,true)
			Timers[handle] = nil
		end
	end
end

local UIFrameFadeOut = UIFrameFadeOut
function Alerts:Fade(alert)
	UIFrameFadeOut(alert.frame,2,alert.frame:GetAlpha(),0)
end

function Alerts:Destroy(alert)
	self:CancelAlertTimers(alert)
	self:RemoveFromStacks(alert) 
	self:RemoveAlert(alert)
	AceGUI:Release(alert)
end

local function MoveFunc(self,time)
	local userdata = self.userdata
	local perc = (time-userdata.movet0) / userdata.movedt
	if perc < 0 or perc > 1 then return end
	local x = userdata.movefx + ((userdata.movetox - userdata.movefx) * perc)
	local y = userdata.movefy + ((userdata.movetoy - userdata.movefy) * perc)
	local a = userdata.movefroma + ((userdata.movetoa - userdata.movefroma) * perc)
	self.frame:ClearAllPoints() 
	self.frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", x,y)
	self.frame:SetAlpha(a)
end

function Alerts:Move(alert,dt,tox,toy,froma,toa)
	local t0 = GetTime()
	local fx,fy = alert.frame:GetCenter()
	fy = fy + alert.frame:GetHeight()/2
	local userdata = alert.userdata
	local worldscale = UIParent:GetEffectiveScale()
	local escale = alert.frame:GetEffectiveScale()
	userdata.moving = true
	userdata.movefx = fx
	userdata.movefy = fy
	userdata.movetox = tox*worldscale/escale
	userdata.movetoy = toy*worldscale/escale
	userdata.movefroma = froma
	userdata.movetoa = 0.9
	userdata.movet0 = t0
	userdata.movedt = dt
	userdata.animFunc = MoveFunc
end

function Alerts:RemoveFromStacks(alert)
	self:RemoveAlertFromStack(alert, TopAlertStack)
	self:RemoveAlertFromStack(alert, CenterAlertStack)
end

function Alerts:ToTop(alert)
	self:RemoveFromStacks(alert)
	if alert.userdata.forceTop then
		TopAlertStack[#TopAlertStack+1] = alert
		self:LayoutAlertStack(TopAlertStack, TopStackAnchor)
	else
		local x,y = TopStackAnchor:GetCenter()
		y = y - TopStackAnchor:GetHeight()/2
		self:Move(alert,animTime, x, y, alert.frame:GetAlpha())
		Timers[self:ScheduleTimer("ToTop",alert.userdata.animTime,alert)] = alert
		alert.userdata.forceTop = true
	end
end

function Alerts:ToCenter(alert)
	self:RemoveFromStacks(alert)
	if alert.userdata.forceCenter then 
		CenterAlertStack[#CenterAlertStack+1] = alert
		self:LayoutAlertStack(CenterAlertStack, CenterStackAnchor)
	else
		if alert.userdata.sound then PlaySoundFile(alert.userdata.sound) end
		local x,y = CenterStackAnchor:GetCenter()
		y = y - CenterStackAnchor:GetHeight()/2
		self:Move(alert,alert.userdata.animTime, x, y, alert.frame:GetAlpha())
		Timers[self:ScheduleTimer("ToCenter",alert.userdata.animTime, alert)] = alert
		alert.userdata.forceCenter = true
	end
end

local function CountdownFunc(self,time)
	local timeleft = self.userdata.endt - time
	if timeleft < 0 then return end
	self.timer:SetTime(timeleft)
	local value = 1 - (timeleft / self.userdata.dt)
	self.bar:SetValue(value)
end

local function blend(c1, c2, factor)
	local r = (1-factor) * c1.r + factor * c2.r
	local g = (1-factor) * c1.g + factor * c2.g
	local b = (1-factor) * c1.b + factor * c2.b
	return r,g,b
end

local cos = math.cos
local function CountdownFlashFunc(self,time)
	local userdata = self.userdata
	local timeleft = userdata.endt - time
	if timeleft < 0 then return end
	self.timer:SetTime(timeleft)
	local value = 1 - (timeleft / userdata.dt)
	self.bar:SetValue(value)
	if timeleft < userdata.flashdt then 
		self.bar:SetStatusBarColor(blend(userdata.c1, userdata.c2, 0.5*(cos(timeleft*12) + 1))) 
	end
end

function Alerts:RemoveCountdownFuncs(alert)
	alert.userdata.endt = nil
	alert.userdata.dataFunc = nil
end

function Alerts:Countdown(alert, dt, flash)
	local endt = GetTime() + dt
	alert.userdata.endt,alert.userdata.dt = endt, dt
	if flash then
		alert.userdata.flashdt = flash
		alert.userdata.dataFunc = CountdownFlashFunc
	else
		alert.userdata.dataFunc = CountdownFunc
	end
	Timers[self:ScheduleTimer("RemoveCountdownFuncs",endt,alert)] = alert
end

-- Dropdown countdown alert.
-- This alert counts down a timer at the top of the screen.
-- When a "Lead Time" is achieved, it drops to the center, announces a message, and plays a sound effect.
-- When it expires, it fades off the screen.
function Alerts:Dropdown(id, text, totalTime, flashTime, sound, c1, c2)
	if sound then sound = Sounds[sound] end
	if c1 then c1 = Colors[c1] end
	if c2 then c2 = Colors[c2] end
	local alert = self:GetAlert()
	alert:SetColor(c1,c2)
	alert:SetText(text) 
	alert:SetAlpha(0.6) 
	alert.userdata.name = id
	alert.userdata.sound = sound
	alert.userdata.animTime = 0.3
	alert.userdata.forceTop = true
	self:Countdown(alert,totalTime,flashTime)
	self:ToTop(alert)
	if flashTime then Timers[self:ScheduleTimer("ToCenter",totalTime - flashTime, alert)] = alert end
	Timers[self:ScheduleTimer("Fade",totalTime,alert)] = alert
	Timers[self:ScheduleTimer("Destroy",totalTime + 3,alert)] = alert
	self:StartUpdating()
	return alert
end


-- Center popup countdown alert
-- This alert plays a sound right away, then displays a (short) countdown midscreen.
function Alerts:CenterPopup(id, text, time, flashTime, sound, c1, c2)
	if sound then sound = Sounds[sound] end
	if c1 then c1 = Colors[c1] end
	if c2 then c2 = Colors[c2] end
	local alert = self:GetAlert()
	alert.userdata.name = id 
	alert.userdata.forceCenter = true
	alert:SetColor(c1,c2)
	alert:SetText(text)
	alert:SetAlpha(0.6)
	self:Countdown(alert,time, flashTime)
	self:ToCenter(alert)
	Timers[self:ScheduleTimer("Fade",time,alert)] = alert
	Timers[self:ScheduleTimer("Destroy",time+3,alert)] = alert
	if sound then PlaySoundFile(sound) end
	self:StartUpdating()
	return alert
end

-- Center popup, simple text
function Alerts:Simple(text, sound, persist, c1)
	if sound then sound = Sounds[sound] end
	local alert = self:GetAlert()
	if c1 then 
		c1 = Colors[c1] 
		alert:SetColor(c1)
		alert.bar:SetValue(1)
	end
	alert:SetText(text) 
	alert.timer.frame:Hide()
	alert:SetAlpha(0.6)
	alert.userdata.forceCenter = true
	self:ToCenter(alert)
	if sound then PlaySoundFile(sound) end
	Timers[self:ScheduleTimer("Fade",persist,alert)] = alert
	Timers[self:ScheduleTimer("Destroy",persist+3,alert)] = alert
	self:StartUpdating()
	return alert
end

DXE.Alerts = Alerts
