ENT.Type = "anim"

ENT.Model = Model("models/weapons/w_crossbow.mdl")
ENT.WeaponClass = "weapon_noxcrossbow"

function ENT:CanUse(classname)
	return classname == "Conjurer" or classname == "Archer"
end
