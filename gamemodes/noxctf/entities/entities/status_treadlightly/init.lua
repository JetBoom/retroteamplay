AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Slow(self:GetDieTime() - CurTime(), true)
end

function ENT:StatusOnRemove(owner)
	owner:RemoveStatus("slow_noeffect")
end
