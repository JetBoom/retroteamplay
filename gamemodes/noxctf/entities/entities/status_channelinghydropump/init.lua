AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	return owner:GetVelocity():Length() > 20 or owner:GetStatus("manastun") or owner:GetMana() < self.ManaPerTick
end

function ENT:StatusThink(owner)
	if not self.NextTick or CurTime() >= self.NextTick then
		self.NextTick = CurTime() + self.TickInterval
		owner:SetMana(owner:GetMana() - self.ManaPerTick, true)
		
		local pos = owner:GetShootPos()
		local ang = owner:EyeAngles()
		ang.pitch = math.Clamp(ang.pitch, -25, 25)
		local dir = ang:Forward()

		local ent = ents.Create("projectile_hydropump")
		if ent:IsValid() then
			ent:SetOwner(owner)
			ent:SetTeamID(owner:Team())
			ent:SetPos(pos - dir * 150) -- it travels so fast that it doesnt properly initialize until it's 150 or so units from where it was made. this is to compensate for that.
			ent.Origin = pos
			ent.MinDamage = self.MinDamage
			ent.MaxDamage = self.MaxDamage
			ent.DeathTime = CurTime() + self.ProjTravelTime
			ent.Range = self.Range
			ent.Force = self.Force
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(dir * self.Range * 1/self.ProjTravelTime)
			end
		end
	end
	
	self:NextThink(CurTime())
	return true
end
