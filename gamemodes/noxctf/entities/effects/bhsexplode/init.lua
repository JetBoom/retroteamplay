EFFECT.LifeTime = 1

function EFFECT:Init(effectdata)
	self.Pos = effectdata:GetOrigin()
	self.Normal = effectdata:GetNormal()
	self.DeathTime = CurTime() + self.LifeTime
	
	sound.Play("nox/explosion0"..math.random(1,5)..".ogg", self.Pos, 80, math.random(85, 110))

	self.Emitter = ParticleEmitter(self.Pos)
	self.Emitter:SetNearClip(24, 32)
	
	ExplosiveEffect(self.Pos, 240, 240, DMGTYPE_FIRE)
end

function EFFECT:Think()
	if CurTime() >= self.DeathTime then
		--self.Emitter:Finish()
		return false
	end

	for i=1, math.random(32, 48) do
		local vel = VectorRand():GetNormal() * 1024
		vel.z = vel.z * 0.25
		local particle = self.Emitter:Add("effects/fire_cloud"..math.random(1, 2), self.Pos)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(1.5, 2))
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(8, 24))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(255, math.Rand(90, 125), math.Rand(50, 100))
		particle:SetCollide(true)
		particle:SetBounce(0.2)
		particle:SetAirResistance(math.Rand(64, 256))
	end

	return true
end

local matRefraction	= Material("refract_ring")
function EFFECT:Render()
	local normal = self.Normal
	local pos = self.Pos + normal * 2

	local ct = CurTime()

	local delta = math.max(0, self.DeathTime - ct)
	local rdelta = self.LifeTime - delta

	matRefraction:SetFloat("$refractamount", delta * math.sin(rdelta * math.pi) * 0.5)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	local qsiz = (delta ^ 2) * 2048
	render.DrawQuadEasy(pos, normal, qsiz, qsiz, color_white, 0)
	render.DrawQuadEasy(pos, normal * -1, qsiz, qsiz, color_white, 0)
end