include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 48)

	self:SetColor(Color(255, 125, 75, 255))
	self:SetMaterial("models/props_wasteland/rockcliff04a")

	self:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))
	self.NextEmit = 0
	self.AmbientSound = CreateSound(self, "weapons/rpg/rocket1.wav")
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.72, math.max(80, math.min(255, self:GetVelocity():Length() * 0.3)))

	self.Emitter:SetPos(self:GetPos())

	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/fireballwhoosh.ogg", 85, math.random(95, 105))
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

local matFire = Material("sprites/light_glow02_add")
local matHeatWave = Material("sprites/heatwave")
function ENT:Draw()
	self:SetModelScale(0.75, 0)
	self:DrawModel()

	local rt = RealTime()

	local vPos = self:GetPos()
	local siz = math.abs(math.sin(rt * 10)) * 32 + 32
	render.SetMaterial(matFire)
	render.DrawSprite(vPos, siz, siz, color_white)

	render.SetMaterial(matHeatWave)
	render.DrawSprite(vPos, 140, 140, color_white)

	if RealTime() < self.NextEmit then return end
	self.NextEmit = RealTime() + 0.03 * EFFECT_IQUALITY

	local emitter = self.Emitter
	emitter:SetPos(vPos)

	local particle = emitter:Add("particles/smokey", vPos)
	particle:SetDieTime(0.75)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(0)
	particle:SetStartSize(4)
	particle:SetEndSize(math.Rand(24, 32))
	particle:SetColor(math.Rand(20, 30), math.Rand(20, 30), math.Rand(20, 30))
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-21, 21))

	local vel = self:GetVelocity()
	local negvel = vel * -2
	local ang = vel:Angle()
	ang:RotateAroundAxis(ang:Forward(), RealTime() * 400)

	local particle = emitter:Add("sprites/flamelet"..math.random(1,4), vPos)
	particle:SetVelocity(negvel + ang:Up() * 700)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(100)
	particle:SetStartSize(math.Rand(10, 34))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-41, 41))
	particle:SetAirResistance(1000)

	ang:RotateAroundAxis(ang:Forward(), 120)

	local particle = emitter:Add("sprites/flamelet"..math.random(1,4), vPos)
	particle:SetVelocity(negvel + ang:Up() * 700)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(100)
	particle:SetStartSize(math.Rand(10, 34))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-41, 41))
	particle:SetAirResistance(1000)

	ang:RotateAroundAxis(ang:Forward(), 120)

	local particle = emitter:Add("sprites/flamelet"..math.random(1,4), vPos)
	particle:SetVelocity(negvel + ang:Up() * 700)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(100)
	particle:SetStartSize(math.Rand(10, 34))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-41, 41))
	particle:SetAirResistance(1000)
end
