AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:SetLocalVelocity(Vector()*0)
	pPlayer:Freeze(true)
end

function ENT:StatusOnRemove(owner)
	owner:Freeze(false)
end
