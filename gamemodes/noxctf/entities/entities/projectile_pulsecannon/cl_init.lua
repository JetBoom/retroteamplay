include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-60, -60, -60), Vector(60, 60, 60))
end

function ENT:Think()
end

function ENT:OnRemove()
end

local matBeam = Material("effects/spark")
function ENT:Draw()
	render.SetMaterial(matBeam)
	local pos = self:GetPos()
	local norm = self:GetVelocity():GetNormal()
	local col = self:GetColor()
	local start = pos + norm * 10
	local endpos = pos - norm * 40
	render.DrawBeam(start, endpos, 16, 1, 0, col)
	render.DrawBeam(start, endpos, 12, 1, 0, col)
end
