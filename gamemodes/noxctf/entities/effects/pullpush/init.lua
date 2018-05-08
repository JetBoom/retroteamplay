function EFFECT:Init(data)
	if tobool(data:GetMagnitude()) then
		local pos = data:GetOrigin() + Vector(0,0,48)
		sound.Play("weapons/physcannon/physcannon_pickup.wav", pos, 75, math.random(90, 95))
		sound.Play("nox/pull.ogg", pos)

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)
			for i=1, math.random(80, 150) do
				local pPos = pos + Vector(math.random(-256, 256), math.random(-256, 256), 1):GetNormal() * 256
				local particle = emitter:Add("effects/blueflare1", pPos)
				particle:SetVelocity((pos - pPos):GetNormal() * 700)
				particle:SetDieTime(0.34)
				particle:SetStartAlpha(math.Rand(20, 40))
				particle:SetEndAlpha(230)
				particle:SetStartSize(math.random(16, 32))
				particle:SetEndSize(5)
				particle:SetRoll(math.random(0, 360))
				particle:SetRollDelta(0.5)
				particle:SetColor(255, 255, 255)
			end
		emitter:Finish()
	else
		local pos = data:GetOrigin() + Vector(0,0,48)
		sound.Play("ambient/explosions/explode_9.wav", pos, 70, math.random(105, 120))
		sound.Play("nox/push.ogg", pos)

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)
			for i=1, math.random(80, 150) do
				local particle = emitter:Add("effects/blueflare1", pos)
				particle:SetVelocity(Vector(math.random(-256, 256), math.random(-256, 256), 1):GetNormal() * 700)
				particle:SetDieTime(0.48)
				particle:SetStartAlpha(math.Rand(20, 40))
				particle:SetEndAlpha(230)
				particle:SetStartSize(math.random(12, 28))
				particle:SetEndSize(5)
				particle:SetRoll(math.random(0, 360))
				particle:SetRollDelta(0.5)
				particle:SetColor(255, 255, 255)
			end
		emitter:Finish()
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
