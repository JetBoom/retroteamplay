include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)
end

function ENT:StatusThink(owner)
	--self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if owner:IsInvisible() then return end

	local pos = owner:GetPos() + Vector(0,0,16)
	local emitter = self.Emitter
	for i=1, 2 do
		local particle = emitter:Add("particle/smokestack", pos + VectorRand() * 12)
		particle:SetVelocity(Vector(0,0,30))
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(200)
		particle:SetStartSize(6)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(255, 255, 0)
		particle:SetGravity(Vector(0,0,-500))

		particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand() * 12)
		particle:SetVelocity(Vector(0,0,30))
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(200)
		particle:SetStartSize(2)
		particle:SetEndSize(8)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(255, 255, 0)
		particle:SetGravity(Vector(0,0,-500))
	end
end
