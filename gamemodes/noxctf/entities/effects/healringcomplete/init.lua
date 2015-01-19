function EFFECT:Init(data)
	local pos = data:GetOrigin() + Vector(0,0,32)

	sound.Play("nox/healringend.ogg", pos)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, 360, math.max(3, EFFECT_IQUALITY) * 4 do
		local particle = emitter:Add("sprites/glow04_noz", pos + Vector(64 * math.cos(i), 64 * math.sin(i), 0))
		particle:SetVelocity(Vector(128 * math.cos(i), 128 * math.sin(i), 0))
		particle:SetDieTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(48)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-16, 16))
		particle:SetColor(180, 255, 180)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
