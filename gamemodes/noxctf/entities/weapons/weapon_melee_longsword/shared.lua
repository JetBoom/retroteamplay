SWEP.Base = "weapon_tp_base_melee"
SWEP.HoldType = "melee2"

SWEP.WeaponStatus = "weapon_longsword"

SWEP.MeleeDamage = 25
SWEP.MeleeDamageType = DMGTYPE_SLASHING
SWEP.MeleeRange = 44
SWEP.MeleeSize = 12
SWEP.MeleeSwingTime = 0.26
SWEP.MeleeCooldown = 0.78
SWEP.Special2Cooldown = 2

SWEP.MeleeSwingSound = {sound = {Sound("nox/sword_miss.ogg")}, vol = 80, pitchLB = 80, pitchRB = 93}
SWEP.HitFleshSound = {sound = {Sound("nox/sword_hit.ogg")}, vol = 77, pitchLB = 98, pitchRB = 102}
SWEP.HitSound = {sound = {Sound("nox/sword_hit.ogg")}, vol = 77, pitchLB = 98, pitchRB = 102}

function SWEP:CanMeleeAttack(owner)
	return not owner:GetStatus("berserkercharge")
end

function SWEP:CanSpecialAttack2(owner)
	return not owner:GetStatus("berserkercharge")
end
