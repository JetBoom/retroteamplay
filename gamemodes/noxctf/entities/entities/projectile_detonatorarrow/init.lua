AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.DeathTime = CurTime() + 30
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:Wake()
	end

	self:EmitSound("nox/arrow_flying0"..math.random(1,2)..".ogg")
end

function ENT:Think()
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	elseif 0 < self:WaterLevel() or self.ExplodeTime and CurTime() >= self.ExplodeTime then
		self:Explode()
	elseif self.Hit then
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 32)) do
			if ent:IsPlayer() and ent:Alive() and ent:Team() ~= self:GetTeamID() then
				self:Explode()
				break
			end
		end
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:Hit(hitpos, hitnormal, hitentity)
	if self.Hit or self.Exploded then return end
	self.Hit = true
	self.DeathTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)
	hitentity = hitentity or NULL

	local owner = self:GetOwner()
	if not owner:IsValid() then	owner = self end

	if hitentity:IsValid() and (hitentity:IsPlayer() or not hitentity.PHealth) then
		self:Explode(hitpos, hitnormal)
	else
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
			phys:EnableCollisions(false)
		end
		self.ExplodeTime = CurTime() + 20
		self.DeathTime = CurTime() + 60
	end
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ExplosiveDamage(owner, hitpos, 85, 85, 1, 0.46, 1, self)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("firearrowhit", effectdata)

	self:NextThink(CurTime())
end
