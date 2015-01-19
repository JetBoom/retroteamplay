AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self:SetTrigger(true)
	self:PhysicsInitBox(Vector(-38, -38, -40), Vector(38, 38, 64))
	self:SetCollisionBounds(Vector(-38, -38, -40), Vector(38, 38, 40))
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions(false)
		phys:EnableMotion(false)
	end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetNotSolid(true)

	self.LastTouched = {}
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Stun(self:GetDieTime() - CurTime(), true, true)
end

function ENT:StatusShouldRemove(owner)
	return owner:GetStatus("manastun") or owner:IsAnchored() or owner:IsCarrying() or not TrueVisible(owner:GetCenter(), owner:GetCenter() + self:GetDir() * 20) or not TrueVisible(owner:GetShootPos(), owner:GetShootPos() + self:GetDir() * 20) or not TrueVisible(owner:GetPos(), owner:GetPos() + self:GetDir() * 20)
end

function ENT:StatusOnRemove(owner)
	owner:RemoveStatus("stun_noeffect")
	owner:SetLocalVelocity(Vector(0,0,0))
end

function ENT:Touch(ent)
	local owner = self:GetOwner()
	if owner:IsValid() and ent:GetSolid() > 0 and ent:GetTeamID() ~= owner:Team() and CurTime() >= (self.LastTouched[ent] or 0) + 0.5 and TrueVisible(self:GetPos(), ent:NearestPoint(self:GetPos())) then
		self.LastTouched[ent] = CurTime()

		ent:TakeSpecialDamage(self.Damage, DMGTYPE_WIND, owner, self)
		if ent:IsPlayer() and ent:Alive() then
			ent:SetGroundEntity(NULL)	
			ent:SetVelocity(Vector(0, 0, 400))
		end
	end
end

function ENT:StatusThink(owner)
	owner:SetGroundEntity(NULL)
	if util.TraceLine({start = owner:GetPos(), endpos = owner:GetPos() + Vector(0, 0, -25), filter=owner}).Hit then
		owner:SetLocalVelocity(Vector(0, 0, 500) + self:GetDir() * self.Speed)
	else
		owner:SetLocalVelocity(self:GetDir() * self.Speed)
	end
	
	--debugoverlay.Box(self:GetCenter(), Vector(-38, -38, -40), Vector(38, 38, 40), 5, COLOR_YELLOW)

	self:NextThink(CurTime())
	return true
end
