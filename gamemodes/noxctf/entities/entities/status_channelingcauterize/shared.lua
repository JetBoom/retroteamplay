ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Animation = "CAUTERIZE"

ENT.DisableJump = true

ENT.StatusImage = "spellicons/flickerflame.png"

ENT.HealInterval = .25
ENT.Heal = 2

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(62)
	return true
end