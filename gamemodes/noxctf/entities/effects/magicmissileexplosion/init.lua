function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1

	sound.Play("ambient/explosions/explode_9.wav", pos, 75, math.random(115, 130))

	local additional = normal * 100
	local emitter = ParticleEmitter(pos)
		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(additional)
		particle:SetDieTime(math.Rand(2.1, 2.5))
		particle:SetStartAlpha(254)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(64)
		particle:SetColor(30, 20, 20, 255)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-4, 4))
		particle:SetAirResistance(300)
		for i=1, math.Rand(3, 4) * EFFECT_QUALITY do
			local particle = emitter:Add("particle/smokestack", pos + VectorRand() * 8)
			particle:SetVelocity(additional + VectorRand():GetNormal() * math.Rand(200, 300))
			particle:SetDieTime(math.Rand(0.7, 1.1))
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(4)
			particle:SetEndSize(32)
			particle:SetColor(30, 20, 20, 255)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetAirResistance(300)
		end

		for i=1, math.Rand(4, 5) * EFFECT_QUALITY do
			local particle = emitter:Add("effects/fire_cloud1", pos + VectorRand() * 8)
			particle:SetVelocity(additional + VectorRand():GetNormal() * math.Rand(155, 342))
			particle:SetDieTime(math.Rand(0.5, 0.75))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(16)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-5, 5))
			particle:SetAirResistance(280)
		end
	emitter:Finish()

	ExplosiveEffect(pos, 48, 20, DMGTYPE_FIRE)

	util.Decal("FadingScorch", pos + normal, pos - normal)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
