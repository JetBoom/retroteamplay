if SERVER then
	AddCSLuaFile("shared.lua")
 
	function SWEP:Deploy()
		self.Owner:DrawViewModel(true)
		self.Owner:DrawWorldModel(true)
		self.Owner.PreInvisibleDrawWorldModel = true
	end
 
	function SWEP:Initialize()
		self:SetWeaponHoldType("melee")
	end
end
 
if CLIENT then
	SWEP.ViewModelFlip = false
 
	function SWEP:Initialize()
		self.PrintName = self.Owner:GetPlayerClassTable().Name and (self.Owner:GetPlayerClassTable().Name or "Nobody") .."'s Wand"
		self:SetWeaponHoldType("melee")
	end
       
	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		draw.SimpleText(self.PrintName, "teamplay", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
 
SWEP.ViewModel = "models/weapons/v_stunbaton.mdl"
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl"
 
SWEP.Classes = {"Mage", "Sorcerer"}
 
SWEP.Primary.ClipSize = -1
SWEP.Primary.Delay = 1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1.5
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.MeleeDamage = 5
 
function SWEP:Think()
end
 
function SWEP:CanSecondaryAttack()
	return false
end
 
function SWEP:PrimaryAttack()
	local owner = self.Owner
	if owner:KeyDown(IN_ATTACK2) or CurTime() < self:GetNextPrimaryFire() then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
               
	owner:DoAttackEvent()
		
	if SERVER then
		if owner:IsInvisible() then
			owner:RemoveInvisibility()
		end
	end
               
	local tr = util.TraceHull({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * 38, filter = owner, mins = Vector(-1, -1, -1), maxs = Vector(1, 1, 1)})
	local hitent = tr.Entity

	if hitent:IsPlayer() then
		self:SendWeaponAnim(ACT_VM_HITCENTER)
		if SERVER then owner:EmitSound("physics/body/body_medium_impact_hard1.wav", 75, math.random(95, 105)) end
		if hitent:Team() ~= owner:Team() then
			hitent:TakeSpecialDamage(self.MeleeDamage, DMGTYPE_BASHING, owner, self)
		end
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
		if SERVER then owner:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(95, 105)) end
	end

	if tr.Hit and not tr.HitSky then
		if tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_ALIENFLESH then
			util.Decal("Blood", tr.HitPos + tr.HitNormal * 8, tr.HitPos - tr.HitNormal * 8)
		else
			util.Decal("Impact.Concrete", tr.HitPos + tr.HitNormal * 8, tr.HitPos - tr.HitNormal * 8)
		end
	end
end
 
if CLIENT then	
	function SWEP:DrawWorldModel()
		if self.Owner and self.Owner:IsValid() and self.Owner:IsInvisible() then return end

		self:DrawModel()
	end
end
