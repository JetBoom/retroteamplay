local matGlow = Material("sprites/light_glow02_add")

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("nox/counterspell.ogg", pos, 90, math.random(95, 105))

	local emitter = ParticleEmitter(pos)
	for i=1, math.random(120, 150) do
		local particle = emitter:Add("effects/spark", pos)
		particle:SetVelocity(Vector(math.Rand(-150, 150), math.Rand(-150, 150), math.Rand(-75, 75)))
		particle:SetLifeTime(0.5)
		particle:SetDieTime(math.Rand(0.5, 1.0))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.random(20,30))
		particle:SetEndSize(0)
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(0)
	end
	emitter:Finish()
	self.DieTime = 2
	self.SpritePos = pos

	for i=1, math.random(4, 5) do
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + VectorRand() * 6)
			effectdata:SetNormal(VectorRand():GetNormal())
			effectdata:SetScale(math.Rand(1.5, 2.5))
		util.Effect("sparkle", effectdata)
	end
end

function EFFECT:Think()
	self.DieTime = self.DieTime - FrameTime()
	return self.DieTime > 0
end

function EFFECT:Render()
	local ySize = math.max(self.DieTime * 200, 1)
	local xSize = math.max(ySize * 0.25, 1)

	render.SetMaterial(matGlow)

	local alpha = math.min(self.DieTime * 100, 255)
	local whiteness = Color(255, 255, 255, alpha)
	render.DrawSprite(self.SpritePos, xSize, ySize, whiteness)
end
