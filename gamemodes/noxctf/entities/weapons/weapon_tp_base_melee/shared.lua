SWEP.Base = "weapon_tp_base"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ChargeAmmo = -9999

-- everything above here should not be changed in derivative SWEPS.

SWEP.UseHullTrace = true

SWEP.MeleeDamage = 25
SWEP.MeleeDamageType = DMGTYPE_SLASHING
SWEP.MeleeRange = 35
SWEP.MeleeSize = 16
SWEP.MeleeSwingTime = 0.26
SWEP.MeleeCooldown = 0.78

SWEP.SpecialCooldown = 2
SWEP.Special2Cooldown = 2

SWEP.MeleeSwingSound = {sound = {Sound("nox/sword_miss.ogg")}, vol = 80, pitchLB = 80, pitchRB = 93}
SWEP.HitFleshSound = {sound = {Sound("nox/sword_hit.ogg")}, vol = 77, pitchLB = 98, pitchRB = 102}
SWEP.HitSound = {sound = {Sound("nox/sword_hit.ogg")}, vol = 77, pitchLB = 98, pitchRB = 102}

function SWEP:WeaponInitialize()
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)

	self:WeaponInitialize()
end

function SWEP:HitEffect(owner, tr)
end

function SWEP:HitFleshEffect(owner, tr)
	if CLIENT then return end

	local pos = owner:GetCenter()
	local pl = tr.Entity or tr
	local nearest = pl:NearestPoint(pos)
	local mag = math.Round(self.MeleeDamage / 2)

	pl:BloodSpray(nearest, math.random(math.max(0, mag - 4), mag + 4), owner:GetAimVector(), 250)
end

function SWEP:HitWorldEffect(owner, tr)
end

function SWEP:OnHitPlayer(pl, damage, hitpos)
	pl:TakeSpecialDamage(damage, self.MeleeDamageType, self.Owner, self, hitpos)
end

function SWEP:OnHitBuilding(ent, damage, hitpos)
	ent:TakeSpecialDamage(damage, self.MeleeDamageType, self.Owner, self, hitpos)
end

-- this method uses a hull trace. better for long range weapons with narrow scans like spears. this causes problems with larger scan areas because the hitscan will hit the world and then stop.
function SWEP:DoMeleeSwing(owner)
	owner:LagCompensation(true)

	local targets = owner:GetMeleeTargets(self.MeleeRange, self.MeleeSize)

	local hit, hitworld, hitflesh

	local eyepos = owner:GetShootPos()
	for _, tr in pairs(targets) do
		if tr.Hit and tr.HitPos:Distance(eyepos) > 128 then continue end -- We don't want prediction giving people with huge ping an advantage.

		local ent = tr.Entity
		if ent:IsValid() then
			if ent:IsPlayer() then
				self:OnHitPlayer(ent, self.MeleeDamage, tr.HitPos)
				hitflesh = tr
			else
				self:OnHitBuilding(ent, self.MeleeDamage, tr.HitPos)
				hit = tr
			end
		elseif ent:IsWorld() then
			hitworld = tr
		end
	end

	-- We don't want tons of hit effects so only do one per 'type' of hit.
	if hitflesh then
		if SERVER then self:PlaySound(hitflesh.Entity, "HitFlesh") end
		self:HitFleshEffect(owner, hitflesh)
	end
	if hitworld then
		if SERVER then self:PlaySound(self.Owner, "HitWorld") end
		self:HitWorldEffect(owner, hitworld)
	end
	if hit then
		local ent = hit.Entity
		if ent.PHealth or ent.ScriptVehicle or ent.VehicleParent or ent.CoreHealth then
			if SERVER then self:PlaySound(ent, "Hit") end
			self:HitEffect(owner, hit)
		end
	end

	owner:LagCompensation(false)
end

-- this uses findinsphere with a trace to determine if the target is melee visisble. better for weapons with large scan areas.
function SWEP:DoMeleeSwingSphere(owner)
	owner:LagCompensation(true)

	local targets, hitworld = owner:GetMeleeTargets2(self.MeleeRange, self.MeleeSize)

	if DEBUG then PrintTable(targets) end

	local hit, hitworld, hitflesh

	local start = owner:GetShootPos()
	for ent, hitpos in pairs(targets) do
		if ent:IsValid() then
			if ent:IsPlayer() then
				self:OnHitPlayer(ent, self.MeleeDamage, hitpos)
				hitflesh = ent
			else
				self:OnHitBuilding(ent, self.MeleeDamage, hitpos)
				hit = ent
			end
		end
	end

	-- We don't want tons of hit effects so only do one per 'type' of hit.
	if hitflesh then
		if SERVER then self:PlaySound(hitflesh, "HitFlesh") end
		self:HitFleshEffect(owner, hitflesh)
	end
	if hitworld then
		if SERVER then self:PlaySound(hitworld.Entity, "HitWorld") end
		self:HitWorldEffect(owner, hitworld)
	end
	if hit then
		if SERVER then self:PlaySound(hit, "Hit") end
		self:HitEffect(owner, hit)
	end

	owner:LagCompensation(false)
