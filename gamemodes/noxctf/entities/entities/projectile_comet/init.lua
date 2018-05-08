AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:DrawShadow(false)
	self:PhysicsInitSphere(12)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetMass(3)
		phys:Wake()
		phys:AddAngleVelocity(VectorRand() * math.Rand(0.25, 5))
	end

	self:SetMaterial("models/props_wasteland/rockcliff04a")

	self.DeathTime = CurTime() + 20
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	elseif 0 < self:WaterLevel() then
		self:Explode()
	end
end

function ENT:PhysicsUpdate(phys)
	phys:AddVelocity(Vector(0, 0, -1200 * FrameTime()))
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

	ExplosiveDamage(owner, hitpos, 176, 176, 1, 0.4, 4, self, DMGTYPE_ICE)

	local _filter = player.GetAll()
	table.Add(_filter, ents.FindByClass("projectile_protrusionspike"))
	table.Add(_filter, ents.FindByClass("projectile_comet"))
	local tr2 = util.TraceLine({start = self:GetPos(), endpos = self:GetPos() + Vector(0, 0, 10000), filter=_filter, mask = MASK_SOLID})
	local tr = util.TraceLine({start = tr2.HitPos, endpos = tr2.HitPos + Vector(0, 0, -10000), filter=_filter, mask = MASK_WATER+MASK_SOLID})
	local ent = ents.Create("projectile_protrusionspike")
	if ent:IsValid() then
		ent:SetPos(tr.HitPos)
		ent:SetOwner(self:GetOwner())
		ent:SetTeamID(self:GetTeamID())
		ent:SetFreezes(true)
		ent:Spawn()
	end
	if tr.Hit and tr.MatType == 83 then
		local ent2 = ents.Create("iceburg")
		if ent2:IsValid() then
			ent2:SetPos(tr.HitPos+Vector(0,0,-48))
			ent2:Spawn()
			for _, pl in pairs(ents.FindInSphere(tr.HitPos,40)) do
				if pl:IsPlayer() then
					ent2:Remove()
				end
			end
		end
	end

	for i=0,5 do
		local tr2 = util.TraceLine({start = self:GetPos()+64*Vector(math.cos(math.rad(i*60)),math.sin(math.rad(i*60)),0), endpos = self:GetPos()+64*Vector(math.cos(math.rad(i*60)),math.sin(math.rad(i*60)),0) + Vector(0, 0, 10000), filter=_filter, mask = MASK_SOLID})
		local tr = util.TraceLine({start = tr2.HitPos, endpos = tr2.HitPos + Vector(0, 0, -10000), filter=_filter, mask = MASK_WATER+MASK_SOLID})

		if tr.Hit and tr.MatType == 83 then
			local ent3 = ents.Create("iceburg")
			table.Add(_filter,ent3)
			if ent3:IsValid() then
				ent3:SetPos(tr.HitPos+Vector(0, 0, -48))
				ent3:Spawn()
				for _, pl in pairs(ents.FindInSphere(tr.HitPos,40)) do
					if pl:IsPlayer() then
						ent3:Remove()
					end
				end
			end
		end
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("CometExplosion", effectdata)

	self:NextThink(CurTime())
end
