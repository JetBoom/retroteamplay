include("shared.lua")

SWEP.PrintName = "Zombie"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:Think()
end

SWEP.DrawWorldModel = SWEP.Think
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "DefaultBold", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
