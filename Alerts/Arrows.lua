local addon = DXE
local L = addon.L
local SM = addon.SM

local module = addon:NewModule("Arrows")
addon.Arrows = module

local frames = {}
local units = {}
local CreateArrow

---------------------------------------
-- PROTOTYPE
---------------------------------------
local prototype = {}

do
	local name_to_unit = addon.Roster.name_to_unit
	local blend = addon.util.blend
	local CN = addon.CN

	local GetPlayerFacing = GetPlayerFacing
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
	local TRANS_TIME = 0.5

	local colors = {
		{r = 0, g = 1,    b = 0}, -- Green
		{r = 1, g = 1,    b = 0}, -- Yellow
		{r = 1, g = 0.65, b = 0}, -- Orange
		{r = 1, g = 0,    b = 0}, -- Red
	}

	local function GetColor(d,action)
		if action == "TOWARD" then
			-- Faster than if-else chain
			local i = (d <= 10 and 1 or (d <= 20 and 2 or (d <= 30 and 3 or 4)))
			return colors[i]
		elseif action == "AWAY" then
			local i = (d <= 10 and 4 or (d <= 20 and 3 or (d <= 30 and 2 or 1)))
			return colors[i]
		end
	end

	local function TransitionFunc(self)
		local perc = (self.elapsed - self.st) / TRANS_TIME
		if perc < 1 then
			local r,g,b = blend(self.color,self.tcolor,perc)
			self.t:SetVertexColor(r,g,b)
		else
			local color = self.tcolor
			self.color = color
			self.t:SetVertexColor(color.r,color.g,color.b)
			self.tcolor = nil
			self.transFunc = nil
		end
	end

	function prototype:SetColor(d)
		local color = GetColor(d,self.action)
		if self.color == color then return end
		-- Transition
		self.tcolor = color
		self.st = self.elapsed
		self.transFunc = TransitionFunc
	end

	local e = 10e-5
	function prototype:SetAngle(dx,dy)
		-- Calculate
		if dy == 0 then dy = e end -- Prevents division by 0
		local angle_axis = dy < 0 and PI + atan(dx/dy) or atan(dx/dy)
		local angle = (PI-(GetPlayerFacing()-angle_axis)) % PI2
		if self.action == "AWAY" then angle = (PI + angle) % PI2 end

		-- Simplified from Claidhaire's TomTom
		local cell = floor(angle / PI2 * NUM_CELLS + 0.5) % NUM_CELLS
		local col = (cell % NUM_COLUMNS) * CELL_WIDTH_PERC
		local row = floor(cell / NUM_COLUMNS) * CELL_HEIGHT_PERC

		self.t:SetTexCoord(col, col + CELL_WIDTH_PERC, row, row + CELL_HEIGHT_PERC)
	end

	function prototype:SetFixed()
		self.fx,self.fy = addon:GetPlayerMapPosition(self.unit)
	end

	local function OnUpdate(self,elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > self.persist then
			self:Destroy()
		else
			if not UnitIsVisible(self.unit) then self:Destroy() return end
			local d,dx,dy = addon:GetDistanceToUnit(self.unit,self.fx,self.fy)
			if not d then self:Destroy() return end
			self:SetAngle(dx,dy)
			self.label2:SetFormattedText(self.fmt,d)

			if self.transFunc then
				self:transFunc()
			else
				self:SetColor(d)
			end
		end
	end

	-- @param action a string == "TOWARD" or "AWAY"
	function prototype:SetTarget(unit,persist,action,msg,spell,sound,fixed)
		-- Factor in mute all toggle from Alerts
		if sound and not addon.Alerts.db.profile.DisableSounds then PlaySoundFile(SM:Fetch("sound",sound)) end
		UIFrameFadeRemoveFrame(self)
		self.action = action
		self.unit = unit
		self.elapsed = 0
		self.persist = persist
		self.fmt = spell.." <|cffffff78%.0f|r> "..CN[unit]

		if fixed then self:SetFixed() end
		local d,dx,dy = addon:GetDistanceToUnit(unit,self.fx,self.fy)
		if not d then return end
		self:SetAngle(dx,dy)

		local color = GetColor(d,action)
		self.color = color
		self.t:SetVertexColor(color.r,color.g,color.b)
		units[unit] = true
		self.label:SetText(msg)
		self.label2:SetFormattedText(self.fmt,d)
		self:SetAlpha(1)
		self:SetScript("OnUpdate",OnUpdate)
		self:Show()
	end

	function prototype:Destroy()
		units[self.unit] = nil
		self.unit = nil
		self.color = nil
		self.tcolor = nil
		self.fx = nil
		self.fy = nil
		self.fmt = nil
		self.transFunc = nil
		local fadeTable = self.fadeTable
		fadeTable.fadeTimer = 0
		fadeTable.finishedFunc = self.Hide
		UIFrameFade(self,fadeTable)
		self:SetScript("OnUpdate",nil)
	end

	function CreateArrow(i)
		local self = CreateFrame("Frame","DXEArrow"..i,UIParent)
		self:SetWidth(56)
		self:SetHeight(42)
		self:Hide()

		local t = self:CreateTexture(nil,"OVERLAY")
		t:SetTexture(ARROW_FILE)
		t:SetAllPoints(true)
		self.t = t

		local label = self:CreateFontString(nil,"ARTWORK")
		label:SetFont(GameFontNormal:GetFont(),12,"THICKOUTLINE")
		label:SetPoint("TOP",self,"BOTTOM")
		self.label = label

		local label2 = self:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		label2:SetPoint("TOP",label,"BOTTOM")
		label2:SetShadowOffset(1,-1)
		label2:SetShadowColor(0,0,0)
		self.label2 = label2

		self.fadeTable = {mode = "OUT", timeToFade = 0.5, startAlpha = 1, endAlpha = 0, finishedArg1 = self}

		for k,v in pairs(prototype) do self[k] = v end

		return self
	end
end

---------------------------------------
-- INITIALIZATION
---------------------------------------

function module:OnInitialize()
	for i=1,3 do 
		local arrow = CreateArrow(i)
		local anchor = addon:CreateLockableFrame("ArrowsAnchor"..i,85,42,format("%s - %s",L["Arrows"],L["Anchor"].." "..i))
		addon:RegisterMoveSaving(anchor,"CENTER","UIParent","CENTER",0,-(25 + (i*65)))
		addon:LoadPosition("DXEArrowsAnchor"..i)
		arrow:SetPoint("CENTER",anchor,"CENTER")
		frames[i] = arrow
	end
end

function module:OnDisable()
	self:RemoveAll()
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
		-- Distinction test
		for k in pairs(units) do if UnitIsUnit(k,unit) then return end end

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
		if arrow.unit and UnitIsUnit(arrow.unit,unit) then
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
