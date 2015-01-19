SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.AnimPrefix = "python"

SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Mana = 1

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Mana = 1000

SWEP.HoldType = "pistol"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Reload()
	if self:GetNextReload() <= CurTime() and self:DefaultReload(ACT_VM_RELOAD) then
		if self.ReloadSound then
			self:EmitSound(self.ReloadSound)
		end
		self:SetNextReload(CurTime() + self:SequenceDuration())
	end
end

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	return true
end

function SWEP:ShootEffects()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

if SERVER then
	SWEP.NextSendMana = 0

	local BulletCallback = BulletCallback
	function SWEP:ShootBullet(damage, num_bullets, aimcone, mana)
		local owner = self.Owner
		if self.NextSendMana < CurTime() then
			owner:SetMana(owner:GetMana() - mana, true)
			self.NextSendMana = CurTime() + 1
		else
			owner:SetMana(owner:GetMana() - mana)
		end

		owner:RemoveInvisibility()

		owner:FireBullets({Num = num_bullets, Src = owner:GetShootPos(), Dir = owner:GetAimVector(), Spread = Vector(aimcone, aimcone, 0), Tracer = 1, Force = 1, Damage = self.Primary.Damage, Callback = BulletCallback, TracerName = "manatrace"})

		self:ShootEffects()
	end

	function SWEP:CanPrimaryAttack()
		if self.Owner:GetMana() < self.Primary.Mana then
			self:SetNextPrimaryFire(CurTime() + 0.25)
			return false
		end

		return self:GetNextPrimaryFire() <= CurTime()
	end

	function SWEP:CanSecondaryAttack()
		if self.Owner:GetMana() < self.Secondary.Mana then
			self:SetNextPrimaryFire(CurTime() + 0.25)
			return false
		end

		return self:GetNextPrimaryFire() <= CurTime()
	end
end

if CLIENT then
	function SWEP:ShootBullet(damage, num_bullets, aimcone, mana)
		local owner = self.Owner
		owner:SetMana(owner:GetMana() - mana)
		owner:FireBullets({Num = num_bullets, Src = owner:GetShootPos(), Dir = owner:GetAimVector(), Spread = Vector(aimcone, aimcone, 0), Tracer = 1, Force = 1, Damage = 0, TracerName = "manatrace"})
		self:ShootEffects()
	end

	SWEP.NextNoMana = 0
	function SWEP:CanPrimaryAttack()
		if self.Owner:GetMana() < self.Primary.Mana then
			self:SetNextPrimaryFire(CurTime() + 0.25)
			if self.NextNoMana <= CurTime() then
				self.NextNoMana = CurTime() + 0.75
				surface.PlaySound("nox/nomana.ogg")
			end
			return false
		end

		return self:GetNextPrimaryFire() <= CurTime()
	end

	function SWEP:CanSecondaryAttack()
		if self.Owner:GetMana() < self.Secondary.Mana then
			self:SetNextPrimaryFire(CurTime() + 0.25)
			if self.NextNoMana <= CurTime() then
				self.NextNoMana = CurTime() + 0.75
				surface.PlaySound("nox/nomana.ogg")
			end
			return false
		end

		return self:GetNextPrimaryFire() <= CurTime()
	end
end

function SWEP:TakePrimaryAmmo(num)
	if self:Clip1() <= 0 then 
		if self:Ammo1() <= 0 then return end
		self.Owner:RemoveAmmo(num, self:GetPrimaryAmmoType())
		return
	end

	self:SetClip1(self:Clip1() - num)
end

function SWEP:TakeSecondaryAmmo(num)
	if self:Clip2() <= 0 then 
		if self:Ammo2() <= 0 then return end
		self.Owner:RemoveAmmo(num, self:GetSecondaryAmmoType())
		return
	end

	self:SetClip2(self:Clip2() - num)
end

function SWEP:Ammo1()
	return self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
end

function SWEP:Ammo2()
	return self.Owner:GetAmmoCount(self:GetSecondaryAmmoType())
end

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

		self:EmitSound(self.Primary.Sound)
		self.Owner:DoAttackEvent()
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Mana)
	end
end

function SWEP:SecondaryAttack()
	if self:CanSecondaryAttack() then
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

		self:EmitSound(self.Secondary.Sound)
		self.Owner:DoAttackEvent()
		self:ShootBullet(self.Secondary.Damage, self.Secondary.NumShots, self.Secondary.Cone, self.Secondary.Mana)
	end
end
