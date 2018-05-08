AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Classes = {"Spell Saber"}
SWEP.ChargeAmmo = 0
SWEP.NextVamp = CurTime()
SWEP.VampPool = 0

function SWEP:Deploy()
	local owner = self.Owner
	owner:DrawViewModel(false)
	owner:RemoveStatus("weapon_*", false, true)
	if owner:Alive() then
		owner:GiveStatus("weapon_spell_saber")
	end
end

function SWEP:Holster()
	self.Owner:RemoveStatus("weapon_spell_saber", false, true)
	return true
end

function SWEP:Think()
	local ct = CurTime()
	local owner = self.Owner

	if self.VampPool > 0 and self.NextVamp < CurTime() then
		GAMEMODE:PlayerHeal(owner, owner, math.min(1,self.VampPool))
		self.VampPool = math.max(0,self.VampPool - 1)
		self.NextVamp = CurTime() + 0.15
	end
		
	if owner:GetMana() < 15 then
		owner:RemoveStatus("spellsaber_flameblade", false, true)
	end
	if owner:GetMana() < 20 then
		owner:RemoveStatus("spellsaber_stormblade", false, true)
	end
	if owner:GetMana() < 20 then
		owner:RemoveStatus("spellsaber_nullblade", false, true)
	end
	if owner:GetMana() < 25 then
		owner:RemoveStatus("spellsaber_sanguineblade", false, true)
	end
	if owner:GetMana() < 30 then
		owner:RemoveStatus("spellsaber_corruptblade", false, true)
	end
	if owner:GetMana() < 4 then
		owner:RemoveStatus("spellsaber_frostblade", false, true)
	end
	if owner:GetMana() < 15 then
		owner:RemoveStatus("spellsaber_shockblade", false, true)
	end

	if self.FinishSwing and self.FinishSwing <= ct then
		self.FinishSwing = nil

		owner:LagCompensation(true)

		local eyepos = owner:GetShootPos()
		local ownerteam = owner:Team()
		local _filter = player.GetAll()
		table.Add(_filter, ents.FindByClass("vehiclepart"))
		table.insert(_filter, self)
		local tr = util.TraceLine({start = eyepos, endpos = eyepos + owner:GetAimVector() * 100, filter = _filter, mask = MASK_SOLID})
		
		if tr.Hit and not tr.HitSky then
			if owner:GetStatus("spellsaber_shockblade") then
				if owner:IsCarrying() or owner:GetStatus("anchor") then return end
				owner:SetMana(math.max(0, owner:GetMana() - 15), true)
				local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)
					effectdata:SetNormal(tr.HitNormal)
					SuppressHostEvents(NULL)
				util.Effect("shockwave", effectdata)
				owner:SetGroundEntity(NULL)
				owner:SetVelocity(Vector(0,0, owner:GetAimVector().z * -500))
			end
			if owner:GetStatus("spellsaber_nullblade") then
				owner:SetMana(math.max(0, owner:GetMana() - 20), true)
				local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)
					SuppressHostEvents(NULL)
				util.Effect("nullexplode", effectdata)

				CounterSpellEffect(owner, tr.HitPos, 256)
			end
		end

		for _, ent in pairs(ents.FindInSphere(eyepos + owner:GetAimVector() * 30, 24)) do
			if ent:GetTeamID() ~= ownerteam then
				if ent.PHealth or ent.ScriptVehicle or ent.VehicleParent then
					if MeleeVisible(ent:NearestPoint(eyepos), eyepos, {ent, owner}) then
						ent:EmitSound("ambient/machines/slicer"..math.random(4)..".wav", 76, math.Rand(108, 112))
						ent:TakeSpecialDamage(self.Primary.Damage, DMGTYPE_SLASHING, owner, self)
						if (ent.PHealth or ent.ScriptVehicle) and ent:GetTeamID() ~= ownerteam then
							if owner:GetStatus("spellsaber_flameblade") then
								owner:SetMana(math.max(0, owner:GetMana() - 15), true)
								ent:TakeSpecialDamage(12 * (owner:GetStatus("ruin") and 2/3 or 1), DMGTYPE_FIRE, owner, self)
							end
							if owner:GetStatus("spellsaber_stormblade") then
								owner:SetMana(math.max(0, owner:GetMana() - 20), true)
								ent:TakeSpecialDamage(10 * (owner:GetStatus("ruin") and 2/3 or 1), DMGTYPE_LIGHTNING, owner, self)
							end
						end
					end
				elseif ent:IsPlayer() then
					local nearest = ent:NearestPoint(eyepos)
					if ent:Alive() and TrueVisible(nearest, eyepos) then
						ent:BloodSpray(nearest, math.random(4, 7), owner:GetAimVector(), 150)
						ent:EmitSound("ambient/machines/slicer"..math.random(4)..".wav", 76, math.random(108, 112))
						ent:TakeSpecialDamage(self.Primary.Damage, DMGTYPE_SLASHING, owner, self)
						if owner:GetStatus("spellsaber_flameblade") then
							owner:SetMana(math.max(0, owner:GetMana() - 15), true)
							ent:GiveStatus("flameblade_burn", 2.4).Inflictor = owner
						end
						if owner:GetStatus("spellsaber_corruptblade") then
							owner:SetMana(math.max(0, owner:GetMana() - 30), true)
							ent:GiveStatus("corruption", 3).Inflictor = owner
						end
						if owner:GetStatus("spellsaber_sanguineblade") then
							owner:SetMana(math.max(0, owner:GetMana() - 25), true)
							ent:EmitSound("npc/ichthyosaur/snap.wav")
						end
						if owner:GetStatus("spellsaber_stormblade") then
							ent:GiveStatus("stormblade_arc", 0.6).Inflictor = owner
							owner:SetMana(math.max(0, owner:GetMana() - 20), true)
						end
						if owner:GetStatus("spellsaber_shockblade") then
							owner:SetMana(math.max(0, owner:GetMana() - 15), true)
							local effectdata = EffectData()
								effectdata:SetOrigin(ent:NearestPoint(eyepos))
								effectdata:SetNormal(Vector(0,0,1))
								SuppressHostEvents(NULL)
							util.Effect("shockwave", effectdata)
							if ent:GetStatus("anchor") then return end
							ent:SetGroundEntity(NULL)
							ent:SetVelocity((owner:GetPos() - ent:GetPos()):GetNormal() * -500 + Vector(0, 0, 140))
						end
						if owner:GetStatus("spellsaber_nullblade") then
							local manaleech = math.min(12, ent:GetMana())
							if 0 < manaleech then
								local effectdata = EffectData()
									effectdata:SetOrigin(ent:NearestPoint(eyepos))
									effectdata:SetEntity(ent)
									effectdata:SetMagnitude(0)
									SuppressHostEvents(NULL)
								util.Effect("drainmana", effectdata)
								ent:SetMana(ent:GetMana() - manaleech, true)
								owner:SetMana(math.max(0, owner:GetMana() - 20), true)
							end
						end
					end
				end
			end
		end

		if owner.WeaponStatus and owner.WeaponStatus:IsValid() then
			owner.WeaponStatus:SetSkin(0)
		end

		owner:LagCompensation(false)
	end
	self:NextThink(ct)
	return true
