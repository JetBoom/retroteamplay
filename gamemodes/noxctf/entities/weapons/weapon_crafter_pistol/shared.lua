if SERVER then
	AddCSLuaFile("shared.lua")

	function SWEP:Deploy()
		self.Owner:DrawViewModel(true)
		self.Owner:DrawWorldModel(true)
		self.Owner.PreInvisibleDrawWorldModel = true
	end

end

if CLIENT then
	SWEP.PrintName = "Crafter Pistol"
	
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.NoBuilderMenu = true

	killicon.AddFont(GetSWEPClassName(SWEP.Folder), "HL2MPTypeDeath", "-", color_white)
end

SWEP.Base = "weapon_ctfbase"

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Classes = {"Crafter"}

SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 7
SWEP.Primary.NumShots = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.Delay = 0.4
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Cone = 0.05

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Delay = 1.5
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

if SERVER then
	SWEP.NextSendMana = 0

	function SWEP:SecondaryAttack()
	end

	function SWEP:CanPrimaryAttack()
		if self.Owner:GetMana() < 5 then
			self:SetNextPrimaryFire(CurTime() + 0.25)
			return false
		end

		return true
	end

	function SWEP:CanSecondaryAttack()
		return false
	end

	local BulletCallback = BulletCallback
	function SWEP:ShootBullet(damage, num_bullets, aimcone)
		local owner = self.Owner
		if self.NextSendMana < CurTime() then
			owner:SetMana(owner:GetMana() - 3, true)
			self.NextSendMana = CurTime() + 1
		else
			owner:SetMana(owner:GetMana() - 3)
		end

		owner:RemoveInvisibility()

		owner:FireBullets({Num = num_bullets, Src = owner:GetShootPos(), Dir = owner:GetAimVector(), Spread = Vector(aimcone, aimcone, 0), Tracer = 1, Force = 1, Damage = self.Primary.Damage, Callback = BulletCallback, TracerName = "manatrace"})

		owner:DoAttackEvent()

		self:ShootEffects()
	end
end

if CLIENT then
	SWEP.NextNoMana = 0
	function SWEP:CanPrimaryAttack()
		if self.Owner:GetMana() < 3 then
			if self.NextNoMana <= CurTime() then
				self.NextNoMana = CurTime() + 0.75
				surface.PlaySound("nox/nomana.ogg")
			end
			self:SetNextPrimaryFire(CurTime() + 0.25)
			return false
		end

		return true
	end
	
	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		draw.SimpleText(self.PrintName, "teamplay", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function SWEP:SecondaryAttack()
	end

	function SWEP:CanSecondaryAttack()
		return false
	end

	function SWEP:ShootBullet(damage, num_bullets, aimcone)
		local owner = self.Owner
		owner:SetMana(owner:GetMana() - 3)
		owner:FireBullets({Num = num_bullets, Src = owner:GetShootPos(), Dir = owner:GetAimVector(), Spread = Vector(aimcone, aimcone, 0), Tracer = 1, Force = 1, Damage = self.Primary.Damage, Callback = BulletCallback, TracerName = "manatrace"})
		owner:DoAttackEvent()
		self:ShootEffects()
	end
end
