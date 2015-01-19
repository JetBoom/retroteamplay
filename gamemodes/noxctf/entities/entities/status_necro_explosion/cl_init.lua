include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 32))
end

function ENT:OnRemove()
end

local matExpl = Material("effects/fire_cloud1")
function ENT:DrawTranslucent()
end
