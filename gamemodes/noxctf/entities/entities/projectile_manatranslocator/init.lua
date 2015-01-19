AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.DeathTime = CurTime() + 30
	self:PhysicsInitSphere(5)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0.000001)
		phys:SetMass(5)
		phys:Wake()
	end

	self.ManaAmount = self.ManaAmount or 50
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:Explode(hitpos, hitnormal, hitentity)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)
	hitentity = hitentity or NULL

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	if hitentity:IsValid() and hitentity.ManaStorage then
		if not hitentity.ManaReceived or not hitentity:ManaReceived(self, self.ManaAmount) then
			hitentity.ManaStorage = math.min(hitentity.MaxManaStorage, hitentity.ManaStorage + self.ManaAmount)
		end

		util.Effect("manatranslocatorrec", effectdata)
	else
		util.Effect("ebexplode", effectdata)
		ExplosiveDamage(owner, hitpos, 100, 100, 0, 0.4, 1, self, DMGTYPE_ELECTRIC)
	end

	self:NextThink(CurTime())
end
