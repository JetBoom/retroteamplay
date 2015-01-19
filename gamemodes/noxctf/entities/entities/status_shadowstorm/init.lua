AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:RemoveAllStatus(false, false, true)
end

function ENT:StatusShouldRemove(owner)
	local ent = self:GetEnt()
	return not ent:IsValid() or owner:GetCenter():Distance(ent:GetPos()) > ent.Radius
end