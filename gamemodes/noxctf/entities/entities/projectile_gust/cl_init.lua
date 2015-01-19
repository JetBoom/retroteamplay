include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:GetOwner():EmitSound("ambient/wind/wind_hit"..math.random(1,3)..".wav")
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

function ENT:Draw()
	local particle = self.Emitter:Add("particle/SmokeStack", self:GetPos() + VectorRand():GetNormal() * math.Rand(0, 72))
	particle:SetVelocity(self:GetVelocity() * .5)
	particle:SetDieTime(1)
	particle:SetStartAlpha(200)
	particle:SetEndAlpha(0)
	particle:SetStartSize(10)
	particle:SetEndSize(30)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1, 1))
	particle:SetCollide(true)
	particle:SetBounce(0.2)
end
