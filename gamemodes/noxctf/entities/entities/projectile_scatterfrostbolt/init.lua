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
		phys:Wake()
	end

	self.DeathTime = CurTime() + 30
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	elseif 0 < self:WaterLevel() then
		self:Explode()
		local _filter = player.GetAll()
		local pos = self:GetPos()
		table.Add(_filter, ents.FindByClass("projectile_scatterfrostbolt"))
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

	ExplosiveDamage(owner, hitpos, 48, 48, 1, 0.55, 2, self, DMGTYPE_ICE)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("ScatterFrostExplode", effectdata)

	self:NextThink(CurTime())
end
