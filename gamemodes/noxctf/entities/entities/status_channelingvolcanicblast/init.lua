AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Slow(self:GetDieTime() - CurTime(), true)
end

function ENT:StatusShouldRemove(owner)
	if owner:GetStatus("manastun") then
		self.SilentRemove = true
		return true
	end
	
	return false
end

function ENT:StatusOnRemove(owner, interrupted)
	owner:RemoveStatus("slow_noeffect")

	if not interrupted and CurTime() >= self:GetDieTime() and owner:Alive() then
		local c = self.TeamCol
		local ang = owner:EyeAngles()
		ang.pitch = math.min(ang.pitch, -15)

		local ent = ents.Create("projectile_volcanicblast")
		if ent:IsValid() then
			ent:SetPos(owner:GetShootPos())
			ent:SetOwner(owner)
			ent:SetTeamID(owner:Team())
			ent:SetColor(Color(c.r, c.g, c.b, 255))
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(ang:Forward() * 900)
			end
		end
	end
end