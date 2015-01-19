function EFFECT:Init(data)
	local normal = data:GetNormal() * -1

	local pos = data:GetOrigin()
	util.Decal("SmallScorch", pos + normal, pos - normal)
	pos = pos + normal * 2

	sound.Play("nox/fireballexplosion.ogg", pos, 85, math.random(95, 105))

	local ang = normal:Angle()

	local alt
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local sep = 6 - EFFECT_QUALITY
	for i=1, 359, sep do
		alt = not alt
		ang:RotateAroundAxis(normal, sep)
		local vel = ang:Up()
		if alt then
			local particle = emitter:Add("noxctf/sprite_smoke", pos + vel * 32)
			particle:SetVelocity(vel * math.Rand(140, 180))
			particle:SetDieTime(math.Rand(1, 1.2))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(50, 72))
			particle:SetEndSize(0)
			particle:SetColor(50, 39, 15)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetAirResistance(math.Rand(10, 22))
			particle:SetCollide(true)
			particle:SetBounce(0.4)
		else
			local particle = emitter:Add("effects/fire_cloud1", pos + vel * 18)
			particle:SetVelocity(vel * 75)
			particle:SetDieTime(1)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(32)
			particle:SetEndSize(4)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetAirResistance(12)
			particle:SetCollide(true)
			particle:SetBounce(0.4)
		end
	end

	for i=1, math.Rand(3, 4) * EFFECT_QUALITY do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetVelocity(VectorRand() * 128 + Vector(0, 0, 200))
		particle:SetDieTime(1.5)
		particle:SetStartAlpha(225)
		particle:SetEndAlpha(30)
		particle:SetStartSize(math.random(12, 16))
		particle:SetEndSize(2)
		particle:SetColor(255, 200, 50)
		particle:SetRoll(math.random(0, 360))
		particle:SetGravity(Vector(0, 0, -600))
		particle:SetCollide(true)
		particle:SetBounce(0.4)
	end

	for i=1, math.Rand(3, 4) * EFFECT_QUALITY do
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
		particle:SetCollide(true)
		particle:SetBounce(0.4)
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
