include("shared.lua")

function ENT:Draw()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + math.max(0.04, EFFECT_IQUALITY * 0.04)

	if ent:IsInvisible() then return end

	local pos = ent:GetPos() + Vector(0, 0, 2)

	local emitter = self.Emitter
	for i=1, math.Rand(1, 2) do
		local particle = emitter:Add("sprites/glow04_noz", pos + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal() * math.Rand(4, 18))
		particle:SetVelocity(Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal() * math.Rand(16, 32))
		particle:SetGravity(Vector(0,0,500))
		particle:SetDieTime(math.Rand(0.5, 0.6))
		particle:SetStartSize(32)
		particle:SetEndSize(0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(127.5)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
	end
end

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 40)

	self.NextEmit = 0
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end