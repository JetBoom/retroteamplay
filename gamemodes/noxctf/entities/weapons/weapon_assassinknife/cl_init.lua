include("shared.lua")

SWEP.PrintName = "Assassin's Knife"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

SWEP.Slot = 0
SWEP.SlotPos = 1

killicon.AddFont(GetSWEPClassName(SWEP.Folder), "teamplaydeathnoticecs", "j", color_white)

function SWEP:Initialize()
	self:SetWeaponHoldType("knife")
end

function SWEP:PrimaryAttack()
	if CurTime() < self:GetNetworkedFloat("LastShootTime", -100) + self.Primary.Delay then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local trace = self.Owner:TraceLine(62)

	if trace.Hit then
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		else
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		end
	end

	self.Owner:DoAttackEvent()

	self:SetNetworkedFloat("LastShootTime", CurTime())
end

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:DrawWorldModel()
	if self.Owner and self.Owner:IsValid() and (self.Owner:IsInvisible() or self.Owner:GetStatus("voidwalk")) then return end
	self:DrawModel()
end

function SWEP:Reload()
	return false
end

function SWEP:Think()
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "teamplay", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
