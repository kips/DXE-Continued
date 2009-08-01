-- Based off RDX's alert system

local defaults = {
	profile = {
		BarTexture = "Blizzard",
		DisableDropdowns = false,
		TopScale = 1,
		CenterScale = 1,
		TopGrowth = "DOWN",
		CenterGrowth = "DOWN",
		TopAlpha = 0.55,
		CenterAlpha = 0.75,
		FlashAlpha = 0.6,
		FlashDuration = 0.8,
		FlashOscillations = 2,
	}
}

local addon = DXE
local version = tonumber(("$Rev$"):match("%d+"))
addon.version = version > addon.version and version or addon.version
local L = addon.L

local UIParent = UIParent
local SM = addon.SM
local format = string.format
local wipe = table.wipe
local Colors = addon.Media.Colors

local GetTime,PlaySoundFile,ipairs,pairs,next,remove = GetTime,PlaySoundFile,ipairs,pairs,next,table.remove

local util = addon.util

local ANIMATION_TIME = 0.3
local FADE_TIME = 2
local BARWIDTH = 250
local BARHEIGHT = 30

local db,pfl

---------------------------------------
-- INITIALIZATION
---------------------------------------

local module = addon:NewModule("Alerts")
addon.Alerts = module
local Active = {}
local TopAlertStack = {}
local CenterAlertStack = {}
local AlertPool = {}
local prototype = {}

local TopStackAnchor,CenterStackAnchor

function module:RefreshProfile()
	pfl = db.profile
	self:RefreshAlerts()
end

function module:RefreshAlerts()
	if not next(Active) then return end
	for alert in pairs(Active) do
		alert.bar:SetStatusBarTexture(SM:Fetch("statusbar",pfl.BarTexture))
		local data = alert.data
		if data.anchor == "TOP" then
			alert:SetScale(pfl.TopScale)
			alert:SetAlpha(pfl.TopAlpha)
		elseif data.anchor == "CENTER" then
			alert:SetScale(pfl.CenterScale)
			alert:SetAlpha(pfl.CenterAlpha)
		end
	end
	prototype:LayoutAlertStack(TopAlertStack, TopStackAnchor, pfl.TopGrowth)
	prototype:LayoutAlertStack(CenterAlertStack, CenterStackAnchor, pfl.CenterGrowth)
end

