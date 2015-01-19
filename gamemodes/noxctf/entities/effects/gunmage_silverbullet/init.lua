local matBeam = Material("Effects/laser1")

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Dir = self.EndPos - self.StartPos
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)

	self.TracerTime = 0.3

	self.DieTime = CurTime() + self.TracerTime

	local pitch = math.random(110, 180)
	sound.Play("weapons/mortar/mortar_explode3.wav", self.StartPos, 70, pitch)
	if self.EndPos:Distance(self.StartPos) > 128 then
		sound.Play("weapons/mortar/mortar_explode3.wav", self.EndPos, 70, pitch)
	end

	local pos = self.EndPos
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, math.max(12, math.Rand(32, 50) * EFFECT_QUALITY) do
		local start = VectorRand():GetNormal() * 128
		local particle = emitter:Add("sprites/light_glow02_add", pos + start)
			particle:SetVelocity(start * -0.5)
			particle:SetDieTime(math.Rand(2, 2.5))
			particle:SetStartAlpha(100)
			particle:SetEndAlpha(250)
			particle:SetStartSize(math.Rand(2, 6))
			particle:SetEndSize(math.Rand(24, 32))
			particle:SetRoll(math.Rand(-60, 60))
	end

	for i=1, math.max(5, math.Rand(8, 12) * EFFECT_QUALITY) do
		local particle = emitter:Add("effects/spark", pos)
			particle:SetVelocity(VectorRand():GetNormal() * math.Rand(190, 360))
			particle:SetDieTime(math.Rand(1, 3.5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(44, 52))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			if math.random(1, 2) == 1 then
				particle:SetRollDelta(math.Rand(-300, -200))
			else
				particle:SetRollDelta(math.Rand(200, 300))
			end
			particle:SetAirResistance(math.Rand(140, 200))
	end
	emitter:Finish()
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

function EFFECT:Render()
	local fDelta = (self.DieTime - CurTime()) / self.TracerTime
	fDelta = math.Clamp(fDelta, 0, 1)

	render.SetMaterial(matBeam)

	local sinWave = math.sin(fDelta * math.pi)

	render.DrawBeam(self.EndPos - self.Dir * (fDelta - sinWave * 0.25 ), self.EndPos - self.Dir * (fDelta + sinWave * 0.25 ), 2 + sinWave * 32, 1, 0, color_white)
end
