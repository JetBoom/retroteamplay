include("shared.lua")

SWEP.PrintName = "Staff of Discharge"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

SWEP.Slot = 0
SWEP.SlotPos = 2

function SWEP:Initialize()
	self:SetWeaponHoldType("melee2")
end

function SWEP:Think()
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "teamplay", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SWEP:DrawHUD()
	local charges = math.floor(MySelf:GetAmmoCount(self.ChargeAmmo) / self.AmmoPerCharge)
	local maxcharges = self.MaxMana / self.AmmoPerCharge
	draw.RoundedBox(8, 0, h*0.39, 32, h*0.16, color_black_alpha180)
	draw.SimpleText(charges, "DefaultBold", 25, h*0.4, COLOR_RED, TEXT_ALIGN_RIGHT)

	local chargeheight = math.floor(h*0.12 / maxcharges)
	local y = h*0.42
	local xend = 28
	for i=1, charges do
		surface.SetDrawColor(0, 255, 255, 255)
		surface.DrawRect(2, y, xend, chargeheight)
		y = y + chargeheight + 2
	end
end

SWEP.DrawWorldModel = SWEP.Think
SWEP.DrawWorldModelTranslucent = SWEP.Think
