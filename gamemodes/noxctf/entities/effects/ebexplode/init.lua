local randparticles = {"particle/snow", "effects/yellowflare"}

function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()

	util.Decal("FadingScorch", pos - normal, pos + normal)

	sound.Play("ambient/levels/labs/electric_explosion2.wav", pos, 77, math.Rand(68, 75))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, math.max(12, math.Rand(EFFECT_QUALITY * 8, EFFECT_QUALITY * 10)) do
		local heading = (VectorRand() + normal):GetNormal()
		local particle = emitter:Add(randparticles[math.random(1, #randparticles)], pos + heading * 8)
		particle:SetVelocity(heading * 600)
		particle:SetGravity(heading * -600)
		particle:SetDieTime(math.Rand(1.25, 1.5))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(80)
		particle:SetStartSize(math.Rand(50, 75))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(50)
		particle:SetCollide(true)
		particle:SetBounce(0.1)
		particle:SetColor(200, 230, 255)
	end
	emitter:Finish()

	self.Start = CurTime()
	self.Pos = pos

	ExplosiveEffect(pos, 130, 30, DMGTYPE_LIGHTNING)
end

function EFFECT:Think()
	return CurTime() < self.Start + 1.6
end

local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	render.SetMaterial(matGlow)
	local size = 230.1 + math.sin((CurTime() - self.Start) * 3) * 230
	render.DrawSprite(self.Pos, size, size, color_white)
	render.DrawSprite(self.Pos, size, size, COLOR_CYAN)

	--[[
	local particle = emitter:Add("sprites/glow04_noz", pos)
	particle:SetDieTime(1.6)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(64)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetColor(200, 230, 255)]]
end
