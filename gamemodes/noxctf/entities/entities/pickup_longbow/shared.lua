ENT.Base = "pickup"
ENT.Type = "anim"

ENT.Model = Model("models/w_nox_longbow.mdl")
ENT.WeaponClass = "weapon_longbow"

function ENT:CanUse(classname)
	return classname == "Conjurer" or classname == "Archer"
end
