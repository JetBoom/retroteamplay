AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Stun(self:GetDieTime() - CurTime(), true, true)
end

function ENT:StatusShouldRemove(owner)
	return owner:GetStatus("manastun")
end

function ENT:StatusThink(owner)
	if not self.EruptTime or self.EruptTime <= CurTime() then
		self.EruptTime = CurTime() + .75
		
		self:EmitSound("ambient/explosions/explode_"..math.random(1,5)..".wav")

		local myteam = owner:GetTeamID()
		local pos = owner:GetPos() + Vector(0, 0, 120)
		for _, ent in pairs(ents.FindInSphere(pos, self.Radius)) do
			if ent:IsValid() and ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= myteam and not ent:GetStatus("invisibility") and TrueVisible(pos, ent:NearestPoint(pos)) then
				local entpos = ent:GetCenter()
				local entvel = ent:GetVelocity()
					
				local predictedpos = PredictedCollision(pos, self.ProjectileSpeed, entpos, entvel)
				
				if not predictedpos or not TrueVisible(pos, predictedpos) then
					predictedpos = entpos
				end
				
				local fbolt = ents.Create("projectile_firebolt")
				if fbolt:IsValid() then
					fbolt:SetOwner(owner)
					fbolt:SetTeamID(owner:Team())
					fbolt:SetPos(pos)
					fbolt.EruptionFbolt = DUMMY_ERUPTION
					fbolt:Spawn()
					local phys = fbolt:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous((predictedpos - pos):GetNormal() * self.ProjectileSpeed)
					end
				end
			end
		end
	end
	
	self:NextThink(CurTime())
	return true
end

function ENT:StatusOnRemove(owner)
	owner:RemoveStatus("stun_noeffect")
end
