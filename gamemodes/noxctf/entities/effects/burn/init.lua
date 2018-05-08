function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("nox/burn.ogg", pos, 100, math.random(95, 105))

	local emitter = ParticleEmitter(pos)
		for i=1, math.random(6, 10) do
			local particle = emitter:Add("sprites/light_glow02_add", pos)
			particle:SetVelocity(VectorRand() * 48 + Vector(0,0,200))
			particle:SetDieTime(1)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(50)
			particle:SetStartSize(10)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetCollide(true)
			particle:SetColor(255, 200, 50)
			particle:SetBounce(0.75)
			particle:SetGravity(Vector(0,0,-600))
		end
		for i=1, math.random(6, 8) do
			local particle = emitter:Add("sprites/light_glow02_add", pos)
			particle:SetVelocity(VectorRand() * 32 + Vector(0,0,math.random(75, 100)))
			particle:SetDieTime(1.5)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(50)
			particle:SetStartSize(16)
			particle:SetEndSize(4)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetColor(255, 200, 50)
			particle:SetCollide(true)
			particle:SetAirResistance(80)
		end
	emitter:Finish()
--[[
	for i=1, math.random(2, 4) do
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + VectorRand() * 8)
			effectdata:SetNormal(VectorRand() + Vector(0,0,0.4))
			effectdata:SetScale(300)
		util.Effect("ember", effectdata)
	end]]

	ExplosiveEffect(pos, 24, 0.01, DMGTYPE_FIRE)

	local tr = util.TraceLine({start = pos, endpos = pos + Vector(0,0,-64), mask = MASK_SOLID})
	util.Decal("FadingScorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
