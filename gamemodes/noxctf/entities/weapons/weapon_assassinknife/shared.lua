SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 15
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.65

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 10
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

function SWEP:Reload()
	return false
end

function SWEP:Precache()
	util.PrecacheSound("weapons/knife/knife_hit1.wav")
	util.PrecacheSound("weapons/knife/knife_hit2.wav")
	util.PrecacheSound("weapons/knife/knife_hit3.wav")
	util.PrecacheSound("weapons/knife/knife_hit4.wav")
	util.PrecacheSound("weapons/knife/knife_slash1.wav")
	util.PrecacheSound("weapons/knife/knife_slash2.wav")
	util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
	util.PrecacheSound("weapons/knife/knife_stab.wav")
end
