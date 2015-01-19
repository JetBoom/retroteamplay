AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.CounterSpell = COUNTERSPELL_DESTROY

	self:PhysicsInitSphere(4)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCustomCollisionCheck( true )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetBuoyancyRatio(0.00001)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 15
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
	elseif self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end

	self.Exploded = true
	self.DeathTime = -10

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end
	hitpos = hitpos or self:GetPos()

	local myteam = self:GetTeamID()
	for _, ent in pairs(ents.FindInSphere(hitpos, 64)) do
		if ent:IsPlayer() and ent:Alive() and TrueVisible(ent:NearestPoint(hitpos), hitpos) and (ent:Team() ~= myteam or ent == owner) then
			ent:Slow(4)
			if owner:IsPlayer() and ent ~= owner then
				ent:SetLastAttacker(owner)
			end
		end
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal or Vector(0, 0, 1))
	util.Effect("slowexplosion", effectdata)

	self:NextThink(CurTime())
end
