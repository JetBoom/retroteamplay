AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Classes = {"Wizard"}

function SWEP:Initialize()
	self:SetWeaponHoldType("melee2")

	if mana_lstaff then
		self.Mana = mana_lstaff
		mana_lstaff = nil
	else
		self.Mana = self.MaxMana
	end

end

function SWEP:Deploy()
	local owner = self.Owner
	owner:DrawViewModel(false)
	if not self.GaveAmmo then
		if self.Mana then
			owner:GiveAmmo(self.Mana - owner:GetAmmoCount(self.ChargeAmmo), self.ChargeAmmo)
		else
			owner:GiveAmmo(self.MaxMana - owner:GetAmmoCount(self.ChargeAmmo), self.ChargeAmmo)
		end
		self.GaveAmmo = true
	end
	owner:RemoveStatus("weapon_*", false, true)
	owner:GiveStatus("weapon_lightningstaff")
end

function SWEP:Holster()
	self.Owner:RemoveStatus("weapon_lightningstaff", false, true)
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:PrimaryAttack()
	if CurTime() < self.NextAttack then return end

	if self.Owner:GetAmmoCount(self.ChargeAmmo) < self.AmmoPerCharge then return end

	if self.Owner:KeyDown(IN_ATTACK2) then
		self.NextAttack = CurTime() + 1.5
		return
	end

	self.Owner:RemoveInvisibility()

	local pl = self.Owner
	self.NextAttack = CurTime() + 1.5
	pl:DoAttackEvent()
	pl:RemoveAmmo(self.AmmoPerCharge, self.ChargeAmmo)

	mana_lstaff = self.Owner:GetAmmoCount(self.ChargeAmmo)

	spells.Discharge(pl)
end
