local addon = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
addon.version = version > addon.version and version or addon.version
local L = addon.L

local module = addon:NewModule("Arrows")
addon.Arrows = module

local frames = {}
local units = {}

---------------------------------------
-- CREATION
---------------------------------------

local name_to_unit = addon.Roster.name_to_unit
local ProximityFuncs = addon:GetProximityFuncs()
local Sounds = addon.Constants.Sounds
local util = addon.util
local CN = addon.CN

local GetPlayerMapPosition,GetPlayerFacing = GetPlayerMapPosition,GetPlayerFacing
local UnitIsVisible = UnitIsVisible
local PI,PI2 = math.pi,math.pi*2
local floor,atan = math.floor,math.atan

local ARROW_FILE = "Interface\\Addons\\DXE\\Textures\\Arrow"
local NUM_CELLS = 108
local NUM_COLUMNS = 9
local CELL_WIDTH = 56
local CELL_HEIGHT = 42
local IMAGESIZE = 512
local CELL_WIDTH_PERC = CELL_WIDTH / IMAGESIZE
local CELL_HEIGHT_PERC = CELL_HEIGHT / IMAGESIZE

local colors = {
	{r = 0, g = 1,    b = 0}, -- Green
	{r = 1, g = 1,    b = 0}, -- Yellow
	{r = 1, g = 0.65, b = 0}, -- Orange
	{r = 1, g = 0,    b = 0}, -- Red
}

local TRANS_TIME = 0.5

local function GetColor(self)
	if self.action == "TOWARD" then
		local i = 4
		if ProximityFuncs[10](self.unit) then i = 1
		elseif ProximityFuncs[18](self.unit) then i = 2
		elseif ProximityFuncs[28](self.unit) then i = 3 end
		return colors[i]
	elseif self.action == "AWAY" then
		local i = 1
		if ProximityFuncs[10](self.unit) then i = 4
		elseif ProximityFuncs[18](self.unit) then i = 3
		elseif ProximityFuncs[28](self.unit) then i = 2 end
		return colors[i]
	end
end

local function SetColor(self)
	local color = self:GetColor()
	if self.color == color then return end
	-- Transition
	self.tcolor = color
	self.dt = self.elapsed + TRANS_TIME
end

local e = 10e-5
local function GetAngle(self)
	if not UnitIsVisible(self.unit) then self:Destroy() return end
	local x_0,y_0 = GetPlayerMapPosition("player")
	local x,y
	if self.isFixed then
		x,y = self.fixedX,self.fixedY
	else
		x,y = GetPlayerMapPosition(self.unit)
	end
	local dx,dy = x - x_0, y - y_0
	if dy == 0 then dy = e end -- Prevents NaN
	local angle_axis = dy < 0 and PI + atan(dx/dy) or atan(dx/dy)
	local angle = (PI-(GetPlayerFacing()-angle_axis)) % PI2
	if self.action == "AWAY" then angle = (PI + angle) % PI2 end
	return angle
end

-- Simplified from Claidhaire's TomTom
local function SetAngle(self,angle)
	local cell = floor(angle / PI2 * NUM_CELLS + 0.5) % NUM_CELLS
	local col = (cell % NUM_COLUMNS) * CELL_WIDTH_PERC
	local row = floor(cell / NUM_COLUMNS) * CELL_HEIGHT_PERC

	self.t:SetTexCoord(col, col + CELL_WIDTH_PERC, row, row + CELL_HEIGHT_PERC)
end

local function SetFixed(self)
	self.fixedX,self.fixedY = GetPlayerMapPosition(self.unit)
	self.isFixed = true
end

