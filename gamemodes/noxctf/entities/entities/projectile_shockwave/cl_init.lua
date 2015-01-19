include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "ambient/explosions/exp2.wav")
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(1, 50)
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

local matGlow = "sprites/muzzleflash4"
function ENT:Draw()
	for i = 1, 5 do
		local particle = self.Emitter:Add(matGlow, self:GetPos() - Vector(0, 0, self.Radius))
		particle:SetVelocity(self:GetVelocity() + VectorRand() * 100)
		particle:SetDieTime(1)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(64)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetCollide(true)
		particle:SetBounce(0.2)
		particle:SetColor(255, 255, 0)
	end
end
