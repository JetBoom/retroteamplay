AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.ProtectFromPoison = true
end

function ENT:StatusOnRemove(owner, silent)
	owner.ProtectFromPoison = false
end
