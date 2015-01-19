AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	return owner:WaterLevel() > 0 or owner:GetStatus("salamanderskin")
end

function ENT:StatusThink(owner)
	owner:TakeSpecialDamage(2, DMGTYPE_FIRE, self.Inflictor or self, self)

	self:NextThink(CurTime() + 0.25)
	return true
end