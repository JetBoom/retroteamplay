AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_EXPLODE
	self:SetTrigger(true)
	self:PhysicsInitSphere(4)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0.05)
		phys:Wake()
	end

	self.NumBounces = 0
	self.MaxBounces = 4
	self.Touched = {}
	self.DeathTime = CurTime() + 10

	self:EmitSound("npc/scanner/scanner_electric2.wav", 75, math.random(108, 116))
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:StartTouch(ent)
	local data = self.PhysicsData
	local owner = self:GetOwner()
	local pos = self:GetPos()
	if not self.Touched[ent] and ent:IsValid() and ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= owner:Team() then
		self.Touched[ent] = true
		ent:TakeSpecialDamage(18, DMGTYPE_SHOCK, owner, self)
		ent:EmitSound("weapons/stunstick/spark"..math.random(1,3)..".wav")
		local Near = {}
		for _, pl in ipairs(ents.FindInSphere(pos, 450)) do
			if not self.Touched[pl] and pl:IsValid() and pl:IsPlayer() and pl:Alive() and pl:GetTeamID() ~= owner:Team() and TrueVisible(pl:NearestPoint(pos), pos) then
				Near[pl] = pl:NearestPoint(pos):Distance(pos) * -1
			end
		end
		local nearest = table.GetWinningKey( Near )
		local phys = self:GetPhysicsObject()
		if nearest then
			if self.NumBounces <= (self.MaxBounces - 1) then
				if phys:IsValid() then
					local normal = (nearest:LocalToWorld(nearest:OBBCenter()) - pos):GetNormal()
					phys:SetVelocityInstantaneous(normal * self:GetVelocity():Length())
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

function ENT:Explode(hitpos, normal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ExplosiveDamage(owner, hitpos, 20, 18, 0, 1, 18, self, DMGTYPE_SHOCK)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("sparklerexplode", effectdata)

	self:NextThink(CurTime())
end
