include("shared.lua")

util.PrecacheSound("WeaponDissolve.Charge")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self:DrawShadow(false)
	self.AmbientSound = CreateSound(self, "WeaponDissolve.Charge")
	self.AmbientSound:PlayEx(0.7, 100)
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(0.7, 100 + math.sin(RealTime()))
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local vOffset = self:GetPos()

	local pos1 = self:GetPos()
	render.SetMaterial(matGlow)
	local size1 = math.sin(RealTime() * 35) * 33 + 64
	local size2 = math.cos(RealTime() * 38) * 21 + 64
	render.DrawSprite(pos1, size1, size1, COLOR_CYAN)
	render.DrawSprite(pos1, size2, size2, color_white)

	local emitter = self.Emitter
	for i=1, 2 do
		local particle = emitter:Add("sprites/light_glow02_add", pos1 + VectorRand():GetNormal() * math.Rand(2, 6))
		particle:SetDieTime(math.Rand(0.3, 0.5))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(8, 10))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
		particle:SetColor(50, 100, 255)

		particle = emitter:Add("effects/spark", pos1)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(16, 32))
		particle:SetDieTime(math.Rand(0.6, 0.8))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(60)
		particle:SetStartSize(math.Rand(12, 15))
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.8, 0.8))
		particle:SetColor(50, 100, 255)
		particle:SetAirResistance(10)
	end
end
