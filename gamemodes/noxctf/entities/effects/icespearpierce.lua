function EFFECT:Init(data)
	local pos = data:GetOrigin()
	sound.Play("weapons/crossbow/hitbod"..math.random(1,2)..".wav", pos, 80, math.random(85, 110))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, math.max(3, EFFECT_QUALITY * 4) do
		local particle = emitter:Add("particle/snow", pos)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(40, 50))
		particle:SetDieTime(math.Rand(0.7, 0.9))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(12)
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetCollide(true)
		particle:SetBounce(0.2)
		particle:SetAirResistance(50)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
