AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.LastHeal = 0

function SWEP:Deploy()
	self.Owner:DrawViewModel(true)
	self.Owner:DrawWorldModel(true)
	self.Owner.PreInvisibleDrawWorldModel = true
	return true
end

local damageMult = 1
function SWEP:Think()
	if CurTime() > self.LastHeal + 0.75 then
		if self.Owner:GetVelocity():Length() == 0 then
			local health = self.Owner:Health()
			local maxhealth = self.Owner:GetMaxHealth()
			if health < maxhealth then
				self.Owner:SetHealth(health + 1)
			end
		end
		self.LastHeal = CurTime()
	end

	if self.Owner:GetStatus("ruin") then
		if damageMult ~= 2/3 then
			damageMult = 2/3
		end
	elseif damageMult ~= 1 then
		damageMult = 1
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType("knife")
end

local function StabCallback(attacker, trace, dmginfo)
	local ent = nil

	if trace.HitNonWorld then
		ent = trace.Entity
	end

	if trace.Hit and trace.HitPos:Distance(trace.StartPos) <= 70 then
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			attacker:EmitSound("weapons/knife/knife_hit"..math.random(1,4)..".wav")
			util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		else
			attacker:EmitSound("weapons/knife/knife_hitwall1.wav")
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		end
	else
		attacker:EmitSound("weapons/knife/knife_slash"..math.random(1,2)..".wav")
	end

	if ent and ent:IsValid() and trace.HitPos:Distance(trace.StartPos) <= 70 then
		if ent:IsPlayer() then
			if ent:GetForward():Distance(attacker:GetForward()) < 0.88 then
				if ent:Team() ~= attacker:Team() then
					ent:BloodSpray(trace.HitPos, 22, attacker:GetAimVector(), 100)
				end
				ent:TakeSpecialDamage(math.min((ent:GetMaxHealth()*0.7+17.5) * damageMult, ent:Health()), DMGTYPE_PIERCING, attacker)
				ent:EmitSound("weapons/knife/knife_stab.wav")
				local wep = attacker:GetActiveWeapon()
				if wep:IsValid() then
					wep:SetNextPrimaryFire(CurTime() + wep.Primary.Delay*1.75)
				end
			else
				local guarded = false
				if ent:Team() ~= attacker:Team() then
					if ent:GetActiveWeapon().Guarding and 1.4 < attacker:GetForward():Distance(ent:GetForward()) then
						guarded = true
						attacker:Stun(1, true)
						attacker.LastAttacker = ent
						attacker.LastAttacked = CurTime()
						attacker:SetGroundEntity(NULL)
						attacker:SetVelocity((attacker:GetPos() - ent:GetPos()):GetNormal() * 220 + Vector(0,0,190))
						local effectdata = EffectData()
							effectdata:SetOrigin(ent:GetShootPos())
							effectdata:SetEntity(ent)
						util.Effect("meleeguard", effectdata, true, true)
					end
					ent:BloodSpray(trace.HitPos, 5, attacker:GetAimVector(), 60)
				end

				if not guarded then
					ent:TakeSpecialDamage(15 * damageMult, DMGTYPE_PIERCING, attacker)
				end
			end
			
			if attacker:GetStatus("venomblade") and ent:Team() ~= attacker:Team() then
				ent:GiveStatus("venom", 10).Attacker = attacker
			end
		else
			if ent.TakeSpecialDamage then
				ent:TakeSpecialDamage(15 * damageMult, DMGTYPE_PIERCING, attacker)
			else
				ent:TakeDamage(15 * damageMult, attacker)
			end
		end
	end

	if attacker:GetStatus("venomblade") then
		attacker:RemoveStatus("venomblade", true, true)
	end

	return {effects = false, damage = false}
end

function SWEP:PrimaryAttack()
	if CurTime() < self:GetNextPrimaryFire() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self.Owner:RemoveInvisibility()

	if self.Alternate then
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
	else
		self:SendWeaponAnim(ACT_VM_HITCENTER)
	end

	self.Alternate = not self.Alternate

	self.Owner:DoAttackEvent()

	self.Owner:FireBullets({Num = 1, Src = self.Owner:GetShootPos(), Dir = self.Owner:GetAimVector(), Spread = Vector(0, 0, 0), Tracer = 0, Force = 0, Damage = 0, HullSize = 2, Callback = StabCallback})
end

function SWEP:SecondaryAttack()
end
