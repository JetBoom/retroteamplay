include('shared.lua')

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self:SetMaterial("models/shiny")
	local col = team.GetColor(self:GetSkin())
	self.Col = col
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local c = self.Col
	self:SetColor(Color(c.r, c.g, c.b, 255))
	self:DrawModel()

	local vOffset = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(vOffset, math.Rand(18, 25), math.Rand(18, 25), color_white)
	render.DrawSprite(vOffset, 32, 42, col)

	local emitter = self.Emitter
	for i=1, 4 do
		local particle = emitter:Add("sprites/light_glow02_add", vOffset)
		particle:SetVelocity(self:GetVelocity() * -0.25 - VectorRand() * math.random(-40, 40))
		particle:SetDieTime(1)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(100)
		particle:SetStartSize(math.Rand(8, 12))
		particle:SetEndSize(0)
		particle:SetColor(c.r, c.g, c.b)
		particle:SetRoll(math.Rand(0, 360))
	end
end