function module:InitializeOptions(area)
	area.alerts_group = {
		type = "group",
		name = L["Alerts"],
		order = 200,
		handler = self,
		get = function(info) return pfl[info[#info]] end,
		set = function(info,v) pfl[info[#info]] = v end,
		args = {
			bars_group = {
				type = "group",
				name = L["Bars"],
				order = 100,
				inline = true,
				args = {
					AlertsTest = {
						type = "execute",
						name = L["Test Bars"],
						desc = L["Fires a dropdown, center popup, and simple alert bars"],
						order = 100,
						func = "AlertsTest",
					},
					BarTexture = {
						order = 300,
						type = "select",
						name = L["Bar Texture"],
						desc = L["Select a bar texture used on all bars"],
						values = SM:HashTable("statusbar"),
						set = function(info,v) pfl.BarTexture = v; self:RefreshAlerts() end,
						dialogControl = "LSM30_Statusbar",
					},
					DisableDropdowns = {
						order = 400,
						type = "toggle",
						name = L["Disable Dropdowns"],
						desc = L["Anchor bars onto the center anchor only"],
					},
					top_group = {
						type = "group",
						name = L["Top"],
						order = 500,
						args = {
							top_desc = {
								type = "description",
								name = L["Adjust settings related to the top anchor"],
								order = 1,
							},
							TopScale = {
								order = 100,
								type = "range",
								name = L["Scale"],
								desc = L["Adjust the size of top bars"],
								min = 0.5,
								max = 1.5,
								step = 0.05,
								set = function(info,v) pfl.TopScale = v; self:RefreshAlerts() end,
							},
							TopAlpha = {
								type = "range",
								name = L["Alpha"],
								desc = L["Adjust the transparency of top bars"],
								order = 300,
								min = 0.1,
								max = 1,
								step = 0.05,
								set = function(info,v) pfl.TopAlpha = v; self:RefreshAlerts() end,
							},
							TopGrowth = {
								order = 300,
								type = "select",
								name = L["Growth"],
								desc = L["The direction top bars grow"],
								values = {DOWN = L["Down"], UP = L["Up"]},
								set = function(info,v) pfl.TopGrowth = v; self:RefreshAlerts() end,
							},
						},
					},
					center_group = {
						type = "group",
						name = L["Center"],
						order = 600,
						args = {
							center_desc = {
								type = "description",
								name = L["Adjust settings related to the center anchor"],
								order = 1,
							},
							CenterScale = {
								order = 100,
								type = "range",
								name = L["Scale"],
								desc = L["Adjust the size of center bars"],
								min = 0.5,
								max = 1.5,
								step = 0.05,
								set = function(info,v) pfl.CenterScale = v; self:RefreshAlerts() end,
							},
							CenterAlpha = {
								type = "range",
								name = L["Alpha"],
								desc = L["Adjust the transparency of center bars"],
								order = 200,
								min = 0.1,
								max = 1,
								step = 0.05,
								set = function(info,v) pfl.CenterAlpha = v; self:RefreshAlerts() end,
							},
							CenterGrowth = {
								order = 300,
								type = "select",
								name = L["Growth"],
								desc = L["The direction center bars grow"],
								values = {DOWN = L["Down"], UP = L["Up"]},
								set = function(info,v) pfl.CenterGrowth = v; self:RefreshAlerts() end,
							},
						},
					},
				},
			},
			flash_group = {
				type = "group",
				name = L["Screen Flash"],
				order = 200,
				inline = true,
				args = {
					flash_desc = {
						type = "description",
						name = L["The color of the flash becomes the main color of the alert. Colors for each alert are set in the Encounters section. If the color is set to 'Clear' it defaults to black"],
						order = 1,
					},
					FlashTest = {
						type = "execute",
						name = L["Test Flash"],
						desc = L["Fires a flash using a random color"],
						order = 100,
						func = "FlashTest",
					},
					FlashAlpha = {
						type = "range",
						name = L["Flash Alpha"],
						desc = L["Adjust the transparency of the flash"],
						order = 200,
						min = 0.1,
						max = 1,
						step = 0.05,
					},
					FlashDuration = {
						type = "range",
						name = L["Duration"],
						desc = L["Adjust how long the flash lasts"],
						order = 300,
						min = 0.2,
						max = 3,
						step = 0.05,
					},
					FlashOscillations = {
						type = "range",
						name = L["Oscillations"],
						desc = L["Adjust how many times the flash fades in and out"],
						order = 400,
						min = 1,
						max = 10,
						step = 1,
					},
				},
			},
		},
	}
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

	self.db = addon.db:RegisterNamespace("Alerts", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

	addon:AddModuleOptionInitializer(module,"InitializeOptions")
end

function module:OnDisable()
	self:QuashAllAlerts()
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
		c = c or Colors.BLACK
		counter = 0
		FLASH_DURATION = pfl.FlashDuration
		PERIOD = FLASH_DURATION / pfl.FlashOscillations
		AMP = PERIOD / 2
		MULT = 1 / AMP
		flash:SetBackdropColor(c.r,c.g,c.b,pfl.FlashAlpha)
		flash:SetAlpha(0)
		flash:Show()
	end
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


function prototype:SetColor(c1,c2)
	self.data.c1 = c1
	self.bar:SetStatusBarColor(c1.r,c1.g,c1.b)
	self.data.c2 = c2 or c1
end

function prototype:Destroy()
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
	local function SortDesc(a1, a2)
		return (a1.data.timeleft or 10000) > (a2.data.timeleft or 10000)
	end

	function prototype:LayoutAlertStack(stack,anchor,growth)
		sort(stack, SortDesc)
		local point,relpoint,mult
		if growth == "DOWN" then
			point = "TOP"
			relpoint = "BOTTOM"
			mult = -1
		elseif growth == "UP" then
			point = "BOTTOM"
			relpoint = "TOP"
			mult = 1
		end
		for i,alert in ipairs(stack) do
			alert:ClearAllPoints()
			alert:SetPoint(point,anchor,relpoint,0,mult*(i-1)*BARHEIGHT)
		end
	end
end

function prototype:AnchorToTop()
	self.data.anchor = "TOP"
	self:SetAlpha(pfl.TopAlpha)
	self:SetScale(pfl.TopScale)
	self:RemoveFromStacks()
	TopAlertStack[#TopAlertStack+1] = self
	self:LayoutAlertStack(TopAlertStack, TopStackAnchor, pfl.TopGrowth)
end

function prototype:AnchorToCenter()
	if self.data.sound then PlaySoundFile(self.data.sound) end
	self.data.anchor = "CENTER"
	self:SetAlpha(pfl.CenterAlpha)
	self:SetScale(pfl.CenterScale)
	self:RemoveFromStacks()
	CenterAlertStack[#CenterAlertStack+1] = self
	self:LayoutAlertStack(CenterAlertStack, CenterStackAnchor, pfl.CenterGrowth)
end

do
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
		local tox,toy = cx*worldscale,cy*worldscale
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
	for i,alert in ipairs(stack) do
		if alert == self then 
			remove(stack,i) 
			return
		end
	end
end

function prototype:RemoveFromStacks()
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

function prototype:SetText(text)
	self.text:SetText(text)
end

local Backdrop = {bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", tileSize=16, insets = {left = 2, right = 2, top = 1, bottom = 2}}
local BackdropBorder = {edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 9, insets = {left = 2, right = 2, top = 3, bottom = 2}}

local BarCount = 1
local function CreateAlert()
	local self = CreateFrame("Frame","DXEAlertBar"..BarCount,UIParent)
	self:SetWidth(BARWIDTH)
	self:SetHeight(BARHEIGHT)
	self:SetBackdrop(Backdrop)

	self.data = {}

	local bar = CreateFrame("StatusBar",nil,self)
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

	self.timer = addon.AceGUI:Create("DXE_Timer")
	self.timer:SetPoint("LEFT",self.text,"RIGHT")
	self.timer.frame:SetFrameLevel(self:GetFrameLevel()+1)
	self.timer.frame:SetParent(self)

	addon.AceTimer:Embed(self)
	for k,v in pairs(prototype) do self[k] = v end

	self.fadeTable = {mode = "OUT", timeToFade = FADE_TIME, endAlpha = 0, finishedArg1 = self }

	BarCount = BarCount + 1

	return self
end

local function GetAlert()
	local alert = next(AlertPool)
	if alert then AlertPool[alert] = nil
	else alert = CreateAlert() end
	Active[alert] = true
	UpdateFrame:Show()
	alert:Show()

	-- Apply settings
	alert:SetScale(pfl.Scale)
	alert.bar:SetStatusBarTexture(SM:Fetch("statusbar",pfl.BarTexture))

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

function module:Dropdown(id, text, totalTime, flashTime, sound, c1, c2, flashscreen)
	if pfl.DisableDropdowns then self:CenterPopup(id, text, totalTime, flashTime, sound, c1, c2, flashscreen) return end
	local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local alert = GetAlert()
	alert:SetID(id)
	alert:SetTimeleft(totalTime)
	alert:SetText(text) 
	alert:SetFlashScreen(flashscreen)
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
	return alert
end

function module:CenterPopup(id, text, totalTime, flashTime, sound, c1, c2, flashscreen)
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
	if flashscreen then self:FlashScreen(c1Data) end
	return alert
end

function module:Simple(text, totalTime, sound, c1, flashscreen)
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
	if flashscreen then self:FlashScreen(c1Data) end
	return alert
end

---------------------------------------------
-- ALERT TESTS
---------------------------------------------

function module:AlertsTest()
	self:CenterPopup("AlertTest1", "Decimating. Life Tap Now!", 10, 5, "DXE ALERT1", "DCYAN")
	self:Dropdown("AlertTest2", "Bigger City Opening", 20, 5, "DXE ALERT2", "BLUE", "ORANGE")
	self:Simple("Just Kill It!",3,"DXE ALERT3","RED")
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
