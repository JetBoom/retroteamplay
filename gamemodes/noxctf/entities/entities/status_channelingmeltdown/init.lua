AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	return owner:GetStatus("manastun")
end

function ENT:StatusThink(owner)
	if util.TraceLine({start = owner:GetPos(), endpos = owner:GetPos() + Vector(0, 0, -100), filter=owner}).Hit and owner:CanTeleport() and not owner:IsCarrying() then
		local vVel = owner:GetVelocity()
		if util.TraceLine({start = owner:GetPos(), endpos = owner:GetPos() + Vector(0, 0, -75), filter=owner}).Hit then
			vVel.z = 250
		elseif vVel.z < 0 then
			vVel.z = 2
		end			

		owner:SetGroundEntity(NULL)
		vVel.x = 0
		vVel.y = 0
		owner:SetLocalVelocity(vVel)
	end

	local pos = owner:GetCenter()
	for _, ent in pairs(ents.FindInSphere(pos, 250)) do
		if ent:IsValid() and ent:GetTeamID() ~= owner:Team() and TrueVisible(pos, ent:NearestPoint(pos)) then
			ent:TakeSpecialDamage(3, DMGTYPE_FIRE, owner, self)
		end
	end

	self:NextThink(CurTime() + 0.1)
	return true
end
