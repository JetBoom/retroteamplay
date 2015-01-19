include("shared.lua")

local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(255, 255, 255, 255)
function ENT:Draw()
	local mypos = self:GetPos()
	local c = self:GetColor()
	local newa = math.Clamp(255 - mypos:Distance(EyePos()) * 0.4, 1, 255)
	local radius = 8 + math.cos(CurTime() * 10) * 4

	colGlow.r = c.r
	colGlow.g = c.g
	colGlow.b = c.b
	colGlow.a = newa

	self:SetColor(Color(c.r, c.g, c.b, newa))
	self:DrawModel()

	render.SetMaterial(matGlow)
	render.DrawSprite(mypos + self:GetUp() * 8, radius, radius, colGlow)
end
