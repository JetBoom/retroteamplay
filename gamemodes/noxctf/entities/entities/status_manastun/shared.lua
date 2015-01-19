ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Hostile = true

ENT.StartSound = Sound("nox/nullon.ogg")
ENT.EndSound = Sound("nox/nulloff.ogg")
ENT.StatusImage = "spellicons/manastun.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:SendLua("insma()")
	pl:LM(68)
	return true
end