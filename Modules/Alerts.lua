-- Based off RDX's alert system

local defaults = {
	profile = {
		BarTexture = "Blizzard",
		DisableDropdowns = false,
		DisableScreenFlash = false,
		DisableSounds = false,
		IconPosition = "LEFT",
		IconOffset = 0,
		HideIcons = false,
		TopScale = 1,
		CenterScale = 1,
		TopGrowth = "DOWN",
		CenterGrowth = "DOWN",
		TopAlpha = 0.55,
		CenterAlpha = 0.75,
		FlashAlpha = 0.6,
		FlashDuration = 0.8,
		FlashOscillations = 2,
		TopBarWidth = 250,
		CenterBarWidth = 275,
		BarBackgroundColor = {0,0,0,0.8},
		BarBorder = "Blizzard Tooltip",
		BarBorderColor = {1,1,1},
		BarFont = "Franklin Gothic Medium",
		BarFontSize = 10,
		BarStyle = "RDX",
		BarBorderSize = 8,
		BarFillDirection = "FILL",
	}
}

local addon = DXE
local L = addon.L

local UIParent = UIParent
local SM = addon.SM
local format,gsub = string.format,string.gsub
local wipe = table.wipe
local name_to_unit = addon.Roster.name_to_unit
local CN = addon.CN
local Colors = addon.Media.Colors

local GetTime,PlaySoundFile,ipairs,pairs,next,remove = GetTime,PlaySoundFile,ipairs,pairs,next,table.remove

local util = addon.util

local ANIMATION_TIME = 0.3
local FADE_TIME = 2
local BARHEIGHT

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

