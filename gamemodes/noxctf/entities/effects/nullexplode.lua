function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin()

	self.Emitter = ParticleEmitter(pos)
	self.Emitter:SetNearClip(24, 32)
	
	sound.Play("physics/glass/glass_sheet_break"..math.random(1,3)..".wav", pos, 70, math.random(50, 70))
	sound.Play("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav", pos, 75, math.random(70, 90))


	for i=1,100 do
		local particle = self.Emitter:Add("effects/splash2", pos)
		particle:SetDieTime(0.4)
		particle:SetColor(50,50,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(6)
		particle:SetEndSize(6)
		particle:SetStartLength(60)
		particle:SetEndLength(60)
		particle:SetVelocity(VectorRand():GetNormal() * 520)
	end
	for i=1,300 do
		local particle = self.Emitter:Add("effects/fleck_glass"..math.random(1,3), pos + VectorRand():GetNormal() * 200)
		particle:SetDieTime(4)
		particle:SetColor(0,0,255)
		particle:SetRoll(math.random(0,360))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(8)
		particle:SetEndSize(8)
		particle:SetAirResistance(50)
		particle:SetGravity(Vector(0,0,-200))
		particle:SetVelocity(Vector(0,0,60))
		particle:SetCollide(true)
		particle:SetBounce(0.3)
	end
	for i=1,160 do
		local particlepos = VectorRand():GetNormal() * 256
		local particle = self.Emitter:Add("effects/blueflare1", pos + particlepos)
		particle:SetDieTime(1)
		particle:SetColor(50,50,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(7)
		particle:SetEndSize(7)
		particle:SetVelocity(particlepos * -2.3)
	end

	
	--self.Emitter:Finish()

	
	ExplosiveEffect(pos, 256, 20, DMGTYPE_LIGHTNING)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

