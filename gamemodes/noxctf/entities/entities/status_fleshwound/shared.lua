ENT.Type = "anim"
ENT.Base = "status__base"

ENT.StatusImage = "spellicons/summonzombie.png"

ENT.StartSound = Sound( "npc/barnacle/barnacle_bark"..math.random(2)..".wav" )
ENT.EndSound = Sound( "npc/barnacle/barnacle_gulp"..math.random(2)..".wav" )

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if dmginfo:GetDamageType() == DMGTYPE_PIERCE or dmginfo:GetDamageType() == DMGTYPE_BASHING or dmginfo:GetDamageType() == DMGTYPE_SLASHING then
		dmginfo:SetDamage(dmginfo:GetDamage() * 0.85)
	end
end