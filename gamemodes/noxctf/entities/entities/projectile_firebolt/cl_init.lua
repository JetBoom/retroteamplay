include("shared.lua")

local matFire = Material("sprites/light_glow02_add")

function ENT:Draw()
	self:SetModelScale(0.4, 0)
	self:DrawModel()
	render.SetMaterial(matFire)
	render.DrawSprite(self:GetPos(), math.random(32, 48), math.random(32, 48), color_white)
end

function ENT:DrawOffScreen()
	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	local particle = emitter:Add("effects/fire_embers"..math.random(1,3), vOffset)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(14, 20))
	particle:SetEndSize(2)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1, 1))

	local vel = self:GetVelocity()

	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("effects/fire_embers"..math.random(1,3), vOffset)
		particle:SetVelocity(vel * -0.7 + VectorRand() * 100)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(100)
		particle:SetStartSize(math.Rand(10, 14))
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))

		local particle = emitter:Add("sprites/light_glow02_add", vOffset + VectorRand():GetNormal() * 10)
		particle:SetVelocity(vel * -0.1 + VectorRand() * 8)
		particle:SetDieTime(1.25)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(20)
		particle:SetStartSize(math.Rand(12, 16))
		particle:SetEndSize(2)
		particle:SetColor(255, 200, 50)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
	end
end

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:SetColor(Color(255, 125, 75, 255))
	self:SetMaterial("models/props_wasteland/rockcliff04a")

	self.AmbientSound = CreateSound(self, "ambient/fire/fire_big_loop1.wav")
end

function ENT:Think()
	self.AmbientSound:Play()

	self:DrawOffScreen()
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/fireballwhoosh.ogg", 85, math.random(95, 105))
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end
