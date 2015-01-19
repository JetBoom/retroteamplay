AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MAXRADIUS = 16

function ENT:Initialize()
	self:DrawShadow(false)

	self:SetTrigger(true)
	self:PhysicsInitSphere(16)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:EnableCollisions(false)
	end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetNotSolid(true)

	self.DeathTime = CurTime() + 0.4
	self.Touched = {}
end

function ENT:Touch(ent)
	local pos = self:GetPos()
	if ent:GetSolid() > 0 and ent:GetTeamID() ~= self:GetTeamID() and not self.Touched[ent] then
		local nearest = ent:NearestPoint(pos)
		if nearest:Distance(pos) <= 16 * (1 - (100 - pos:Distance(self.Origin)) / 100) and TrueVisible(self.Origin, nearest) then
			self.Touched[ent] = true

			ent:TakeSpecialDamage(6, DMGTYPE_FIRE, self:GetOwner(), self)
		end
	end
end

function ENT:Think()
	local radius = 16 * (1 - (100 - self:GetPos():Distance(self.Origin)) / 100)
	if radius >= 16 or self.DeathTime <= CurTime() then
		self:Remove()
	end
	
	self:NextThink(CurTime())
	return true
end
