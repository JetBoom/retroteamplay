AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInitSphere(3)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0.05)
		phys:Wake()
	end

	self.NumBounces = 0
	self.MaxBounces = 5
	self.Touched = {}
	self.DeathTime = CurTime() + 30

	self:EmitSound("nox/arrow_flying0"..math.random(1,2)..".ogg")
end

function ENT:Think()
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.Hit then return end

	if self.NumBounces <= (self.MaxBounces - 1) then
		self.NumBounces = self.NumBounces + 1
		self.DeathTime = CurTime() + 15
		local normal = data.OurOldVelocity:GetNormal()
		phys:SetVelocityInstantaneous((2 * data.HitNormal * data.HitNormal:Dot(normal * -1) + normal) * data.OurOldVelocity:Length() * 0.8)
		self:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav", 70, 180)
	else
		self.Hit = true
		self:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")

		local heading = data.OurOldVelocity:GetNormal()
		local ang = heading:Angle()
		local hitpos = data.HitPos - heading * 10
		self:SetSolid(SOLID_NONE)
		self.DeathTime = CurTime() + 5
		if phys:IsValid() then
			phys:EnableMotion( false )
			phys:SetAngles(ang)
			phys:SetPos(hitpos)
		end
	end
end

function ENT:StartTouch(ent)
	local data = self.PhysicsData
	local owner = self:GetOwner()
	local pos = self:GetPos()
	if not self.Touched[ent] and ent:IsValid() and ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= owner:Team() then
		self.Touched[ent] = true
		ent:TakeSpecialDamage(self.Damage, DMGTYPE_PIERCING, owner, self)
		ent:BloodSpray(ent:NearestPoint(pos), math.random(5, 7), self:GetVelocity(), 125)
		ent:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav")
		local Near = {}
		for i, ent in ipairs(ents.FindInSphere(pos, 500)) do
			if not self.Touched[ent] and ent:IsValid() and ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= owner:Team() and TrueVisible(ent:NearestPoint(pos), pos) then
				Near[ent] = ent:NearestPoint(pos):Distance(pos) * -1
			end
		end
		local nearest = table.GetWinningKey( Near )
		local phys = self:GetPhysicsObject()
		if nearest then
			if self.NumBounces <= (self.MaxBounces - 1) then
				if phys:IsValid() then
					local normal = (nearest:LocalToWorld(nearest:OBBCenter()) - pos):GetNormal()
					phys:SetVelocityInstantaneous(normal * self:GetVelocity():Length() * 0.8)
					self.NumBounces = self.NumBounces + 1
				end
			else
				self:Remove()
			end
		else
			self:Remove()
		end
	end
end
