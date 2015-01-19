include("shared.lua")

ENT.NextEmit = 0

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(16, 24)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + math.max(1, EFFECT_IQUALITY) * 0.03

	local ent = self:GetOwner()
	if not ent:IsValid() or ent:IsInvisible() then return end

	local pos = ent:GetPos() + ent:GetUp() * ent:OBBMaxs().z
	local emitter = self.Emitter
	for i=1, 2 do
		local particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand():GetNormalized())
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetStartSize(10)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.8, 0.8))
		particle:SetColor(20, 255, 20)
	end
end
