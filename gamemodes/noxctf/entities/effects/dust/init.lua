function EFFECT:Init(data)
	local pos = data:GetOrigin() + Vector(0, 0, 10)

	self.Entity:SetRenderBounds(Vector(-500, -500, -144), Vector(500, 500, 144))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, math.Rand(140, 160) do
		local vel = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(0, .5)):GetNormal()
		local particle = emitter:Add("particle/smokestack", pos + vel * 16)
		particle:SetStartSize(5)
		particle:SetEndSize(28)
		particle:SetStartAlpha(127.5)
		particle:SetEndAlpha(0)
		particle:SetVelocity(vel * 200)
		particle:SetAirResistance(100)
		particle:SetDieTime(math.Rand(1.8, 1.2))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
		particle:SetColor(194, 178, 128)
		particle:SetCollide(true)
		particle:SetBounce(0.1)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
