AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.DeathTime = CurTime() + 10
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetMass(4)
		phys:SetBuoyancyRatio(0.05)
		phys:Wake()
	end

	self.HitAlready = {}

	self.Killed = 0
	self.Damage = self.Damage or 50
	self:EmitSound("nox/arrow_flying0"..math.random(1,2)..".ogg")
end

function ENT:Think()
	if self.PhysicsData and not self.Hit then
		self.Hit = true

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
			phys:EnableCollisions(false)
		end

		self:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.NoTouch then return end
	self.NoTouch = true

	local ent = data.HitEntity
	if not ent:IsValid() or ent.PHealth then
		self.PhysicsData = data

		self.DeathTime = CurTime() + 5

		self:NextThink(CurTime())
	end
end

function ENT:Touch(ent)
	if self.NoTouch or self.HitAlready[ent] or self:GetSkin() ~= 0 then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if ent:IsPlayer() and ent:GetTeamID() ~= self:GetTeamID() then
		ent:BloodSpray(ent:NearestPoint(self:GetPos()), math.random(8, 12), self:GetVelocity():GetNormal(), 140)
	end

	ent:TakeSpecialDamage(self.Damage, DMGTYPE_PIERCING, owner, self)
	ent:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav")

	self.HitAlready[ent] = true
end
