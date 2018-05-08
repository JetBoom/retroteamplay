include("shared.lua")

ENT.NextEmit = 0

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))
	self.AmbientSound = CreateSound(self, "ambient/fire/fire_med_loop1.wav")
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.4, 70)
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:Draw()
	if self.NextEmit > RealTime() then return end
	self.NextEmit = RealTime() + 0.1
	
	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	local particle = emitter:Add("effects/fire_cloud"..math.random(2), pos + Vector(0,0,-5))
	particle:SetDieTime(math.Rand(0.3,0.4))
	particle:SetGravity(Vector(math.random(-25, 25),math.random(-25, 25),math.random(200, 300)):GetNormal() * 300)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(100)
	particle:SetStartSize(12)
	particle:SetEndSize(4)
	particle:SetStartLength(10)
	particle:SetEndLength(18)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-20, 20))

	emitter:Finish()
end
