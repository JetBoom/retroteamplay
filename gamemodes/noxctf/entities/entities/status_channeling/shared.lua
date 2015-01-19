ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(62)
	return true
end
