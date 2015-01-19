AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_DESTROY
	self:PhysicsInitSphere(6)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 10
	self.ExplodeTime = CurTime() + 0.9
end

function ENT:Think()
	local owner = self:GetOwner()
	if self.DeathTime <= CurTime() then
		local hitpos = self.ExplodeAt or self:GetPos()
		local normal = self.ExplodeDir or self:GetVelocity():GetNormal()

		if self.HitSomething then
			if not self.Split then
				self.Split = true

				ExplosiveDamage(owner, hitpos, 48, 48, 1, 0.55, 2, self, DMGTYPE_ICE)

				local effectdata = EffectData()
					effectdata:SetOrigin(hitpos + normal)
					effectdata:SetNormal(normal)
				util.Effect("ScatterFrostExplode", effectdata)
			end
		elseif not self.Split then
			self.Split = true
			local owner = self:GetOwner()
			if not owner:IsValid() then owner = self end

			for i=1, math.random(8, 10) do
				local ent = ents.Create("projectile_scatterfrostbolt")
				if ent:IsValid() then
					ent:SetOwner(owner)
					local dir = (normal + VectorRand() * 0.2):GetNormal()
					ent:SetPos(hitpos + dir * 8)
					ent:SetTeamID(self:GetTeamID())
					ent:Spawn()
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous(dir * math.Rand(670, 825))
					end
				end
			end

			local effectdata = EffectData()
				effectdata:SetOrigin(hitpos + normal)
				effectdata:SetNormal(normal)
			util.Effect("ScatterFrostExplode", effectdata)
		end

		self:Remove()
		return
	end

	if 0 < self:WaterLevel() then
		self:Explode(self:GetPos(), self:GetVelocity():GetNormal())
		local _filter = player.GetAll()
		local pos = self:GetPos()
		table.Add(_filter, ents.FindByClass("projectile_scatterfrost"))
		local tr2 = util.TraceLine({start = pos, endpos = pos + Vector(0, 0, 1000), filter=_filter, mask = MASK_SOLID})
		local tr = util.TraceLine({start = tr2.HitPos, endpos = tr2.HitPos + Vector(0, 0, -10000), filter=_filter, mask = MASK_WATER + MASK_SOLID})
		if tr.Hit and tr.MatType == 83 then
			local ent = ents.Create("iceburg")
			if ent:IsValid() then
				ent:SetPos(tr.HitPos + Vector(0,0,-48))
				ent:Spawn()
				for _, pl in pairs(ents.FindInSphere(tr.HitPos,40)) do
					if pl:IsPlayer() then 
						ent:Remove()
					end
				end
			end
		end
	elseif self.ExplodeTime < CurTime() then
		self:Explode(self:GetPos(), self:GetVelocity():GetNormal())
		return
	end
		
end

function ENT:PhysicsCollide(data, physobj)
	self.HitSomething = true
	self:Explode(data.HitPos, data.HitNormal * -1)
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	self.ExplodeAt = hitpos or self:GetPos()
	self.ExplodeDir = hitnormal or self:GetVelocity():GetNormal() * -1
end
