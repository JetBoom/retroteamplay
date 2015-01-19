include("shared.lua")

ENT.Rotation = 0

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 128))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(34, 42)
end

function ENT:StatusThink(Owner)
	self.Emitter:SetPos(self:GetPos())
end

local matHex = Material("effects/laser1")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if owner:IsInvisible() then return end

	local pos = owner:EyePos() + Vector(0,0,32)

	render.SetMaterial(matHex)

	self.Rotation = self.Rotation + FrameTime() * 100
	if self.Rotation > 360 then self.Rotation = self.Rotation - 360 end

	local ang = Angle(0, self.Rotation, 0)
	local vec1 = ang:Forward()
	local vec2 = ang:Right()
	local g, b = math.cos(RealTime() * 9.5) * 55 + 200, math.sin(RealTime() * 12) * 55 + 200
	local col = Color(255, g, b, 255)
	render.DrawBeam(pos + Vector(0, 0, -32), pos + Vector(0, 0, 32), 28, 1, 0, col)
	render.DrawBeam(pos + vec1 * 32, pos + vec1 * -32, 28, 1, 0, col)
	render.DrawBeam(pos + vec2 * 32, pos + vec2 * -32, 28, 1, 0, col)

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, math.Rand(12, 18), math.Rand(12, 18), COLOR_RED)
	render.DrawSprite(pos + Vector(0, 0, -32), 14, 14, COLOR_RED)
	render.DrawSprite(pos + Vector(0, 0, 32), 14, 14, COLOR_RED)

	local myvel = owner:GetVelocity()

	local particle = self.Emitter:Add("effects/yellowflare", pos + vec1 * -32 + VectorRand():GetNormal() * 4)
	particle:SetVelocity(myvel)
	particle:SetDieTime(math.Rand(0.25, 0.35))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(80)
	particle:SetStartSize(math.Rand(14, 18))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetColor(255, b, g)

	particle = self.Emitter:Add("effects/yellowflare", pos + vec1 * 32 + VectorRand():GetNormal() * 4)
	particle:SetVelocity(myvel)
	particle:SetDieTime(math.Rand(0.25, 0.35))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(80)
	particle:SetStartSize(math.Rand(14, 18))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetColor(255, g, b)

	local particle = self.Emitter:Add("effects/yellowflare", pos + vec2 * -32 + VectorRand():GetNormal() * 4)
	particle:SetVelocity(myvel)
	particle:SetDieTime(math.Rand(0.25, 0.35))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(80)
	particle:SetStartSize(math.Rand(14, 18))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetColor(255, g, b)

	particle = self.Emitter:Add("effects/yellowflare", pos + vec2 * 32 + VectorRand():GetNormal() * 4)
	particle:SetVelocity(myvel)
	particle:SetDieTime(math.Rand(0.25, 0.35))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(80)
	particle:SetStartSize(math.Rand(14, 18))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetColor(255, b, g)
end
