include("shared.lua")

-- TODO: Model material.

function ENT:Draw()
	self:SetMaterial("models/flesh")
	self:DrawModel()

	if self.NextEmit <= RealTime() then
		self.NextEmit = RealTime() + 0.02 + EFFECT_IQUALITY * 0.02
		local particle = self.Emitter:Add("effects/blood", self:GetPos())
		particle:SetDieTime(math.Rand(0.6, 0.85))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(16, 20))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(255, 50, 50)
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(35, 45)

	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))

	self.NextEmit = 0
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
