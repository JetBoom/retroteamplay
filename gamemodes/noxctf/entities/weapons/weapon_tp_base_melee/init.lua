AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:WeaponDeploy(owner)
	self.Status = owner:GiveStatus(self.WeaponStatus)
	self.Status.Damage = self.MeleeDamage
	self.Status.DamageType = self.MeleeDamageType
end

function SWEP:WeaponHolster(owner)
	owner:RemoveStatus(self.WeaponStatus, false, true)
	self.Status = nil
	return true
end

function SWEP:WeaponReload(owner)
end

function SWEP:Deploy()
	local owner = self.Owner
	owner:DrawViewModel(false)
	owner:RemoveStatus("weapon_*", false, true)
	
	self:PlayAnimation(owner, "HoldPosition")
	
	self:WeaponDeploy(owner)
end

function SWEP:Holster()
	local owner = self.Owner
	if self.HoldPositionAnimation then owner:StopLuaAnimation(self.HoldPositionAnimation, .1) end
	self:WeaponHolster(owner)
	
	return true
end


