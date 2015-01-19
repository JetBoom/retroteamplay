function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local power = math.Clamp(data:GetMagnitude(), 1, 5)
	self.vPos = pos
	self.Power = power

	self.DieTime = CurTime() + 1

	self.tPos = {}
	for i=1, 40 do
		table.insert(self.tPos, Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal())
	end

	self.Entity:SetRenderBounds(Vector(-90, -90, -90), Vector(90, 90, 2624))

	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", pos, 82 + power, math.Rand(100, 110) - power * 3)
	ExplosiveEffect(pos, 64, 20, DMGTYPE_GENERIC)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, math.Rand(2, 3) * power do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetStartSize(100 + power * 14)
		particle:SetEndSize(0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(127.5)
		particle:SetVelocity((math.Rand(128, 256) + power * 16) * VectorRand():GetNormal() + Vector(0, 0, 100 + power * 16))
		particle:SetAirResistance(32)
		particle:SetDieTime(math.Rand(0.8, 1.1) + power * 0.1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1) * power)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(255, 255, 255, 255)
function EFFECT:Render()
	local left = math.max(0, self.DieTime - CurTime()) * 100
	local size = 140 + self.Power * 20
	local basesize = 230 + self.Power * 35
	colGlow.a = math.min(255, left * 5.1)

	render.SetMaterial(matGlow)
	render.DrawSprite(self.vPos, basesize, basesize, colGlow)
	for i, pos in ipairs(self.tPos) do
		render.DrawSprite(self.vPos + pos * left + Vector(0, 0, i * size * 0.5), size, size, colGlow)
	end
end
