function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("ambient/explosions/explode_"..math.random(2,5)..".wav", pos, 90, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
		for i=1, math.random(5, 7) do
			local particle = emitter:Add("particle/smokestack", pos)
			particle:SetVelocity(VectorRand():GetNormal() * 320)
			particle:SetDieTime(0.75)
			particle:SetStartAlpha(160)
			particle:SetEndAlpha(0)
			particle:SetStartSize(32)
			particle:SetEndSize(247)
			particle:SetColor(20, 20, 20)
			particle:SetRoll(math.Rand(-360, 360))
		end
		for i=1, math.random(30, 45) do
			local particle = emitter:Add("effects/fire_cloud1", pos)
			particle:SetVelocity(VectorRand():GetNormal() * math.Rand(230, 360))
			particle:SetDieTime(math.Rand(1, 1.5))
			particle:SetStartAlpha(240)
			particle:SetEndAlpha(20)
			particle:SetStartSize(math.Rand(30, 86))
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetCollide(true)
			particle:SetGravity(Vector(0,0,-100))
		end
	emitter:Finish()

	util.Decal("Scorch", pos, pos + Vector(0,0,-4))
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
