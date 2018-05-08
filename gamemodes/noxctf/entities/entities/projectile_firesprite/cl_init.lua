include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "ambient/fire/fire_big_loop1.wav")

	self.Col = self:GetColor()

	self.Rotation = math.Rand(0, 180)
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.77, 100 + math.sin(CurTime()))

	self.Emitter:SetPos(self:GetPos())

	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("ambient/fire/gascan_ignite1.wav")
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local vOffset = self:GetPos()

	local pos1 = self:GetPos()
	render.SetMaterial(matGlow)
	local size1 = math.sin(RealTime() * 35) * 33 + 64
	local size2 = math.cos(RealTime() * 38) * 21 + 64
	render.DrawSprite(pos1, size2, size1, self.Col)
	render.DrawSprite(pos1, size1, size2, color_white)
	
	local c = self.Col

	local emitter = self.Emitter
	for i=1, 2 do
		local particle = emitter:Add("sprites/light_glow02_add", pos1 + VectorRand():GetNormal() * math.Rand(2, 6))
		particle:SetDieTime(math.Rand(0.4, 0.6))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(11, 14))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
		particle:SetColor(c.r, c.g, c.b)

		particle = emitter:Add("effects/muzzleflash2", pos1)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(16, 32))
		particle:SetDieTime(math.Rand(0.7, 0.95))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(60)
		particle:SetStartSize(math.Rand(12, 15))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.8, 0.8))
		particle:SetColor(255, 200, 0)
		particle:SetAirResistance(10)
	end

	local ang = self:GetVelocity():Angle()
	ang:RotateAroundAxis(ang:Up(), 90)

	self.Rotation = self.Rotation + FrameTime() * 90
	if 360 < self.Rotation then
		self.Rotation = self.Rotation - 360
	end

	ang:RotateAroundAxis(ang:Right(), self.Rotation)

	local particle = emitter:Add("effects/fire_embers"..math.random(1,3), pos1 + ang:Forward() * 24)
	particle:SetDieTime(math.Rand(0.7, 0.9))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(10, 14))
	particle:SetEndSize(10)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-8, 8))
	particle:SetColor(c.r, c.g, c.b)

	particle = emitter:Add("effects/fire_embers"..math.random(1,3), pos1 + ang:Forward() * -24)
	particle:SetDieTime(math.Rand(0.7, 0.9))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(10, 14))
	particle:SetEndSize(10)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-8, 8))
	particle:SetColor(c.r, c.g, c.b)
end
