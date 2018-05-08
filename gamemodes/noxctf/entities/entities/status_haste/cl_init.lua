include("shared.lua")

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 48))
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if owner:IsInvisible() then return end

	local pos = owner:GetPos() + Vector(0,0,6)
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(42, 48)
	for i=1, 2 do
		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(VectorRand() * 20)
		particle:SetDieTime(0.8)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(200)
		particle:SetStartSize(2)
		particle:SetEndSize(8)
		particle:SetRoll(math.Rand(-0.8, 0.8))

		particle = emitter:Add("sprites/light_glow02_add", pos)
		particle:SetVelocity(VectorRand() * 20)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(200)
		particle:SetStartSize(2)
		particle:SetEndSize(8)
		particle:SetRoll(math.Rand(-0.8, 0.8))
	end
	
	emitter:Finish()
end
