function EFFECT:Init(data)
	local normal = data:GetNormal():GetNormal() * -1

	local pos = data:GetOrigin()
	util.Decal("SmallScorch", pos + normal, pos - normal)
	pos = pos + normal * 2

	sound.Play("ambient/explosions/explode_"..math.random(4,5)..".wav", pos, 85, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("particle/smokestack", pos)
	particle:SetDieTime(3)
	particle:SetStartAlpha(225)
	particle:SetEndAlpha(0)
	particle:SetStartSize(100)
	particle:SetEndSize(100)
	particle:SetColor(30, 30, 30)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1, 1))

	for i=1, math.Rand(4, 6) * EFFECT_QUALITY do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetVelocity(VectorRand() * 128 + Vector(0, 0, 200))
		particle:SetDieTime(1.5)
		particle:SetStartAlpha(225)
		particle:SetEndAlpha(30)
		particle:SetStartSize(math.Rand(12, 16))
		particle:SetEndSize(2)
		particle:SetColor(255, 200, 50)
		particle:SetRoll(math.Rand(0, 360))
	end

	for i=1, math.Rand(4, 6) * EFFECT_QUALITY do
		local particle = emitter:Add("effects/fire_cloud1", pos)
		particle:SetVelocity(normal * math.Rand(120, 150) + VectorRand():GetNormal() * math.Rand(80, 100))
		particle:SetDieTime(math.Rand(0.8, 1.1))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(48)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(8)
	end

	emitter:Finish()

	ExplosiveEffect(pos, 72, 58, DMGTYPE_FIRE)

	for i=1, math.Rand(1, 1.5) * EFFECT_QUALITY do
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + VectorRand() * 6)
			effectdata:SetNormal((normal + VectorRand() * 0.25):GetNormal())
			effectdata:SetScale(math.Rand(180, 250))
		util.Effect("ember", effectdata)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
