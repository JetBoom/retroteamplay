include("shared.lua")

local matGlow = Material("sprites/light_glow02_add")

function ENT:Draw()
	render.SetMaterial(matGlow)
	render.DrawSprite(self:GetPos(), math.random(32, 48), math.random(32, 48), color_white)
end

function ENT:DrawOffScreen()
	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	local particle = emitter:Add("particle/snow", vOffset)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(14, 20))
	particle:SetEndSize(2)
	particle:SetRoll(math.Rand(0, 359))
	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("particle/snow", vOffset)
		particle:SetVelocity(self:GetVelocity() * -0.7 + VectorRand() * 100)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 12))
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.75, 0.75))
		particle:SetGravity(Vector(0,0,-100))
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self:DrawShadow(false)
end

function ENT:Think()
	self:DrawOffScreen()
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/scatterfrost.ogg", 85, math.Rand(95, 105))
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
