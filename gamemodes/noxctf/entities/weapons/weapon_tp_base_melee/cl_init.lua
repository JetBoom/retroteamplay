include("shared.lua")

SWEP.PrintName = "Base"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

SWEP.Slot = 0
SWEP.SlotPos = 0
killicon.Add(GetSWEPClassName(SWEP.Folder), "spellicons/sword.png", color_white)

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "DefaultFontBold", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.DrawWorldModel = function() end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel
