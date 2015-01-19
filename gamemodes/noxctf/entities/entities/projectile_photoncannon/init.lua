AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.HitEffect = "bullethit_basic"

ENT.Damage = 25
ENT.DamageType = DMG_BULLET
ENT.Speed = 7680
ENT.LifeTime = 5

function ENT:Initialize()
	self:DrawShadow(false)

	self:PhysicsInitSphere(1)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then 
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0.00001)
		phys:Wake()
	end

	self.DeathTime = CurTime() + self.LifeTime

	self.LastPosition = self.LastPosition or self:GetPos()

	-- I cache this because it would be rediculous to do it dynamically.
	local owner = self:GetOwner()
	if owner:IsValid() and owner:IsPlayer() then
		self.Filter = owner:GetAttackFilter()
	end

	self:NextThink(CurTime())
end

function ENT:Launch(dir)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetVelocityInstantaneous(dir * self.Speed)
	end
end

function ENT:Hit(tr)
	local hitent = tr.Entity
	if hitent:IsValid() then
		if self:GetTeamID() ~= 0 then
			if hitent:GetTeamID() == self:GetTeamID() then return end
			local vp = hitent:GetVehicleParent()
			if vp:IsValid() and vp:GetTeamID() == self:GetTeamID() then return end
		end

		hitent:TakeSpecialDamage(self.Damage, self.DamageType, self:GetOwner(), self.Inflictor or self, tr.HitPos)
	end

	if self.HitEffect and not tr.HitSky then
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			local owner = self:GetOwner()
			effectdata:SetScale(owner:IsValid() and owner:IsPlayer() and owner:Team() or 0)
			effectdata:SetMagnitude(self.Damage)
		util.Effect(self.HitEffect, effectdata, true, true)
	end

	self.DeathTime = 0
	self.HitTrace = tr
	self:Remove()
end

local mins = Vector(-1, -1, -1)
local maxs = Vector(1, 1, 1)
function ENT:Trace()
	return util.TraceHull({start = self.LastPosition, endpos = self:GetPos(), mask = MASK_SHOT, filter = self.Filter, mins = mins, maxs = maxs})
end

function ENT:Think()
	if CurTime() >= self.DeathTime then
		self:Remove()
		return
	end

	local tr = self:Trace()
	if not (tr.Hit and self:Hit(tr)) then
		self.LastPosition = self:GetPos()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsCollide(data, phys)
	self:NextThink(CurTime())
end
