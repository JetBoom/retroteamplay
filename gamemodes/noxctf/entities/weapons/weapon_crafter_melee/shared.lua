SWEP.ViewModel = "models/weapons/v_spanner/v_spanner.mdl"
SWEP.WorldModel = "models/weapons/w_spanner.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 5
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 2
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Reload()
	return false
end

function SWEP:Precache()
	util.PrecacheSound("buttons/lever1.wav")
	util.PrecacheSound("buttons/lever2.wav")
	util.PrecacheSound("buttons/lever3.wav")
	util.PrecacheSound("buttons/lever4.wav")
	util.PrecacheSound("buttons/lever5.wav")
	util.PrecacheSound("buttons/lever6.wav")
	util.PrecacheSound("buttons/lever7.wav")
	util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
	util.PrecacheSound("weapons/melee/wrench/wrench_hit-01.wav")
	util.PrecacheSound("weapons/melee/wrench/wrench_hit-02.wav")
	util.PrecacheSound("weapons/melee/wrench/wrench_hit-03.wav")
	util.PrecacheSound("weapons/melee/wrench/wrench_hit-04.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet1.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet2.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet3.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet4.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet5.wav")
end
