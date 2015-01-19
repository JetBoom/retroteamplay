include("shared.lua")

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	local owner = self:GetOwner()
	owner:ManipulateBonePosition(owner:LookupBone("valvebiped.bip01_spine4"), Vector(-5,0,0))
	owner:ManipulateBonePosition(owner:LookupBone("valvebiped.bip01_spine2"), Vector(-5,0,0))
end

function ENT:StatusOnRemove(owner)
	owner:ManipulateBonePosition(owner:LookupBone("valvebiped.bip01_spine4"), Vector(0,0,0))
	owner:ManipulateBonePosition(owner:LookupBone("valvebiped.bip01_spine2"), Vector(0,0,0))
end
