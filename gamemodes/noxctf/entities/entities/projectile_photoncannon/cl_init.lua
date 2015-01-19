include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
end

local matBeam = Material("Effects/laser1")
local colBeam = Color(255, 255, 255)
function ENT:DrawTranslucent()
	local r, g, b, a = self:GetColorOld()
	colBeam.r = r
	colBeam.g = g
	colBeam.b = b

	local pos = self:GetPos()
	local dir = self:GetVelocity():GetNormalized() * -1
	local pos1 = pos + dir * 24
	local pos2 = pos + dir * 100
	local pos3 = pos + dir * 280

	render.SetMaterial(matBeam)
	render.StartBeam(4)
		render.AddBeam(pos, 2, 0, color_white)
		render.AddBeam(pos1, 16, 0.1, colBeam)
		render.AddBeam(pos2, 16, 0.6, colBeam)
		render.AddBeam(pos3, 2, 1, colBeam)
	render.EndBeam()
	render.StartBeam(4)
		render.AddBeam(pos, 1, 0, color_white)
		render.AddBeam(pos1, 8, 0.1, color_white)
		render.AddBeam(pos2, 8, 0.6, color_white)
		render.AddBeam(pos3, 1, 1, color_white)
	render.EndBeam()
end
