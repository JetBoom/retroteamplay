EFFECT.Size = 2

local function DoSecondarySmallParticlesAt(emitter, pos, index)
	local particle = emitter:Add("particles/smokey", pos + Vector(math.Rand(-15, 15), math.Rand(-15, 15), index * 64 + math.Rand(-15, -15)))
	particle:SetVelocity(Vector(0, 0, 0))
	particle:SetDieTime(math.Rand(3.9, 4.3))
	particle:SetStartAlpha(math.Rand(205, 255))
	particle:SetStartSize(math.Rand(22, 48))
	particle:SetEndSize(math.Rand(192, 256))
	particle:SetRoll(math.Rand(360, 480))
	particle:SetRollDelta(math.Rand(-4, 4))
	particle:SetColor(70, 60, 60)
	particle:SetCollide(true)
	particle:SetBounce(0.4)
end

local function DoSecondaryParticlesAt(emitter, pos)
	for i=1, 2 do
		local particle = emitter:Add("particles/smokey", pos + Vector(0, 0, 352) + Vector(math.Rand(-80, 80), math.Rand(-80, 80), math.Rand(0, 120)))
		particle:SetVelocity(Vector(math.Rand(-0.8, 0.8), math.Rand(-0.8, 0.8), math.Rand(0, 1)):GetNormalized() * math.Rand(16, 64))
		particle:SetDieTime(math.Rand(6.9, 7.8))
		particle:SetStartAlpha(240)
		particle:SetStartSize(math.Rand(16, 32))
		particle:SetEndSize(math.Rand(92, 256))
		particle:SetRoll(math.Rand(360, 480))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(70, 60, 60)
		particle:SetCollide(true)
		particle:SetBounce(0.4)
	end
	emitter:Finish()
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	local tr = util.TraceLine({start = pos, endpos = pos + Vector(0,0,-90)})
	util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	sound.Play("nox/explosion0"..math.random(1,5)..".wav", pos, 100, math.random(85, 110))

	pos = pos + Vector(0,0,16)
	local pos2 = pos + Vector(0,0,72)
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(32, 48)
		for i=1, math.max(8, EFFECT_QUALITY * 16) do
			local particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos2)
			particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(400, 600) + Vector(0,0,math.Rand(500, 700)))
			particle:SetDieTime(math.Rand(1.8, 2.3))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(72)
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetCollide(true)
			particle:SetBounce(0.2)
			particle:SetAirResistance(50)
		end
		for i=1, math.max(2, EFFECT_QUALITY * 3) do
			local particle = emitter:Add("particles/smokey", pos + Vector(math.Rand(-40, 40), math.Rand(-40, 40), math.Rand(0, 80)))
			particle:SetVelocity(Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(0, 0.5)):GetNormalized() * math.Rand(32, 128))
			particle:SetDieTime(math.Rand(5.9, 6.8))
			particle:SetStartAlpha(math.Rand(205, 255))
			particle:SetStartSize(math.Rand(42, 68))
			particle:SetEndSize(math.Rand(192, 256))
			particle:SetRoll(math.Rand(360, 480))
			particle:SetRollDelta(math.Rand(-4, 4))
			particle:SetColor(70, 60, 60)
			particle:SetCollide(true)
			particle:SetBounce(0.4)
		end
		for i=1, math.max(1, EFFECT_QUALITY) * 1.5 do
			local particle = emitter:Add("particles/smokey", pos + Vector(math.Rand(-15, 15), math.Rand(-15, 15), i * 64 + math.Rand(-15, -15)))
			particle:SetVelocity(Vector(0,0,0))
			particle:SetDieTime(math.Rand(3.9, 4.3))
			particle:SetStartAlpha(math.Rand(205, 255))
			particle:SetStartSize(math.Rand(22, 48))
			particle:SetEndSize(math.Rand(192, 256))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetColor(70, 60, 60)
			particle:SetCollide(true)
			particle:SetBounce(0.4)
		end

		for i=1, 360, 3 + EFFECT_IQUALITY * 1.5 do
			local particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos)
			particle:SetVelocity(Vector(1000 * math.cos(i), 1000 * math.sin(i), 0))
			particle:SetDieTime(2.5)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(32)
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-0.8, 0.8))
			particle:SetCollide(true)
			particle:SetBounce(0.2)
			particle:SetAirResistance(70)

			particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos2)
			particle:SetVelocity(Vector(800 * math.cos(i), 800 * math.sin(i), 0))
			particle:SetDieTime(2)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(26)
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-0.8, 0.8))
			particle:SetCollide(true)
			particle:SetBounce(0.2)
			particle:SetAirResistance(50)
		end

	emitter:Finish()

	for i=1, math.Rand(3, 4) * EFFECT_QUALITY do
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + Vector(math.Rand(-64, 64), math.Rand(-64, 64), 16))
			effectdata:SetNormal(VectorRand() + Vector(0,0,0.45))
			effectdata:SetScale(800)
		util.Effect("tp_bigexplosionember", effectdata)
	end

	util.ExplosiveForce(pos, 300, 150, DMGTYPE_FIRE)

	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetRenderBoundsWS(pos + Vector(-768, -768, -768), pos + Vector(768, 768, 768))
end

function EFFECT:Think()
	local ft = FrameTime()
	self.Size = self.Size + ft * self.Size * 2.25
	self:SetAngles(Angle(0, self:GetAngles().yaw + ft * 360, 0))
	return self.Size < 48
end

function EFFECT:Render()
	local siz = self.Size
	self:SetModelScale(siz, 0)
	self:SetColor(Color(255, 200, 25, (48 - siz) * 5.3125))
	self:SetMaterial("models/shiny")
	self:DrawModel()
end
