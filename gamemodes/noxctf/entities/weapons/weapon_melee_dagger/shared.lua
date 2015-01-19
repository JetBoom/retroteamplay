SWEP.Base = "weapon_tp_base_melee"
SWEP.HoldType = "melee"

SWEP.MeleeDamage = 10
SWEP.MeleeDamageType = DMGTYPE_SLASHING
SWEP.MeleeRange = 30
SWEP.MeleeSize = 8
SWEP.MeleeSwingTime = 0.25
SWEP.MeleeCooldown = 0.4
SWEP.Combo = 1
SWEP.UseHullTrace = true
SWEP.WeaponStatus = "weapon_dagger"
SWEP.LastHeal = 0

SWEP.MeleeSwingSound = {sound = {Sound("nox/sword_miss.ogg")}, vol = 80, pitchLB = 105, pitchRB = 113}
SWEP.HitFleshSound = {
	sound = {
		Sound("ambient/machines/slicer1.wav"),
		Sound("ambient/machines/slicer2.wav"),
		Sound("ambient/machines/slicer3.wav"),
		Sound("ambient/machines/slicer4.wav")
		},
	vol = 77,
	pitchLB = 108,
	pitchRB = 112
}
SWEP.HitSound = {
	sound = {
		Sound("ambient/machines/slicer1.wav"),
		Sound("ambient/machines/slicer2.wav"),
		Sound("ambient/machines/slicer3.wav"),
		Sound("ambient/machines/slicer4.wav")
		},
	vol = 77,
	pitchLB = 108,
	pitchRB = 112
}

SWEP.MeleeSwingAnimation = {"dagger_combo_1"}

function SWEP:CanPrimaryAttack()
	local owner = self.Owner
	return not owner:StatusHook("PlayerCantAttack", owner, self) and self:CanMeleeAttack(owner)
end

function SWEP:WeaponThink(owner)
	if CurTime() > self.LastHeal + 0.5 then
		if owner:GetVelocity():Length() == 0 or owner:GetStatus("shadowstorm") then
			local health = owner:Health()
			local maxhealth = owner:GetMaxHealth()
			if health < maxhealth then
				owner:SetHealth(health + 1)
			end
		end
		self.LastHeal = CurTime()
	end

	if self.Combo == 2 then
		if CurTime() > self:GetNextPrimaryFire() + 1 then
			owner:ResetLuaAnimation("dagger_combo_1_reset")
			self.Combo = 1
			self.MeleeSwingAnimation = {"dagger_combo_1"}
		end
	elseif self.Combo == 3 then
		if CurTime() > self:GetNextPrimaryFire() + 1 then
			owner:ResetLuaAnimation("dagger_combo_2_reset")
			self.Combo = 1
			self.MeleeSwingAnimation = {"dagger_combo_1"}
		end
	end
end

function SWEP:DoMeleeSwing(owner)
	owner:LagCompensation(true)

	local targets = owner:GetMeleeTargets(self.MeleeRange, self.MeleeSize)
	
	local hit, hitworld, hitflesh

	local eyepos = owner:EyePos()
	for _, tr in pairs(targets) do
		if tr.Hit and tr.HitPos:Distance(eyepos) > 128 then continue end -- We don't want prediction giving people with huge ping an advantage.
		
		local ent = tr.Entity
		if ent:IsValid() then
			if ent:IsPlayer() then
				if ent:GetForward():Distance(owner:GetForward()) < 0.88 then
					self:OnHitPlayer(ent, self.MeleeDamage * 2, tr.HitPos)
					hitflesh = tr

					if SERVER then
						if owner:GetStatus("venomblade") and ent:Team() ~= owner:Team() and ent:Alive() and not ent.ProtectFromPoison then
							ent:GiveStatus("venom", 10).Attacker = owner
						end
					end
				else
					self:OnHitPlayer(ent, self.MeleeDamage, tr.HitPos)
					hitflesh = tr

					if SERVER then
						if owner:GetStatus("venomblade") and ent:Team() ~= owner:Team() and ent:Alive() and not ent.ProtectFromPoison then
							ent:GiveStatus("venom", 5).Attacker = owner
						end
					end
				end
			else
				self:OnHitBuilding(ent, self.MeleeDamage, tr.HitPos)
				hit = tr
			end
		elseif ent:IsWorld() then
			hitworld = tr
		end
	end
	
	if SERVER and owner:GetStatus("venomblade") then
		owner:RemoveStatus("venomblade", true, true)
	end

	-- We don't want tons of hit effects so only do one per 'type' of hit.
	if hitflesh then
		if SERVER then self:PlaySound(hitflesh.Entity, "HitFlesh") end
		self:HitFleshEffect(owner, hitflesh)
	end
	if hitworld then
		if SERVER then self:PlaySound(hitworld.Entity, "HitWorld") end
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

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if self.Combo == 1 then
		local cd = self.MeleeCooldown
		self:SetNextPrimaryFire(CurTime() + cd)
		local owner = self.Owner
		if IsFirstTimePredicted() then
			self:PlaySound(self, "MeleeSwing")
			self:PlayAnimation(owner, "MeleeSwing")
			
			if SERVER and not owner:StatusWeaponHook("ShouldRemainInvisible") then owner:RemoveInvisibility() end
		end
		self.MeleeSize = 25
		self.MeleeSwingTime = 0.25
		self.MeleeDamage = 10
		self:SetMeleeHitTime(CurTime() + self.MeleeSwingTime)
		self.Combo = 2
		self.MeleeSwingAnimation = {"dagger_combo_2"}
	elseif self.Combo == 2 then
		local cd = self.MeleeCooldown
		self:SetNextPrimaryFire(CurTime() + cd)
		local owner = self.Owner
		if IsFirstTimePredicted() then
			self:PlaySound(self, "MeleeSwing")
			self:PlayAnimation(owner, "MeleeSwing")
			
			if SERVER and not owner:StatusWeaponHook("ShouldRemainInvisible") then owner:RemoveInvisibility() end
		end
		self:SetMeleeHitTime(CurTime() + self.MeleeSwingTime)
		self.Combo = 3
		self.MeleeSwingAnimation = {"dagger_combo_3"}
	elseif self.Combo == 3 then
		local cd = self.MeleeCooldown
		self:SetNextPrimaryFire(CurTime() + 1.2)
		local owner = self.Owner
		if IsFirstTimePredicted() then
			self:PlaySound(self, "MeleeSwing")
			self:PlayAnimation(owner, "MeleeSwing")
			
			if SERVER and not owner:StatusWeaponHook("ShouldRemainInvisible") then owner:RemoveInvisibility() end
		end
		self.MeleeSwingTime = 0.4
		self.MeleeSize = 30
		self.MeleeDamage = 20
		self:SetMeleeHitTime(CurTime() + self.MeleeSwingTime)
		self.Combo = 1
		self.MeleeSwingAnimation = {"dagger_combo_1"}
	end
end