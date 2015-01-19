ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Hostile = true

ENT.StatusImage = "spellicons/aurify.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(88)
	return true
end
