ENT.Base = "pickup"
ENT.Type = "anim"

ENT.Model = Model("models/mixerman3d/weapons/axe01.mdl")
ENT.WeaponClass = "weapon_melee_axe"

function ENT:CanUse(classname)
	return classname == "Warrior"
end
