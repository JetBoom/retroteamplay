include("shared.lua")

SWEP.PrintName = "Scripted Weapon"
SWEP.Slot = 0
SWEP.SlotPos = 10
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "DefaultBold", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SWEP:DrawWorldModel()
	if self.Owner and self.Owner:IsValid() and self.Owner:IsInvisible() then return end
	self:DrawModel()
end
