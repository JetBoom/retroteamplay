include("shared.lua")

local matGlow = Material("sprites/orangecore1")

function ENT:Draw()
	self:SetModelScale(0.4, 0)
	render.SetMaterial(matGlow)
	render.DrawSprite(self:GetPos(), math.random(17, 22), math.random(17, 22), self:GetColor())
end


function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "ambient/levels/labs/machine_ring_resonance_loop1.wav")
end

function ENT:Think()
	self.AmbientSound:PlayEx(80, 80)
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end
