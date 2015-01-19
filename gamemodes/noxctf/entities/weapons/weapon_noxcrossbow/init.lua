AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Classes = {"Conjurer", "Archer"}

function SWEP:Deploy()
	local owner = self.Owner
	owner:DrawViewModel(true)
	owner:RemoveStatus("weapon_*", false, true)
end
