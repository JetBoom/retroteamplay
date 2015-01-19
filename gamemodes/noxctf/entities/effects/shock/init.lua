function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("nox/shocked.ogg", pos, 77, math.Rand(80, 115))

	local particles = {}

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=0, math.Rand(32, 48) do
		local heading = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-0.2, 0.2)):GetNormal()

		local particle = emitter:Add("effects/yellowflare", pos + heading * 8)
		particle:SetVelocity(heading * math.Rand(1024, 1560))
		particle:SetDieTime(math.Rand(1.5, 1.6))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(200)
		particle:SetStartSize(math.Rand(20, 32))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-75, 75))
		particle:SetAirResistance(math.Rand(500, 700))
		if math.random(1, 2) == 1 then
			particle:SetColor(200, 230, 255)
		end

		particles[#particles + 1] = particle
	end
	emitter:Finish()

	self.DieTime = CurTime() + 1.6
	self.Pos = pos
	self.Particles = particles

	ExplosiveEffect(pos, 64, 45, DMGTYPE_LIGHTNING)
end

function EFFECT:Think()
	return CurTime() <= self.DieTime
end

local matBeam = Material("Effects/laser1")
function EFFECT:Render()
	render.SetMaterial(matBeam)

	local pos = self.Pos
	local siz = (self.DieTime - CurTime()) * 16

	for i, particle in pairs(self.Particles) do
		if particle and math.random(1, 3) == 1 then
			render.DrawBeam(particle:GetPos(), pos, siz, 1, 0, color_white)
		end
	end
end
