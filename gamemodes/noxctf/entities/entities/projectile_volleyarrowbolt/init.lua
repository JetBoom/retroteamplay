AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.DeathTime = CurTime() + 30
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:DrawShadow(false)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0.05)
		phys:Wake()
	end
end

function ENT:Think()
	if self.PhysicsData and not self.Hit then
		self.Hit = true

		local data = self.PhysicsData
		self.PhysicsData = nil

		local ent = data.HitEntity
		if ent:IsValid() then
			local owner = self:GetOwner()
			if not owner:IsValid() then owner = self end

			if ent:IsPlayer() then
				ent:BloodSpray(data.HitPos, math.random(5, 7), data.OurOldVelocity:GetNormal(), 125)
			end
			ent:TakeSpecialDamage(self.Damage, DMGTYPE_PIERCING, owner, self)
			ent:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav")
			self.DeathTime = 0
		else
			self:EmitSound("physics/metal/sawblade_stick"..math.random(1, 3)..".wav")
			self.DeathTime = CurTime() + 5
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
				phys:EnableCollisions(false)
			end
		end
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
