include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 40)

	self.Rotation = 120
	self.NextEmit = 0
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local matGlow = Material("sprites/glow04_noz")
local matSnow = Material("particle/snow")
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	if ent:IsInvisible() then return end

	local pos = ent:GetPos() + Vector(0,0,36)

	local newrot = self.Rotation + FrameTime() * 4.2
	if newrot > 360 then newrot = newrot - 360 end
	self.Rotation = newrot

	render.SetMaterial(matGlow)
	local vOffset = Vector(32 * math.cos(self.Rotation), 32 * math.sin(self.Rotation), 0)
	local pos1 = pos + vOffset
	render.DrawSprite(pos1, 28, 28, color_white)
	local pos2 = pos - vOffset
	render.DrawSprite(pos2, 28, 28, color_white)
	render.SetMaterial(matSnow)
	render.DrawSprite(pos1, 6, 6, color_white)
	render.DrawSprite(pos2, 6, 6, color_white)

	if 1 < EFFECT_QUALITY and self.NextEmit < CurTime() then
		self.NextEmit = self.NextEmit + 0.06 * EFFECT_IQUALITY
		//local emitter = ParticleEmitter(pos)
		local emitter = self.Emitter
		particle = emitter:Add("particle/snow", pos1 + VectorRand() * 6)
		particle:SetVelocity(ent:GetVelocity())
		particle:SetDieTime(math.Rand(0.3, 0.5))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(5, 7))
		particle:SetEndSize(5)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetColor(240, 240, 255)
		particle:SetAirResistance(10)
		particle:SetGravity(Vector(0,0,-150))

		particle = emitter:Add("particle/snow", pos2 + VectorRand() * 6)
		particle:SetVelocity(ent:GetVelocity())
		particle:SetDieTime(math.Rand(0.3, 0.5))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(5, 7))
		particle:SetEndSize(5)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetColor(240, 240, 255)
		particle:SetAirResistance(10)
		particle:SetGravity(Vector(0,0,-150))
	end
end
