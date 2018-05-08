AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	return owner:GetPlayerClassTable().PoisonImmune
end

function ENT:StatusThink(owner)
	owner:TakeSpecialDamage(1.6, DMGTYPE_POISON, self.Attacker or self, self)

	self:NextThink(CurTime() + 0.5)
	return true
end
