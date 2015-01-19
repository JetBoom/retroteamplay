AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.NextHeal = 0

function ENT:PlayerSet(pPlayer, bExists)
	self.HealLeft = self.TotalHeal
end

function ENT:StatusShouldRemove(owner)
	return self.HealLeft <= 0
end

function ENT:StatusThink(owner)
	local ct = CurTime()
	if self.NextHeal <= ct then
		self.HealLeft = self.HealLeft - 1
		self.NextHeal = ct + self.LifeTime / self.TotalHeal

		local pl = self:GetParent()
		if pl:IsValid() then
			GAMEMODE:PlayerHeal(pl, self.Owner, 1)
		end
	end
	
	self:NextThink(ct)
	return true
end
