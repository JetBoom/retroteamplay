function EFFECT:Init(data)
	local target = data:GetEntity()

	if not target:IsPlayer() then
		return
	end

	target:EmitSound("nox/invison.ogg")

	if EFFECT_QUALITY < 1 then return end

	self.Entity:SetPos(target:GetPos() + Vector(0, 0, 16))

	local emitter = ParticleEmitter(self.Entity:GetPos())
	for i=0, 8 do
		local particle = emitter:Add("sprites/light_glow02_add", self.Entity:GetPos() + Vector(math.Rand(-16, 16), math.Rand(-16, 16), math.Rand(-16, 48)))
		particle:SetVelocity(VectorRand() * 6 + Vector(0, 0, math.Rand(0, 8)))
		particle:SetDieTime(math.Rand(0.25, 0.75))
		particle:SetStartAlpha(192)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(2, 4))
		particle:SetEndSize(math.Rand(2, 4))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5.5, 5.5))
		particle:SetColor(64, 64, 64)
	end

	if render.GetDXLevel() < 90 then emitter:Finish() return end

	for i=0, 2 do
		local particle = emitter:Add("sprites/heatwave", self.Entity:GetPos() + (VectorRand() * 24) + Vector(0, 0, math.Rand(8, 32)))
		particle:SetVelocity(VectorRand() * math.random(2, 4) + Vector(0, 0, math.Rand(64, 128)) + (target:GetVelocity() / 3))
		particle:SetDieTime(math.Rand(1, 0.35))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(32)
		particle:SetEndSize(2)
		particle:SetColor(255, 255, 255)
	end

	for i=0, 1 do
		local particle = emitter:Add("sprites/heatwave", self.Entity:GetPos() + Vector(0, 0, math.Rand(8, 16)))
		particle:SetVelocity(Vector(0, 0, math.Rand(64, 128)) + (target:GetVelocity() / 3))
		particle:SetDieTime(math.Rand(1, 0.35))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(2)
		particle:SetColor(255, 255, 255)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
