AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Slow(self:GetDieTime() - CurTime(), true)
end

function ENT:StatusShouldRemove(owner)
	return owner:WaterLevel() > 0 or owner:GetStatus("manastun")
end

function ENT:StatusThink(owner)
	if not self.NextHeal or CurTime() >= self.NextHeal then
		self.NextHeal = CurTime() + self.HealInterval
	
		GAMEMODE:PlayerHeal(owner, owner, self.Heal)
		owner:EmitSound("nox/burn.ogg")
	
		local pos = owner:GetCenter()
		local bound = Vector(16, 16, 36)
		--debugoverlay.Box(pos, bound * -1, bound, 3, COLOR_YELLOW)
		for _, ent in pairs(ents.FindInBox(pos - bound, pos + bound)) do
			if ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= owner:GetTeamID() and TrueVisible(pos, ent:NearestPoint(pos)) then
				ent:GiveStatus("burn", 3).Inflictor = owner
			end
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:StatusOnRemove(owner)
	owner:RemoveStatus("slow_noeffect")
end