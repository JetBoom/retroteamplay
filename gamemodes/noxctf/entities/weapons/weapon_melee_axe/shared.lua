SWEP.Base = "weapon_tp_base_melee"
SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 30
SWEP.MeleeDamageType = DMGTYPE_SLASHING
SWEP.MeleeRange = 40
SWEP.MeleeSize = 14
SWEP.MeleeSwingTime = 0.26
SWEP.MeleeCooldown = 1.1

SWEP.MeleeSwingSound = {sound = {Sound("npc/zombie/claw_miss1.wav")}, vol = 80, pitchLB = 60, pitchRB = 70}
SWEP.HitFleshSound = {sound = {Sound("nox/sword_hit.ogg")}, vol = 80, pitchLB = 98, pitchRB = 102}
SWEP.HitSound = {sound = {Sound("nox/sword_hit.ogg")}, vol = 80, pitchLB = 80, pitchRB = 100}

function SWEP:CanMeleeAttack(owner)
	return not owner:GetStatus("berserkercharge")
end
