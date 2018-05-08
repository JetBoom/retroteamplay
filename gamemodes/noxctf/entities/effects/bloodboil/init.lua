function EFFECT:Init(effectdata)
	self.Pos = effectdata:GetOrigin()
	self.Magnitude = effectdata:GetMagnitude()
	self.DeathTime = CurTime() + 0.25

	self.Emitter = ParticleEmitter(self.Pos)
	self.Emitter:SetNearClip(24, 32)

	ExplosiveEffect(self.Pos, self.Magnitude, self.Magnitude * 0.75, DMGTYPE_FIRE)
end

function EFFECT:Think()
	if CurTime() >= self.DeathTime then
		--self.Emitter:Finish()
		return false
	end

	local pos = self.Pos
	for i=1, EFFECT_QUALITY * math.Rand(3, 6) do
		local particle = self.Emitter:Add("sprites/glow04_noz", pos + VectorRand():GetNormal() * math.Rand(0, self.Magnitude))
		particle:SetColor(255, 0, 0)
		particle:SetStartSize(128)
		particle:SetEndSize(0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(127.5)
		particle:SetVelocity(Vector(0,0,128))
		particle:SetAirResistance(32)
		particle:SetDieTime(math.Rand(0.9, 1.3))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
	end

	return true
end

function EFFECT:Render()
end