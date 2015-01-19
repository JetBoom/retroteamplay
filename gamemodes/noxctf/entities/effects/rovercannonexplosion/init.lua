function EFFECT:Init(data)
	local normal = data:GetNormal() * -1

	local pos = data:GetOrigin()
	util.Decal("Scorch", pos + normal, pos - normal)
	pos = pos + normal * 2

	sound.Play("ambient/explosions/explode_"..math.random(4,5)..".wav", pos, 85, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("particle/smokestack", pos)
	particle:SetDieTime(2)
	particle:SetStartAlpha(225)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(150)
	particle:SetColor(30, 30, 30)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-2, 2))

	for i=1, math.Rand(6, 8) * EFFECT_QUALITY do
		local particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(VectorRand() * 90 + normal * 200)
		particle:SetDieTime(math.Rand(1.5, 2.25))
		particle:SetStartAlpha(225)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(70, 92))
		particle:SetColor(40, 40, 40)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetAirResistance(32)
	end

	local oldang = normal:Angle():Right():Angle()
	local numparts = 360 / math.max(32, math.Rand(EFFECT_QUALITY * 10, EFFECT_QUALITY * 13))
	for i=1, 360, numparts do
		local ang = oldang
		ang:RotateAroundAxis(normal, i)
		local heading = ang:Forward() * 128
		local particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(heading)
		particle:SetGravity(heading * -0.25)
		particle:SetDieTime(math.Rand(1.4, 1.78))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(92)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetAirResistance(16)
		particle:SetColor(45, 45, 45)
	end

	for i=1, math.max(12, math.Rand(6, 9) * EFFECT_QUALITY) do
		local particle = emitter:Add("effects/fire_cloud1", pos)
		particle:SetVelocity(normal * math.Rand(150, 190) + VectorRand():GetNormal() * math.Rand(180, 200))
		particle:SetDieTime(math.Rand(1.35, 1.6))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(48)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetAirResistance(100)
	end

	emitter:Finish()

	ExplosiveEffect(pos, 180, 80, DMGTYPE_FIRE)

	for i=1, math.Rand(2, 2.5) * EFFECT_QUALITY do
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + VectorRand() * 16)
			effectdata:SetNormal((normal + VectorRand() * 0.25):GetNormal())
			effectdata:SetScale(math.Rand(240, 340))
		util.Effect("ember", effectdata)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
