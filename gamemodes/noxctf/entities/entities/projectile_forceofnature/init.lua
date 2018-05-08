AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.CounterSpell = COUNTERSPELL_EXPLODE

function ENT:Initialize()
	self:SetMaterial("models/shiny")
	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(16)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetTrigger(true)

	self.DeathTime = CurTime() + 6

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
		phys:SetMass(5)
	end

	self.Touched = {}
end

function ENT:Think()
	if CurTime() >= self.DeathTime then self:Remove() return end
end

function ENT:PhysicsCollide(data, phys)
	if data.DeltaTime > 0.2 then
		local effectdata = EffectData()
			effectdata:SetOrigin(data.HitPos)
			effectdata:SetNormal(data.HitNormal)
			effectdata:SetMagnitude(self:GetTeamID())
		util.Effect("forceofnaturebounce", effectdata)
	end

	local normal = data.OurOldVelocity:GetNormalized()
	phys:SetVelocityInstantaneous((2 * data.HitNormal * data.HitNormal:Dot(normal * -1) + normal) * 600)

	self.OwnerTouches = true
	self.Touched = {}
end

function ENT:StartTouch(ent)
	if ent:IsValid() then
		local owner = self:GetOwner()
		if ent:IsPlayer() and (ent ~= owner or self.OwnerTouches) and not self.Touched[ent] then
			ent:TakeSpecialDamage(48, DMGTYPE_GENERIC, owner, self)

			self.Touched[ent] = true
		end
	end
end

function ENT:Explode()
	self.DeathTime = 0

	local owner = self
	local teamid = 0
	if self:GetOwner() and self:GetOwner():IsValid() then
		owner = self:GetOwner()
		teamid = owner:GetTeamID()
	end

	for i=1, 6 do
		local ent = ents.Create("projectile_forceofnaturefragment")
		if ent:IsValid() then
			local offset = VectorRand()
			ent:SetPos(self:GetPos() + offset * 24)
			ent:SetTeamID(teamid)
			local speed = math.Rand(900, 1400)
			ent.Speed = speed
			ent:SetSkin(teamid)
			ent:Spawn()
			ent:SetOwner(owner)
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(offset * speed)
			end
		end
	end
end
