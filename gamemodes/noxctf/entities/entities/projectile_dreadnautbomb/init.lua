AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.DeathTime = CurTime() + 20
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetMass(5)
		phys:Wake()
	end

	self:SetMaterial("models/antlion/antlion_innards")
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	elseif 0 < self:WaterLevel() then
		self:Explode()
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:PhysicsUpdate(phys)
	phys:AddVelocity(Vector(0, 0, 440 * FrameTime()))
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ExplosiveDamage(owner, hitpos, 350, 350, 1, 0.375, 8, self)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	local elec = self.Electricity
	if elec then
		local effect2 = ents.Create("point_tesla")
		if effect2:IsValid() then
			effect2:SetKeyValue("m_flRadius", "800")
			effect2:SetKeyValue("m_SoundName", "DoSpark")
			effect2:SetKeyValue("m_Color", "255 255 255")
			effect2:SetKeyValue("texture", "effects/laser1.vmt")
			effect2:SetKeyValue("beamcount_min", "35")
			effect2:SetKeyValue("beamcount_max", "55")
			effect2:SetKeyValue("thick_min", "170")
			effect2:SetKeyValue("thick_max", "300")
			effect2:SetKeyValue("lifetime_min", "1")
			effect2:SetKeyValue("lifetime_max", "3")
			effect2:SetKeyValue("interval_min", "0.1")
			effect2:SetKeyValue("interval_max", "0.3")
			effect2:SetPos(hitpos)
			effect2:Spawn()
			effect2:Fire("DoSpark", "", 0)
			effect2:Fire("DoSpark", "", 0.1)
			effect2:Fire("DoSpark", "", 0.2)
			effect2:Fire("kill", "", 0.5)
		end

		local elecowner = elec:IsPlayer() and elec
		if not elecowner then elecowner = owner end

		ExplosiveDamage(elecowner, hitpos, 400, 60, 0, 1, 60, DUMMY_SHOCKNAUT, DMGTYPE_SHOCK)
		effectdata:SetMagnitude(1)
	else
		effectdata:SetMagnitude(0)
	end

	util.Effect("dreadnautexplosion", effectdata)

	self:NextThink(CurTime())
end
