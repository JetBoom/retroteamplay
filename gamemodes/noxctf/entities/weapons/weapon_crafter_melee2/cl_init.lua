include("shared.lua")

SWEP.PrintName = "Super Crafter Wrench"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

SWEP.Slot = 4
SWEP.SlotPos = 0

killicon.Add(GetSWEPClassName(SWEP.Folder), "spellicons/crafter.png", color_white)

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if CurTime() < self:GetNetworkedFloat("LastShootTime", -100) + self.Primary.Delay then return end

	local trace = self.Owner:TraceLine(70)

	if trace.Hit then
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		else
			util.Decal("Impact.Concrete", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		end
	end

	self.Owner:DoAttackEvent()
end

function SWEP:SecondaryAttack()
end

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:Think()
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "teamplay", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SWEP:DrawWorldModel()
	if self.Owner and self.Owner:IsValid() and self.Owner:IsInvisible() then return end
	self:DrawModel()
end
