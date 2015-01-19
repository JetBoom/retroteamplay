AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Classes = {"Warrior"}
SWEP.Droppable = "pickup_axe"

function SWEP:WeaponDeploy(owner)
	owner:GiveStatus("weapon_axe")
end

function SWEP:WeaponHolster(owner)
	owner:RemoveStatus("weapon_axe", false, true)
	return true
end