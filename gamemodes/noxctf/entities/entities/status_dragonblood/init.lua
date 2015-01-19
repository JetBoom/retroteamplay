AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusThink(owner)
	if not owner:GetStatus("dragonbloodchannel") then
		GAMEMODE:PlayerHeal(owner, owner, 1)
	end
	
	self:NextThink(CurTime() + 0.2)
	return true
end
