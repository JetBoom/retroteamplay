include("shared.lua")

-- TODO: Model material.

function ENT:Draw()
	self:DrawModel()

	for i=1, 3 do
		local particle = self.Emitter:Add("effects/fire_cloud"..math.random(1, 2), self:GetPos() + VectorRand():GetNormal() * math.Rand(1, 8))
		particle:SetDieTime(math.Rand(0.7, 1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(4, 8))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
