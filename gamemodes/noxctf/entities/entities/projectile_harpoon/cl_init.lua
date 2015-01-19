include("shared.lua")

function ENT:Initialize()
	self:SetModelScale(.65, 0)
end

function ENT:Draw()
	self:SetModelScale(.65, 0)
	self:DrawModel()
end
