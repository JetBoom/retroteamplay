AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusThink(owner)
	local pos = owner:GetShootPos() + owner:GetAimVector() * 5
	local ang = owner:EyeAngles()
	local dir = ang:Forward()

	local myteam = owner:Team()
	

	local ent = ents.Create("projectile_flamethrower")
	if ent:IsValid() then
		ent:SetOwner(owner)
		ent:SetTeamID(myteam)
		ent:SetPos(pos)
		ent.Origin = pos
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(dir * 1000 + owner:GetVelocity())
		end
	end

	self:NextThink(CurTime() + 0.25)
	return true
end
