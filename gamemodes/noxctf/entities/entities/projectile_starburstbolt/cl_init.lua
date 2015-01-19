include("shared.lua")

local matGlow = Material("sprites/glow04_noz")

function ENT:Draw()
	render.SetMaterial(matGlow)
	
	local c = self:GetColor()
	render.DrawSprite(self:GetPos(), math.random(58, 64), math.random(58, 64), Color(c.r, c.g, c.b, 255))
end

function ENT:DrawOffScreen()
	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("sprites/glow04_noz", vOffset + VectorRand():GetNormal() * math.Rand(6, 18))
		particle:SetDieTime(math.Rand(1, 1.4))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(100)
		particle:SetStartSize(math.Rand(5, 6))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self:DrawShadow(false)
end

function ENT:Think()
	self:DrawOffScreen()
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
