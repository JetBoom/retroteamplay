AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(0.1)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:EnableDrag(false)
	phys:EnableGravity(false)
	phys:SetBuoyancyRatio(0.00001)
	phys:Wake()

	self.DeathTime = CurTime() + 8
end

function ENT:Think()
	if self.PhysicsData and not self.Hit then
		self.Hit = true
		self.DeathTime = 0

		local data = self.PhysicsData
		local ent = data.HitEntity
		if ent:IsValid() then
			ent:TakeSpecialDamage(7, DMGTYPE_GENERIC, self:GetOwner(), self)
		end

		local effectdata = EffectData()
			effectdata:SetOrigin(data.HitPos)
			effectdata:SetNormal(data.HitNormal)
		util.Effect("pulsecannonhit", effectdata)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
