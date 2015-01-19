AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:DrawShadow(false)
	self:PhysicsInitSphere(self.Radius)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.Touched = {}
	self.DeathTime = CurTime() + self.LifeTime
end

function ENT:Touch(ent)
	local mypos = self:GetPos()
	if ent:IsValid() and not self.Touched[ent] and ent:GetTeamID() ~= self:GetTeamID() and TrueVisible(mypos, ent:NearestPoint(mypos)) then
		self.Touched[ent] = true
			
		ent:TakeSpecialDamage(self.Damage, DMGTYPE_PHYSICAL, self:GetOwner(), self)
		if ent:IsPlayer() and ent:Alive() then
			ent:Slow(self.SlowDuration)
		end
	end
end

function ENT:Think()
	if CurTime() > self.DeathTime then self:Remove() end
end

function ENT:PhysicsUpdate(phys)
	if not self.NextMove or CurTime() >= self.NextMove then
		self.NextMove = CurTime() + self.Speed
		if not self.ProjectileHeading and phys:GetVelocity():Length() > 0 then
			self.ProjectileHeading = phys:GetVelocity():GetNormal()
		end
	
		local pos1 = self:GetPos() + self.ProjectileHeading * self.Radius
		local pos2 = self:GetPos() + self.ProjectileHeading * self.Radius - Vector(0, 0, self.Radius * 3)
		local tr = util.TraceLine({start=pos1, endpos=pos2, mask = MASK_SOLID_BRUSHONLY})
	
		if tr.HitWorld and TrueVisible(self:GetPos(), pos1) then
			local pos = tr.HitPos + Vector(0, 0, self.Radius)
			--debugoverlay.Sphere(pos, self.Radius, .5, COLOR_RED)
			self:SetPos(pos)
			phys:SetPos(pos)
		else
			self:Remove()
		end
	end
end

function ENT:PhysicsCollide(data, physobj)
	self:Remove()
end
