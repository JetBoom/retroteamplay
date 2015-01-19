include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "ambient/fire/fire_big_loop1.wav")
	self.AmbientSound:Play()

	self.NextEmit = 0
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(1, 150)
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

local numSprites = 6
local rotSpeed = 60
local offset = 16
local flameSiz = 20
local glowSiz = 100
local matFire = "particles/flamelet2"
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local pos = self:GetPos()
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, glowSiz, glowSiz, Color(0, 255, 255))

	if RealTime() < self.NextEmit then return end
	self.NextEmit = RealTime() + 0.02 + EFFECT_IQUALITY * 0.01

	local dir = self:GetVelocity():GetNormal()
	local ang = dir:Angle()
	ang = ang:Up():Angle()
	ang:RotateAroundAxis(dir, RealTime() * rotSpeed)

	for i = 1, numSprites do
		local particle = self.Emitter:Add(matFire, pos + ang:Forward() * (offset + math.abs(4*math.sin(RealTime()*2))))
		particle:SetDieTime(math.Rand(.2, .4))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(flameSiz)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-6, 6))
		particle:SetColor(0, 255, 255)
		particle:SetVelocity(VectorRand():GetNormal() * 5)
		particle:SetAirResistance(200)
		ang:RotateAroundAxis(dir, 360/numSprites)
	end
end
