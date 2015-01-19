include("shared.lua")

local vecHalf = Vector(0.5, 0.5, 0.5)
function ENT:Draw()
	self:SetMaterial("models/shiny")
	self:SetModelScale(0.45, 0)
	self:DrawModel()
end
