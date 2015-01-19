include("shared.lua")

ENT.NextEmit = 0

function ENT:Initialize()
	self.Seed = math.Rand(0, 10000)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(48, 64)

	self.ThrusterSound = CreateSound(self, "vehicles/APC/apc_start_loop3.wav")
	self.PilotGunSound = CreateSound(self, "weapons/airboat/airboat_gun_loop2.wav")
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())

	self.ThrusterSound:PlayEx(0.95, 120 + math.min(1, self:GetVelocity():Length() / self.MaxSpeed) * 120)

	if self:GetFiring() then
		self.PilotGunSound:PlayEx(0.9, 90 + math.sin(CurTime()))
	else
		self.PilotGunSound:Stop()
	end
end

function ENT:OnRemove()
	self.ThrusterSound:Stop()
	self.PilotGunSound:Stop()
	--self.Emitter:Finish()
end

local matFire = Material("effects/fire_cloud1")
function ENT:Draw()
	self:DrawModel()

	local Scale = math.min(self:GetVelocity():Length() / self.MaxSpeed, 1)
	if Scale < 0.05 or CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.02

	local pos = self:GetPos() + self:GetForward() * -64

	local particle = self.Emitter:Add("effects/fire_cloud"..math.random(2), pos)
	particle:SetDieTime(math.Rand(0.6, 0.75))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(Scale * 12)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-20, 20))

	render.SetMaterial(matFire)
	Scale = Scale + math.sin(RealTime() * 10) * 4 + 4
	render.DrawSprite(pos, Scale, Scale, color_white)
end
