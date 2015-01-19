AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_spanner.mdl")
	self:DrawShadow(false)
	self:PhysicsInitSphere(2)
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
	self.ReturnTime = CurTime() + 0.5
	self.SpawnedTime = CurTime()
	self.Touched = {}
	self.OriginalOwner = self:GetOwner()
	self.OldPos = self:GetPos()
end

function ENT:OnRemove()
	self.OriginalOwner:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
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
		if not self.OriginalOwner:Alive() or self.OriginalOwner:GetPlayerClassTable().Name ~= "Crafter" then
			self:Remove()
		end
		if self.OriginalOwner:EyePos():Distance(self:GetPos()) < 15 then
			self:Remove()
		end
		
		self:SetSolid(SOLID_NONE)
		if phys:IsValid() then
			phys:SetVelocity(self.OriginalOwner:GetVelocity() * 0.8 + (self.OriginalOwner:EyePos() - phys:GetPos()):GetNormal() * 1400)
		end
	end
	
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 20)) do
		if ent:IsValid() then
			if ent:IsPlayer() and MeleeVisible(ent:NearestPoint(self:GetPos()), self:GetPos(), {ent, self}) and not self.Touched[ent] and ent:GetTeamID() ~= ownerteam and ent:Alive() then
				ent:TakeSpecialDamage(10, DMGTYPE_IMPACT, owner, self)
				self.Touched[ent] = true
				ent:BloodSpray(ent:WorldSpaceCenter(), 12, VectorRand(), 150)
				ent:EmitSound("weapons/melee/wrench/wrench_hit-0"..math.random(1, 4)..".wav", 75, 100)
			end
			if (ent.PHealth or ent.ScriptVehicle) and ent:GetTeamID() ~= ownerteam and MeleeVisible(ent:NearestPoint(self:GetPos()), self:GetPos(), {ent, self}) and not self.Touched[ent] and not self.Returning then
				ent:TakeSpecialDamage(20, DMGTYPE_IMPACT, owner, self)
				self.Touched[ent] = true
				ent:EmitSound("weapons/melee/wrench/wrench_hit-0"..math.random(1, 4)..".wav", 75, 100)
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
		phys:AddAngleVelocity(Vector(phys:GetAngleVelocity().x * -1, -2000 -phys:GetAngleVelocity().y, phys:GetAngleVelocity().z * -1))
	end
end

