ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:PlayerCantCastSpell(pl, spellid)
	if spellid == NameToSpell["Oversoul"] then
		return false
	end
	
	pl:LM(82)
	return true
end
