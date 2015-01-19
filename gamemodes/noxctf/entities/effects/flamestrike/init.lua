function EFFECT:Init(data)
	self.DieTime = CurTime() + 0.5
	self.Entity:SetRenderBounds(Vector(-90, -90, -90), Vector(90, 90, 90))

	local pos = data:GetOrigin()
	self.vPos = pos

	sound.Play("ambient/machines/thumper_top.wav", pos, 86, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(30, 40)
	for i=1, math.max(1, EFFECT_QUALITY) * math.Rand(70, 80) do
		local vel = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal()

		local particle = emitter:Add("effects/fire_cloud"..math.random(1, 2), pos + vel * 148)
		particle:SetStartSize(2)
		particle:SetEndSize(16)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(127.5)
		particle:SetVelocity(vel * -256)
		particle:SetDieTime(math.Rand(0.45, 0.55))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
	end

	local particle = emitter:Add("particle/smokestack", pos)
	particle:SetStartSize(0)
	particle:SetEndSize(90)
	particle:SetStartAlpha(0)
	particle:SetEndAlpha(240)
	particle:SetDieTime(0.54)
	particle:SetColor(20, 20, 20)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1.5, 1.5))

	emitter:Finish()
end

function EFFECT:Think()
	if self.DieTime and self.DieTime <= CurTime() then
		self.DieTime = nil

		local pos = self.vPos
		sound.Play("ambient/explosions/explode_7.wav", pos, 85, math.Rand(96, 104))
		ExplosiveEffect(pos, 100, 35, DMGTYPE_FIRE)

		local emitter = ParticleEmitter(self.vPos)
		emitter:SetNearClip(40, 50)
		for i=1, math.max(14, EFFECT_QUALITY * 11) do
			local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), pos + VectorRand():GetNormal() * math.Rand(32, 64))
			particle:SetStartSize(90)
			particle:SetEndSize(0)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetDieTime(math.Rand(0.9, 1.1))
			particle:SetVelocity(VectorRand():GetNormal() * math.Rand(200, 500))
			particle:SetGravity(Vector(0,0,-500))
			particle:SetCollide(true)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-4, 4))
		end

		for i=1, math.max(1, EFFECT_QUALITY) * math.Rand(70, 80) do
			local vel = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal()

			local particle = emitter:Add("particle/smokestack", pos + vel * 16)
			particle:SetStartSize(28)
			particle:SetEndSize(0)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(127.5)
			particle:SetVelocity(vel * 512)
			particle:SetVelocity(vel * 512)
			particle:SetDieTime(math.Rand(0.45, 0.55))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
			particle:SetColor(30, 20, 20)

			local particle = emitter:Add("effects/fire_embers"..math.random(1,3), pos + vel * 32)
			particle:SetStartSize(48)
			particle:SetEndSize(0)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(180)
			particle:SetDieTime(math.Rand(0.9, 1.3))
			particle:SetVelocity(vel * math.Rand(120, 160))
			particle:SetGravity(Vector(0,0,400))
			particle:SetCollide(true)
		end

		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetStartSize(90)
		particle:SetEndSize(200)
		particle:SetStartAlpha(127.5)
		particle:SetEndAlpha(0)
		particle:SetDieTime(0.54)
		particle:SetColor(80, 20, 20)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))

		emitter:Finish()

		return false
	end

	return true
end

function EFFECT:Render()
end
