AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_DESTROY
	self:PhysicsInitSphere(6)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end
	self.DeathTime = CurTime() + 10
	self.ExplodeTime = CurTime() + 3.5
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		if not self.Split then
			self.Split = true

			local hitpos = self:GetPos()
			local owner = self:GetOwner()
			if not owner:IsValid() then owner = self end

			local seed = math.Rand(0, 360)
			local myteam = self:GetTeamID()
			for i=1 + seed, 360 + seed, 39.999 do
				local ent = ents.Create("projectile_starburstbolt")
				if ent:IsValid() then
					ent:SetOwner(owner)
					ent:SetTeamID(myteam)
					local dir = Vector(math.sin(i), math.cos(i), 0.65)
					ent:SetPos(hitpos + dir)
					ent:Spawn()
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous(dir * 325)
					end
				end
			end

			ExplosiveDamage(owner, hitpos, 120, 120, 1, 0.4, 1, self)

			local effectdata = EffectData()
				effectdata:SetOrigin(hitpos)
			util.Effect("Explosion", effectdata)
		end

		self:Remove()
	elseif 0 < self:WaterLevel() or self.ExplodeTime <= CurTime() then
		self:Explode()
	else
		local target
		local owner = self:GetOwner()
		if owner:IsValid() then
			target = owner:TraceLine(99999).HitPos
		elseif self.Target then
			target = self.Target
		else
			target = self:GetPos()
		end
		self:GetPhysicsObject():SetVelocityInstantaneous(((target - self:GetPos()):GetNormal() + self:GetVelocity():GetNormal() * 2.25):GetNormal() * 900)
	end
end

function ENT:PhysicsCollide(data, physobj)
	self:Explode()
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0
	self:NextThink(CurTime())
end