local function OnUpdate(self,elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed > self.persist then
		self:Destroy()
	else
		local angle = self:GetAngle()
		if not angle then return end
		self:SetAngle(angle)

		if self.tcolor then
			local perc = 1 - ((self.dt - self.elapsed) / TRANS_TIME)
			if perc < 0 or perc > 1 then
				local color = self.tcolor
				self.color = color
				self.tcolor = nil
				self.t:SetVertexColor(color.r,color.g,color.b)
			else
				local r,g,b = util.blend(self.color,self.tcolor,perc)
				self.t:SetVertexColor(r,g,b)
			end
		else
			self:SetColor()
		end
	end
end

-- @param action a string == "TOWARD" or "AWAY"
local function SetTarget(self,unit,persist,action,msg,spell,sound,fixed)
	if sound then PlaySoundFile(SM:Fetch(sound)) end
	UIFrameFadeRemoveFrame(self)
	self.action = action
	self.unit = unit
	self.elapsed = 0
	self.persist = persist

	local color = self:GetColor()
	self.color = color
	self.t:SetVertexColor(color.r,color.g,color.b)
	units[unit] = true
	self.label:SetText(msg)
	self.label2:SetText(spell .. " > " .. CN[unit])
	self:SetAlpha(1)
	if fixed then self:SetFixed() end
	self:SetScript("OnUpdate",OnUpdate)
	self:SetAngle(self:GetAngle())
	self:Show()
end

local function Destroy(self)
	units[self.unit] = nil
	self.unit = nil
	self.color = nil
	self.tcolor = nil
	self.isFixed = nil
	self.fixedX = nil
	self.fixedY = nil
	self.fadeTable.fadeTimer = 0
	UIFrameFade(self,self.fadeTable)
	self:SetScript("OnUpdate",nil)
end

local function CreateArrow()
	local arrow = CreateFrame("Frame",nil,UIParent)
	arrow:SetWidth(56)
	arrow:SetHeight(42)

	local t = arrow:CreateTexture(nil,"OVERLAY")
	t:SetTexture(ARROW_FILE)
	t:SetAllPoints(true)
	arrow.t = t

	local label = arrow:CreateFontString(nil,"ARTWORK")
	label:SetFont(GameFontNormal:GetFont(),12,"THICKOUTLINE")
	label:SetPoint("TOP",arrow,"BOTTOM")
	arrow.label = label

	local label2 = arrow:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	label2:SetPoint("TOP",label,"BOTTOM")
	label2:SetShadowOffset(1,-1)
	label2:SetShadowColor(0,0,0)
	arrow.label2 = label2

	arrow.SetAngle = SetAngle
	arrow.GetAngle = GetAngle
	arrow.SetTarget = SetTarget
	arrow.Destroy = Destroy
	arrow.GetColor = GetColor
	arrow.SetColor = SetColor
	arrow.SetFixed = SetFixed
	arrow.fadeTable = {mode = "OUT", timeToFade = 0.5, startAlpha = 1, endAlpha = 0, finishedFunc = function() arrow:Hide() end}

	arrow:Hide()
	return arrow
end

---------------------------------------
-- INITIALIZATION
---------------------------------------

function module:OnInitialize()
	for i=1,3 do 
		local arrow = CreateArrow()
		local anchor = addon:CreateLockableFrame("ArrowsAnchor"..i,85,42,format("%s - %s",L["Arrows"],L["Anchor"].." "..i))
		addon:RegisterMoveSaving(anchor,"CENTER","UIParent","CENTER",0,-(25 + (i*65)))
		addon:LoadPosition("DXEArrowsAnchor"..i)
		arrow:SetPoint("CENTER",anchor,"CENTER")
		frames[i] = arrow
	end
end

---------------------------------------
-- API
---------------------------------------

function module:AddTarget(unit,persist,action,msg,spell,sound,fixed)
	--@debug@
	assert(type(unit) == "string")
	assert(type(persist) == "number")
	assert(type(action) == "string")
	assert(type(msg) == "string")
	assert(type(spell) == "string")
	--@end-debug@
	if UnitExists(unit) and UnitIsVisible(unit) then
		local distinct = true
		for k in pairs(units) do if UnitIsUnit(k,unit) then distinct = false break end end
		if not distinct then return end
		for i,arrow in ipairs(frames) do
			if not arrow.unit then
				arrow:SetTarget(unit,persist,action,msg,spell,sound,fixed)
				break
			end
		end
	end
end

function module:RemoveTarget(unit)
	for i,arrow in ipairs(frames) do
		if UnitIsUnit(arrow.unit,unit) then
			arrow:Destroy()
			break
		end
	end
end

function module:RemoveAll()
	for i,arrow in ipairs(frames) do
		if arrow.unit then
			arrow:Destroy()
		end
	end
end
