include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) then return end

	local a = owner:GetAlpha()
	local pos = owner:GetPos()
	local vel = Angle(0, CurTime() * 72, 0):Forward() * 64

	local particle = self.Emitter:Add("particle/smokestack", pos)
	particle:SetVelocity(vel)
	particle:SetDieTime(0.4)
	particle:SetStartAlpha(a)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(8)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-3, 3))

	local particle = self.Emitter:Add("sprites/light_glow02_add", pos)
	particle:SetVelocity(vel)
	particle:SetDieTime(0.4)
	particle:SetStartAlpha(a)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(8)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-3, 3))
end
