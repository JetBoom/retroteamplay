AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Deploy()
	self.Owner:DrawViewModel(true)
	self.Owner:DrawWorldModel(true)
	self.Owner.PreInvisibleDrawWorldModel = true
	return true
end

function SWEP:Think()
end

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

local function SwingCallback(attacker, trace, dmginfo)
	local ent = NULL

	if trace.HitNonWorld then
		ent = trace.Entity
	end

	if trace.Hit and trace.HitPos:Distance(trace.StartPos) <= 70 then
		if not (ent:IsValid() and ent.PHealth and ent:GetTeamID() == attacker:Team()) then
			if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
				attacker:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1,5)..".wav", 75, 100)
				util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
			elseif not ent.Destroyed then
				util.Decal("Impact.Concrete", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
			end
		end
		attacker:EmitSound("weapons/melee/wrench/wrench_hit-0"..math.random(1, 4)..".wav", 75, 100)
	else
		attacker:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(95, 105))
	end

	if ent:IsValid() and trace.HitPos:Distance(trace.StartPos) <= 70 then
		if ent:GetClass() == "ffdoor" then ent = ent:GetParent() end
		if ent.ScriptVehicle and ent:Team() == attacker:Team() then
			local maxhealth = ent:GetMaxVHealth()
			local newhealth = math.min(ent:GetVHealth() + 15, maxhealth)
			ent:SetVHealth(newhealth)
			attacker:EmitSound("buttons/lever"..math.random(1,7)..".wav")
			if ent.Ignited and newhealth > maxhealth * 0.3 then
				for _, ent2 in pairs(ents.FindByClass("env_fire_trail")) do
					if ent2:GetParent() == ent then
						ent2:Remove()
					end
				end
				ent.Ignited = false
			end
		elseif ent.PHealth and ent:GetTeamID() == attacker:Team() then
			local maxhealth = ent.MaxPHealth
			local col = team.GetColor(ent:GetTeamID())

			if ent.LastTakeDamage and CurTime() < ent.LastTakeDamage + 4 then
				attacker:EmitSound("buttons/combine_button7.wav")
			elseif ent.Destroyed then
				if not ent:IsPlayerHolding() then
					local newhealth = math.ceil(math.min(ent.PHealth + (OVERTIME and 10 or 30), maxhealth))
					local brit = newhealth / maxhealth
					if newhealth == maxhealth then
						local aa, bb = ent:WorldSpaceAABB()
						for _, e2 in pairs(ents.FindInBox(aa, bb)) do
							if e2:IsValid() and e2:IsPlayer() and e2:Alive() and e2:Team() ~= TEAM_SPECTATE then
								newhealth = maxhealth - 1
							end
						end
						if newhealth == maxhealth then
							ent.Destroyed = nil
							ent.PHealth = maxhealth
							ent:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), 255))
							ent:SetCollisionGroup(COLLISION_GROUP_NONE)
							ent:GetPhysicsObject():EnableCollisions(true)
							ent:Fire("created", "", 0)
							local entpos = ent:GetPos()
							local effectdata = EffectData()
								effectdata:SetEntity(ent)
								effectdata:SetOrigin(entpos)
							util.Effect("building_spawn", effectdata, true, true)
							if 100 < maxhealth then
								local home = team.TeamInfo[ent:GetTeamID()].FlagPoint
								if home:Distance(entpos) < 1400 then
									local ownersteamid = ent.Owner
									for _, pl in pairs(player.GetAll()) do
										if pl:SteamID() == ownersteamid or pl == attacker then
											pl:CenterPrint("Crafting Bonus (+1)", "COLOR_LIMEGREEN", 3)
											if NDB then
												pl:AddSilver(CRAFTER_CORE_DEFENSE_BONUS)
											end
											pl:AddFrags(1)
											pl:AddDefense(1)
											ent.ReversePointsThresh = CurTime() + 0
										end
									end
								end
							end
						else
							attacker:PrintMessage(HUD_PRINTCENTER, "Building is being blocked and can't be completed.")
						end
					else
						ent.PHealth = newhealth
						ent:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), 60 + math.ceil(brit * 194)))
					end
				end
				attacker:EmitSound("buttons/lever"..math.random(7)..".wav")
			else
				local newhealth = math.ceil(math.min(ent.PHealth + math.Clamp(ent.MaxPHealth * 0.04, 18, 40), maxhealth))
				ent.PHealth = newhealth
				local brit = newhealth / maxhealth
				ent:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), 255))
				attacker:EmitSound("buttons/lever"..math.random(7)..".wav")
			end
		elseif ent.TakeSpecialDamage then
			if ent.PHealth then
				ent:TakeSpecialDamage(20, DMGTYPE_IMPACT, attacker)
			else
				local guarded = false
				if ent:IsPlayer() and ent:Team() ~= attacker:Team() then
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
					ent:BloodSpray(trace.HitPos, math.random(3, 4), attacker:GetAimVector(), 40)
				end
				if not guarded then
					ent:TakeSpecialDamage(10, DMGTYPE_IMPACT, attacker)
				end
			end
		else
			ent:TakeDamage(ent.PHealth and 20 or 10, attacker)
		end
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

	self.Owner:FireBullets({Num = 1, Src = self.Owner:GetShootPos(), Dir = self.Owner:GetAimVector(), Spread = Vector(0, 0, 0), Tracer = 0, Force = 0, Damage = 0, HullSize = 2, Callback = SwingCallback})
end

function SWEP:Reload()
	GAMEMODE:OnPhysgunReload(self, self.Owner)
end

function SWEP:SecondaryAttack()
end
