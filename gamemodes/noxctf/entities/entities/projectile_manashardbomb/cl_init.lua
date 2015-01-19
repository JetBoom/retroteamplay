include("shared.lua")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(35, 40)
	self:DrawShadow(false)
	self.Col = self:GetColor()
end

function ENT:Think()
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

local matGlow = Material("effects/yellowflare")
function ENT:Draw()
	local c = self.Col
	
	render.SetMaterial(matGlow)
	local vOffset = self:GetPos()
	render.DrawSprite(vOffset, math.random(32, 48), math.random(32, 48), col)

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	local particle = emitter:Add("effects/yellowflare", vOffset)
	particle:SetDieTime(0.1)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(14, 20))
	particle:SetEndSize(2)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-50, 50))
	particle:SetColor(c.r, c.g, c.b)
	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("sprites/glow04_noz", vOffset)
		particle:SetVelocity(self:GetVelocity() * -0.7 + VectorRand() * 100)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 12))
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5.75, 5.75))
		particle:SetGravity(Vector(0,0,-50))
		particle:SetColor(c.r, c.g, c.b)
	end
end
