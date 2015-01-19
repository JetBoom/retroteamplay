AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	return owner:WaterLevel() > 0
end

function ENT:StatusThink(owner)
	owner:TakeSpecialDamage(1, DMGTYPE_FIRE, self.Inflictor or self, self)

	self:NextThink(CurTime() + 0.3)
	return true
end