end

local function CreateIcePath(owner, pos, teamid)
	if not owner:IsValid() or not owner:Alive() or owner:GetMana() < 4 then return end

	local ent = ents.Create("ice_path")

	if ent:IsValid() then
		ent:SetPos(pos)
		if owner:IsValid() then
			ent:SetOwner(owner)
		end
		ent:SetTeamID(teamid)
		ent:Spawn()
		owner:SetMana(math.max(0, owner:GetMana() - 4), true)
	end
end

function SWEP:PrimaryAttack()
	local owner = self.Owner
	
	if CurTime() < self.NextAttack or owner:KeyDown(IN_ATTACK2) or not owner:GetStatus("weapon_spell_saber") then return end

	self.NextAttack = CurTime() + self.Primary.Delay
	self.FinishSwing = CurTime() + 0.19
	
	if owner:GetStatus("blade_spirit") then
		local blades = owner:GetStatus("blade_spirit"):GetBlades()
		owner:GetStatus("blade_spirit"):SetBlades(blades - 1)
		owner:EmitSound("npc/roller/blade_out.wav", 80, math.Rand(95, 105))
		local ent = ents.Create("projectile_blade_spirit")
		if ent:IsValid() then
			ent:SetOwner(owner)
			ent:SetTeamID(owner:Team())
			ent:SetPos(owner:GetShootPos())
			ent:Spawn()
			ent:SetAngles(owner:EyeAngles())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocity(owner:GetAimVector() * 1500)
			end
		end
	end

	owner:EmitSound("nox/sword_miss.ogg", 80, math.Rand(105, 113))
	owner:DoAttackEvent()

	local eyepos = owner:EyePos()
	local ownerteam = owner:Team()

	owner:RemoveInvisibility()

	if owner.WeaponStatus and owner.WeaponStatus:IsValid() then
		owner.WeaponStatus:SetSkin(1)
	end
	
	if owner:GetStatus("spellsaber_frostblade") then
		local vStart = owner:GetPos() + Vector(0,0,32)
		local vForward = owner:GetAngles():Forward()
		local _filter = player.GetAll()
		table.Add(_filter, ents.FindByClass("ice_path"))

		local tocreate = {}

		local dist = 64
		for i=1, 5 do
			local tr = util.TraceLine({start = vStart, endpos = dist * vForward + vStart, filter = _filter, mask = MASK_SOLID})
			local tr2 = util.TraceLine({start = tr.HitPos, endpos = tr.HitPos + Vector(0, 0, -100), filter = _filter, mask = MASK_SOLID})

			if tr2.Hit then
				dist = dist + 80
				table.insert(tocreate, tr2.HitPos)
			end

			if tr.Hit then break end
		end

		if #tocreate <= 0 then return true end

		local teamid = owner:GetTeamID()
		for i, pos in ipairs(tocreate) do
			timer.Simple(i * 0.1, function() CreateIcePath( owner, pos, teamid) end)
		end
	end
end

