AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	local pos = owner:GetPos()
	for _, ent in pairs(ents.FindInSphere(pos, 400)) do
		if ent:IsValid() and ent:IsPlayer() and ent:GetTeamID() == owner:Team() and ent:Alive() and ent:GetStatus("hallowedgroundchanneling") then
			return false
		end
	end
	return true
end


function ENT:StatusThink(owner)
	self:NextThink(CurTime())
	return true
end
