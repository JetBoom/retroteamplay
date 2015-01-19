include("shared.lua")

function ENT:Initialize()
	self:SetMaterial("models/shiny")
	self:SetModelScale(2.6, 0)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.Col = team.GetColor(self:GetSkin()) or color_white
end

function ENT:Think()
	self:SetModelScale(2.6, 0)
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/forceofnature.ogg")
	end
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local col = self.Col
	local r,g,b = col.r, col.g, col.b
	render.SetColorModulation(r / 255, g / 255, b / 255)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)

	local vOffset = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(vOffset, 64, 64, col)

	local emitter = self.Emitter
	for i=1, 6 do
		local particle = emitter:Add("sprites/light_glow02_add", vOffset)
		particle:SetVelocity(self:GetVelocity() * -0.25 - Vector(math.random(-75, 75), math.random(-75, 75), math.random(-75, 75)))
		particle:SetDieTime(1)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(200)
		particle:SetStartSize(math.Rand(12, 16))
		particle:SetEndSize(2)
		particle:SetColor(r, g, b)
		particle:SetRoll(math.Rand(0, 360))
	end
end
