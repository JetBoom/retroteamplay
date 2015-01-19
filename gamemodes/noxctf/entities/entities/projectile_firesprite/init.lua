AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.CounterSpell = COUNTERSPELL_DESTROY

function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(15)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(true)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 20
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	local ct = CurTime()
	if self.DeathTime <= ct then
		self:Remove()
		return
	elseif 0 < self:WaterLevel() then
		self:Explode()
		return
	end

	local owner = self:GetOwner()
	if owner:IsValid() and owner:IsPlayer() and owner:Alive() then
		local mypos = self:GetPos()

		local target = owner:TraceHull(10240, MASK_SOLID, 4).HitPos
		local vHeading = (target - mypos):GetNormal()
		local aOldHeading = self:GetVelocity():Angle()
		self:SetAngles(aOldHeading)

		if target:Distance(mypos) < 89 then
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(vHeading * 1500)
			end
		else
			local diffang = self:WorldToLocalAngles(vHeading:Angle())

			local ft = FrameTime() * math.max(1.4, math.min(5.2, 6 - target:Distance(mypos) * 1.2))
			aOldHeading:RotateAroundAxis(aOldHeading:Up(), diffang.yaw * ft)
			aOldHeading:RotateAroundAxis(aOldHeading:Right(), diffang.pitch * -ft)

			local vNewHeading = aOldHeading:Forward()
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(vNewHeading * 1500)
			end
		end
	end

	self:NextThink(ct)
	return true
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

	ExplosiveDamage(owner, hitpos, 72, 72, 1, 0.5, 2, self)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("firespriteexplosion", effectdata)

	self:NextThink(CurTime())
end
