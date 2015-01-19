ENT.Base = "pickup"
ENT.Type = "anim"

ENT.Model = Model("models/weapons/w_pist_usp.mdl")
ENT.WeaponClass = "weapon_battleaxe"

function ENT:CanUse(classname)
	return classname == "Gunslinger"
end
