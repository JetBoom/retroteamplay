include("shared.lua")

local matGlow = Material("sprites/light_glow02_add")

ENT.MaxTraceHUDPaintLength = 512

function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos() + self:GetUp() * 28
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 32, 32, COLOR_ORANGE)
	render.DrawSprite(pos, 32, 32, COLOR_RED)

	if EFFECT_QUALITY < 2 then return end

	local emitter = self.Emitter
	for i=1, 2 do
		local particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand() * 6)
		particle:SetVelocity(VectorRand() * 12)
		particle:SetDieTime(math.Rand(0.3, 0.5))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.random(8, 10))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(255, 180, 30)
		particle:SetAirResistance(10)
	end
end

function ENT:TraceHUDPaint()
	local c = self:GetColor()
	if c.a == 0 then return end
	draw.SimpleText("Staff of Magic Arrow", "teamplay", w*0.5, h*0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)
	local classname = MySelf:GetPlayerClassTable().Name
	if classname == "Wizard" or classname == "Conjurer" then
		local _, hhh = surface.GetTextSize("A")
		draw.SimpleText("(Pick up with USE key)", "teamplay", w*0.5, h*0.5 + hhh, color_white, TEXT_ALIGN_CENTER)
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
end

function ENT:Think()
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
