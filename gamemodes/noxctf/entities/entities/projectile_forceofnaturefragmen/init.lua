AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props/cs_italy/orange.mdl")
	self:SetMaterial("models/shiny")
	self:SetColor(Color(50, 255, 50, 255))
	self:PhysicsInitSphere(6)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
		phys:SetMass(5)
	end

	self.CounterSpell = COUNTERSPELL_DESTROY
	self.DeathTime = CurTime() + 3
end

function ENT:Think()
	if CurTime() > self.DeathTime then self:Remove() return end
end

function ENT:PhysicsCollide(data, phys)
	if data.DeltaTime > 0.2 then
		self:EmitSound("nox/forceofnature_bounce.ogg", 85, 100)
	end

	local normal = data.OurOldVelocity:GetNormal()
	local DotProduct = data.HitNormal:Dot(normal * -1)

	phys:SetVelocityInstantaneous((2 * data.HitNormal * DotProduct + normal) * self.Speed)
end

function ENT:Touch(ent)
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if ent:IsValid() and ent:GetTeamID() ~= self:GetTeamID() then
		ent:TakeSpecialDamage(15, DMGTYPE_GENERIC, owner, self)
	end
end
