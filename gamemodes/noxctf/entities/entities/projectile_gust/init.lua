AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_DESTROY
	self:PhysicsInitSphere(4)
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
	self.DeathTime = CurTime() + 0.2
end

function ENT:Think()
	local mypos = self:GetPos()
	local myteam = self:GetTeamID()
	for _, ent in pairs(ents.FindInSphere(mypos, 48)) do
		if ent:IsValid() and not self.Touched[ent] then
			if ent:IsPlayer() and ent:Alive() and ent:Team() ~= myteam and TrueVisible(mypos, ent:NearestPoint(mypos)) and not ent:IsAnchored()  then
				self.Touched[ent] = true

				ent:SetLastAttacker(self:GetOwner())
				ent:SetGroundEntity(NULL)
				ent:SetVelocity(ent:GetVelocity() * -1 + self:GetVelocity() * Vector(1, 1, 0) + Vector(0, 0, 300))
			elseif ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetTeamID() ~= myteam then
				local nearest = ent:NearestPoint(mypos)
				if IsVisible(ent:NearestPoint(mypos), mypos) then
					if ent.Inversion then 
						Invert(ent, self:GetOwner())
					else
						local phys = ent:GetPhysicsObject()
						if phys:IsValid() and phys:IsMoveable() then
							self.Touched[ent] = true
							phys:ApplyForceOffset(self:GetVelocity() * phys:GetMass(), ent:NearestPoint(mypos))
						end
					end
				end
			end
		end
	end

	if self.DeathTime <= CurTime() or 0 < self:WaterLevel() then
		self:Remove()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsCollide(data, physobj)
	self.DeathTime = 0
	self:NextThink(CurTime())
end
