AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	if not bExists then
		RestoreSpeed(pPlayer)
	end
end

function ENT:StatusOnRemove(owner)
	RestoreSpeed(owner)
end
