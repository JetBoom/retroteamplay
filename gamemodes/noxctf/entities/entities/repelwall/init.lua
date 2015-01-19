AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/fence03a.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger(true)
	self:SetNotSolid(true)

	self.Touched = {}
	self.DeathTime = CurTime() + self.LifeTime
	self.AntiStuckTime = CurTime() + .1
end

-- since generichomings and firebomb don't collide with the wall so touch doesn't work unless there's a collision group that hits everything
function ENT:Think()
	if self.DeathTime < CurTime() then
		self:Remove()
	end

	local mypos = self:GetPos()
	local myteam = self:GetTeamID()
	for _, ent in pairs(ents.FindInSphere(mypos, 150)) do
		local entpos = ent:GetPos()
		local nearest = ent:NearestPoint(mypos)
		if ent:IsValid() and not self.Touched[ent] and ent:GetTeamID() ~= myteam and ent:IsProjectile() and IsVisible(nearest, mypos) then
			local classname = ent:GetClass()
			if ent.Inversion and entpos:Distance(nearest) <= 10 then 
				self.Touched[ent] = true
				if ent.Target then
					ent.Target = NULL
				end
				Invert(ent, self:GetOwner())
				
			elseif classname == "projectile_firebomb" or classname == "projectile_forceofnature" or classname == "projectile_gust" or classname == "projectile_napalmbomb" or classname == "projectile_hydropump" or classname == "projectile_icespear" and entpos:Distance(nearest) <= 40 then
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() and phys:IsMoveable() then
					self.Touched[ent] = true
					local pl = self:GetOwner()
					ent:SetTeamID(pl:GetTeamID())
					ent:SetOwner(pl)
					if ent.ProjectileHeading then
						ent.ProjectileHeading = ent.ProjectileHeading * -1
					else
						phys:SetVelocityInstantaneous(phys:GetVelocity() * -1)
					end
				end
			end
		end
	end
end

function ENT:Touch(ent)
	local mypos = self:GetPos()
	local myteam = self:GetTeamID()
	if ent:IsValid() then
		if ent:IsPlayer() and ent:Alive() and ent:Team() ~= myteam and TrueVisible(mypos, ent:NearestPoint(mypos)) then
			if CurTime() <= self.AntiStuckTime and not self.Touched[ent] then
				self.Touched[ent] = true

				local tr1 = util.TraceLine({start=ent:GetCenter() + Vector(0, 0, 7), endpos=ent:GetCenter() + self:GetForward() * 90 + Vector(0, 0, 7), filter = ent, mask = MASK_PLAYERSOLID})
				local tr2 = util.TraceLine({start=ent:GetCenter() - Vector(0, 0, 25), endpos=ent:GetCenter() + self:GetForward() * 90 - Vector(0, 0, 25), filter = ent, mask = MASK_PLAYERSOLID})
				local tr3 = util.TraceLine({start=ent:GetCenter() + Vector(0, 0, 35), endpos=ent:GetCenter() + self:GetForward() * 90 + Vector(0, 0, 35), filter = ent, mask = MASK_PLAYERSOLID})
				if (not tr1.HitWorld and not tr2.HitWorld and not tr3.HitWorld) and (tr1.Entity == NULL and tr2.Entity == NULL and tr3.Entity == NULL) then
					ent:SetPos(ent:GetPos() + self:GetForward() * 50 + Vector(0, 0, 5))
					ent:SetVelocity(Vector(0, 0, 0))
				end
			else
				if ent:GetStatus("berserkercharge") then ent:RemoveStatus("berserkercharge", true, true) end
				ent:SetLastAttacker(self:GetOwner())
				ent:SetGroundEntity(NULL)
				ent:SetVelocity(ent:GetVelocity() * -3)
			end
		elseif not self.Touched[ent] and ent:IsProjectile() and ent:GetTeamID() ~= myteam then
			local nearest = ent:NearestPoint(mypos)
			if IsVisible(nearest, mypos) then
				
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() and phys:IsMoveable() then
					self.Touched[ent] = true
					local pl = self:GetOwner()
					ent:SetTeamID(pl:GetTeamID())
					ent:SetOwner(pl)
					if ent.ProjectileHeading then
						ent.ProjectileHeading = ent.ProjectileHeading * -1
					else
						phys:SetVelocityInstantaneous(phys:GetVelocity() * -1)
					end
				end
			end
		end
	end
end