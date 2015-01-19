include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "ambient/levels/citadel/field_loop1.wav")
	self.AmbientSound:Play()

	self.NextEmit = 0
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local pos = self:GetPos()

	if RealTime() < self.NextEmit then return end
	self.NextEmit = RealTime() + 0.02 + EFFECT_IQUALITY * 0.01

	for i=1, 4 do
		local heading = VectorRand():GetNormal()
		local start = pos + heading * math.random(0, 32)
		local vel = self:GetVelocity()

		local particle = self.Emitter:Add("effects/fire_cloud"..math.random(1,2), start)
		particle:SetDieTime(math.Rand(0.5, 0.75))
		particle:SetStartAlpha(255)
		particle:SetStartSize(12)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-6, 6))
		particle:SetColor(10, 255, 10)
		particle:SetVelocity(vel)

		particle = self.Emitter:Add("particles/smokey", start)
		particle:SetDieTime(math.Rand(0.5, 0.75))
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-14, 14))
		particle:SetColor(10, 255, 10)
		particle:SetVelocity(vel)
	end
end
