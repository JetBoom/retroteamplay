AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.CounterSpell = COUNTERSPELL_DESTROY

	self:PhysicsInitSphere(4)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCustomCollisionCheck(true)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetBuoyancyRatio(0.00001)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 15
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
	elseif self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end

	self.Exploded = true

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end
	
	
	local tr = util.TraceLine({start = hitpos, endpos = hitpos + Vector(0, 0, -10000), mask=COLLISION_GROUP_DEBRIS})
	local hitpos = tr.HitPos or self:GetPos()

	local ent = ents.Create("burn")
	if ent:IsValid() then
		ent:SetPos(hitpos + tr.HitNormal)
		ent:SetOwner(owner)
		ent:Spawn()
		ent:SetTeamID(owner:GetTeamID())
		local effectdata = EffectData()
			effectdata:SetOrigin(hitpos)
		util.Effect("burn", effectdata)
	end
	
	self:Remove()
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:GetTeamID() ~= self:GetTeamID() and not ent:GetStatus("salamanderskin") then
		ent:GiveStatus("burn", 2)
	end
end
