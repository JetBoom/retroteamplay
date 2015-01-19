ENT.Base = "pickup"
ENT.Type = "anim"

ENT.Model = Model("models/weapons/w_pist_elite_dropped.mdl")
ENT.WeaponClass = "weapon_dualbattleaxe"

function ENT:CanUse(classname)
	return classname == "Gunslinger"
end
