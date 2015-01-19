ENT.Type = "anim"
ENT.Base = "status__base"

ENT.StartSound = Sound("ambient/fire/mtov_flame2.wav")
ENT.EndSound = Sound("nox/protectoff.ogg")
ENT.StatusImage = "spellicons/salamanderscales.png"

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if dmginfo:GetDamageType() == DMGTYPE_FIRE then
		if dmginfo:GetDamage() <= 5 then
			dmginfo:SetDamage(0)
		else
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.5)
		end
	end
end