function module:InitializeOptions(area)
	local function SetNotRefresh(info,v,v2,v3,v4)
		local var = info[#info]
		if var:find("Color") then pfl[var] = {v,v2,v3,v4}
		else pfl[var] = v end
	end

	area.alerts_group = {
		type = "group",
		name = L["Alerts"],
		order = 200,
		handler = self,
		get = function(info) 
			local var = info[#info]
			if var:find("Color") then return unpack(pfl[var])
			else return pfl[var] end
		end,
		set = function(info,v,v2,v3,v4) 
			local var = info[#info]
			if var:find("Color") then pfl[var] = {v,v2,v3,v4}
			else pfl[var] = v end
			self:RefreshAlerts()
		end,
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
					general_group = {
						type = "group",
						name = L["General"],
						order = 200,
						args = {
							BarStyle = {
								order = 100,
								type = "select",
								name = L["Bar Style"],
								desc = L["Select a bar style"],
								values = {RDX = "RDX", BIGWIGS = "BigWigs"},
							},
							BarTexture = {
								order = 200,
								type = "select",
								name = L["Bar Texture"],
								desc = L["Select a bar texture"],
								values = SM:HashTable("statusbar"),
								dialogControl = "LSM30_Statusbar",
							},
							BarFillDirection = {
								order = 250,
								type = "select",
								name = L["Bar Fill Direction"],
								desc = L["The direction bars fill"],
								values = {
									FILL = L["Left to Right"],
									DEPLETE = L["Right to Left"],
								},
							},
							BarBackgroundColor = {
								order = 300,
								type = "color",
								name = L["Bar Background Color"],
								desc = L["Select a bar background color"],
								hasAlpha = true,
							},
							DisableDropdowns = {
								order = 400,
								type = "toggle",
								name = L["Disable Dropdowns"],
								desc = L["Anchor bars onto the center anchor only"],
								set = SetNoRefresh,
							},
							DisableSounds = {
								order = 500,
								type = "toggle",
								name = L["Disable Sounds"],
								desc = L["Turns off all alert sounds"],
								set = SetNoRefresh,
							},
						},
					},
					border_group = {
						type = "group",
						order = 300,
						name = L["Border"],
						disabled = function() return pfl.BarStyle == "BIGWIGS" end,
						args = {
							BarBorder = {
								order = 100,
								type = "select",
								name = L["Bar Border"],
								desc = L["Select a bar border"],
								values = SM:HashTable("border"),
								dialogControl = "LSM30_Border",
							},
							BarBorderColor = {
								order = 200,
								type = "color",
								name = L["Bar Border Color"],
								desc = L["Select a bar border color"],
							},
							BarBorderSize = {
								order = 300,
								type = "range",
								name = L["Bar Border Size"],
								desc = L["Adjust the size of bar borders"],
								min = 6,
								max = 20,
								step = 1,
							},
						},
					},

					font_group = {
						type = "group",
						name = L["Font"],
						order = 400,
						args = {
							BarFont = {
								order = 100,
								type = "select",
								name = L["Bar Font"],
								desc = L["Select a font used on all"],
								values = SM:HashTable("font"),
								dialogControl = "LSM30_Font",
							},
							BarFontSize = {
								order = 200,
								type = "range",
								name = L["Bar Font Size"],
								desc = L["Select a font size used on all"],
								min = 8,
								max = 20,
								step = 1,
							},
						},
					},
					icon_group = {
						type = "group",
						name = L["Icon"],
						order = 500,
						args = {
							HideIcons = {
								order = 100,
								type = "toggle",
								name = L["Hide Icons"],
								desc = L["Hide icons on bars"],
							},
							IconPosition = {
								order = 200,
								type = "select",
								name = L["Icon Position"],
								desc = L["Select where to show icons on bars"],
								values = {LEFT = L["Left"], RIGHT = L["Right"]},
								disabled = function() return pfl.HideIcons end,
							},
							IconOffset = {
								order = 300,
								type = "range",
								name = L["Icon Offset"],
								desc = L["How far away the icon is from the bar"],
								min = -4,
								max = 10,
								step = 0.1,
								disabled = function() return pfl.HideIcons end,
							},
						},
					},
					
					top_group = {
						type = "group",
						name = L["Top Anchored Bars"],
						order = 600,
						disabled = function() return pfl.DisableDropdowns end,
						args = {
							top_desc = {
								type = "description",
								name = L["Adjust settings related to the top anchor"],
								order = 1,
							},
							TopScale = {
								order = 100,
								type = "range",
								name = L["Bar Scale"],
								desc = L["Adjust the size of top bars"],
								min = 0.5,
								max = 1.5,
								step = 0.05,
							},
							TopAlpha = {
								type = "range",
								name = L["Bar Alpha"],
								desc = L["Adjust the transparency of top bars"],
								order = 200,
								min = 0.1,
								max = 1,
								step = 0.05,
							},
							TopBarWidth = {
								order = 300,
								type = "range",
								name = L["Bar Width"],
								desc = L["Adjust the width of top bars"],
								min = 220,
								max = 1000,
								step = 1,
							},
							TopGrowth = {
								order = 400,
								type = "select",
								name = L["Bar Growth"],
								desc = L["The direction top bars grow"],
								values = {DOWN = L["Down"], UP = L["Up"]},
							},
						},
					},
					center_group = {
						type = "group",
						name = L["Center Anchored Bars"],
						order = 700,
						args = {
							center_desc = {
								type = "description",
								name = L["Adjust settings related to the center anchor"],
								order = 1,
							},
							CenterScale = {
								order = 100,
								type = "range",
								name = L["Bar Scale"],
								desc = L["Adjust the size of center bars"],
								min = 0.5,
								max = 1.5,
								step = 0.05,
							},
							CenterAlpha = {
								type = "range",
								name = L["Bar Alpha"],
								desc = L["Adjust the transparency of center bars"],
								order = 200,
								min = 0.1,
								max = 1,
								step = 0.05,
							},
							CenterBarWidth = {
								order = 300,
								type = "range",
								name = L["Bar Width"],
								desc = L["Adjust the width of center bars"],
								min = 220,
								max = 1000,
								step = 1,
							},
							CenterGrowth = {
								order = 400,
								type = "select",
								name = L["Bar Growth"],
								desc = L["The direction center bars grow"],
								values = {DOWN = L["Down"], UP = L["Up"]},
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
						order = 50,
					},
					DisableScreenFlash = {
						order = 75,
						type = "toggle",
						name = L["Disable Screen Flash"],
						desc = L["Turns off all alert screen flashes"],
						set = SetNoRefresh,
						width = "full",
					},
					flash_inner_group = {
						name = "",
						type = "group",
						order = 100,
						disabled = function() return pfl.DisableScreenFlash end,
						args = {
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
		if pfl.DisableScreenFlash then return end
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
	self.iconf:Hide()
	self.icon:SetTexture("")
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
		self.bar:SetValue(pfl.BarFillDirection == "FILL" and value or 1 - value)
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
		self.bar:SetValue(pfl.BarFillDirection == "FILL" and value or 1 - value)
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

do
	local function colorname(word)
		return name_to_unit[word] and CN[word] or word
	end

	function prototype:SetText(text)
		text = gsub(text,".+: (%w+)",colorname)
		self.text:SetText(text)
	end
end

function prototype:SetIcon(texture)
	if not texture then self.iconf:Hide() return end
	self.data.icon = texture
	if pfl.HideIcons then return end
	self.iconf:Show()
	self.icon:SetTexture(texture)
end

local Backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", insets = {left = 2, right = 2, top = 2, bottom = 2}}
local BackdropBorder = {edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8, insets = {left = 2, right = 2, top = 2, bottom = 2}}
local BackdropDummy = {bgFile = "", insets = {left = 0, right = 0, top = 0, bottom = 0}}
local function StyleAlert(alert,style)
	alert.bar:ClearAllPoints()
	alert.icon:ClearAllPoints()

	local timer = alert.timer
	timer.frame:ClearAllPoints()

	if style == "RDX" then
		BARHEIGHT = 30

		timer.left:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",20)
		timer.right:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",12)
		timer.frame:SetPoint("RIGHT",alert,"RIGHT",-5,0)
		alert.border:Show()

		local inset = pfl.BarBorderSize/4
		alert.bar:SetPoint("TOPLEFT",inset,-inset)
		alert.bar:SetPoint("BOTTOMRIGHT",-inset,inset)

		for k,v in pairs(Backdrop.insets) do 
			Backdrop.insets[k] = inset 
			BackdropBorder.insets[k] = inset
		end
		Backdrop.bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"

		BackdropBorder.edgeSize = pfl.BarBorderSize
		alert.iconf:SetBackdrop(BackdropBorder)

		alert.icon:SetPoint("TOPLEFT",2,-2)
		alert.icon:SetPoint("BOTTOMRIGHT",-2,2)

	elseif style == "BIGWIGS" then
		BARHEIGHT = 14

		timer.left:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",13)
		timer.right:SetFont("Interface\\Addons\\DXE\\Fonts\\BS.ttf",8)
		timer.frame:SetPoint("RIGHT",alert,"RIGHT",5,0)

		alert.border:Hide()

		alert.bar:SetAllPoints(true)

		for k,v in pairs(Backdrop.insets) do Backdrop.insets[k] = 0 end
		Backdrop.bgFile = SM:Fetch("statusbar",pfl.BarTexture)

		alert.iconf:SetBackdrop(BackdropDummy)

		alert.icon:SetAllPoints(true)
	end

	alert:SetBackdrop(Backdrop)
	alert:SetHeight(BARHEIGHT)
	alert.iconf:SetWidth(BARHEIGHT)
	alert.iconf:SetHeight(BARHEIGHT)
end

local function SkinAlert(alert)
	StyleAlert(alert,pfl.BarStyle)

	alert.bar:SetStatusBarTexture(SM:Fetch("statusbar",pfl.BarTexture))

	if pfl.HideIcons then 
		alert.iconf:Hide() 
	else
		alert:SetIcon(alert.data.icon)
	end

	alert.iconf:ClearAllPoints()
	if pfl.IconPosition == "LEFT" then
		alert.iconf:SetPoint("RIGHT",alert,"LEFT",-pfl.IconOffset,0)
	elseif pfl.IconPosition == "RIGHT" then
		alert.iconf:SetPoint("LEFT",alert,"RIGHT",pfl.IconOffset,0)
	end

	BackdropBorder.edgeFile = SM:Fetch("border",pfl.BarBorder)
	local r,g,b = unpack(pfl.BarBorderColor)
	alert.border:SetBackdrop(BackdropBorder)
	alert.border:SetBackdropBorderColor(r,g,b)
	alert.iconf:SetBackdropBorderColor(r,g,b)

	alert.text:SetFont(SM:Fetch("font",pfl.BarFont),pfl.BarFontSize)

	alert:SetBackdropColor(unpack(pfl.BarBackgroundColor))

	local data = alert.data
	if data.anchor == "TOP" then
		alert:SetScale(pfl.TopScale)
		alert:SetAlpha(pfl.TopAlpha)
		alert:SetWidth(pfl.TopBarWidth)
	elseif data.anchor == "CENTER" then
		alert:SetScale(pfl.CenterScale)
		alert:SetAlpha(pfl.CenterAlpha)
		alert:SetWidth(pfl.CenterBarWidth)
	end
end

function module:RefreshAlerts()
	if not next(Active) and not next(AlertPool) then return end
	for alert in pairs(Active) do SkinAlert(alert) end
	for alert in pairs(AlertPool) do SkinAlert(alert) end
	prototype:LayoutAlertStack(TopAlertStack, TopStackAnchor, pfl.TopGrowth)
	prototype:LayoutAlertStack(CenterAlertStack, CenterStackAnchor, pfl.CenterGrowth)
end

local BarCount = 1
local function CreateAlert()
	local self = CreateFrame("Frame","DXEAlertBar"..BarCount,UIParent)

	self.data = {}

	local bar = CreateFrame("StatusBar",nil,self)
	bar:SetMinMaxValues(0,1) 
	bar:SetValue(0)
	self.bar = bar

	local border = CreateFrame("Frame",nil,self)
	border:SetAllPoints(true)
	border:SetFrameLevel(bar:GetFrameLevel()+1)
	self.border = border

	local timer = addon.AceGUI:Create("DXE_Timer")
	timer.frame:SetFrameLevel(self:GetFrameLevel()+1)
	timer.frame:SetParent(self)
	timer.left:SetShadowOffset(1,-1)
	timer.right:SetShadowOffset(1,-1)
	self.timer = timer

	local text = bar:CreateFontString(nil,"ARTWORK")
	text:SetPoint("LEFT",self,"LEFT",5,0)
	-- Adjust if we ever have a timer > 1 hour
	text:SetPoint("RIGHT",self.timer.frame,"LEFT",7,0)
	text:SetShadowOffset(1,-1)
	self.text = text

	local iconf = CreateFrame("Frame",nil,self)
	self.iconf = iconf

	local icon = iconf:CreateTexture(nil,"BACKGROUND")
	icon:SetTexCoord(0.07,0.93,0.07,0.93)
	self.icon = icon

	addon.AceTimer:Embed(self)
	for k,v in pairs(prototype) do self[k] = v end

	self.fadeTable = {mode = "OUT", timeToFade = FADE_TIME, endAlpha = 0, finishedArg1 = self }

	BarCount = BarCount + 1

	SkinAlert(self)

	return self
end

local function GetAlert()
	local alert = next(AlertPool)
	if alert then AlertPool[alert] = nil
	else alert = CreateAlert() end
	Active[alert] = true
	UpdateFrame:Show()
	alert:Show()

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

function module:Dropdown(id, text, totalTime, flashTime, sound, c1, c2, flashscreen, icon)
	if pfl.DisableDropdowns then self:CenterPopup(id, text, totalTime, flashTime, sound, c1, c2, flashscreen, icon) return end
	local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local alert = GetAlert()
	alert:SetID(id)
	alert:SetIcon(icon)
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

function module:CenterPopup(id, text, totalTime, flashTime, sound, c1, c2, flashscreen, icon)
	local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local alert = GetAlert()
	alert:SetID(id)
	alert:SetIcon(icon)
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

function module:Simple(text, totalTime, sound, c1, flashscreen, icon)
	local soundFile,c1Data = GetMedia(sound,c1)
	local alert = GetAlert()
	if c1Data then 
		alert:SetColor(c1Data)
		alert.bar:SetValue(1)
	end
	alert:SetIcon(icon)
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
