SWEP.Base = "weapon_tp_base_melee"
SWEP.HoldType = "melee"

SWEP.WeaponStatus = "weapon_shortsword"

SWEP.MeleeDamage = 17
SWEP.MeleeDamageType = DMGTYPE_SLASHING
SWEP.MeleeRange = 40
SWEP.MeleeSize = 12
SWEP.MeleeSwingTime = 0.16
SWEP.MeleeCooldown = 0.68

SWEP.MeleeSwingSound = {sound = {Sound("nox/sword_miss.ogg")}, vol = 80, pitchLB = 105, pitchRB = 113}
SWEP.HitFleshSound = {
	sound = {
		Sound("ambient/machines/slicer1.wav"),
		Sound("ambient/machines/slicer2.wav"),
		Sound("ambient/machines/slicer3.wav"),
		Sound("ambient/machines/slicer4.wav")
		},
	vol = 77,
	pitchLB = 108,
	pitchRB = 112
}
SWEP.HitSound = {
	sound = {
		Sound("ambient/machines/slicer1.wav"),
		Sound("ambient/machines/slicer2.wav"),
		Sound("ambient/machines/slicer3.wav"),
		Sound("ambient/machines/slicer4.wav")
		},
	vol = 77,
	pitchLB = 108,
	pitchRB = 112
}

function SWEP:CanMeleeAttack(owner)
	return not owner:GetStatus("berserkercharge")
end