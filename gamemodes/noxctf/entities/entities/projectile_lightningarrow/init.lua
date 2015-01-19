AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.DeathTime = CurTime() + 30
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0.001)
		phys:Wake()
	end

	self:EmitSound("nox/shocked.ogg", 77, math.random(75, 90))
	self:EmitSound("nox/shocked.ogg", 76, math.random(75, 90))
end

function ENT:Think()
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:Hit(hitpos, hitnormal, hitentity)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)
	hitentity = hitentity or NULL

	local effect2 = ents.Create("point_tesla")
	if effect2:IsValid() then
		effect2:SetKeyValue("m_flRadius", "200")
		effect2:SetKeyValue("m_SoundName", "DoSpark")
		effect2:SetKeyValue("m_Color", "255 255 255")
		effect2:SetKeyValue("texture", "effects/laser1.vmt")
		effect2:SetKeyValue("beamcount_min", "6")
		effect2:SetKeyValue("beamcount_max", "10")
		effect2:SetKeyValue("thick_min", "20")
		effect2:SetKeyValue("thick_max", "50")
		effect2:SetKeyValue("lifetime_min", "0.5")
		effect2:SetKeyValue("lifetime_max", "1")
		effect2:SetKeyValue("interval_min", "0.1")
		effect2:SetKeyValue("interval_max", "0.25")
		effect2:SetPos(hitpos + hitnormal * 8)
		effect2:Spawn()
		effect2:Fire("DoSpark", "", 0.1)
		effect2:Fire("DoSpark", "", 0.3)
		effect2:Fire("DoSpark", "", 0.5)
		effect2:Fire("kill", "", 0.8)
	end

	self:EmitSound("nox/lightning_impact.ogg", 79, math.random(95, 110))

	local owner = self:GetOwner()
	if not owner:IsValid() then	owner = self end

	if hitentity:IsValid() then
		hitentity:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav")
		hitentity:TakeSpecialDamage(self.Damage, DMGTYPE_LIGHTNING, owner, self, hitpos)
		self:NextThink(CurTime())
	else
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
			phys:EnableCollisions(false)
		end
		self.DeathTime = CurTime() + 5
	end
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
