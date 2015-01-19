include("shared.lua")

SWEP.PrintName = "Weapon"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	-- We don't draw anything because you can only have one weapon anyway.
end
