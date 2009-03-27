local UIParent = UIParent
local AceGUI = LibStub("AceGUI-3.0")
local Colors,Sounds = DXE.Constants.Colors,DXE.Constants.Sounds

local GetTime,PlaySoundFile = GetTime,PlaySoundFile
local ipairs, pairs = ipairs, pairs
local insert,remove= table.insert,table.remove

---------------------------------------
-- INITIALIZATION
---------------------------------------

local Alerts = {}
LibStub("AceTimer-3.0"):Embed(Alerts)

---------------------------------------
-- ALERT ANCHORS
---------------------------------------

-- Top stack anchor
local TopStackAnchor = CreateFrame("Frame",nil,UIParent)
TopStackAnchor:SetWidth(1) 
TopStackAnchor:SetHeight(10)
TopStackAnchor:SetPoint("TOP",-125,-16)

-- Bottom stack anchor
local CenterStackAnchor = CreateFrame("Frame",nil,UIParent)
CenterStackAnchor:SetWidth(1)
CenterStackAnchor:SetHeight(1)
CenterStackAnchor:SetPoint("CENTER",-125,100)

---------------------------------------
-- ALERT UPDATING
---------------------------------------
-- The active alerts
local Active= {}
local frame = CreateFrame("Frame",nil,UIParent)
local function OnUpdate(elapsed)
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
		alert:Anchor("TOPLEFT",anchor,"BOTTOMLEFT")
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

function Alerts:GetAlert()
	local alert = AceGUI:Create("DXE_Alert")
	insert(Active, alert)
	return alert
end

function Alerts:RemoveAlert(alert)
	for i,_alert in ipairs(Active) do
		if _alert == alert then 
			remove(Active,i) 
			break 
		end
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

do
	local temp = {}
	function Alerts:CancelAlertTimers(alert)
		wipe(temp)
		for handle,_alert in pairs(Timers) do
			if _alert == alert then temp[handle] = alert end
		end
		for handle,_alert in pairs(temp) do
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
	self.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	self.frame:SetAlpha(a)
end

function Alerts:Move(alert,dt,tox,toy,froma,toa)
	local fx,fy,t0 = alert.frame:GetLeft(), alert.frame:GetTop(), GetTime()
	local userdata = alert.userdata
	userdata.moving = true
	userdata.movefx = fx
	userdata.movefy = fy
	userdata.movetox = tox
	userdata.movetoy = toy
	userdata.movefroma = froma
	userdata.movetoa = 1
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
		insert(TopAlertStack, alert)
		self:LayoutAlertStack(TopAlertStack, TopStackAnchor)
	else
		local x,y = TopStackAnchor:GetLeft(), TopStackAnchor:GetBottom()
		self:Move(alert,animTime, x, y, alert.frame:GetAlpha())
		Timers[self:ScheduleTimer("ToTop",alert.userdata.animTime,alert)] = alert
		alert.userdata.forceTop = true
	end
end

function Alerts:ToCenter(alert)
	self:RemoveFromStacks(alert)
	if alert.userdata.forceCenter then 
		insert(CenterAlertStack, alert)
		self:LayoutAlertStack(CenterAlertStack, CenterStackAnchor)
	else
		if alert.userdata.sound then PlaySoundFile(alert.userdata.sound) end
		local x,y = CenterStackAnchor:GetLeft(), CenterStackAnchor:GetBottom()
		self:Move(alert,alert.userdata.animTime, x, y, alert.frame:GetAlpha())
		Timers[self:ScheduleTimer("ToCenter",alert.userdata.animTime, alert)] = alert
		alert.userdata.forceCenter = true
	end
end

local function CountdownFunc(self,time)
	local timeleft = self.userdata.endt - time
	if timeleft < 0 then return end
	self.timer.SetTime(timeleft)
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
	local ldt = totalTime - flashTime
	local alert = self:GetAlert()
	alert:SetColor(c1,c2)
	alert:SetText(text) 
	alert:SetAlpha(.60) 
	alert.userdata.name = id
	alert.userdata.sound = sound
	alert.userdata.animTime = 0.3
	alert.userdata.forceTop = true
	self:Countdown(alert,totalTime,flashTime)
	self:ToTop(alert)
	Timers[self:ScheduleTimer("ToCenter",ldt, alert)] = alert
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
function Alerts:Simple(text, sound, persist)
	if sound then sound = Sounds[sound] end
	local alert = self:GetAlert()
	alert:SetText(text) 
	alert.timer.frame:Hide()
	alert:SetAlpha(0.7)
	alert.userdata.forceCenter = true
	self:ToCenter(alert)
	if sound then PlaySoundFile(sound) end
	Timers[self:ScheduleTimer("Fade",persist,alert)] = alert
	Timers[self:ScheduleTimer("Destroy",persist+3,alert)] = alert
	self:StartUpdating()
	return alert
end

DXE.Alerts = Alerts
