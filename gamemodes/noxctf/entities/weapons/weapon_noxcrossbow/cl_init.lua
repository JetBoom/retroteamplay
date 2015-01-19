include("shared.lua")

SWEP.PrintName = "Crossbow"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.MaxAmmo = 0

killicon.AddFont(GetSWEPClassName(SWEP.Folder), "HL2MPTypeDeath", "1", color_white)
killicon.AddFont("projectile_crossbowbolt", "HL2MPTypeDeath", "1", color_white)

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "teamplay", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SWEP:DrawWorldModel()
	if self.Owner and self.Owner:IsValid() and self.Owner:IsInvisible() then return end
	self:DrawModel()
end
