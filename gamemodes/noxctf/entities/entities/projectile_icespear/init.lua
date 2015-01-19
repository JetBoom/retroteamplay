AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_DESTROY
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
		phys:Wake()
	end

	self:SetMaterial("models/shadertest/shader2")

	self.DeathTime = CurTime() + 10
end

function ENT:Think()
	if self.PhysicsData and not self.Hit then
		self.Hit = true

		local data = self.PhysicsData
		self.PhysicsData = nil
		local dir = data.OurOldVelocity
		dir:Normalize()
		
		self:Explode(nil, dir)
	end
	
	if self.DeathTime <= CurTime() then
		self:Remove()
	elseif 0 < self:WaterLevel() then
		local pos = self:GetPos()
		self:Explode(nil, self:GetVelocity():GetNormal())
		local _filter = player.GetAll()
		table.Add(_filter, ents.FindByClass("projectile_icespear"))
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
	end
	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:StartTouch(ent)
	if self.Hit then return end
	
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end
	if owner == ent then return end

	if ent:IsPlayer() and ent:GetTeamID() ~= self:GetTeamID() then
		ent:BloodSpray(ent:NearestPoint(self:GetPos()), math.random(5, 7), self:GetVelocity():GetNormal(), 125)
		ent:TakeSpecialDamage(20, DMGTYPE_PIERCING, owner, self)
		
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetNormal(Vector(0,0,1))
		util.Effect("IceSpearPierce", effectdata)
	end
end

function ENT:Explode(hitpos, hitnormal)
	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ExplosiveDamage(owner, hitpos, 52, 52, 1, 0.48, 2, self, DMGTYPE_ICE)
	
	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("IceSpearHit", effectdata)
	
	self:Remove()
end
