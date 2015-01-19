local particles = {"effects/spark", "sprites/light_glow02_add"}

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	if not pos then return end

	sound.Play("nox/blink.ogg", pos, 90, math.random(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
		for i=1, math.random(120, 150) do
			local particle = emitter:Add(particles[math.random(1, 2)], pos)
			local particleVel = VectorRand() * 80
			particleVel.z = math.max(32, particleVel.z)
			particle:SetVelocity(particleVel)
			particle:SetDieTime(math.Rand(1.0, 1.7))
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.random(9,14))
			particle:SetEndSize(0)
			particle:SetRoll(math.random(0, 360))
			particle:SetRollDelta(0)
			local brightness = math.random(100, 180)
			particle:SetColor(brightness * 0.5, brightness, 255)
		end
		for i=1, 10 do
			local particle = emitter:Add("sprites/light_glow02_add", pos)
			particle:SetDieTime(1.7)
			particle:SetStartAlpha(254)
			particle:SetEndAlpha(100)
			particle:SetStartSize(40)
			particle:SetEndSize(5)
			particle:SetRoll(math.random(0, 360))
			particle:SetRollDelta(0)
			particle:SetColor(100, 110, 255)
		end
	emitter:Finish()

	self.DieTime = RealTime() + 2
end

function EFFECT:Think()
	return RealTime() < self.DieTime
end

function EFFECT:Render()
end
