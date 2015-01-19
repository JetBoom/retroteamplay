include("shared.lua")

util.PrecacheSound("ambient/energy/force_field_loop1.wav")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 48)
	self:DrawShadow(false)
	self.AmbientSound = CreateSound(self, "ambient/energy/force_field_loop1.wav")
	self.AmbientSound:PlayEx(0.7, 100)
	self.Rotation = math.Rand(0, 180)
	self.Dir = math.random(1, 2) == 1
	self.Col = self:GetColor()
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	if MySelf:IsValid() then
		self.AmbientSound:PlayEx(0.7, math.max(120, 230 - MySelf:GetShootPos():Distance(self:GetPos()) * 0.12))
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
local matGlow2 = Material("effects/yellowflare")
function ENT:DrawTranslucent()
	local vOffset = self:GetPos()

	local pos1 = self:GetPos()
	render.SetMaterial(matGlow)
	local size1 = math.sin(RealTime() * 15) * 20 + 80
	local size2 = math.cos(RealTime() * 23) * 30 + 80
	render.DrawSprite(pos1, size1 * 0.6, size1 * 0.6, color_white)
	local currentheading = self:GetVelocity():GetNormal()
	local currentang = currentheading:Angle()
	currentang:RotateAroundAxis(currentheading, self.Rotation)
	if self.Dir then
		self.Rotation = self.Rotation + FrameTime() * 430
		if 360 < self.Rotation then self.Rotation = self.Rotation - 360 end
	else
		self.Rotation = self.Rotation - FrameTime() * 430
		if self.Rotation < 0 then self.Rotation = self.Rotation + 360 end
	end
	local up = currentang:Up()
	render.SetMaterial(matGlow2)
	local c = self.Col
	render.DrawSprite(pos1 + up * 16, size2, size1, col)
	render.DrawSprite(pos1 + up * -16, size1, size2, col)

	local emitter = self.Emitter
	local heading = VectorRand():GetNormal()
	local particle = emitter:Add("effects/yellowflare", pos1 + heading * 16 + up * 16)
	particle:SetDieTime(math.Rand(0.3, 0.5))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(200)
	particle:SetStartSize(math.Rand(10, 14))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-4, 4))
	particle:SetVelocity(heading * -32)
	particle:SetAirResistance(10)
	if math.random(1, 2) == 1 then
		particle:SetColor(c.r, c.g, c.b)
	end

	local particle = emitter:Add("effects/yellowflare", pos1 + heading * 16 + up * -16)
	particle:SetDieTime(math.Rand(0.3, 0.5))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(200)
	particle:SetStartSize(math.Rand(10, 14))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-4, 4))
	particle:SetVelocity(heading * -32)
	particle:SetAirResistance(10)
	if math.random(1, 2) == 1 then
		particle:SetColor(c.r, c.g, c.b)
	end

	local particle = emitter:Add("effects/spark", pos1)
	particle:SetVelocity(VectorRand():GetNormal() * math.Rand(16, 32))
	particle:SetDieTime(math.Rand(0.9, 1.2))
	particle:SetStartAlpha(230)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(6, 9))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-5.8, 5.8))
	particle:SetAirResistance(5)
	particle:SetColor(20, 230, 255)
end
