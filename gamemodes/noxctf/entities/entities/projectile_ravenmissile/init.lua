AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Target = NULL

function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(5)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 20
end

function ENT:Think()
	local ct = CurTime()

	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.DeathTime <= ct then
		self:Remove()
	elseif 0 < self:WaterLevel() then
		self:Explode()
	elseif self.Target:IsValid() then
		self.DeathTime = ct + 15

		local target = self.Target
		local mypos = self:GetPos()
		local nearest = (target:NearestPoint(mypos) + target:LocalToWorld(target:OBBCenter()) * 0.6) / 1.6
		local vHeading = (nearest - mypos):GetNormalized()
		local aOldHeading = self:GetVelocity():Angle()

		self:SetAngles(aOldHeading)
		local diffang = self:WorldToLocalAngles(vHeading:Angle())

		local ft = FrameTime() * math.max(3, math.min(7, 7 - nearest:Distance(mypos) * 0.97))
		aOldHeading:RotateAroundAxis(aOldHeading:Up(), diffang.yaw * ft)
		aOldHeading:RotateAroundAxis(aOldHeading:Right(), diffang.pitch * -ft)

		local vNewHeading = aOldHeading:Forward()
		self:GetPhysicsObject():SetVelocityInstantaneous(vNewHeading * self.Speed)

		if 1.4 < vNewHeading:Distance(vHeading) then
			self.Target = NULL
			if target.SendLua then
				target:SendSound("buttons/button14.wav")
			else
				local enemydriver = target.PilotSeat:GetDriver()
				if enemydriver:IsValid() then
					enemydriver:SendSound("buttons/button14.wav")
				end
			end
		else
			self:NextThink(ct)
			return true
		end
	end
end

function ENT:PhysicsCollide(data, phys)
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

	ExplosiveDamage(owner, hitpos, 200, 200, 1, 0.4, 8, self)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("rovercannonexplosion", effectdata)

	self:NextThink(CurTime())
end

function ENT:SetTarget(ent)
	self.Target = ent

	local owner = self:GetOwner()
	if owner:IsValid() and owner:IsPlayer() then
		owner:SendSound("buttons/button3.wav")
	end

	for _, veh in pairs(ents.FindByClass("prop_vehicle_*")) do
		if veh:GetVehicleParent() == ent then
			local enemydriver = veh:GetDriver()
			if enemydriver:IsPlayer() then enemydriver:SendLua("RLO()") end
		end
	end
end
