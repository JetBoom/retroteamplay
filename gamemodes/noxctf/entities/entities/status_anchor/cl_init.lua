include("shared.lua")

local matAnchor = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if not owner:IsVisibleTarget(owner) then return end

	local pos = owner:GetPos() + Vector(0, 0, 2)
	local rotation = CurTime() * 200 % 360
	local size = rotation * 0.5

	render.SetMaterial(matAnchor)
	render.DrawQuadEasy(pos, Vector(0, 0, 1), size, size, color_white, rotation)
	render.DrawQuadEasy(pos, Vector(0, 0, -1), size, size, color_white, rotation)
end