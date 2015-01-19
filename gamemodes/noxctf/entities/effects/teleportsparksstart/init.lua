local particles = {"effects/spark", "sprites/light_glow02_add"}

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	if not pos then return end

	sound.Play("nox/blink.ogg", pos, 90, math.random(95, 105))

	self.DieTime = 0.75
	self.SpritePos = pos
	self.NextSpark = -10
	self.Pos = pos
end

function EFFECT:Think()
	self.DieTime = self.DieTime - FrameTime()
	return self.DieTime > 0
end

function EFFECT:Render()
	if RealTime() < self.NextSpark then return end
	self.NextSpark = RealTime() + 0.1
	local emitter = ParticleEmitter(self.Pos)
	emitter:SetNearClip(24, 32)
		for i=1, math.random(20, 30) do
			local particle = emitter:Add(particles[math.random(1, 2)], self.Pos)
			local particleVel = VectorRand() * 80 + Vector(0,0, 120)
			particle:SetVelocity(particleVel)
			particle:SetDieTime(math.Rand(0.6, 0.9))
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.random(9,14))
			particle:SetEndSize(0)
			particle:SetRoll(math.random(0, 360))
			particle:SetRollDelta(0)
			local brightness = math.random(100, 180)
			particle:SetColor(brightness * 0.5, brightness, 255)
		end
	emitter:Finish()
end
