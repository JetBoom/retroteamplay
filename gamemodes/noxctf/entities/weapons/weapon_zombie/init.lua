AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.NextHeal = 0
SWEP.NextSwing = 0
SWEP.NextYell = 0

function SWEP:Deploy()
	self.Owner:DrawViewModel(true)
	self.Owner:RemoveStatus("weapon_*", false, true)
end

function SWEP:Think()
	local owner = self.Owner
	local ct = CurTime()
	if self.NextHeal <= ct then
		self.NextHeal = ct + 1
		owner:SetHealth(math.min(owner:GetMaxHealth(), owner:Health() + 1))
	end

	if self.NextHit then
		if self.NextSwingAnim and self.NextSwingAnim < ct then
			if self.SwapAnims then self:SendWeaponAnim(ACT_VM_HITCENTER) else self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) end
			self.SwapAnims = not self.SwapAnims
			self.NextSwingAnim = nil
		end

		if self.NextHit <= ct then
			self.NextHit = nil

			local eyepos = owner:EyePos()
			local ownerteam = owner:Team()
			for _, ent in pairs(ents.FindInSphere(eyepos + owner:GetAimVector() * 40, 20)) do
				if ent.PHealth or ent.CoreHealth then
					if MeleeVisible(ent:NearestPoint(eyepos), eyepos, {ent, owner}) then
						owner:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav", 80, 80)
						ent:TakeSpecialDamage(45, DMGTYPE_SLASHING, owner, self)
					end
				elseif ent ~= owner and (ent:IsPlayer() or ent:IsNPC()) then
					if not (ent:IsPlayer() and not ent:Alive()) and TrueVisible(ent:NearestPoint(eyepos), eyepos) then
						owner:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav", 80, 80)
						ent:TakeSpecialDamage(45, DMGTYPE_SLASHING, owner, self)
					end
				--elseif ent.Inversion and ent:GetTeamID() ~= ownerteam then
				--	ent:EmitSound("npc/manhack/bat_away.wav", 80, math.random(95, 105))
				--	Invert(ent, owner)
				end
			end

			owner:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav", 90, 80)
		end
	end
end

function SWEP:PrimaryAttack()
	if self.NextSwing <= CurTime() then
		local owner = self:GetOwner()

		if not owner:StatusWeaponHook("ShouldRemainInvisible") then owner:RemoveInvisibility() end

		owner:DoAnimationEvent(ACT_MELEE_ATTACK1)
		owner:SendLua("LocalPlayer():DoAnimationEvent(ACT_MELEE_ATTACK1)")
		owner:EmitSound("npc/zombie_poison/pz_warn"..math.random(1, 2)..".wav")
		self.NextSwing = CurTime() + self.Primary.Delay
		self.NextYell = self.NextSwing + 0.1
		self.NextSwingAnim = CurTime() + 0.6
		self.NextHit = CurTime() + 1
	end
end

function SWEP:Reload()
	return false
end

local function DoPuke(pl, wep)
	if pl:IsValid() and pl:Alive() and not pl:InVehicle() and wep:IsValid() then
		local shootpos = pl:GetShootPos()
		local startpos = pl:GetPos()
		startpos.z = shootpos.z
		local aimvec = pl:GetAimVector()
		aimvec.z = math.max(aimvec.z, -0.7)
		for i=1, 8 do
			local ent = ents.Create("projectile_zombieflesh")
			if ent:IsValid() then
				local heading = (aimvec + VectorRand() * 0.2):GetNormal()
				ent:SetPos(startpos + heading * 8)
				ent:SetOwner(pl)
				ent:Spawn()
				ent:SetTeamID(pl:Team())
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(heading * math.Rand(300, 550))
				end
				ent:SetPhysicsAttacker(pl)
			end
		end

		pl:EmitSound("physics/body/body_medium_break"..math.random(2,4)..".wav", 80, math.random(70, 80))

		pl:TakeSpecialDamage(25, DMG_GENERIC, pl, wep)
	end
end

local function DoSwing(pl, wep)
	if pl:IsValid() and pl:Alive() and not pl:InVehicle() and wep:IsValid() then
		pl:EmitSound("physics/body/body_medium_break"..math.random(2,4)..".wav", 80, math.random(70, 83))
		if wep.SwapAnims then wep:SendWeaponAnim(ACT_VM_HITCENTER) else wep:SendWeaponAnim(ACT_VM_SECONDARYATTACK) end
		wep.SwapAnims = not wep.SwapAnims
	end
end

function SWEP:SecondaryAttack()
	if self.NextYell <= CurTime() then
		local owner = self:GetOwner()

		if not owner:StatusWeaponHook("ShouldRemainInvisible") then owner:RemoveInvisibility() end

		owner:DoAnimationEvent(ACT_RANGE_ATTACK2)
		owner:SendLua("LocalPlayer():DoAnimationEvent(ACT_RANGE_ATTACK2)")
		owner:EmitSound("npc/zombie_poison/pz_throw"..math.random(2,3)..".wav")
		--GAMEMODE:SetPlayerSpeed(owner, 1)
		--Stun(owner, 1, true, true)
		self.NextYell = CurTime() + 4
		self.NextSwing = CurTime() + self.Primary.Delay
		timer.Simple(0.6, function() DoSwing(owner, self) end)
		timer.Simple(1, function() DoPuke(owner, self) end)
	end
end
