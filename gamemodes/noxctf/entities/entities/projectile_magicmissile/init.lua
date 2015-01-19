AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Target = NULL

function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(4)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 7
	self.SpawnTime = CurTime() + 0.3
end

function ENT:Think()
	if self.PhysicsData and self.SpawnTime <= CurTime() then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.DeathTime <= CurTime() or self.Exploded then
		self:Remove()
	elseif 0 < self:WaterLevel() then
		self:Explode()
	else
		if not self.Trailed then
			self.Trailed = true
			util.SpriteTrail(self, 0, Color(255, 255, 120, 160), false, 22, 16, 1, 1 / 42, "trails/smoke.vmt")
		end

		local target = self.Target
		if target:IsValid() and target:Alive() then
			local mypos = self:GetPos()
			local nearest = (target:NearestPoint(mypos) + target:LocalToWorld(target:OBBCenter()) * 0.6) / 1.6
			local vHeading = (nearest - mypos):GetNormalized()
			local aOldHeading = self:GetVelocity():Angle()

			self:SetAngles(aOldHeading)
			local diffang = self:WorldToLocalAngles(vHeading:Angle())

			local ft = FrameTime() * 2.5
			aOldHeading:RotateAroundAxis(aOldHeading:Up(), math.Clamp(diffang.yaw, -34, 34) * ft)
			aOldHeading:RotateAroundAxis(aOldHeading:Right(), math.Clamp(diffang.pitch, -34, 34) * -ft)

			local vNewHeading = aOldHeading:Forward()
			self:GetPhysicsObject():SetVelocityInstantaneous(vNewHeading * self.Speed)
		else
			local myteam = self:GetTeamID()
			local mypos = self:GetPos()
			for _, ent in pairs(ents.FindInSphere(mypos, 256)) do
				if ent:IsPlayer() and ent:GetTeamID() ~= myteam and ent:Alive() and ent:IsVisibleTarget(self:GetOwner()) and TrueVisible(mypos, ent:NearestPoint(mypos)) then
					self.Target = ent
					break
				end
			end
		end
	end

	self:NextThink(CurTime())
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

	ExplosiveDamage(owner, hitpos, 50, 50, 0.5, 0.16, 1, self)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("magicmissileexplosion", effectdata)

	self:NextThink(CurTime())
end
