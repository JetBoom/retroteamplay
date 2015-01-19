AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/misc/sphere1x1.mdl")
	self:SetColor(Color(0, 0, 0, 255))
	self:SetMaterial("models/debug/debugwhite")
	self:DrawShadow(false)
	self:PhysicsInitSphere(19)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end
	self.DeathTime = CurTime() + 4
	self.InitialSlow = {}
	--self.ExplosionAnchor = {}
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		if not self.Exploded then
			self.Exploded = true

			ExplosiveDamage(self:GetOwner(), self:GetPos(), 240, 240, 1, 0.54, 0, self, DMGTYPE_FIRE)
			local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
				effectdata:SetNormal(Vector(0, 0, 1))
			util.Effect("bhsexplode", effectdata, true, true)
		end

		self:Remove()
		return
	end

	local lifepercent = (self.DeathTime - CurTime()) / 4
	local lifedelta = 1 - lifepercent

	local myteam = self:GetTeamID()
	local pos = self:GetPos()
	for _, ent in pairs(ents.FindInSphere(pos, math.max(240 * lifepercent, 75))) do
		if ent:IsPlayer() then
			if ent:Team() ~= myteam and TrueVisible(pos, ent:NearestPoint(pos)) then
				ent:SetLastAttacker(self:GetOwner())
				ent:SetGroundEntity(NULL)
				if not self.InitialSlow[ent] then
					self.InitialSlow[ent] = true
					ent:SetLocalVelocity(Vector() * 0)
				end
				--[[if not self.ExplosionAnchor[ent] and lifepercent <= 0.375 then
					self.ExplosionAnchor[ent] = true
					ent:GiveStatus("anchor", 1.5)
				end]]
				ent:SetVelocity((pos - ent:GetPos()):GetNormal() * 400 * math.max(0.25, lifedelta))
			end
		elseif ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetTeamID() ~= myteam and IsVisible(pos, ent:GetPos()) then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() and phys:IsMoveable() then
				phys:ApplyForceCenter((pos - ent:GetPos()):GetNormal() * 400 * phys:GetMass() * lifedelta)
			end
		end
	end

	local phys = self:GetPhysicsObject()
	if not self.StopMovement and phys:IsValid() then
		phys:SetVelocity(phys:GetVelocity() * lifepercent)
		if lifepercent <= 0.375 then
			self.StopMovement = true
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			phys:SetVelocity(Vector()*0)
		end
	end
end
