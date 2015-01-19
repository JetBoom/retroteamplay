function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()

	util.Decal("FadingScorch", pos - normal, pos + normal)

	sound.Play("ambient/explosions/explode_3.wav", pos, 70, math.Rand(128, 145))

	local c = team.GetColor(math.Round(data:GetScale()))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local grav = Vector(0,0,-600)
	for i=1, math.max(24, math.Rand(EFFECT_QUALITY * 16, EFFECT_QUALITY * 20)) do
		local heading = (VectorRand() + normal):GetNormal()
		local particle = emitter:Add("sprites/light_glow02_add", pos + heading * 8)
		particle:SetVelocity(heading * math.Rand(150, 200))
		particle:SetGravity(grav)
		particle:SetDieTime(math.Rand(1.25, 1.5))
		particle:SetStartAlpha(255)
		particle:SetStartSize(math.Rand(25, 48))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetCollide(true)
		particle:SetBounce(0.6)
		particle:SetColor(c.r, c.g, c.b)
	end

	local spos = pos + normal * 8
	local particle = emitter:Add("noxctf/sprite_nova", spos)
	local dtime = math.Rand(0.6, 0.8)
	particle:SetDieTime(dtime)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	local esize = math.Rand(101, 140)
	particle:SetEndSize(math.Rand(101, 140))
	local roll = math.Rand(0, 360)
	particle:SetRoll(roll)
	local rolld = math.Rand(-60, 60)
	particle:SetRollDelta(rolld)
	particle:SetColor(c.r, c.g, c.b)

	local particle = emitter:Add("noxctf/sprite_nova", spos)
	particle:SetDieTime(dtime)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(esize)
	particle:SetRoll(roll)
	particle:SetRollDelta(rolld)
	particle:SetColor(c.r, c.g, c.b)

	emitter:Finish()

	ExplosiveEffect(pos, 72, 35, DMGTYPE_FIRE)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
