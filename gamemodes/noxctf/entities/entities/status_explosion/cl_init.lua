include("shared.lua")

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 32))

	self.Rotation = 0
end

local matExpl = Material("effects/fire_cloud1")
function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if owner:IsInvisible() then return end

	local pos = owner:GetPos() + Vector(0,0,2)

	render.SetMaterial(matExpl)
	self.Rotation = self.Rotation + FrameTime() * 150
	if self.Rotation > 360 then self.Rotation = self.Rotation - 360 end
	render.DrawQuadEasy(pos, Vector(0, 0, 1), 80, 80, color_white, self.Rotation)
	render.DrawQuadEasy(pos, Vector(0, 0, -1), 80, 80, color_white, self.Rotation)
end
