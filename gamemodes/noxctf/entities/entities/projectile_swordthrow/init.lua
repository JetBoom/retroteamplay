AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(4)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
		phys:Wake()
	end
	self.Returning = false
	self.DeathTime = CurTime() + 30
	self.ReturnTime = CurTime() + 1.35
	self.SpawnedTime = CurTime()
	self.Touched = {}
	self.OriginalOwner = self:GetOwner()
	self.OriginalOwner.SwordThrow = true
	self.OldPos = self:GetPos()
end

function ENT:OnRemove()
	self.OriginalOwner.AbilityDelays[NameToSpell["Sword Throw"]] = CurTime() + (10 - math.min(10, CurTime() - self.SpawnedTime ))
	self.OriginalOwner:DI(NameToSpell["Sword Throw"], 10 - math.min(10, CurTime() - self.SpawnedTime ))
	self.OriginalOwner:RemoveStatus("swordwarp", false, true)
	if self.OriginalOwner:GetPlayerClassTable().Name == "Spell Saber" and self.OriginalOwner:Alive() then
		self.OriginalOwner:GiveStatus("weapon_spell_saber")
	end
	self.OriginalOwner:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
	self.OriginalOwner.SwordThrow = false
end

function ENT:Think()
	local owner = self:GetOwner()

	if self.PhysicsData then
		self:ComeBack()
	end

	if self.DeathTime <= CurTime() or not owner:IsValid() then
		self:Remove()
	end
	if self.ReturnTime <= CurTime() then
		self:ComeBack()
	end
	
	local phys = self:GetPhysicsObject()
	local ownerteam = owner:Team()

	if self.Returning then
		if not self.OriginalOwner:Alive() or self.OriginalOwner:GetPlayerClassTable().Name ~= "Spell Saber" then
			self:Remove()
		end
		if self.OriginalOwner:EyePos():Distance(self:GetPos()) < 66 then
			self:Remove()
		end
		
		self:SetSolid(SOLID_NONE)
		if phys:IsValid() then
			local prediction
			if self.OriginalOwner:GetStatus("swordwarp") then
				prediction = Vector(0,0,0)
			else
				prediction = self.OriginalOwner:GetVelocity() * 0.9
			end
			phys:SetVelocity(prediction + (self.OriginalOwner:EyePos() - phys:GetPos()):GetNormal() * 700)
		end
	end
	
	if owner:GetStatus("spellsaber_frostblade") then
		local _filter = player.GetAll()
		table.Add(_filter, ents.FindByClass("ice_path"))
		table.insert(_filter, self)
		local tr = util.TraceLine({start = self:GetPos(), endpos = self:GetPos() + Vector(0,0,-70), filter = _filter, mask = MASK_SOLID + MASK_WATER})
		if tr.Hit and self:GetPos():Distance(self.OldPos) > 80 then
			if owner:GetMana() < 4 then return end
			self.OldPos = self:GetPos()
			local path = ents.Create("ice_path")
			if path:IsValid() then
				path:SetPos(tr.HitPos)
				if owner:IsValid() then
					path:SetOwner(owner)
				end
				path:SetTeamID(owner:GetTeamID())
				path:Spawn()
				owner:SetMana(math.max(0, owner:GetMana() - 4), true)
			end
			if tr.Hit and tr.MatType == 83 then
				local ent2 = ents.Create("iceburg")
				if ent2:IsValid() then
					ent2:SetPos(tr.HitPos + Vector(0,0,-48))
					ent2:Spawn()
					for _, pl in pairs(ents.FindInSphere(tr.HitPos,40)) do
						if pl:IsPlayer() then 
							ent2:Remove()
						end
					end
				end
			end
		end
	end
	
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 55)) do
		if ent:IsValid() then
			if ent:IsPlayer() and MeleeVisible(ent:NearestPoint(self:GetPos()), self:GetPos(), {ent, self}) and not self.Touched[ent] and ent:GetTeamID() ~= ownerteam and ent:Alive() then
				ent:TakeSpecialDamage(15, DMGTYPE_SLASHING, owner, self)
				self.Touched[ent] = true
				ent:BloodSpray(ent:WorldSpaceCenter(), 12, VectorRand(), 150)
				ent:EmitSound("ambient/machines/slicer"..math.random(1,4)..".wav", 76, math.random(108, 112))
				if owner:GetStatus("spellsaber_flameblade") and owner:GetMana() >= 15 then
					owner:SetMana(math.max(0, owner:GetMana() - 15), true)
					ent:GiveStatus("flameblade_burn", 2.4).Inflictor = owner
				end
				if owner:GetStatus("spellsaber_corruptblade") and owner:GetMana() >= 30 then
					owner:SetMana(math.max(0, owner:GetMana() - 30), true)
					ent:GiveStatus("corruption", 3).Inflictor = owner
				end
				if owner:GetStatus("spellsaber_stormblade") and owner:GetMana() >= 20 then
					owner:SetMana(math.max(0, owner:GetMana() - 20), true)
					ent:GiveStatus("stormblade_arc", 0.6).Inflictor = owner
				end
				if owner:GetStatus("spellsaber_shockblade") and owner:GetMana() >= 15 then
					owner:SetMana(math.max(0, owner:GetMana() - 15), true)
					local effectdata = EffectData()
						effectdata:SetOrigin(ent:NearestPoint(self:GetPos()))
						effectdata:SetNormal(Vector(0,0,1))
					util.Effect("shockwave", effectdata)
					if ent:GetStatus("anchor") then return end
					ent:SetGroundEntity(NULL)
					local pushforce = (self:GetPos() - ent:GetPos()):GetNormal()
					ent:SetVelocity(Vector(pushforce.x * -500, pushforce.y * -500, 200))
				end
				if owner:GetStatus("spellsaber_sanguineblade") and owner:GetMana() >= 25 then
					owner:SetMana(math.max(0, owner:GetMana() - 25), true)
					ent:EmitSound("npc/ichthyosaur/snap.wav")
				end
				if owner:GetStatus("spellsaber_nullblade") and owner:GetMana() >= 20 then
					local manaleech = math.min(12, ent:GetMana())
					if 0 < manaleech then
						local effectdata = EffectData()
						effectdata:SetOrigin(self:GetPos())
						effectdata:SetEntity(ent)
						effectdata:SetMagnitude(0)
						SuppressHostEvents(NULL)
						util.Effect("drainmana", effectdata)
						ent:SetMana(ent:GetMana() - manaleech, true)
						owner:SetMana(math.max(0, owner:GetMana() - 20), true)
					end
				end
			end
			if (ent.PHealth or ent.ScriptVehicle) and ent:GetTeamID() ~= ownerteam and MeleeVisible(ent:NearestPoint(self:GetPos()), self:GetPos(), {ent, self}) and not self.Touched[ent] and not self.Returning then
				ent:TakeSpecialDamage(15, DMGTYPE_SLASHING, owner, self)
				self.Touched[ent] = true
				ent:EmitSound("ambient/machines/slicer"..math.random(1,4)..".wav", 76, math.random(108, 112))
				if owner:GetStatus("spellsaber_flameblade") and owner:GetMana() >= 15 then
					owner:SetMana(math.max(0, owner:GetMana() - 15), true)
					ent:TakeSpecialDamage(12, DMGTYPE_FIRE, owner, self)
				end
				if owner:GetStatus("spellsaber_stormblade") and owner:GetMana() >= 20 then
					owner:SetMana(math.max(0, owner:GetMana() - 20), true)
					ent:TakeSpecialDamage(10, DMGTYPE_LIGHTNING, owner, self)
				end
			end
		end
	end
	self:NextThink(CurTime())
	return true
end


function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:ComeBack()
	if self.Returning then return end
	local phys = self:GetPhysicsObject()
	self.Returning = true
	self.Touched = {}
	if phys:IsValid() then
		phys:AddAngleVelocity(Vector(-2000 - phys:GetAngleVelocity().x, phys:GetAngleVelocity().y * -1, phys:GetAngleVelocity().z * -1))
	end
end

