include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-60, -60, -60), Vector(60, 60, 60))
	self:SetModelScale(2.5, 0)
	self:SetMaterial("models/shiny")

	self.Col = self:GetColor()
	self.Created = CurTime()
end

function ENT:OnRemove()
end

local matBeam = Material("Effects/laser1")
local matGlow = Material("sprites/glow04_noz")
function ENT:Draw()
	local vel = self:GetVelocity()
	if 10 < vel:Length() then
		self:SetAngles(vel:Angle())
	end

	local pos = self:GetPos()
	local siz = math.Rand(16, 24)

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, siz, siz, self.Col)

	render.SetMaterial(matBeam)
	render.DrawBeam(pos, pos + vel:GetNormal() * math.max(-32, (self.Created - CurTime()) * 128), 24, 1, 0, self.Col)

	self:DrawModel()
end
