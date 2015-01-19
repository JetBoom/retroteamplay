include("shared.lua")

function ENT:Initialize()
	self:SetModelScale(1.65, 0)
	self:SetRenderBounds(Vector(-160, -160, -160), Vector(160, 160, 160))
end

function ENT:Draw()
	self:SetModelScale(1.65, 0)
	self:DrawModel()
end
