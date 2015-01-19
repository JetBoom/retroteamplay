function EFFECT:Init(data)
	local pos = data:GetOrigin()
	sound.Play("nox/explosion0"..math.random(1,5)..".ogg", pos, 100, math.random(85, 110))
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
	util.Effect("Explosion", effectdata)
	pos = pos + Vector(0, 0, 16)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, 3 do
		local vBaseAng = Angle(math.random(1, 90), math.random(1, 90), math.random(1, 90))
		for x=0, 360, 15 do
			local vVec = Vector(2560 * math.cos(x), 2560 * math.sin(x), 0)
			vVec:Rotate(vBaseAng, 180)

			local particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos)
			particle:SetVelocity(vVec)
			particle:SetDieTime(math.Rand(2.5, 2.7))
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(32)
			particle:SetStartSize(64)
			particle:SetEndSize(4)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetCollide(true)
			particle:SetBounce(0.2)
			particle:SetAirResistance(260)

			local particle = emitter:Add("particles/smokey", pos)
			particle:SetVelocity(vVec * 0.98)
			particle:SetDieTime(math.Rand(2.5, 3.4))
			particle:SetStartAlpha(math.Rand(205, 255))
			particle:SetStartSize(math.Rand(22, 38))
			particle:SetEndSize(math.Rand(92, 156))
			particle:SetRoll(math.Rand(360, 480))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(70, 60, 60)
			particle:SetAirResistance(260)
		end
	end

	for i=1, 2 do
		local particle = emitter:Add("effects/fire_cloud"..math.random(1, 2), pos)
		particle:SetDieTime(math.Rand(2, 3))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(32, 64))
		particle:SetEndSize(math.Rand(750, 800))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(6, 8))
	end

	if math.Round(data:GetMagnitude()) == 1 then
		for i=1, 90 do
			local particle = emitter:Add("effects/yellowflare", pos)
			particle:SetVelocity(VectorRand():GetNormal() * 5048)
			particle:SetAirResistance(600)
			particle:SetDieTime(math.Rand(2.5, 3.5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(90)
			particle:SetEndSize(90)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-60, 60))
		end
	end

	emitter:Finish()

	for i=1, math.random(6, 8) do
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + VectorRand() * 8)
			effectdata:SetNormal(VectorRand() + Vector(0, 0, 0.25))
			effectdata:SetScale(700)
		util.Effect("firebombember", effectdata)
	end

	ExplosiveEffect(pos, 300, 150, DMGTYPE_FIRE)

	local tr = util.TraceLine({start = pos, endpos = pos + Vector(0,0,-64), mask = MASK_PLAYERSOLID})
	util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
