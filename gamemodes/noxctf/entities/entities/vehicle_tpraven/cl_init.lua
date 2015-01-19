include("shared.lua")

ENT.NextEmit = 0

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(48, 64)

	self.ThrusterSound = CreateSound(self, "ambient/levels/citadel/zapper_loop2.wav")
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	self.ThrusterSound:PlayEx(0.95, 60 + math.min(1, self:GetVelocity():Length() / self.MaxSpeed) * 160)
end

function ENT:OnRemove()
	self.ThrusterSound:Stop()
	--self.Emitter:Finish()
end

function ENT:Draw()
	self:DrawModel()

	local Scale = math.min(self:GetVelocity():Length() / self.MaxSpeed, 1)
	if Scale < 0.05 or CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.02

	local fwd = self:GetForward()
	local pos = self:GetPos() + fwd * -64

	local particle = self.Emitter:Add("effects/fire_cloud"..math.random(1,2), pos)
	particle:SetDieTime(math.Rand(0.6, 0.75))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(Scale * 18)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-20, 20))

	local ang = self:GetForward():Angle()
	local grav = -130 * Scale * fwd
	ang:RotateAroundAxis(fwd, CurTime() * 120)
	for i=1, 3 do
		ang:RotateAroundAxis(fwd, 120)

		local particle = self.Emitter:Add("effects/fire_cloud"..math.random(2), pos)
		particle:SetVelocity(Scale * 100 * ang:Up())
		particle:SetGravity(grav)
		particle:SetDieTime(math.Rand(0.5, 0.65))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(Scale * 6)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
	end
end
