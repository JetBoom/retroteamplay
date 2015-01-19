AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetMass(5)
		phys:Wake()
	end

	self:SetMaterial("models/shiny")

	self.DeathTime = CurTime() + 30
end

function ENT:Think()
	if CurTime() > self.DeathTime then
		self:Remove()
		return
	end

	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	elseif self:WaterLevel() > 0 then
		self:Explode()
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	for _, ent in pairs(ents.FindInSphere(hitpos,128)) do
		if ent:IsPlayer() and ent:Alive() and (ent:GetTeamID() ~= owner:GetTeamID() or ent == owner) and TrueVisible(hitpos, ent:NearestPoint(hitpos)) then
			ent:GiveStatus("burn", 5).Inflictor = owner
		end
	end

	for i=0, 15 do
		local ent = ents.Create("burn")
		local trpos = Vector(math.Rand(0, 192),math.Rand(0, 192), 0) * Angle(math.Rand(-180, 180), math.Rand(-180, 180), math.Rand(-180, 180)):Forward()
		local tr2 = util.TraceLine({start = hitpos, endpos = hitpos + trpos})
		local tr = util.TraceLine({start = tr2.HitPos + tr2.HitNormal, endpos = tr2.HitPos + tr2.HitNormal + Vector(0, 0, -256)})
		if ent:IsValid() then
			ent:SetPos(tr.HitPos + tr.HitNormal)
			ent:SetOwner(self:GetOwner())
			ent:Spawn()
			ent:SetTeamID(self:GetTeamID())
		end
	end
	
	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("rovercannonexplosion", effectdata)

	self:NextThink(CurTime())
end
