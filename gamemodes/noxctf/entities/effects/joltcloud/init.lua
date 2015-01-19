function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("ambient/atmosphere/thunder"..math.random(1,4)..".wav", pos, 90, 100)
	sound.Play("ambient/atmosphere/thunder"..math.random(1,4)..".wav", pos, 90, 90)

	self.vPos = pos
	
	ExplosiveEffect(pos, 150, 0.01, DMGTYPE_SHOCK)

	self.DieTime = CurTime() + 3.5
	self.InitTime = CurTime() + 0.5
	self.NextEmit = 0
end

function EFFECT:Think()
	if self.DieTime <= CurTime() then
		return false
	end

	if self.InitTime and self.InitTime < CurTime() then
		self.InitTime = nil
		sound.Play("nox/lightning_impact.ogg", self:GetPos(), 100, 100)
		sound.Play("ambient/levels/labs/electric_explosion"..math.random(1,5)..".wav", self:GetPos(), 100, 90)
	end

	if self.NextEmit < CurTime() then
		self.NextEmit = CurTime() + (EFFECT_IQUALITY + 1) * 0.035

		local emitter = ParticleEmitter(self.vPos)
		emitter:SetNearClip(24, 32)

		local particle = emitter:Add("particle/smokestack", self.vPos + VectorRand():GetNormal() * math.Rand(50, 250))
		particle:SetDieTime(1.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(100)
		particle:SetEndSize(100)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2.5, 2.5))
		if math.random(2) == 1 then
			particle:SetColor(50, 40, 5)
		else
			particle:SetColor(5, 5, 5)
		end

		emitter:Finish()
	end

	return true
end

function EFFECT:Render()
end
