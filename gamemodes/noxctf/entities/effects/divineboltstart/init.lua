function EFFECT:Init(data)
	self.DieTime = CurTime() + .75
	self.Entity:SetRenderBounds(Vector(-90, -90, -90), Vector(90, 90, 90))

	local pos = data:GetOrigin()
	self.vPos = pos

	sound.Play("weapons/physcannon/energy_sing_flyby"..math.random(1,2)..".wav", pos, 86, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, math.random(8, 10) do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetStartSize(64)
		particle:SetEndSize(0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(127.5)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(32, 64) + Vector(0, 0, 32))
		particle:SetDieTime(math.Rand(0.9, 1.3))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
	end
	emitter:Finish()
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	local pos = self.vPos

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 160, 160, color_white)

	local left = (self.DieTime - CurTime()) * 150
	for i=1, math.random(24, 32) do
		render.DrawSprite(pos + left * Vector(math.Rand(-200, 200), math.Rand(-200, 200), math.Rand(25, 150)):GetNormal(), 24, 24, color_white)
	end
end
