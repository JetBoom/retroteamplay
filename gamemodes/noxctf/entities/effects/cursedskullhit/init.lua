function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("npc/zombie/zombie_die"..math.random(3)..".wav", pos, 82, math.random(95, 115))
	

	local emitter = ParticleEmitter(pos)
	for i=1, math.random(10, 15) do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetVelocity(VectorRand() * 80)
		particle:SetDieTime(1)
		particle:SetStartAlpha(120)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.random(6,14))
		particle:SetEndSize(0)
		particle:SetAirResistance(20)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetCollide(true)
		particle:SetColor(185, 170, 45)
		particle:SetGravity(Vector(0, 0, 100))
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
