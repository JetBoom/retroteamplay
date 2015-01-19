include("shared.lua")

local matFire = Material("particle/snow")
local matGlow = Material("sprites/light_glow02_add")

function ENT:Draw()
	self:SetColor(Color(225, 225, 255, 255))
	self:DrawModel()
	render.SetMaterial(matGlow)
	render.DrawSprite(self:GetPos(), math.random(32, 48), math.random(32, 48), color_white)
end

function ENT:DrawOffScreen()
	local vOffset = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(vOffset, 80, 80, whiteness)
	render.SetMaterial(matFire)
	render.DrawSprite(vOffset, 80, 80, color_white)

	self:DrawModel()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	local particle = emitter:Add("particle/snow", vOffset + self:GetForward() * 55)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(60)
	particle:SetStartSize(1)
	particle:SetEndSize(math.Rand(4, 6))
	particle:SetRoll(math.Rand(0, 359))
	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("particle/snow", vOffset + self:GetForward() * self:GetVelocity():Length2D()*0.1)
		particle:SetVelocity(self:GetVelocity() * -0.7 + VectorRand() * 50)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(4, 6))
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.75, 0.75))
		particle:SetGravity(Vector(0,0,-100))
	end
end

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:SetMaterial("models/shadertest/shader2")
end

function ENT:Think()
	self:DrawOffScreen()
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/scatterfrost.ogg", 85, math.random(95, 105))
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
