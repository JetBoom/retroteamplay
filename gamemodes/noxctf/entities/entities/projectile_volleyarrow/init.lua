AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.DeathTime = CurTime() + 30
	self.Created = CurTime()
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0.05)
		phys:Wake()
	end
	self:EmitSound("nox/arrow_flying0"..math.random(1,2)..".ogg")
	self.Dot = self:GetForward():Dot(Vector(0,0,1))
end

function ENT:Think()
	local owner = self:GetOwner()
	local vel = self:GetVelocity()
	
	if not self.Volley then
		if self.AttackStrength > 0.8 and self.Dot >= 0.95 and ((not self.Hit and (CurTime() - self.Created) > 0.7) or self.HitSky) then
			local arrowrain = ents.Create("arrowrain")
			if arrowrain then
				arrowrain:SetPos(self:GetPos())
				arrowrain.Spawner = self
				arrowrain:SetOwner(owner)
				arrowrain:SetTeamID(owner:Team())
				arrowrain:Spawn()
			end
			
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(Vector(0,0,-1)*1500)
			end
			self.Volley = true
		elseif (CurTime() - self.Created) > 0.3 then
			self:DoVolley()
		end
	end
	
	if self.PhysicsData and not self.Hit then
		self.Hit = true

		local data = self.PhysicsData
		self.PhysicsData = nil

		local tr = util.TraceLine({start = self:GetPos(), endpos = self:GetPos() + data.OurOldVelocity:GetNormal() * 50, filter = self})
		if tr.HitSky then
			self.HitSky = true
		end
		
		local ent = data.HitEntity
		if ent:IsValid() then
			local owner = self:GetOwner()
			if not owner:IsValid() then owner = self end

			if ent:IsPlayer() then
				ent:BloodSpray(data.HitPos, math.random(5, 7), data.OurOldVelocity:GetNormal(), 125)
			end
			ent:TakeSpecialDamage(self.Damage, DMGTYPE_PIERCING, owner, self)
			ent:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav")
			self.DeathTime = 0
		else
			self:EmitSound("physics/metal/sawblade_stick"..math.random(1, 3)..".wav")
			self.DeathTime = CurTime() + 5
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
				phys:EnableCollisions(false)
			end
		end
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:DoVolley()
	local owner = self:GetOwner()
	local vel = self:GetVelocity()
	if not self.Hit and (self.Dot < 0.95 or self.AttackStrength <= 0.8) and not self.Volley then
		self:EmitSound("nox/arrow_flying0"..math.random(1,2)..".ogg")
		self.Volley = true
		for i=1, 5 do
			local arrow = ents.Create("projectile_volleyarrowbolt")
			if arrow:IsValid() then
				arrow:SetOwner(owner)
				local dir = (vel:GetNormal() + VectorRand() * 0.05):GetNormal()
				arrow:SetPos(self:GetPos() + dir * 8)
				arrow:SetAngles(dir:Angle())
				arrow:SetTeamID(self:GetTeamID())
				arrow.Damage = self.Damage * 0.3
				local teamid = owner:Team()
				local col = team.GetColor(teamid)
				arrow:SetColor(Color(col.r, col.g, col.b, 255))
				arrow:Spawn()
				local phys = arrow:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(dir * vel:Length() * math.Rand(0.9,1))
				end
			end
		end
		self:Remove()
	end
end


function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
