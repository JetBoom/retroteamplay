include("shared.lua")

function ENT:Draw()
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + math.max(0.075, 0.1 * EFFECT_IQUALITY)

	local pos = self:GetPos()
	local emitter = self.Emitter
	local particle = emitter:Add("sprites/glow04_noz", pos + Vector(0,0,90) + VectorRand():GetNormal() * math.Rand(2, 18))
	particle:SetVelocity(VectorRand():GetNormal() * math.Rand(4, 16))
	particle:SetGravity(Vector(0,0,-500))
	particle:SetDieTime(math.Rand(2, 3))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(12)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-5, 5))
	particle:SetColor(255, 255, 255)
	particle:SetBounce(0.75)
	particle:SetCollide(true)

	local timleft = self.DeathTime - CurTime()
	local degree = timleft * 120
	local particle = emitter:Add("sprites/glow04_noz", pos + Vector(64 * math.cos(degree), 64 * math.sin(degree), 0))
	particle:SetVelocity(Vector(0,0,256))
	particle:SetDieTime(timleft + 0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(32)
	particle:SetEndSize(48)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-8, 8))
	particle:SetColor(180, 255, 180)
	particle:SetAirResistance(256)
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.NextEmit = 0

	self:GetOwner().HealRing = self
	self.DeathTime = CurTime() + 2

	self:SetRenderBounds(Vector(-90, -90, -90), Vector(90, 90, 90))
	self:DrawShadow(false)
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	self:GetOwner().HealRing = nil
	--self.Emitter:Finish()
end
