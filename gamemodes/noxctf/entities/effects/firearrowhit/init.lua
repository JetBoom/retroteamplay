function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1

	util.Decal("SmallScorch", pos + normal, pos - normal)

	sound.Play("ambient/explosions/explode_4.wav", pos, 75, math.random(165, 175))
	sound.Play("ambient/machines/floodgate_stop1.wav", pos, 72, math.random(140, 165))

	local emitter = ParticleEmitter(pos)

	for i=1, math.max(2, math.Rand(1, 2) * EFFECT_QUALITY) do
		local particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(normal * math.Rand(16, 32) + VectorRand():GetNormal() * math.Rand(0, 65))
		particle:SetDieTime(math.Rand(2, 4.9))
		particle:SetStartAlpha(math.Rand(90, 135))
		particle:SetStartSize(math.Rand(15, 20))
		particle:SetEndSize(math.Rand(90, 216))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-12, 12))
		particle:SetColor(25, 10, 10)
		particle:SetCollide(true)
		particle:SetAirResistance(10)
	end

	for i=1, math.random(3, 4) do
		local particle = emitter:Add("effects/yellowflare", pos)
		particle:SetVelocity(normal * math.Rand(8, 16) + VectorRand():GetNormal() * math.Rand(0, 60))
		particle:SetDieTime(math.Rand(0.7, 1.2))
		particle:SetStartAlpha(math.Rand(20, 75))
		particle:SetStartSize(math.Rand(5, 10))
		particle:SetEndSize(math.Rand(25, 30))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-15.5, 15.5))
		particle:SetColor(225, 205, 170)
		particle:SetCollide(true)
		particle:SetAirResistance(10)
	end

	for i=0, math.Rand(2, 3) * math.max(EFFECT_QUALITY, 1) do
		local particle = emitter:Add("effects/fire_cloud1", pos)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(0, 545) + normal * math.Rand(320, 550))
		particle:SetDieTime(math.Rand(1, 2))
		particle:SetStartAlpha(math.Rand(200, 230))
		particle:SetEndAlpha(150)
		particle:SetStartSize(math.Rand(12, 14))
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetCollide(true)
		particle:SetAirResistance(560)
	end

	emitter:Finish()

	ExplosiveEffect(pos, 80, 40, DMGTYPE_FIRE)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
