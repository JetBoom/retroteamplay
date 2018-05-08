AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Classes = {"Warrior"}
SWEP.Droppable = "pickup_longsword"
SWEP.DefensiveStance = 0


function SWEP:WeaponSpecialAttack2(owner)
	owner:GiveStatus("pacifism", 0.5)
	owner:GiveStatus("longsworddefensive", 0.5)
end

function SWEP:WeaponMeleeAttack(owner)
	if owner:GetStatus("longsworddefensive") then
		owner:RemoveStatus("longsworddefensive")
	end
end