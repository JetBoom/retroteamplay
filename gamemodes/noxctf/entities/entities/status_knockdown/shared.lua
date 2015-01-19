ENT.Type = "anim"
ENT.Base = "status__base"

ENT.StatusImage = "spellicons/stun.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(79)
	return true
end