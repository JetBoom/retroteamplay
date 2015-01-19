function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("ambient/explosions/explode_"..math.random(2,5)..".wav", pos, 90, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
		for i=1, math.random(5, 10) do
			local vel = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal()
			local particle = emitter:Add("particle/smokestack", pos + Vector(0,0,30))
			particle:SetVelocity(vel * 250)
			particle:SetDieTime(1)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(32)
			particle:SetEndSize(4)
			particle:SetColor(60, 10, 10)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetGravity( vector_up * -520 )
		end
		for i=1, math.random(30, 45) do
			local vel = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal()
			local particle = emitter:Add("effects/fire_cloud1", pos + Vector(0,0,30))
			particle:SetVelocity(vel * 250)
			particle:SetDieTime(math.Rand(0.5, 1))
			particle:SetStartAlpha(240)
			particle:SetEndAlpha(10)
			particle:SetStartSize(math.Rand(33, 54))
			particle:SetEndSize(math.Rand(0, 4))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
			particle:SetGravity( vector_up * 120 )
			particle:SetColor(185, 170, 45)
			particle:SetCollide(true)
			particle:SetAirResistance( 10 )
		end
		for i=1, math.Rand(60, 80) do
			local vel = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal()
			local particle = emitter:Add("particle/smokestack", pos + Vector(0,0,30) + vel * 16)
			particle:SetStartSize(20)
			particle:SetEndSize(60)
			particle:SetStartAlpha(140)
			particle:SetEndAlpha(0)
			particle:SetVelocity(vel * 300)
			particle:SetDieTime(math.Rand(0.5, 1))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
			particle:SetColor(84, 14, 14)
			particle:SetGravity( vector_up * 520 )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			particle:SetAirResistance( 110 )
		end
	emitter:Finish()

	for i=1, math.random(2, 6) do
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + VectorRand() * 8 + vector_up * 10)
			effectdata:SetNormal(VectorRand())
			effectdata:SetScale(200)
		util.Effect("ember", effectdata)
	end

	util.Decal("Scorch", pos, pos + Vector(0,0,-4))
	
	ExplosiveEffect(pos, 100, 50, DMGTYPE_FIRE)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
