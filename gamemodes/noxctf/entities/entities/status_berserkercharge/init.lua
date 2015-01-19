AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetMaterial("models/shiny")

	pPlayer:EmitSound("weapons/mortar/mortar_shell_incomming1.wav", 69, math.Rand(130, 135))

	self.Hit = {}
end

function ENT:StatusThink(owner)
	local midpos = owner:WorldSpaceCenter()

	for _, ent in pairs(ents.FindInSphere(midpos + owner:GetForward() * 16, 32)) do
		if ent ~= owner and ent:IsPlayer() and ent:GetTeamID() ~= owner:GetTeamID() and ent:Alive() and not self.Hit[ent] and TrueVisible(midpos, ent:NearestPoint(midpos)) then
			self.Hit[ent] = true

			ent:EmitSound("physics/concrete/boulder_impact_hard"..math.random(4)..".wav", 70, math.Rand(83, 87))

			if ent:IsPlayer() and ent:Alive() then
				ent:SetGroundEntity(NULL)
				ent:SetVelocity((ent:GetPos() - owner:GetPos()):GetNormalized() * 425 + Vector(0, 0, 200))
			end

			ent:TakeSpecialDamage(15, DMGTYPE_IMPACT, owner, self)
		end
	end

	self:NextThink(CurTime())
	return true
end
