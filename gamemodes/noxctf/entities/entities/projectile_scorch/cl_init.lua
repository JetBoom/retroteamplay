include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 36)

	self.FireSound = CreateSound(self, "ambient/fire/fire_med_loop1.wav")

	self.Col = self:GetColor()
end

function ENT:Think()
	self.FireSound:PlayEx(0.85, 135 + math.sin(CurTime()*5))
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	self.FireSound:Stop()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local vOffset = self:GetPos()

	local pos1 = self:GetPos()
	render.SetMaterial(matGlow)
	local c = self.Col

	render.DrawSprite(pos1, 290, 48, self.Col)
	render.DrawSprite(pos1, 128, 128, color_white)
	render.DrawSprite(pos1 + Vector(0,0,math.sin(RealTime() * 32) * 9), 330, 48, self.Col)

	local emitter = self.Emitter
	particle = emitter:Add("sprites/flamelet"..math.random(1, 4), pos1 + VectorRand():GetNormal() * math.Rand(30, 34))
	particle:SetDieTime(math.Rand(0.6, 1))
	particle:SetStartAlpha(230)
	particle:SetEndAlpha(50)
	particle:SetStartSize(math.Rand(32, 48))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-8, 8))
	particle:SetColor(c.r, c.g, c.b)

	particle = emitter:Add("effects/muzzleflash2", pos1)
	particle:SetVelocity(VectorRand():GetNormal() * math.Rand(32, 48))
	particle:SetDieTime(math.Rand(1, 1.2))
	particle:SetStartAlpha(230)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(20, 28))
	particle:SetEndSize(16)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-9, 9))
end
