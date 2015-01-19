AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_DESTROY
	self:PhysicsInitSphere(3)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end
	self.DeathTime = CurTime() + 30
end

function ENT:Think()
	if self.PhysicsData then
		self.DeathTime = 0
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
		util.Effect("PixieHit", effectdata)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end


function ENT:StartTouch(ent)
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if ent:IsPlayer() and ent:GetTeamID() ~= self:GetTeamID() then
		ent:TakeSpecialDamage(3, DMGTYPE_GENERIC, owner, self)
		self.DeathTime = 0
	end
end

