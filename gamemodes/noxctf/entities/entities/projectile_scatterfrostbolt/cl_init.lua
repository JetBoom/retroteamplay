include("shared.lua")

local matGlow = Material("sprites/light_glow02_add")

function ENT:Draw()
	render.SetMaterial(matGlow)
	render.DrawSprite(self:GetPos(), math.random(8, 13), math.random(8, 13), color_white)
end

function ENT:DrawOffScreen()
	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("particle/snow", vOffset)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(8, 28))
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(100)
		particle:SetStartSize(math.Rand(5, 6))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(50, 60)
	self:DrawShadow(false)
end

function ENT:Think()
	self:DrawOffScreen()
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
