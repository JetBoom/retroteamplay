AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self.Freezer = {}
end

function ENT:StatusThink(owner)
	owner:TakeSpecialDamage(1, DMGTYPE_COLD, self.Inflictor or self, self)
	self.Freezer[owner] = (self.Freezer[owner] or 0) + 1
	if self.Freezer[owner] == 20 then
		owner:SoftFreeze(2)
		owner:EmitSound("physics/glass/glass_impact_bullet"..math.random(1,4)..".wav", 60, 100)
	end
	self:NextThink(CurTime() + 0.2)
	return true
end