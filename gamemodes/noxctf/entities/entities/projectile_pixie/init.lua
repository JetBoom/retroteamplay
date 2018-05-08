AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.CounterSpell = COUNTERSPELL_DESTROY

	self:SetMaterial("models/props_combine/stasisfield_beam")
	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(4)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	self.DeathTime = CurTime() + 3.125

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end
	
	self.Touched = {}
end

function ENT:Think()
	if self.PhysicsData then
		self.DeathTime = 0
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
		util.Effect("PixieHit", effectdata)
	end
	
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 62)) do
		if ent:IsValid() then
			local owner = self:GetOwner()
			if ent:IsPlayer() and ent:Team() ~= owner:Team() and not self.Touched[ent] then
				ent:TakeSpecialDamage(15, DMGTYPE_GENERIC, owner, self)
				local effectdata = EffectData()
					effectdata:SetOrigin(self:NearestPoint(self:GetPos(),ent:GetPos()))
				util.Effect("PixieHit", effectdata)
				self.Touched[ent] = true
			end
		end
	end
	
	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

