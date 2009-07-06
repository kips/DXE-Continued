local DXE = DXE
local version = tonumber(("$Rev$"):sub(7, -3))
DXE.version = version > DXE.version and version or DXE.version
local L = DXE.L

local Arrows = DXE:NewModule("Arrows")
DXE.Arrows = Arrows

local frames = {}

---------------------------------------
-- CREATION
---------------------------------------

local name_to_unit = DXE.Roster.name_to_unit

local GetPlayerMapPosition,GetPlayerFacing = GetPlayerMapPosition,GetPlayerFacing
local PI,PI2 = math.pi,math.pi*2
local floor,atan = math.floor,math.atan

local ARROW_FILE = "Interface\\Addons\\DXE\\Textures\\Arrow"
local ARROW_FILE_UP = "Interface\\Addons\DXE\\Textures\\Arrow-UP"
local NUM_CELLS = 108
local NUM_COLUMNS = 9
local CELL_WIDTH = 56
local CELL_HEIGHT = 42
local IMAGESIZE = 512
local CELL_WIDTH_PERC = CELL_WIDTH / IMAGESIZE
local CELL_HEIGHT_PERC = CELL_HEIGHT / IMAGESIZE

-- Simplified from Claidhaire's TomTom
local function SetAngle(self,angle)
	local cell = floor(angle / PI2 * NUM_CELLS + 0.5) % NUM_CELLS
	local col = (cell % NUM_COLUMNS) * CELL_WIDTH_PERC
	local row = floor(cell / NUM_COLUMNS) * CELL_HEIGHT_PERC

	self.t:SetTexCoord(col, col + CELL_WIDTH_PERC, row, row + CELL_HEIGHT_PERC)
end

local function SetTarget(self,name,persist)
	self:SetAlpha(1)
	self.unit = name
	self.elapsed = 0
	self.persist = persist
	self:Show()
end

local function Destroy(self)
	self.unit = nil
	self:Hide()
end

local function onUpdate(self,elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed > self.persist then
		self:Destroy()
	else
		local x_0,y_0 = GetPlayerMapPosition("player")
		local x,y = GetPlayerMapPosition(self.unit)
		local dx,dy = x - x_0, y - y_0
		if dy == 0 then dy = 10e-5 end
		local angle_axis = dy < 0 and PI + atan(dx/dy) or atan(dx/dy)
		local angle = (PI-(GetPlayerFacing()-angle_axis)) % PI2
		self:SetAngle(angle)
	end
end

local function CreateArrow()
	local arrow = CreateFrame("Frame",nil,UIParent)
	arrow:SetWidth(56)
	arrow:SetHeight(42)

	local t = arrow:CreateTexture(nil,"OVERLAY")
	t:SetTexture(ARROW_FILE)
	t:SetAllPoints(true)
	arrow.t = t

	arrow:SetScript("OnUpdate",onUpdate)

	arrow.SetAngle = SetAngle
	arrow.SetTarget = SetTarget
	arrow.Destroy = Destroy

	arrow:Hide()
	return arrow
end

---------------------------------------
-- INITIALIZATION
---------------------------------------

function Arrows:OnInitialize()
	for i=1,3 do frames[i] = CreateArrow() end

	local CenterAnchor = DXE:CreateLockableFrame("ArrowsCenterAnchor",100,100,format("%s - %s",L["Arrows"],L["Anchor"].." 1"))
	DXE:RegisterMoveSaving(CenterAnchor,"CENTER","UIParent","CENTER",0,-100)
	DXE:LoadPosition("DXEArrowsCenterAnchor")
	frames[1]:SetPoint("CENTER",CenterAnchor,"CENTER")

	local LeftAnchor = DXE:CreateLockableFrame("ArrowsLeftAnchor",100,100,format("%s - %s",L["Arrows"],L["Anchor"].." 2"))
	DXE:RegisterMoveSaving(LeftAnchor,"CENTER","UIParent","CENTER",-150,-100)
	DXE:LoadPosition("DXEArrowsLeftAnchor")
	frames[2]:SetPoint("CENTER",LeftAnchor,"CENTER")

	local RightAnchor = DXE:CreateLockableFrame("ArrowsRightAnchor",100,100,format("%s - %s",L["Arrows"],L["Anchor"].." 3"))
	DXE:RegisterMoveSaving(RightAnchor,"CENTER","UIParent","CENTER",150,-100)
	DXE:LoadPosition("DXEArrowsRightAnchor")
	frames[3]:SetPoint("CENTER",RightAnchor,"CENTER")
end

---------------------------------------
-- API
---------------------------------------

function Arrows:AddTarget(name,persist)
	if name_to_unit[name] then
		for i,arrow in ipairs(frames) do
			if arrow:GetAlpha() < 0 or not arrow:IsShown() then
				arrow:SetTarget(name,persist)
				break
			end
		end
	end
end

function Arrows:RemoveTarget(name)
	for i,arrow in ipairs(frames) do
		if arrow:GetAlpha() == 1 and arrow.unit == name then
			arrow:Destroy()
			break
		end
	end
end

function Arrows:RemoveAll()
	for i,arrow in ipairs(frames) do
		if arrow:GetAlpha() == 1 then
			arrow:Destroy()
		end
	end
end
