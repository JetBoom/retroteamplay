SWEP.ViewModel = "models/nox_longbow_v2.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType("smg")
end

function SWEP:Think()

end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:GetViewModelPosition(pos, ang)
	pos = pos + (ang:Forward()*6 + ang:Right()*5)

	-- Future purposes or not
	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Right(), 0)
	ang:RotateAroundAxis(ang:Forward(), -5)

	return pos, ang
end

function SWEP:CanPrimaryAttack()
	return self.NextAttack <= CurTime() and not self.Fidget and not self.Drawing
end
