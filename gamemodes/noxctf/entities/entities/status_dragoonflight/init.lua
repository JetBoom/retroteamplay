AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	return owner:IsAnchored() or owner:IsCarrying()
end

function ENT:StatusOnRemove(owner, silent)
	owner:SetGravity(1)
end
