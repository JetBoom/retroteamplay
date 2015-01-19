AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Damage = 10
ENT.DamageType = DMGTYPE_PIERCING
ENT.Heading = Vector(0, 0, 1)
ENT.BulletSpeed = 2000

function ENT:Initialize()
	self:SetModel("models/Weapons/w_bullet.mdl")
	self:DrawShadow(false)
	self:PhysicsInitSphere(0.001)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0.00001)
		phys:Wake()
	end

	self:SetMaterial("models/shiny")

	self.DeathTime = CurTime() + 30
end

function ENT:Think()
	if self.DelaySetOwner and self.DelaySetOwner:IsValid() then
		self:SetOwner(self.DelaySetOwner)
		self.DelaySetOwner = nil
	end

	if self.PhysicsData then
		local data = self.PhysicsData
		self.PhysicsData = nil

		local hitentity = data.HitEntity
		if hitentity:IsValid() then
			hitentity:TakeSpecialDamage(self.Damage, self.DamageType, self:GetOwner(), self.Inflictor or self, data.HitPos)
		end

		local effectdata = EffectData()
			effectdata:SetOrigin(data.HitPos)
			effectdata:SetNormal(data.HitNormal)
			effectdata:SetMagnitude(self:GetTeamID() or 0)
		util.Effect("bullethit_basic", effectdata)

		self:Remove()
	elseif self.DeathTime <= CurTime() then	
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	if 0 < self.DeathTime then
		self.DeathTime = 0
		self.PhysicsData = data

		self:NextThink(CurTime())
	end
end
