SWEP.ViewModel = "models/morrowind/magnus/staff/v_magnus_staff.mdl"
SWEP.WorldModel = "models/morrowind/magnus/staff/w_magnus_staff.mdl"

SWEP.HoldType = "slam"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.3

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

SWEP.NextAttack = -10
SWEP.MaxMana = 60
SWEP.ChargeAmmo = 1
SWEP.AmmoPerCharge = 15

SWEP.Droppable = "pickup_lightningstaff"

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

