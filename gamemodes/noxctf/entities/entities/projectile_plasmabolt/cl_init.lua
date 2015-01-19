include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self:SetMaterial("models/shiny")
	self.Col = self:GetColor()
end

function ENT:Think()
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/plasmaturret_fire.ogg")
	end
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	self:DrawModel()

	local vOffset = self:GetPos()

	render.SetMaterial(matGlow)
	local rt = RealTime() * 3
	render.DrawSprite(vOffset, 100 + math.sin(rt) * 32, 100 + math.cos(rt * 1.25) * 80, self.Col)
	render.DrawSprite(vOffset, 100, 100, color_white)

	local col = self.Col
	for i=1, 2 do
		local particle = self.Emitter:Add("effects/stunstick", vOffset + VectorRand():GetNormal() * math.Rand(2, 14))
		particle:SetDieTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(32, 48))
		particle:SetEndSize(32)
		--particle:SetColor(col.r, col.g, col.b)
		particle:SetColor(60, 100, 255)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
	end
end
