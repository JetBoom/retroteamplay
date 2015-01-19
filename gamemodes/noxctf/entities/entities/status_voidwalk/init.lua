AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	return owner:IsAnchored()
end

function ENT:StatusOnRemove(owner)
	owner:SetLocalVelocity(Vector(0,0,0))
end