include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-2200, -2200, -160000), Vector(2200, 2200, 160000))
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:OnRemove()
end

local matBeam = Material("Effects/laser1")
local matGlow = Material("sprites/glow04_noz")
local matRing = Material("effects/select_ring")

function ENT:DrawTranslucent()
	local c = team.GetColor(currentholding) or Color(255, 255, 255, 255)
	local pos = self:GetPos()

	render.SetMaterial(matBeam)
	render.DrawBeam(pos + Vector(0, 0, 50000), pos + Vector(0, 0, -50000), 1024 + math.sin(RealTime() * 10) * 200, 1, 0, Color(c.r, c.g, c.b, 255))

	render.SetMaterial(matGlow)
	render.DrawSprite(pos + Vector(0, 0, math.sin(RealTime() * 0.4) * 25000), 1500, 1500, Color(c.r, c.g, c.b, 255))

	render.SetMaterial(matRing)
	local tr = util.TraceLine({start = pos, endpos = pos + Vector(0,0,-50000), mask = MASK_SOLID_BRUSHONLY})
	local ringpos = tr.HitPos + tr.HitNormal * 24
	local size = 1024 + math.sin(RealTime() * 4) * 256
	local size2 = 1024 + math.cos(RealTime() * 3) * 256
	render.DrawQuadEasy(ringpos, tr.HitNormal, size, size, Color(c.r, c.g, c.b, 255), 0)
	render.DrawQuadEasy(ringpos, tr.HitNormal * -1, size2, size2, Color(c.r, c.g, c.b, 255), 0)
end
