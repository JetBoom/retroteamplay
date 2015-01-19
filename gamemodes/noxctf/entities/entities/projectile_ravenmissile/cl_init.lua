include("shared.lua")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(45, 55)

	self.FireSound = CreateSound(self, "Missile.Ignite")
end

function ENT:Think()
	self.FireSound:PlayEx(0.85, 135 + math.sin(CurTime()*5))
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	self.FireSound:Stop()
	--self.Emitter:Finish()
	util.ExplosiveForce(self:GetPos(), 170, 80, DMGTYPE_FIRE)
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local pos1 = self:GetPos()
	render.SetMaterial(matGlow)
	local col = self:GetColor()
	render.DrawSprite(pos1, 92, 92, col)
	render.DrawSprite(pos1, 64, 64, color_white)

	local r, g, b = col.r, col.g, col.b
	local emitter = self.Emitter
	for i=1, 2 do
		particle = emitter:Add("sprites/light_glow02_add", pos1 + VectorRand():GetNormalized() * math.Rand(2, 6))
		particle:SetDieTime(math.Rand(0.6, 1))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(28, 35))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
		particle:SetColor(r, g, b)

		particle = emitter:Add("effects/muzzleflash2", pos1)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(16, 32))
		particle:SetDieTime(math.Rand(1.6, 2))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(20, 28))
		particle:SetEndSize(16)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2.8, 2.8))
		particle:SetColor(r, g, b)
		particle:SetAirResistance(10)

		particle = emitter:Add("particles/smokey", pos1 + VectorRand():GetNormalized() * math.Rand(2, 14))
		particle:SetDieTime(math.Rand(1.6, 2))
		particle:SetStartAlpha(120)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(math.Rand(20, 28))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2.8, 2.8))
		particle:SetColor(45, 45, 45)
	end
end

function RLO()
	surface.PlaySound("ambient/alarms/klaxon1.wav")
	timer.SimpleEx(0.6, function() surface.PlaySound("ambient/alarms/klaxon1.wav") end)
	timer.SimpleEx(1.2, function() surface.PlaySound("ambient/alarms/klaxon1.wav") end)
end
