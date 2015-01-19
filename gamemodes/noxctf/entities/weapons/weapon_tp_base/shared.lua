SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Delay = 1
SWEP.SecondaryDelay = 1

SWEP.HoldType = "melee"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Reload()
end

function SWEP:Holster()
	if SERVER then
		self:RemoveWearables()
	end

	return true
end

function SWEP:Deploy()
	if SERVER then
		self:AddWearables()
	end

	return true
end

function SWEP:CanPrimaryAttack()
	return self:GetNextPrimaryFire() <= CurTime()
end

function SWEP:CanSecondaryAttack()
	return false --self:GetNextSecondaryFire() <= CurTime()
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self.Delay)
	self:SetNextSecondaryFire(math.max(self:GetNextSecondaryFire(), CurTime() + self.Delay))

	if self.PrimarySound then
		self:EmitSound(self.PrimarySound)
	end

	self.Owner:DoAttackEvent()
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end

	self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + self.SecondaryDelay))
	self:SetNextSecondaryFire(CurTime() + self.SecondaryDelay)

	if self.SecondarySound then
		self:EmitSound(self.SecondarySound)
	end

	self.Owner:DoAttackEvent()
end
