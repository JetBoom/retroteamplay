function EFFECT:Init(data)
	local pos = data:GetOrigin()
	self.Die = CurTime() + 0.4

	sound.Play("nox/plasma_explode.ogg", pos, 85, math.Rand(98, 102))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(2)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(140)

		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(1.25)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(32)
		particle:SetEndSize(170)
		particle:SetColor(180, 200, 255)
	end

	emitter:Finish()

	ExplosiveEffect(pos, 100, 50, DMGTYPE_FIRE)
end

function EFFECT:Think()
	if CurTime() > self.Die then
		local vOffset = self.Entity:GetPos()

		local emitter = ParticleEmitter(vOffset)
		emitter:SetNearClip(24, 32)

		for i=1, EFFECT_QUALITY * math.Rand(3, 4) + 1 do
			local particle = emitter:Add("sprites/glow04_noz", vOffset)
			particle:SetVelocity(VectorRand():GetNormal() * math.Rand(64, 200))
			particle:SetDieTime(2)
			particle:SetStartAlpha(254)
			particle:SetEndAlpha(0)
			particle:SetStartSize(50)
			particle:SetEndSize(1)
			particle:SetColor(180, 240, 255)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-30, 30))
			particle:SetAirResistance(45)

			local particle = emitter:Add("sprites/glow04_noz", vOffset + VectorRand():GetNormal() * 10)
			particle:SetVelocity(VectorRand() * 90)
			particle:SetDieTime(1.5)
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(20)
			particle:SetStartSize(math.Rand(82, 126))
			particle:SetEndSize(16)
			particle:SetColor(55, 200, 255)
			particle:SetRoll(math.Rand(0, 360))
		end

		emitter:Finish()

		return false
	end

	return true
end

function EFFECT:Render()
end
