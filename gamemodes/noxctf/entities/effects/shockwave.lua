function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin()
	local normal = effectdata:GetNormal()

	self.Emitter = ParticleEmitter(pos, true)
	self.Emitter:SetNearClip(24, 32)
	self.Emitter2 = ParticleEmitter(pos)
	self.Emitter2:SetNearClip(24, 32)
	
	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", pos, 80, math.random(100, 120))


	for i=1,3 do
		local particle = self.Emitter:Add("effects/select_ring", pos)
		particle:SetDieTime(0.1 + i * 0.1)
		particle:SetColor(255,255,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(150)
		particle:SetAngles(normal:Angle())
		particle = self.Emitter:Add("effects/select_ring", pos)
		particle:SetDieTime(0.2 + i * 0.1)
		particle:SetColor(255,255,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(180)
		particle:SetAngles(normal:Angle())
	end
	for i=1,100 do
		local particle = self.Emitter2:Add("effects/splash2", pos)
		particle:SetDieTime(0.4)
		particle:SetColor(255,255,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(4)
		particle:SetStartLength(30)
		particle:SetEndLength(30)
		particle:SetVelocity(VectorRand():GetNormal() * math.random(450,600))
	end

	--self.Emitter:Finish()
	self.Emitter2:Finish()
	
	ExplosiveEffect(pos, 160, 40, DMGTYPE_GENERIC)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

