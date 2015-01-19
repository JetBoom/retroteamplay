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

	local c = self:GetColor()
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 48, 48, Color(c.r, c.g, c.b))

	if RealTime() < self.NextEmit then return end
	self.NextEmit = RealTime() + 0.02 + EFFECT_IQUALITY * 0.01

	for i=1, 3 do
		local heading = VectorRand():GetNormal()
		local start = pos + heading * 4
		local vel = heading * 128

		local particle = self.Emitter:Add("effects/splash2", start)
		particle:SetDieTime(math.Rand(0.5, 0.75))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(12)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-6, 6))
		particle:SetColor(137, 207, 240)
		particle:SetVelocity(vel)
		particle:SetAirResistance(200)

		particle = self.Emitter:Add("effects/splash1", start)
		particle:SetDieTime(math.Rand(0.5, 0.75))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(16)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-14, 14))
		particle:SetColor(137, 207, 240)
		particle:SetVelocity(vel)
		particle:SetAirResistance(170)
	end
end
