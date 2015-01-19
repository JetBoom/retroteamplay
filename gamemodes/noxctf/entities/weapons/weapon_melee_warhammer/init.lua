AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Classes = {"Paladin"}
SWEP.Droppable = "pickup_warhammer"

function SWEP:WeaponDeploy(owner)
	owner:GiveStatus("weapon_warhammer")
end

function SWEP:WeaponHolster(owner)
	owner:RemoveStatus("weapon_warhammer", false, true)
	return true
end

function SWEP:WeaponMeleeAttack(owner)
	owner:GlobalCooldown(2)
end

function SWEP:OnHitPlayer(pl, damage, hitpos)
	pl:TakeSpecialDamage(damage, self.MeleeDamageType, self.Owner, self, hitpos)

	pl:SetGroundEntity(NULL)
	local offset = self.Owner:GetAimVector() * self.XYForce
	offset.z = 0
	pl:SetVelocity(Vector(0, 0, self.ZForce) + offset)
end