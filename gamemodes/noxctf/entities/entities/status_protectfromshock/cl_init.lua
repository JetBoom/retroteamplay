include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 40)

	self.Rotation = 180
	self.NextEmit = 0
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	if ent:IsInvisible() then return end

	local pos = ent:GetPos() + Vector(0,0,36)

	local newrot = self.Rotation + FrameTime() * 4.2
	if newrot > 360 then newrot = newrot - 360 end
	self.Rotation = newrot

	render.SetMaterial(matGlow)
	local vOffset = Vector(32 * math.sin(self.Rotation), 32 * math.cos(self.Rotation), 32 * math.cos(self.Rotation))
	local pos1 = pos + vOffset
	render.DrawSprite(pos1, 32, 32, COLOR_CYAN)
	render.DrawSprite(pos1, 32, 32, COLOR_CYAN)
	local pos2 = pos - vOffset
	render.DrawSprite(pos2, 32, 32, COLOR_CYAN)
	render.DrawSprite(pos2, 32, 32, COLOR_CYAN)

	if 1 < EFFECT_QUALITY and self.NextEmit < CurTime() then
		self.NextEmit = self.NextEmit + 0.06 * EFFECT_IQUALITY
		local emitter = ParticleEmitter(pos)
		local vel = ent:GetVelocity()
		particle = emitter:Add("sprites/light_glow02_add", pos1 + VectorRand() * 6)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(0.3, 0.5))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(8, 10))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(50, 100, 255)
		particle:SetAirResistance(10)

		particle = emitter:Add("effects/spark", pos1 + VectorRand() * 6)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(0.4, 0.6))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(8, 10))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(50, 100, 255)
		particle:SetAirResistance(10)

		particle = emitter:Add("sprites/light_glow02_add", pos2 + VectorRand() * 6)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(0.3, 0.5))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(8, 10))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(50, 100, 255)
		particle:SetAirResistance(10)

		particle = emitter:Add("effects/spark", pos2 + VectorRand() * 6)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(0.4, 0.6))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(8, 10))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(50, 100, 255)
		particle:SetAirResistance(10)
	end
end
