function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	for i=1, EFFECT_QUALITY * 200 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetColor(255, 255, 0)
		particle:SetStartSize(16)
		particle:SetEndSize(16)
		particle:SetStartAlpha(127.5)
		particle:SetEndAlpha(255)
		particle:SetVelocity(VectorRand():GetNormal() * 400)
		particle:SetDieTime(.5)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
