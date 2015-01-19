AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:SetGravity(0.25)
end

function ENT:StatusOnRemove(owner, silent)
	owner:SetGravity(1)
end

function ENT:StatusShouldRemove(owner)
	return owner:IsAnchored() or owner:IsCarrying()
end
