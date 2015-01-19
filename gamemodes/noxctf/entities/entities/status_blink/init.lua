AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.CounterSpell = COUNTERSPELL_DESTROY

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Stun(self:GetDieTime() - CurTime(), true, true)
end

function ENT:StatusOnRemove(owner, silent)
	if not silent and self:GetDieTime() <= CurTime() and owner:Alive() then
		CreateTeleportCloud(owner:GetPos(), (GAMEMODE:PlayerSelectSpawn(owner) or owner):GetPos(), owner)
	end
end