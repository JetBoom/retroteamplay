function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()
	self.DieTime = CurTime() + 1
	util.Decal("Scorch", pos + normal, pos - normal)
	pos = pos + normal * 2
	self.Pos = pos
	self.Norm = normal
	self.Entity:SetRenderBoundsWS(pos + Vector(-2500, -2500, -2500), pos + Vector(2500, 2500, 2500))

	sound.Play("nox/explosion0"..math.random(1,5)..".ogg", pos, 100, math.random(85, 110))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(32, 48)
	for i=1, math.max(12, EFFECT_QUALITY * 8) do
		local dir = (VectorRand() + normal):GetNormal()
		local particle = emitter:Add("particle/smokestack", pos + dir * 32)
		particle:SetVelocity(dir * math.Rand(240, 430))
		particle:SetDieTime(math.Rand(4.5, 6))
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(50, 60))
		particle:SetEndSize(math.Rand(250, 450))
		particle:SetColor(40, 40, 40)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(math.Rand(10, 30))

		local particle = emitter:Add("effects/fire_cloud1", pos + dir * 16)
		particle:SetVelocity(dir * math.Rand(300, 400))
		particle:SetDieTime(math.Rand(1.25, 2))
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(8)
		particle:SetEndSize(math.Rand(200, 250))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.5, 0.5))
		particle:SetAirResistance(40)
	end
	emitter:Finish()

	ExplosiveEffect(pos, 460, 230, DMGTYPE_FIRE)

	for i=1, math.Rand(2, 3) * EFFECT_QUALITY do
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + VectorRand() * 16)
			effectdata:SetNormal((normal + VectorRand() * 0.25):GetNormal())
			effectdata:SetScale(math.Rand(1000, 1500))
		util.Effect("firebombember", effectdata)
	end
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matRing = Material("effects/select_ring")
function EFFECT:Render()
	if 0 < EFFECT_QUALITY then
		local ct = CurTime()
		if ct < self.DieTime then
			render.SetMaterial(matRing)

			local size = (1 - (self.DieTime - ct)) * 1500
			local col = Color(255, 190, 40, math.min(255, (self.DieTime - ct) * 560))
			render.DrawQuadEasy(self.Pos, self.Norm, size, size, col, 0)
			render.DrawQuadEasy(self.Pos, self.Norm * -1, size, size, col, 0)
		end
	end
end
