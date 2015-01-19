function EFFECT:Init(effectdata)
	self.Pos = effectdata:GetOrigin()
	self:SetPos(self.Pos)
	self.DeathTime = CurTime() + .25
end

function EFFECT:Think()
	if CurTime() >= self.DeathTime then return end
	
	local emitter = ParticleEmitter(self.Pos)
		for i=1, math.random(9, 10) * EFFECT_QUALITY do
			local particle = emitter:Add("particles/balloon_bit", self.Pos + VectorRand():GetNormal() * 2)
			particle:SetVelocity(VectorRand():GetNormal() * math.Rand(48, 90))
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(100)
			local Size = math.Rand(1, 5)
			particle:SetStartSize(Size)
			particle:SetEndSize(Size * 0.25)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetGravity(Vector(0, 0, -400))
			local RandDarkness = math.Rand(0.8, 1.0)
			particle:SetColor(230 * RandDarkness, 240 * RandDarkness, 255 * RandDarkness)
			particle:SetCollide(true)
			particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))
			particle:SetBounce(0.9)
		end
	emitter:Finish()
	
	return true
end

function EFFECT:Render()
end