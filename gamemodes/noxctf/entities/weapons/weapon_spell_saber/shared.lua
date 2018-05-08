SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.HoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.68
SWEP.Primary.Damage = 15

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.NextAttack = 0
SWEP.ChargeAmmo = -9999

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:Precache()
	util.PrecacheSound("nox_short_sword/sword_miss.wav")
	util.PrecacheSound("nox_short_sword/sword_hit.wav")
	util.PrecacheSound("ambient/machines/slicer1.wav")
	util.PrecacheSound("ambient/machines/slicer2.wav")
	util.PrecacheSound("ambient/machines/slicer3.wav")
	util.PrecacheSound("ambient/machines/slicer4.wav")
	util.PrecacheSound("npc/roller/blade_out.wav")
end
