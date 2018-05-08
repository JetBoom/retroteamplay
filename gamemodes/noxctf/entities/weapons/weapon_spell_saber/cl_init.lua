include("shared.lua")

SWEP.PrintName = "Spell Saber"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

SWEP.Slot = 0
SWEP.SlotPos = 2
killicon.Add(GetSWEPClassName(SWEP.Folder), "spellicons/spellsaber.png", color_white)

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "teamplay", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.NextAttack = 0


function SWEP:Think()
	local ct = CurTime()
	
	if self.FinishSwing and self.FinishSwing <= ct then
		self.FinishSwing = nil
	end	
		
	self:NextThink(ct)
	return true
end

function SWEP:PrimaryAttack()
	local owner = self.Owner
	if owner:KeyDown(IN_ATTACK2) or CurTime() < self.NextAttack or not owner:GetStatus("weapon_spell_saber") then return end

	self.NextAttack = CurTime() + self.Primary.Delay
	self.FinishSwing = CurTime() + 0.19
	owner:DoAttackEvent()
end

SWEP.DrawWorldModel = function() end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel