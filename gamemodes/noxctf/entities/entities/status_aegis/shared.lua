ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = Sound("physics/concrete/boulder_impact_hard3.wav")
ENT.EndSound = Sound("physics/concrete/boulder_impact_hard2.wav")
ENT.StatusImage = "spellicons/aegis.png"

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if dmginfo:GetDamageType() == DMGTYPE_PIERCE or dmginfo:GetDamageType() == DMGTYPE_BASHING or dmginfo:GetDamageType() == DMGTYPE_SLASHING then
		dmginfo:SetDamage(dmginfo:GetDamage() * 0.6)
	end
end
