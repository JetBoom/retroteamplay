AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Classes = {"Warrior"}
SWEP.Droppable = "pickup_longsword"
SWEP.DefensiveStance = 0

function SWEP:WeaponInitialize()
	hook.Add("PlayerHurt", self, self.PlayerHurt)
end

function SWEP:PlayerHurt(pl, attacker, healthremaining, damage)
	if pl ~= self:GetOwner() then return end

	if damage > 0 and not pl:StatusWeaponHook("ShouldRemainInvisible") then
		self:GetOwner():RemoveStatus("longsworddefensive")
		self.DefensiveStance = CurTime() + 1
	end
end

function SWEP:WeaponThink(owner)

	if owner:GetVelocity():Length() > 20 then
		self.DefensiveStance = CurTime() + 0.5
	end
	
	if not owner:GetStatus("longsworddefensive") and not owner:InVehicle() and CurTime() > self.DefensiveStance and not owner:IsFrozen() and not owner:GetStatus("stun") and not owner:GetStatus("stun_noeffect") then
		owner:GiveStatus("longsworddefensive")
	end

end

function SWEP:WeaponMeleeAttack(owner)
	owner:RemoveStatus("longsworddefensive")
	self.DefensiveStance = CurTime() + 1
end