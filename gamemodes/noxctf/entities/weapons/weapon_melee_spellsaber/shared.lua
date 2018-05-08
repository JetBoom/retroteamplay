SWEP.Base = "weapon_tp_base_melee"
SWEP.HoldType = "melee"

SWEP.WeaponStatus = "weapon_spell_saber"

SWEP.MeleeDamage = 15
SWEP.MeleeDamageType = DMGTYPE_SLASHING
SWEP.MeleeRange = 40
SWEP.MeleeSize = 12
SWEP.MeleeSwingTime = 0.16
SWEP.MeleeCooldown = 0.75

SWEP.MeleeSwingSound = {sound = {Sound("nox/sword_miss.ogg")}, vol = 80, pitchLB = 80, pitchRB = 93}
SWEP.HitFleshSound = {sound = {Sound("nox/sword_hit.ogg")}, vol = 77, pitchLB = 98, pitchRB = 102}
SWEP.HitSound = {sound = {Sound("nox/sword_hit.ogg")}, vol = 77, pitchLB = 98, pitchRB = 102}

function SWEP:CanMeleeAttack(owner)
	return not owner.SwordThrow
end
