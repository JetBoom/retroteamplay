AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self:SetTrigger(true)
	self:PhysicsInitSphere(100)
	self:SetCollisionBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:EnableCollisions(false)
	end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetNotSolid(true)

	self.Touched = {}
end

function ENT:Touch(ent)
	local pos = self:GetPos()
	if ent:GetSolid() > 0 and ent:GetTeamID() ~= self:GetTeamID() and not self.Touched[ent] then
		local nearest = ent:NearestPoint(pos)
		if nearest:Distance(pos) <= 100 * (1 - (self.Range - pos:Distance(self.Origin)) / self.Range) and TrueVisible(self.Origin, nearest) then
			self.Touched[ent] = true

			ent:EmitSound("ambient/water/water_splash"..math.random(1, 3)..".wav", 30)

			local distpercent = (self.Range - self.Origin:Distance(pos)) / self.Range
			if ent:IsPlayer() and ent:Alive() then
				ent:SetGroundEntity(NULL)
				ent:SetVelocity(self.Force * distpercent * self:GetVelocity():GetNormal())
				
				if ent:GetStatus("burn") then ent:RemoveStatus("burn") end
				if ent:GetStatus("channelingcauterize") then ent:RemoveStatus("channelingcauterize") end
			end

			ent:TakeSpecialDamage(math.max(self.MinDamage, math.Round(self.MaxDamage * distpercent)), DMGTYPE_COLD, self:GetOwner(), self)
		end
	end
end

function ENT:Think()
	if CurTime() >= self.DeathTime then self:Remove() end
	
	-- this debug code will lag if you have a bad computer
	--[[local pos = self:GetPos()
	local rad = 100 * (1 - (self.Range - pos:Distance(self.Origin)) / self.Range)
	debugoverlay.Sphere(pos, rad, 2, COLOR_RED)]]
	
	self:NextThink(CurTime())
	return true
end
