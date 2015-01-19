AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_EXPLODE
	self:PhysicsInitSphere(6)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self:SetColor(Color(255, 125, 75, 255))
	self:SetMaterial("models/props_wasteland/rockcliff04a")
	
	self.DeathTime = CurTime() + 10.0
	self.Created = CurTime() - 0.25
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
	if not self.ProjectileHeading and phys:GetVelocity():Length() > 0 then
		self.ProjectileHeading = phys:GetVelocity():GetNormal()
	end
	phys:SetVelocityInstantaneous(math.max(250, math.min((CurTime() - self.Created) * 400, 800)) * self.ProjectileHeading)
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ExplosiveDamage(owner, hitpos, 150, 150, 1, 0.45, 1, self)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("rovercannonexplosion", effectdata)

	self:NextThink(CurTime())
end
