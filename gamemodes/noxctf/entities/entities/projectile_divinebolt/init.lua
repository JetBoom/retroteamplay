AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.CounterSpell = COUNTERSPELL_DESTROY

	self:PhysicsInitSphere(4)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCustomCollisionCheck(true)

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

local function DivineBoltExplode(pl, pos)
	if pl:IsValid() then
		local teamid = pl:Team()
		local targets = 0
		for _, ent in pairs(ents.FindInSphere(pos, 150)) do
			if ent:IsPlayer() and ent:Alive() and ent:Team() ~= teamid and TrueVisible(pos, ent:NearestPoint(pos)) then
				targets = targets + 1
			end
		end
		
		--ExplosiveDamage(pl, pos, 150, 18 + targets * 16, 0.5, 2.00, 0, DUMMY_DIVINEBOLT, DMGTYPE_GENERIC)
		ExplosiveDamage(pl, pos, 100, 100, 1, 0.20 + targets * 0.1, 1, DUMMY_DIVINEBOLT, DMGTYPE_GENERIC)

		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetMagnitude(targets)
		util.Effect("divinebolt", effectdata)
	end
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end

	self.Exploded = true
	self.DeathTime = -10

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end
	
	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
	util.Effect("divineboltstart", effectdata)
	
	timer.Simple(.35, function() DivineBoltExplode(owner, hitpos + hitnormal * -1) end)
	self:NextThink(CurTime())
end
