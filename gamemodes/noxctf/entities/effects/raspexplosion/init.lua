function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin() + normal * 2

	self.Pos = pos
	self.Normal = normal
	self.DieTime = RealTime() + .5
	self.Col = Color(255, 255, 0, 255)

	sound.Play("nox/airburst.ogg", pos, 80, math.Rand(95, 10))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(32, 42)
	for i=1, 50 + EFFECT_QUALITY * 15 do
		local heading = (VectorRand() + normal):GetNormal()
		local start = pos + heading * 8
		local vel = heading * math.Rand(100, 156)
		local dtime = math.Rand(0.75, 1.25)

		local particle = emitter:Add("particles/flamelet1", start)
		particle:SetDieTime(dtime)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(12)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-6, 6))
		particle:SetColor(0, 255, 255)
		particle:SetVelocity(vel * 2)
		particle:SetAirResistance(128)

		particle = emitter:Add("particles/flamelet2", start)
		particle:SetDieTime(dtime)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(16)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-14, 14))
		particle:SetColor(0, 255, 255)
		particle:SetVelocity(vel * 2)
		particle:SetAirResistance(128)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return RealTime() < self.DieTime
end

local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	local delta = math.max(0, self.DieTime - RealTime())
	local col = Color(0, 255, 0)
	col.b = delta * 255

	local size = 256 - delta * 160

	render.SetMaterial(matGlow)
	render.DrawQuadEasy(self.Pos, self.Normal, size, size, col)
	render.DrawQuadEasy(self.Pos, self.Normal, size, size, col)
	render.DrawQuadEasy(self.Pos, self.Normal * -1, size, size, col)
	render.DrawQuadEasy(self.Pos, self.Normal * -1, size, size, col)
	render.DrawSprite(self.Pos, size, size, col)
	render.DrawSprite(self.Pos, size, size, col)
end
