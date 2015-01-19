SWEP.Base = "weapon_tp_base_melee"
SWEP.HoldType = "melee"

SWEP.WeaponStatus = "weapon_scepter"

SWEP.MeleeDamage = 13
SWEP.MeleeDamageType = DMGTYPE_BASHING
SWEP.MeleeRange = 40
SWEP.MeleeSize = 11
SWEP.MeleeSwingTime = 0.16
SWEP.MeleeCooldown = 0.9

SWEP.ProjectileSpeed = 500
SWEP.Special2Cooldown = 1.2

SWEP.MeleeSwingSound = {sound = {Sound("npc/zombie/claw_miss1.wav")}, vol = 80, pitchLB = 110, pitchRB = 130}
SWEP.HitFleshSound = {sound = {Sound("weapons/hammer/morrowind_hammer_hit.wav")}, vol = 80, pitchLB = 110, pitchRB = 130}
SWEP.HitSound = {sound = {Sound("weapons/hammer/morrowind_hammer_hit.wav")}, vol = 80, pitchLB = 100, pitchRB = 110}

SWEP.Special2Animation = "ALCH_GESTURE_1"

function SWEP:CanSpecialAttack2(owner)
	return true
end