end

function SWEP:WeaponThink(owner)
end

function SWEP:Think()
	local owner = self.Owner
	if self:GetMeleeHitTime() > 0 and CurTime() >= self:GetMeleeHitTime() then
		self:SetMeleeHitTime(0)

		if self.UseHullTrace then
			self:DoMeleeSwing(owner)
		else
			self:DoMeleeSwingSphere(owner)
		end
	end

	self:WeaponThink(owner)

	self:NextThink(CurTime())
	return true
end

--- functions pertaining to the primary melee attack
function SWEP:CanMeleeAttack(owner)
	return true
end

function SWEP:CanPrimaryAttack()
	local owner = self.Owner
	return self:GetNextPrimaryFire() <= CurTime() and not owner:StatusHook("PlayerCantAttack", owner, self) and self:CanMeleeAttack(owner) and not owner:KeyDown(IN_ATTACK2)
end

function SWEP:WeaponMeleeAttack(owner)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local owner = self.Owner
	local cd = (owner:GetStatus("brute") and self.MeleeCooldown/2) or self.MeleeCooldown
	self:SetNextPrimaryFire(CurTime() + cd)
	self:SetNextSecondaryFire(math.max(self:GetNextSecondaryFire(), CurTime() + cd))
	self:SetNextReload(math.max(self:GetNextReload(), CurTime() + cd))

	local owner = self.Owner
	if IsFirstTimePredicted() then
		self:PlaySound(self, "MeleeSwing")
		self:PlayAnimation(owner, "MeleeSwing")

		if SERVER and not owner:StatusWeaponHook("ShouldRemainInvisible") then owner:RemoveInvisibility() end
	end

	self:SetMeleeHitTime(CurTime() + self.MeleeSwingTime)

	self:WeaponMeleeAttack(owner)
end

-- functions pertaining to an alternative attack/ability. should not be used on classes that cast spells because it conflicts with spell selection
function SWEP:CanSpecialAttack(owner)
	return false
end

function SWEP:CanSecondaryAttack()
	local owner = self.Owner
	return self:GetNextSecondaryFire() <= CurTime() and not owner:StatusHook("PlayerCantAttack", owner, self) and self:CanSpecialAttack(owner)
end

-- the entire special attack is defined here.
function SWEP:WeaponSpecialAttack(owner)
end

-- special melee attack or some other feature
function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end

	self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + self.SpecialCooldown))
	self:SetNextSecondaryFire(CurTime() + self.SpecialCooldown)
	self:SetNextReload(math.max(self:GetNextReload(), CurTime() + self.SpecialCooldown))

	local owner = self.Owner
	if IsFirstTimePredicted() then
		self:PlaySound(owner, "Special")
		self:PlayAnimation(owner, "Special")

		if SERVER and not owner:StatusWeaponHook("ShouldRemainInvisible") then owner:RemoveInvisibility() end
	end

	self:WeaponSpecialAttack(owner)
end

-- functions pertaining to another alternative attack/ability.
function SWEP:CanSpecialAttack2(owner)
	return false
end

function SWEP:CanReload()
	local owner = self.Owner
	return self:GetNextReload() <= CurTime() and not owner:StatusHook("PlayerCantAttack", owner, self) and self:CanSpecialAttack2(owner)
end

function SWEP:WeaponSpecialAttack2(owner)
end

function SWEP:Reload()
	if not self:CanReload() then return end

	self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + self.MeleeCooldown))
	self:SetNextSecondaryFire(math.max(self:GetNextSecondaryFire(), CurTime() + self.SpecialCooldown))
	self:SetNextReload(CurTime() + self.Special2Cooldown)

	local owner = self.Owner
	if IsFirstTimePredicted() then
		self:PlaySound(owner, "Special2")
		self:PlayAnimation(owner, "Special2")

		if SERVER and not owner:StatusWeaponHook("ShouldRemainInvisible") then owner:RemoveInvisibility() end
	end

	self:WeaponSpecialAttack2(owner)
end

function SWEP:SetMeleeHitTime(m) self:SetDTFloat(3, m) end
function SWEP:GetMeleeHitTime() return self:GetDTFloat(3) end

function SWEP:IsIdle()
	return self:GetMeleeHitTime() == 0
end

