ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Hostile = true

ENT.StatusImage = "spellicons/protrusion.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(78)
	return true
end
