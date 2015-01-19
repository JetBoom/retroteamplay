AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:EmitSound("weapons/mortar/mortar_shell_incomming1.wav", 69, math.Rand(130, 135))

	--[[self.StartCharge = CurTime() + 0.25
	self.EndCharge = self.StartCharge + 0.55]]

	self.Hit = {pPlayer}
end

function ENT:StatusShouldRemove(owner)
	return owner:IsCarrying()
end

function ENT:StatusThink(owner)
	local ent = ents.Create("burn")
	local tr = util.TraceLine({start = owner:GetPos() + owner:GetAngles():Forward() * -35 + Vector(0,0,35), endpos = owner:GetPos() + owner:GetAngles():Forward() * -35 + owner:GetAngles():Right() * math.Rand(-50,50) + Vector(0,0,-35)})
	if ent:IsValid() and tr.Hit then
		ent:SetPos(tr.HitPos + tr.HitNormal)
		ent:SetOwner(owner)
		ent:Spawn()
		ent:SetTeamID(owner:GetTeamID())
	end

	self:NextThink(CurTime() + 0.15)
	return true
end
