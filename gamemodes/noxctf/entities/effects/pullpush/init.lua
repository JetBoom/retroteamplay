function EFFECT:Init(data)
	if util.tobool(data:GetMagnitude()) then
		local pos = data:GetOrigin() + Vector(0,0,48)
		sound.Play("nox/pull.ogg", pos, 85, math.random(95, 105))

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)
			for i=1, math.random(80, 150) do
				local pPos = pos + Vector(math.random(-256, 256), math.random(-256, 256), 1):GetNormal() * 256
				local particle = emitter:Add("sprites/glow04_noz", pPos)
				particle:SetVelocity((pos - pPos):GetNormal() * 256)
				particle:SetDieTime(0.98)
				particle:SetStartAlpha(math.Rand(20, 40))
				particle:SetEndAlpha(230)
				particle:SetStartSize(math.random(12, 28))
				particle:SetEndSize(5)
				particle:SetRoll(math.random(0, 360))
				particle:SetRollDelta(0.5)
				particle:SetColor(255, 255, 255)
			end
		emitter:Finish()
	else
		local pos = data:GetOrigin() + Vector(0,0,48)
		sound.Play("nox/push2.ogg", pos, 85, math.random(95, 105))

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)
			for i=1, math.random(80, 150) do
				local particle = emitter:Add("sprites/glow04_noz", pos)
				particle:SetVelocity(Vector(math.random(-256, 256), math.random(-256, 256), 1):GetNormal() * 256)
				particle:SetDieTime(0.98)
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
