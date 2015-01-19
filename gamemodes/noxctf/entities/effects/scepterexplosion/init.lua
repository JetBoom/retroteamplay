local matGlow = "sprites/orangecore1"
function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local ent = data:GetEntity()
	
	local c = team.GetColor(ent:GetTeamID()) or color_white

	local pos = data:GetOrigin()
	pos = pos + normal * 2
	
	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", pos, 70, math.Rand(200, 220))

	local ang = normal:Angle()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	for i=1, math.Rand(6, 8) * EFFECT_QUALITY do
		local particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(normal * math.Rand(120, 150) + VectorRand():GetNormal() * math.Rand(80, 100))
		particle:SetDieTime(math.Rand(0.8, 1.1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(10)
		particle:SetStartSize(6)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(8)
		particle:SetCollide(true)
		particle:SetBounce(0.4)
		particle:SetColor(c.r, c.g, c.b)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
