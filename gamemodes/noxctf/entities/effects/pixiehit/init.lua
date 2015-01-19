function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("nox/pixiehit"..math.random(1,2)..".ogg", pos, 82, math.random(95, 105))

	local emitter = ParticleEmitter(pos)
	for i=1, math.random(10, 16) do
		local particle = emitter:Add("sprites/light_glow02_add", pos)
		particle:SetVelocity(VectorRand() * 430)
		particle:SetDieTime(0.8)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(8)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-24, 24))
		particle:SetCollide(true)
		particle:SetBounce(0.4)
		particle:SetColor(255, 255, 50)
		particle:SetGravity(Vector(0, 0, -600))
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
