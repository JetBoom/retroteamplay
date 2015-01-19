include("shared.lua")

function ENT:Initialize()
	self:SetModelScale(0.5, 0)
end

function ENT:Think()
	self:SetModelScale(0.5, 0)
end

local matShiny = Material("models/shiny")
local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(0, 127.5, 255, 255)
function ENT:DrawTranslucent()
	local brightness = self:GetMana() / self:GetMaxMana()
	local size = brightness * (250 + math.sin((RealTime() + self:EntIndex()) * 8) * 32)
	local pos = self:GetPos() + Vector(0, 0, 2)
	colGlow.a = brightness * 255

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size * 0.75, size * 1.25, colGlow)
	render.DrawQuadEasy(pos, self:GetUp(), size, size, colGlow, RealTime() * 90)

	cam.Start3D(EyePos(), EyeAngles())
		render.SetColorModulation(0, brightness / 2, brightness)
		render.MaterialOverride(matShiny)

			self:DrawModel()

		render.MaterialOverride(0)
		render.SetColorModulation(1, 1, 1)
	cam.End3D()
end
