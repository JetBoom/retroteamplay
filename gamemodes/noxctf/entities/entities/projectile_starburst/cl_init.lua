include("shared.lua")

local matGlow = Material("sprites/light_glow02_add")

function ENT:Draw()
	render.SetMaterial(matGlow)
	local c = self:GetColor()
	render.DrawSprite(self:GetPos(), math.random(150, 180), math.random(150, 180), Color(c.r, c.g, c.b,255))
end

function ENT:DrawOffScreen()
	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)

	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("sprites/glow04_noz", vOffset)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(100, 150))
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 12))
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self:DrawShadow(false)
end

function ENT:Think()
	self:DrawOffScreen()
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/meteorfall.ogg", 85, math.Rand(95, 105))
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
