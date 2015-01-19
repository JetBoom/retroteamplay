ENT.Base = "pickup"
ENT.Type = "anim"

ENT.Model = Model("models/weapons/w_pist_deagle.mdl")
ENT.WeaponClass = "weapon_ctfdeagle"

function ENT:CanUse(classname)
	return classname == "Gunslinger"
end
