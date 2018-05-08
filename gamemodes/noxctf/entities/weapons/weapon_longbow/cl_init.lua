include("shared.lua")

SWEP.PrintName = "Long Bow"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.MaxAmmo = 0
SWEP.NextAttack = 0

killicon.Add(GetSWEPClassName(SWEP.Folder), "spellicons/archer.png", color_white)
killicon.Add("projectile_arrow", "spellicons/archer.png", color_white)

SWEP.DrawWorldModel = function() end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "teamplay", x + wide * 0.5, y + tall * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SWEP:GetViewModelPosition( pos, ang )
	return pos, ang
end

function SWEP:Deploy()
	self.Fidget = nil
	self.Lower = nil
	self.Drawing = nil
end

function SWEP:Think()
	if self.Fidget then
		if not self.Owner:KeyDown(IN_ATTACK) then
			self.Fidget = nil
			self.Lower = CurTime() + 0.75
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self.NextAttack = CurTime() + self.Primary.Delay
			self.FullPower = nil
		end
	elseif self.Drawing and self.Drawing <= CurTime() then
		self.Fidget = true
		self.Drawing = nil
		self.Lower = nil
		self.FullPower = CurTime() + 1
		self:SendWeaponAnim(ACT_VM_FIDGET)
	elseif self.Lower and self.Lower <= CurTime() then
		self.Lower = nil
		self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
	end
end

function SWEP:CanPrimaryAttack()
	return self.NextAttack <= CurTime() and not self.Fidget and not self.Drawing
end

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		if self.Owner:KeyDown(IN_ATTACK2) then
			self.NextAttack = math.max(self.NextAttack, CurTime() + 0.25)
			return
		end

		self.Lower = nil
		self.Drawing = CurTime() + 0.5
		self:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED)
		--self.Owner:EmitSound("nox/bow_takearrow0"..math.random(1,4)..".ogg")
	end
end

local hud_BowchargeX = CreateClientConVar("nox_hud_bowcharge_x", 0.5, true, false)
local hud_BowchargeY = CreateClientConVar("nox_hud_bowcharge_y", 0.6, true, false)

function SWEP:DrawHUD()
	local wid, hei = h * 0.2, h * 0.01
	local x = hud_BowchargeX:GetFloat() * w
	local y = hud_BowchargeY:GetFloat() * h
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(x - wid * 0.5, y, wid, hei)
	local attackstrength = 0
	if self.FullPower then
		attackstrength = math.max(0, math.min(1, 1 - (self.FullPower - CurTime())))
	end
	surface.SetDrawColor(attackstrength * 255, 0, 255 - attackstrength * 255, 220)
	surface.DrawRect(x - wid * 0.5, y, wid * attackstrength, hei)
	surface.SetDrawColor(60, 60, 60, 220)
	surface.DrawLine(x, y, x, y + hei)
	surface.DrawLine(x - wid * 0.4, y, x - wid * 0.4, y + hei)
	surface.DrawLine(x - wid * 0.2, y, x - wid * 0.2, y + hei)
	surface.DrawLine(x + wid * 0.4, y, x + wid * 0.4, y + hei)
	surface.DrawLine(x + wid * 0.2, y, x + wid * 0.2, y + hei)
	if attackstrength == 1 then
		local brit = math.sin(RealTime() * 8) * 127.5 + 127.5
		surface.SetDrawColor(brit, brit, brit, 255)
	end
	surface.DrawOutlinedRect(x - wid * 0.5, y, wid, hei)
end

function SWEP:DrawWorldModel()
end
